From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: Initialize link settings in every nv_open()
Date: Sat, 06 Aug 2005 23:47:55 +0200
Message-ID: <42F5300B.3070909@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070304080809040805050905"
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, Netdev <netdev@oss.sgi.com>,
        cOzmIc.FI@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070304080809040805050905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j76LtXH9010831

R=FCdiger found a bug in nv_open that explains some of the reports
with duplex mismatches:
nv_open calls nv_update_link_speed for initializing the hardware link spe=
ed
registers. If current link setting matches the values in np->linkspeed an=
d
np->duplex, then the function does nothing.
Usually, doing nothing is the right thing, but not in nv_open: During
nv_open, the registers must be initialized because the nic was reset.

The attached patch fixes that by setting np->linkspeed to an invalid valu=
e
before calling nv_update_link_speed from nv_open.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>


--------------070304080809040805050905
Content-Type: text/plain;
 name="patch-forcedeth-042-forcelinkinit"
Content-Disposition: inline;
 filename="patch-forcedeth-042-forcelinkinit"
Content-Transfer-Encoding: 7bit

--- 2.6/drivers/net/forcedeth.c	2005-08-06 19:59:56.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-08-06 19:59:06.000000000 +0200
@@ -93,6 +93,8 @@
  *      0.40: 19 Jul 2005: Add support for mac address change.
  *      0.41: 30 Jul 2005: Write back original MAC in nv_close instead
  *			   of nv_remove
+ *      0.42: 06 Aug 2005: Fix lack of link speed initialization
+ *			   in the second (and later) nv_open call
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -2178,6 +2180,9 @@
 		writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
 		dprintk(KERN_INFO "startup: got 0x%08x.\n", miistat);
 	}
+	/* set linkspeed to invalid value, thus force nv_update_linkspeed
+	 * to init hw */
+	np->linkspeed = 0;
 	ret = nv_update_linkspeed(dev);
 	nv_start_rx(dev);
 	nv_start_tx(dev);

--------------070304080809040805050905--
