From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Sat, 18 Jul 2015 11:23:19 -0400 (EDT)
Message-ID: <1971016402.292095.1437232999941.JavaMail.zimbra@savoirfairelinux.com>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150710171027.GB6585@groeck-UX31A> <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com> <20150710183623.GB19854@roeck-us.net> <645518234.216003.1436556107630.JavaMail.zimbra@savoirfairelinux.com> <20150710200514.GA9469@groeck-UX31A> <20150718145830.GA17961@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150718145830.GA17961@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

----- On Jul 18, 2015, at 10:58 AM, Andrew Lunn andrew@lunn.ch wrote:

>> Good point. The timeout is most definitely quite large and for sure on
>> the safe side. It might make sense to add some statistics gathering to
>> see how long the maximum observed delay actually is.
> 
> Hi All
> 
> Statistics are something which can be used a lot, i bursts and
> interactivily. ATU, VTU etc, are much less often used. So different
> delays might be justified.
> 
> I agree about doing some statistics gathering to determine actual
> delays needed.
> 
>        Andrew

What do you think about something like this?

Thanks,
-v

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4f3701f..6471807 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -563,9 +563,10 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 
 /* Must be called with SMI lock held */
 static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
-			   u16 mask)
+			   u16 mask, unsigned int msecs)
 {
 	unsigned long timeout = jiffies + HZ / 10;
+	unsigned long usecs = msecs * 1000;
 
 	while (time_before(jiffies, timeout)) {
 		int ret;
@@ -576,7 +577,8 @@ static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 		if (!(ret & mask))
 			return 0;
 
-		usleep_range(1000, 2000);
+		if (usecs)
+			usleep_range(usecs, usecs + 1000);
 	}
 	return -ETIMEDOUT;
 }
@@ -585,7 +587,7 @@ static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_STATS_OP,
-			       GLOBAL_STATS_OP_BUSY);
+			       GLOBAL_STATS_OP_BUSY, 0);
 }
 
 /* Must be called with SMI mutex held */
@@ -872,13 +874,14 @@ error:
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask,
+			  unsigned int msecs)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_wait(ds, reg, offset, mask);
+	ret = _mv88e6xxx_wait(ds, reg, offset, mask, msecs);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -887,33 +890,33 @@ static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 static int _mv88e6xxx_phy_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
-			       GLOBAL2_SMI_OP_BUSY);
+			       GLOBAL2_SMI_OP_BUSY, 1);
 }
 
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
 {
 	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_LOAD);
+			      GLOBAL2_EEPROM_OP_LOAD, 1);
 }
 
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 {
 	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_BUSY);
+			      GLOBAL2_EEPROM_OP_BUSY, 1);
 }
 
 /* Must be called with SMI lock held */
 static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_ATU_OP,
-			       GLOBAL_ATU_OP_BUSY);
+			       GLOBAL_ATU_OP_BUSY, 1);
 }
 
 /* Must be called with SMI lock held */
 static int _mv88e6xxx_scratch_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SCRATCH_MISC,
-			       GLOBAL2_SCRATCH_BUSY);
+			       GLOBAL2_SCRATCH_BUSY, 1);
 }
 
 /* Must be called with SMI mutex held */
