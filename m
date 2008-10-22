From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Wed, 22 Oct 2008 13:00:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
 <20081021201857.08faf0a7@topolino> <20081021184539.GA3320@ami.dom.local>
 <20081021.163207.157978465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1227150675-1224669511=:7072"
Cc: jarkao2@gmail.com, sentiniate@tiscali.it,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, olon@verizon.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50450 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbYJVKB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 06:01:28 -0400
In-Reply-To: <20081021.163207.157978465.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0810221258470.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1227150675-1224669511=:7072
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810221258471.7072@wrl-59.cs.helsinki.fi>

On Tue, 21 Oct 2008, David Miller wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 21 Oct 2008 20:45:39 +0200
> 
> > On Tue, Oct 21, 2008 at 08:18:57PM +0200, Aldo Maggi wrote:
> > ...
> > > i've compiled 2.6.27.2 source after having patched it with your today's
> > > patch.
> > > 
> > > it works! i.e. i can navigate (w3m kernel.org) and update (apt-get
> > > update)
> > 
> > Ilpo, I should say you're incredible! ...But, since I've promised to
> > myself not to disturb you anymore (again), I can't do this, sorry :-(
> 
> Indeed, excellent work Ilpo.
> 
> Ilpo, now that we know this fixes things for sure, could you submit
> this formally with a proper signoff?
> 
> I'll queue it up for -stable too.
> 
> Thanks!

Sure, here below is one with a warning (it's the first patch + comment).

Olon, can you please check this as well if it affect to your case too 
(though the symptoms were not that clear in your case).

It would be nice for Aldo to check what the result will be with my second 
patch (only) using sack=1,ts=0,wscale=0. I guess it does but it's a bit 
unclear if nop's in front help or not (having the patch below should 
anyway help also in that case as the mss option gets moved before it 
anyway).

--
[PATCH] tcp: Restore ordering of TCP options for the sake of inter-operability

This is not our bug! Sadly some devices cannot cope with the change
of TCP option ordering which was a result of the recent rewrite of
the option code (not that there was some particular reason steming
from the rewrite for the reordering) though any ordering of TCP
options is perfectly legal. Thus we restore the original ordering
to allow interoperability with/through such broken devices and add
some warning about this trap. Since the reordering just happened
without any particular reason, this change shouldn't cost us
anything.

There are already couple of known failure reports (within close
proximity of the last release), so the problem might be more
wide-spread than a single device. And other reports which may
be due to the same problem though the symptoms were less obvious.
Analysis of one of the case revealed (with very high probability)
that sack capability cannot be negotiated as the first option
(SYN never got a response).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Aldo Maggi <sentiniate@tiscali.it>
Tested-by: Aldo Maggi <sentiniate@tiscali.it>
---
 net/ipv4/tcp_output.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de54f02..e4c5ac9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -362,6 +362,17 @@ struct tcp_out_options {
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
 };
 
+/* Beware: Something in the Internet is very sensitive to the ordering of
+ * TCP options, we learned this through the hard way, so be careful here.
+ * Luckily we can at least blame others for their non-compliance but from
+ * inter-operatibility perspective it seems that we're somewhat stuck with
+ * the ordering which we have been using if we want to keep working with
+ * those broken things (not that it currently hurts anybody as there isn't
+ * particular reason why the ordering would need to be changed).
+ *
+ * At least SACK_PERM as the first option is known to lead to a disaster
+ * (but it may well be that other scenarios fail similarly).
+ */
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			      const struct tcp_out_options *opts,
 			      __u8 **md5_hash) {
@@ -376,6 +387,12 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*md5_hash = NULL;
 	}
 
+	if (unlikely(opts->mss)) {
+		*ptr++ = htonl((TCPOPT_MSS << 24) |
+			       (TCPOLEN_MSS << 16) |
+			       opts->mss);
+	}
+
 	if (likely(OPTION_TS & opts->options)) {
 		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
@@ -392,12 +409,6 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(opts->mss)) {
-		*ptr++ = htonl((TCPOPT_MSS << 24) |
-			       (TCPOLEN_MSS << 16) |
-			       opts->mss);
-	}
-
 	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
 		     !(OPTION_TS & opts->options))) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
-- 
1.5.2.2
---696208474-1227150675-1224669511=:7072--
