From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 6/7] tcp: cache result of earlier divides when mss-aligning
 things
Date: Sun, 15 Mar 2009 10:45:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903151041350.23360@wrl-59.cs.helsinki.fi>
References: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370756753599-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20090315083642.GA31423@ioremap.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-793594907-1237106716=:23360"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46421 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbZCOIpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 04:45:20 -0400
In-Reply-To: <20090315083642.GA31423@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-793594907-1237106716=:23360
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 15 Mar 2009, Evgeniy Polyakov wrote:

> On Sun, Mar 15, 2009 at 02:07:54AM +0200, Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote:
> > @@ -676,7 +676,17 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
> >  				  tp->tcp_header_len);
> >  
> >  		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
> > -		xmit_size_goal -= (xmit_size_goal % mss_now);
> > +
> > +		/* We try hard to avoid divides here */
> > +		old_size_goal = tp->xmit_size_goal_segs * mss_now;
> > +
> > +		if (old_size_goal <= xmit_size_goal &&
> > +		    old_size_goal + mss_now > xmit_size_goal) {
> > +			xmit_size_goal = old_size_goal;
> 
> If this is way more likely condition than changed xmit size, what about
> wrapping it into likely()?

So gcc won't read my comment? :-)

Updated below.

-- 
 i.

--
[PATCHv2] tcp: cache result of earlier divides when mss-aligning things

The results is very unlikely change every so often so we
hardly need to divide again after doing that once for a
connection. Yet, if divide still becomes necessary we
detect that and do the right thing and again settle for
non-divide state. Takes the u16 space which was previously
taken by the plain xmit_size_goal.

This should take care part of the tso vs non-tso difference
we found earlier.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/linux/tcp.h |    1 +
 net/ipv4/tcp.c      |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index ad2021c..9d5078b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -248,6 +248,7 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
+	u16	xmit_size_goal_segs; /* Goal for segmenting output packets */
 
 /*
  *	Header prediction flags
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 886596f..0db9f3b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -665,7 +665,7 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 xmit_size_goal;
+	u32 xmit_size_goal, old_size_goal;
 
 	xmit_size_goal = mss_now;
 
@@ -676,7 +676,17 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				  tp->tcp_header_len);
 
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
-		xmit_size_goal -= (xmit_size_goal % mss_now);
+
+		/* We try hard to avoid divides here */
+		old_size_goal = tp->xmit_size_goal_segs * mss_now;
+
+		if (likely(old_size_goal <= xmit_size_goal &&
+			   old_size_goal + mss_now > xmit_size_goal)) {
+			xmit_size_goal = old_size_goal;
+		} else {
+			tp->xmit_size_goal_segs = xmit_size_goal / mss_now;
+			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
+		}
 	}
 
 	return xmit_size_goal;
-- 
1.5.6.5

---696208474-793594907-1237106716=:23360--
