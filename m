From: Andy Lutomirski <luto@myrealbox.com>
Subject: Re: [patch 0/7] 2.6.6-rc3-mm1 - description of the r8169 queue [resend]
Date: Sun, 02 May 2004 15:34:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4095776D.3050006@myrealbox.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010007000303060502050603"
Cc: jgarzik@pobox.com, Andy Lutomirski <luto@myrealbox.com>,
        Jon D Mason <jonmason@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040501022308.A32762@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010007000303060502050603
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

[resend -- I'm not sure the first one went out]

Three problems:

1. ethtool forgets to report link status
2. On my system, this driver can't bring up the link.  That's because
the PHY reset timer of 1 second is WAAAY too short -- the PHY gets stuck
in a reset loop.  (In the old driver it was 12 seconds because there was
a multiplier in the timer.)
3. NAPI is missing from Kconfig

These patches also chance the initial chipset reset timer from 2 jiffies
to 100ms (for HZ-independence, and 2ms sounds overly short.)

--Andy

Francois Romieu wrote:
> With some delay, the following patches include Jon D Mason's NAPI changes
> (+ fixes) and code from Andy Lutomirski with minor changes.
> I have not moved the initialization of the phy timer in the pci probe
> routine as:
> - I believe it belongs to the netdevice;
> - it should work as is without significant change for the user.
> 
> If someone sees a good reason to move it, just complain (with an axe).
> 
> The patches apply to 2.6.6-rc3 as well as to 2.6.6-rc3-mm1.
> 
> All the patches are merged in a single patch against 2.6.6-rc3 available at:
> http://www.fr.zoreil.com/people/francois/misc/20040501-2.6.6-rc3-r8169.c-test.patch
> 
> The patches are archived below as well:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.6-rc3
> 
> If the patches prove to behave decently on 2.6, a backport for 2.4.x will be
> generated.
> 
> --
> Ueimor


--------------010007000303060502050603
Content-Type: text/plain;
 name="r8169_new_fixes"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169_new_fixes"

--- linux-2.6.6-rc2/drivers/net/r8169.c~fr	2004-04-30 23:27:48.683174600 -0700
+++ linux-2.6.6-rc2/drivers/net/r8169.c	2004-05-02 12:31:00.720041072 -0700
@@ -111,7 +111,7 @@
 
 #define RTL_MIN_IO_SIZE 0x80
 #define RTL8169_TX_TIMEOUT	(6*HZ)
-#define RTL8169_PHY_TIMEOUT	(HZ) 
+#define RTL8169_PHY_TIMEOUT	(10*HZ) 
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -593,6 +593,7 @@
 
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 };
@@ -782,7 +783,7 @@
 		 * A busy loop could burn quite a few cycles on nowadays CPU.
 		 * Let's delay the execution of the timer for a few ticks.
 		 */
-		timeout = 2;
+		timeout = HZ/10;
 		goto out_mod_timer;
 	}
 


--------------010007000303060502050603
Content-Type: text/plain;
 name="r8169_kconfig"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169_kconfig"

--- linux-2.6.6-rc2/drivers/net/Kconfig~r8169_napi	2004-05-02 12:34:44.810974072 -0700
+++ linux-2.6.6-rc2/drivers/net/Kconfig	2004-05-02 12:35:46.553587768 -0700
@@ -1958,6 +1958,10 @@
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
+config R8169_NAPI
+	bool "Realtek 8169 NAPI (EXPERIMENTAL)"
+	depends on R8169 && EXPERIMENTAL
+
 config SK98LIN
 	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support"
 	depends on PCI


--------------010007000303060502050603--
