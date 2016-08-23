From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Tue, 23 Aug 2016 12:03:39 -0700
Message-ID: <1471979019.14381.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
         <20160823.112515.318902967155957764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: labbott@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, samanthakumar@google.com,
        willemb@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823.112515.318902967155957764.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-23 at 11:25 -0700, David Miller wrote:
> From: Laura Abbott <labbott@redhat.com>
> Date: Tue, 23 Aug 2016 10:53:26 -0700
> 
> > Fedora received a report[1] of a unit test failing on Ruby when using
> > the
> > 4.7 kernel. This was a test to send a zero sized UDP packet. With the
> > 4.7 kernel, the test now timing out on a select instead of completing.
> > The reduced ruby test is
> > 
> >   def test_udp_recvfrom_nonblock
> >     u1 = UDPSocket.new
> >     u2 = UDPSocket.new
> >     u1.bind("127.0.0.1", 0)
> >     u2.send("", 0, u1.getsockname)
> >     IO.select [u1]  # test gets stuck here
> >   ensure
> >     u1.close if u1
> >     u2.close if u2
> >   end
> 
> Well, if there is no data, should select really wake up?
> 
> I think it's valid not to.
There are skb in receive queue, with skb->len = 0

This looks like a bug in first_packet_length() or poll logic.

Definitely something we can fix.

Maybe with :

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd65d08..380c05a84041 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1184,11 +1184,11 @@ out:
  *	Drops all bad checksum frames, until a valid one is found.
  *	Returns the length of found skb, or 0 if none is found.
  */
-static unsigned int first_packet_length(struct sock *sk)
+static int first_packet_length(struct sock *sk)
 {
 	struct sk_buff_head list_kill, *rcvq = &sk->sk_receive_queue;
 	struct sk_buff *skb;
-	unsigned int res;
+	int res;
 
 	__skb_queue_head_init(&list_kill);
 
@@ -1203,7 +1203,7 @@ static unsigned int first_packet_length(struct sock *sk)
 		__skb_unlink(skb, rcvq);
 		__skb_queue_tail(&list_kill, skb);
 	}
-	res = skb ? skb->len : 0;
+	res = skb ? skb->len : -1;
 	spin_unlock_bh(&rcvq->lock);
 
 	if (!skb_queue_empty(&list_kill)) {
@@ -1232,7 +1232,7 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 	case SIOCINQ:
 	{
-		unsigned int amount = first_packet_length(sk);
+		int amount = max(0, first_packet_length(sk));
 
 		return put_user(amount, (int __user *)arg);
 	}
@@ -2184,7 +2184,7 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	/* Check for false positives due to checksum errors */
 	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
-	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
+	    !(sk->sk_shutdown & RCV_SHUTDOWN) && first_packet_length(sk) == -1)
 		mask &= ~(POLLIN | POLLRDNORM);
 
 	return mask;
