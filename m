From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp-illinois: incorrect beta usage
Date: Wed, 28 Nov 2007 15:47:25 -0800
Message-ID: <20071128154725.29af2852@freepuppy.rosehill>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	<001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Lachlan Andrew'" <lachlan.andrew@gmail.com>,
	<shaoliu@Princeton.EDU>, "'Douglas Leith'" <doug.leith@nuim.ie>,
	"'Robert Shorten'" <robert.shorten@nuim.ie>, netdev@vger.kernel.org
To: "Julian Shao Liu" <shaoliu@uiuc.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59130 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbXK1XuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 18:50:23 -0500
In-Reply-To: <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lachlan Andrew observed that my TCP-Illinois implementation uses the
beta value incorrectly:
  The parameter  beta  in the paper specifies the amount to decrease
  *by*:  that is, on loss,
     W <-  W -  beta*W
  but in   tcp_illinois_ssthresh() uses  beta  as the amount
  to decrease  *to*: W <- beta*W

This bug makes the Linux TCP-Illinois get less-aggressive on uncongested network,
hurting performance. Note: since the base beta value is .5, it has no
impact on a congested network.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_illinois.c	2007-08-18 07:50:15.000000000 -0700
+++ b/net/ipv4/tcp_illinois.c	2007-11-28 15:39:04.000000000 -0800
@@ -298,7 +298,7 @@ static u32 tcp_illinois_ssthresh(struct 
 	struct illinois *ca = inet_csk_ca(sk);
 
 	/* Multiplicative decrease */
-	return max((tp->snd_cwnd * ca->beta) >> BETA_SHIFT, 2U);
+	return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->beta) >> BETA_SHIFT), 2U);
 }
 
 
