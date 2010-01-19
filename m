From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Tue, 19 Jan 2010 13:17:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi>
References: <200912261703.49067.denys@visp.net.lb> <201001161612.04747.denys@visp.net.lb> <4B5576F4.5020002@tvk.rwth-aachen.de> <201001191309.03927.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48778 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab0ASLR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 06:17:56 -0500
In-Reply-To: <201001191309.03927.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Jan 2010, Denys Fedoryshchenko wrote:

> On Tuesday 19 January 2010 11:10:12 you wrote:
> > Hi,
> > thank you for testing. So srtt and rttvar is zero in any of those cases.
> > Ilpo, it is a bug in tcp_rtt_estimator then, I suppose?
> > 
> > There is also a code comment in tcp_input.c, saying:
> > > * NOTE: clamping at TCP_RTO_MIN is not required, current algo
> > > * guarantees that rto is higher.
> > 
> > So we either fix tcp_rtt_estimator or simply clamp at TCP_RTO_MIN?
> > 
> > Damian
> > 
> > > On Monday 11 January 2010 15:02:34 you wrote:
> > >> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
> > >>> Few more dumps. I notice:
> > >>> 1)Ack always equal 1
> > >>> 2)It is usually first segment of data sent (?)
> > >>>
> > >>> Maybe some value not initialised properly?
> > >>
> > >> Can you see if the RTO lower bound is violated (I added some printing of
> > >> vars there too already now if it turns out to be something):
> > >>
> > >> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > >> index 65b8ebf..d84469f 100644
> > >> --- a/net/ipv4/tcp_ipv4.c
> > >> +++ b/net/ipv4/tcp_ipv4.c
> As i see in code it is rounding RTO to minimum value.
> It fixes my problem seems.
> 
> Btw just a bit about my environment - wireless networks (sometimes lossy!) 
> with low speed (128-512Kbps) customers working over pppoe. Maybe it will give 
> a tip why rtt value is too low.

What I find most strange in it is the fact that when it triggers for the 
first time, the srtt and mdev are zero, not some value in between 0 and 
200ms. Therefore I suspect that this case might be something that we've 
overlooked where srtt/mdev are not valid at all.

Maybe the patch below helps...

-- 
 i.

--
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 65b8ebf..c8166d7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -401,6 +417,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 * (see draft-zimmermann-tcp-lcd) */
 		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
 			break;
+		/* A bit too strict, just want to be on the safe side for now */
+		if (sk->sk_state != TCP_ESTABLISHED)
+			break;
 		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
 		    !icsk->icsk_backoff)
 			break;
