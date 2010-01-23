From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: fix ICMP-RTO war
Date: Sun, 24 Jan 2010 00:34:43 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
References: <200912261703.49067.denys@visp.net.lb> <201001191309.03927.denys@visp.net.lb> <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi> <201001232337.19122.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-2119996630-1264286083=:16552"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33092 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab0AWWeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 17:34:50 -0500
In-Reply-To: <201001232337.19122.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-2119996630-1264286083=:16552
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

Restored Damian cc, please keep them.

On Sat, 23 Jan 2010, Denys Fedoryshchenko wrote:
> On Tuesday 19 January 2010 13:17:51 you wrote:
> > On Tue, 19 Jan 2010, Denys Fedoryshchenko wrote:
> > > On Tuesday 19 January 2010 11:10:12 you wrote:
> > > > Hi,
> > > > thank you for testing. So srtt and rttvar is zero in any of those
> > > > cases. Ilpo, it is a bug in tcp_rtt_estimator then, I suppose?
> > > >
> > > > There is also a code comment in tcp_input.c, saying:
> > > > > * NOTE: clamping at TCP_RTO_MIN is not required, current algo
> > > > > * guarantees that rto is higher.
> > > >
> > > > So we either fix tcp_rtt_estimator or simply clamp at TCP_RTO_MIN?
> > > >
> > > > Damian
> > > >
> > > > > On Monday 11 January 2010 15:02:34 you wrote:
> > > > >> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
> > > > >>> Few more dumps. I notice:
> > > > >>> 1)Ack always equal 1
> > > > >>> 2)It is usually first segment of data sent (?)
> > > > >>>
> > > > >>> Maybe some value not initialised properly?
> > > > >>
> > > > >> Can you see if the RTO lower bound is violated (I added some
> > > > >> printing of vars there too already now if it turns out to be
> > > > >> something):
> > > > >>
> > > > >> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > > >> index 65b8ebf..d84469f 100644
> > > > >> --- a/net/ipv4/tcp_ipv4.c
> > > > >> +++ b/net/ipv4/tcp_ipv4.c
> > >
> > > As i see in code it is rounding RTO to minimum value.
> > > It fixes my problem seems.
> > >
> > > Btw just a bit about my environment - wireless networks (sometimes
> > > lossy!) with low speed (128-512Kbps) customers working over pppoe. Maybe
> > > it will give a tip why rtt value is too low.
> > 
> > What I find most strange in it is the fact that when it triggers for the
> > first time, the srtt and mdev are zero, not some value in between 0 and
> > 200ms. Therefore I suspect that this case might be something that we've
> > overlooked where srtt/mdev are not valid at all.
> > 
> > Maybe the patch below helps...
> > 
> Seems after this patch (and debug patch with warnings) my dmesg is clean.

Cool, thanks for testing.

Dave, please send into stable too (besides net-2.6). If we want less strict 
state check we can continue playing with that in net-next, IMHO.

-- 
 i.

--
[PATCH] tcp: fix ICMP-RTO war

When destination is not reachable, ICMP of that is processed
here. In some TCP state srtt and mdev are not valid, yielding
to zero rto. Since the code below then immediately forces
timeout, a segment is sent which again triggers another ICMP
causing ICMP-RTO war to happen.

Broken since f1ecd5d9e736660 (Revert Backoff [v3]: Revert RTO
on ICMP destination unreachable).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
---
 net/ipv4/tcp_ipv4.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 65b8ebf..ebcfcf6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -401,6 +401,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 * (see draft-zimmermann-tcp-lcd) */
 		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
 			break;
+		/* A bit too strict, just want to be on the safe side for now */
+		if (sk->sk_state != TCP_ESTABLISHED)
+			break;
 		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
 		    !icsk->icsk_backoff)
 			break;
-- 
1.5.6.5

---696230645-2119996630-1264286083=:16552--
