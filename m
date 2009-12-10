From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: TCP not retransmitting
Date: Thu, 10 Dec 2009 15:24:20 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101518050.7024@wel-95.cs.helsinki.fi>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com> <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1D27F7.9000502@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi> <20091207200904.5f6e145a@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-277627459-1260451460=:7024"
Cc: Netdev <netdev@vger.kernel.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41630 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759151AbZLJNYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 08:24:15 -0500
In-Reply-To: <20091207200904.5f6e145a@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-277627459-1260451460=:7024
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Changed subject and dropped all but netdev from Cc.

On Mon, 7 Dec 2009, Frederic Leroy wrote:

> Le Mon, 7 Dec 2009 20:50:11 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Mon, 7 Dec 2009, Damian Lukowski wrote:
> > 
> > > This patch fixes a problem in the TCP connection timeout
> > > calculation. Currently, timeout decisions are made on the basis of
> > > 6fa12c85031485dff38ce550c24f10da23b0adaa.
> > [...]
> >> >  static inline struct sk_buff *tcp_send_head(struct sock *sk) 
> > 
> > Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > 
> > Also, this should be added:
> > 
> > Reported-by: Frederic Leroy <fredo@starox.org>
> > 
> > ...and I think he has already tested this fix a number of times in 
> > different forms, so I'd already include his Tested-by: too.
> 
> If you need a bad connection to do some test, don't hesitate !
> Thank you guys ;)

Hi,

Now that the more important issues are out of the way, could try with the 
following debug patch, if we could get some information on why the 
retransmission are not happening when they're supposed to (the EAGAIN 
problem we noticed earlier). Besides trying with 2.6.32, it might also be 
worth of the effort to try that in 2.6.31 to see if that also gives those 
EAGAIN things or if it's a new issue. It is quite insignificant whether 
to previous fix patch is included or not though perhaps easier to know 
that the problem really happened if a stall is experiencable vs. the fixed 
kernel.

-- 
 i.


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..c29aed0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1894,6 +1894,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		icsk->icsk_mtup.probe_size = 0;
 	}
 
+	printk("sk: %p wm_a: %u wm_q: %u sbuf: %u\n", sk,
+		atomic_read(&sk->sk_wmem_alloc), sk->sk_wmem_queued, sk->sk_sndbuf);
 	/* Do not sent more than we queued. 1/4 is reserved for possible
 	 * copying overhead: fragmentation, tunneling, mangling etc.
 	 */
@@ -1986,6 +1988,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		 */
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
 	}
+	printk("sk: %p E %u", sk, err);
 	return err;
 }
--8323329-277627459-1260451460=:7024--
