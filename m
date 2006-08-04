From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH v2] [PKT_SCHED] RED: Fix overflow in calculation of queue
 average
Date: Fri, 4 Aug 2006 18:44:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0608041836490.8526@kivilampi-30.cs.helsinki.fi>
References: <11546408123792-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20060803184656.55da3939@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45445 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP
	id S1161257AbWHDPoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 11:44:21 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060803184656.55da3939@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Overflow can occur very easily with 32 bits, e.g., with 1 second
us_idle is approx. 2^20, which leaves only 11-Wlog bits for queue
length. Since the EWMA exponent is typically around 9, queue
lengths larger than 2^2 cause overflow. Whether the affected
branch is taken when us_idle is as high as 1 second, depends on
Scell_log, but with rather reasonable configuration Scell_log is
large enough to cause p->Stab to have zero index, which always
results zero shift (typically also few other small indices result
in zero shift).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/red.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/red.h b/include/net/red.h
index 2ed4358..cfc2625 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -213,7 +213,7 @@ static inline unsigned long red_calc_qav
 		 * Seems, it is the best solution to
 		 * problem of too coarse exponent tabulation.
 		 */
-		us_idle =3D (p->qavg * us_idle) >> p->Scell_log;
+		us_idle =3D (p->qavg * (u64)us_idle) >> p->Scell_log;
=20
 		if (us_idle < (p->qavg >> 1))
 			return p->qavg - us_idle;
--=20
1.4.0
