From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: [PATCH] TG3: fiber hw autoneg bounces
Date: Fri, 29 Oct 2004 17:31:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182B6A7.90700@sun.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_t4iqKJrvjhPq07Zcg938/g)"
Cc: Brian Somers <Brian.Somers@Sun.COM>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_t4iqKJrvjhPq07Zcg938/g)
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

We've recently noticed that the autonegotiation cleanup made a while
back (between tg3 3.8 and 3.9) has issues which make the link bounce up
and down.

I've traced it to be caused by the tg3_timer 1 second work noticing that
MAC_STATUS_LNKSTATE_CHANGED was set, which driver would see as the link
going down.

Upon further inspection, it appears that we don't wait long enough
between setting SG_DIG_CTRL and reading the SG_DIG_STATUS for the result.

The following patch (from a quasi recent bk tree) makes this code path
wait up to 200ms for the link to establish.  In my testing, I'm seeing
it take around 20ms for the negotiation to complete.

I haven't had the chance to test how this patch affects the case where
the switch doesn't have autoneg enabled, although I suspect fallback
should work correctly.

Please consider applying, thanks,

Signed-off-by: Mike Waychison <michael.waychison@sun.com>

- --
Mike Waychison
Sun Microsystems, Inc.
1 (650) 352-5299 voice
1 (416) 202-8336 voice

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTICE:  The opinions expressed in this email are held by me,
and may not represent the views of Sun Microsystems, Inc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBgrandQs4kOxk3/MRAhWnAJ9eD+qmG8/NCImsRuLCksXbLfwVCgCcDn8G
dnOG2USQhPV1q13rXr4xot8=
=GSM2
-----END PGP SIGNATURE-----

--Boundary_(ID_t4iqKJrvjhPq07Zcg938/g)
Content-type: text/x-patch; name=tg3-hw-autoneg-wait.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=tg3-hw-autoneg-wait.patch

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.2192  -> 1.2193 
#	   drivers/net/tg3.c	1.204   -> 1.205  
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/10/29	michael.waychison@sun.com	1.2193
# The tg3 driver's fiber hw autonegotiation path wasn't waiting for the
# negotiation to complete.  This caused a delayed change in link state which was
# picked up by the per-second timer and caused the link to bounce up and down
# once every second.  The attached patch fixes this by waiting up to 200ms to get
# a success or error from the chip's built in autonegotiation.
# --------------------------------------------
#
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Fri Oct 29 20:08:53 2004
+++ b/drivers/net/tg3.c	Fri Oct 29 20:08:53 2004
@@ -2140,7 +2140,16 @@
 		tp->tg3_flags2 |= TG3_FLG2_PHY_JUST_INITTED;
 	} else if (mac_status & (MAC_STATUS_PCS_SYNCED |
 				 MAC_STATUS_SIGNAL_DET)) {
-		sg_dig_status = tr32(SG_DIG_STATUS);
+		int i;
+
+		/* Giver time to negotiate (~200ms) */
+		for (i = 0; i < 40000; i++) {
+			sg_dig_status = tr32(SG_DIG_STATUS);
+			if (sg_dig_status & (0x3))
+				break;
+			udelay(5);
+		}
+		mac_status = tr32(MAC_STATUS);
 
 		if ((sg_dig_status & (1 << 1)) &&
 		    (mac_status & MAC_STATUS_PCS_SYNCED)) {

--Boundary_(ID_t4iqKJrvjhPq07Zcg938/g)--
