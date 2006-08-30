From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] Prism54 : add bitrates to scan result
Date: Tue, 29 Aug 2006 18:19:23 -0700
Message-ID: <20060830011923.GQ8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:31942 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932309AbWH3BT5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:19:57 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi John,

	This is unrelated to WE-21. It just adds bitrate information
to the scan result in the Prism54 driver, like some/most other driver
do.
	Rediffed and retested with 2.6.18-rc, apply with fuzz to
wireless-2.6 (ask me for a clean wireless-2.6 patch).

        Have fun...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/prism54/isl_ioctl.r1.c linux/drivers/net/wireless/prism54/isl_ioctl.c
--- linux/drivers/net/wireless/prism54/isl_ioctl.r1.c	2006-04-03 17:12:45.000000000 -0700
+++ linux/drivers/net/wireless/prism54/isl_ioctl.c	2006-04-03 17:15:35.000000000 -0700
@@ -42,6 +42,10 @@ static size_t prism54_wpa_ie_get(islpci_
 static int prism54_set_wpa(struct net_device *, struct iw_request_info *,
 				__u32 *, char *);
 
+/* In 500 kbps */
+static const unsigned char scan_rate_list[] = { 2, 4, 11, 22,
+						12, 18, 24, 36,
+						48, 72, 96, 108 };
 
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
@@ -649,6 +653,32 @@ prism54_translate_bss(struct net_device 
 			kfree(buf);
 		}
 	}
+	/* Do the bitrates */
+	{
+		char *	current_val = current_ev + IW_EV_LCP_LEN;
+		int i;
+		int mask;
+
+		iwe.cmd = SIOCGIWRATE;
+		/* Those two flags are ignored... */
+		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+		/* Parse the bitmask */
+		mask = 0x1;
+		for(i = 0; i < sizeof(scan_rate_list); i++) {
+			if(bss->rates & mask) {
+				iwe.u.bitrate.value = (scan_rate_list[i] * 500000);
+				current_val = iwe_stream_add_value(current_ev, current_val,
+								   end_buf, &iwe,
+								   IW_EV_PARAM_LEN);
+			}
+			mask <<= 1;
+		}
+		/* Check if we added any event */
+		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+			current_ev = current_val;
+	}
+
 	return current_ev;
 }
 
