From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: fix poll() issue with zero sized packets
Date: Tue, 23 Aug 2016 13:53:24 -0700
Message-ID: <1471985604.14381.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
         <20160823.112515.318902967155957764.davem@davemloft.net>
         <1471979019.14381.37.camel@edumazet-glaptop3.roam.corp.google.com>
         <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, samanthakumar@google.com,
        willemb@google.com, netdev <netdev@vger.kernel.org>
To: Laura Abbott <labbott@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35022 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755846AbcHWUx0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:53:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so8819435pfg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:53:26 -0700 (PDT)
In-Reply-To: <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Laura tracked poll() [and friends] regression caused by commit
e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")

udp_poll() needs to know if there is a valid packet in receive queue,
even if its payload length is 0.

Change first_packet_length() to return an signed int, and use -1
as the indication of an empty queue.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
Reported-by: Laura Abbott <labbott@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Laura Abbott <labbott@redhat.com>
---
 net/ipv4/udp.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd65d08..2a2ac9e0c985 100644
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
+		int amount = max_t(int, 0, first_packet_length(sk));
 
 		return put_user(amount, (int __user *)arg);
 	}
@@ -2184,7 +2184,7 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 	/* Check for false positives due to checksum errors */
 	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
-	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))
+	    !(sk->sk_shutdown & RCV_SHUTDOWN) && first_packet_length(sk) == -1)
 		mask &= ~(POLLIN | POLLRDNORM);
 
 	return mask;
