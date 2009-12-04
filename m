From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Fri, 4 Dec 2009 13:14:46 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912041302460.7024@wel-95.cs.helsinki.fi>
References: <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de> <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
 <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba> <4B1820B8.7050500@tvk.rwth-aachen.de> <20091204093629.GA17976@sd-11162.dedibox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45296 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbZLDLOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 06:14:41 -0500
In-Reply-To: <20091204093629.GA17976@sd-11162.dedibox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Dec 2009, Frederic Leroy wrote:

> On Thu, Dec 03, 2009 at 09:34:00PM +0100, Damian Lukowski wrote:
> > Frederic Leroy schrieb:
> >
> > Ok, at least this "fix" seems to work at first glance, but the printk
> > is quite useless now. Could you run another test with the printk's but
> > without the retrans_stamp == 0 check, please?
> 
> I just made 3 more test (.14 .15 .16), all streams has failed.

I noticed that we'll absolutely need that || !retrans_stamp thing as 
at least this can result in icsk_retransmits without retrans_stamp:

        if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
                /* Retransmission failed because of local congestion,
                 * do not backoff.
                 */
                if (!icsk->icsk_retransmits)
                        icsk->icsk_retransmits = 1;

But there may be other error handling related things here too. Can you try 
with the following once you can (probably can print quite much, once per 
arriving packet when in recovery):

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..19934d2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1898,18 +1898,24 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * copying overhead: fragmentation, tunneling, mangling etc.
 	 */
 	if (atomic_read(&sk->sk_wmem_alloc) >
-	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
-		return -EAGAIN;
+	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf)) {
+		err = -EAGAIN;
+		goto out;
+	}
 
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
-		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
-			return -ENOMEM;
+		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq)) {
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 
-	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
-		return -EHOSTUNREACH; /* Routing failure or similar. */
+	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk)) {
+		err = -EHOSTUNREACH; /* Routing failure or similar. */
+		goto out;
+	}
 
 	cur_mss = tcp_current_mss(sk);
 
@@ -1919,12 +1925,16 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * our retransmit serves as a zero window probe.
 	 */
 	if (!before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))
-	    && TCP_SKB_CB(skb)->seq != tp->snd_una)
-		return -EAGAIN;
+	    && TCP_SKB_CB(skb)->seq != tp->snd_una) {
+	    	err = -EAGAIN;
+	    	goto out;
+	}
 
 	if (skb->len > cur_mss) {
-		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
-			return -ENOMEM; /* We'll try again later. */
+		if (tcp_fragment(sk, skb, cur_mss, cur_mss)) {
+			err = -ENOMEM; /* We'll try again later. */
+			goto out;
+		}
 	} else {
 		int oldpcount = tcp_skb_pcount(skb);
 
@@ -1986,6 +1996,9 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		 */
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
 	}
+out:
+	if (err)
+		printk("rxt %p %u %d ca:%d\n", sk, TCP_SKB_CB(skb)->seq, err, icsk->icsk_ca_state);
 	return err;
 }
 
