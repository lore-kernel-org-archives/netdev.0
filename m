From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC net-next v1 6/9] dp83640: correct the periodic output frequency
Date: Sat,  8 Mar 2014 20:42:06 +0100
Message-ID: <b04f6f7600709b522c32ed6e6edabd011373a4d0.1394307304.git.richardcochran@gmail.com>
References: <cover.1394307303.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394307303.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The phyter driver incorrectly feeds the value of the period into what
is in fact a pulse width register, resulting in the actual period
being twice the dialed value. This patch fixes the issue and renames a
variable to make the code at bit more clear.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index d6c1061..9e26555 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -271,7 +271,7 @@ static void periodic_output(struct dp83640_clock *clock,
 {
 	struct dp83640_private *dp83640 = clock->chosen;
 	struct phy_device *phydev = dp83640->phydev;
-	u32 sec, nsec, period;
+	u32 sec, nsec, pwidth;
 	u16 gpio, ptp_trig, trigger, val;
 
 	gpio = on ? gpio_tab[PEROUT_GPIO] : 0;
@@ -296,8 +296,9 @@ static void periodic_output(struct dp83640_clock *clock,
 
 	sec = clkreq->perout.start.sec;
 	nsec = clkreq->perout.start.nsec;
-	period = clkreq->perout.period.sec * 1000000000UL;
-	period += clkreq->perout.period.nsec;
+	pwidth = clkreq->perout.period.sec * 1000000000UL;
+	pwidth += clkreq->perout.period.nsec;
+	pwidth /= 2;
 
 	mutex_lock(&clock->extreg_lock);
 
@@ -310,8 +311,8 @@ static void periodic_output(struct dp83640_clock *clock,
 	ext_write(0, phydev, PAGE4, PTP_TDR, nsec >> 16);      /* ns[31:16] */
 	ext_write(0, phydev, PAGE4, PTP_TDR, sec & 0xffff);    /* sec[15:0] */
 	ext_write(0, phydev, PAGE4, PTP_TDR, sec >> 16);       /* sec[31:16] */
-	ext_write(0, phydev, PAGE4, PTP_TDR, period & 0xffff); /* ns[15:0] */
-	ext_write(0, phydev, PAGE4, PTP_TDR, period >> 16);    /* ns[31:16] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth & 0xffff); /* ns[15:0] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth >> 16);    /* ns[31:16] */
 
 	/*enable trigger*/
 	val &= ~TRIG_LOAD;
-- 
1.7.10.4
