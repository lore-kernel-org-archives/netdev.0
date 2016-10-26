From: Mark Lord <mlord@pobox.com>
Subject: [PATCH] drivers/net/usb/r8152 fix broken rx checksums
Date: Wed, 26 Oct 2016 18:36:57 -0400
Message-ID: <987cfbab-2b48-e28c-1706-967cb2051d63@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------4F7B2BE8A3D61E55C54AE471"
Cc: stable@vger.kernel.org
To: nic_swsd@realtek.com, netdev@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------4F7B2BE8A3D61E55C54AE471
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

The r8152 driver has been broken since (approx) 3.6.16,
when support was added for hardware rx checksum on newer chip versions.
Symptoms include random segfaults and silent data corruption over NFS.

This does not work on the VER_02 dongle I have here
when used with a slow embedded system CPU.
Google reveals others reporting similar issues on Raspberry Pi.

So, disable hardware rx checksum for VER_02, and fix
an obvious coding error for IPV6 checksums in the same function.

Because this bug results in silent data corruption,
it is a good candidate for back-porting to -stable >= 3.16.xx.
Patch attached (to deal with buggy mailer) and also below for review.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- old/drivers/net/usb/r8152.c	2016-09-30 04:20:43.000000000 -0400
+++ linux/drivers/net/usb/r8152.c	2016-10-26 14:15:44.932517676 -0400
@@ -1645,7 +1645,7 @@
  	u8 checksum = CHECKSUM_NONE;
  	u32 opts2, opts3;

-	if (tp->version == RTL_VER_01)
+	if (tp->version == RTL_VER_01 || tp->version == RTL_VER_02)
  		goto return_result;

  	opts2 = le32_to_cpu(rx_desc->opts2);
@@ -1660,7 +1660,7 @@
  			checksum = CHECKSUM_NONE;
  		else
  			checksum = CHECKSUM_UNNECESSARY;
-	} else if (RD_IPV6_CS) {
+	} else if (opts2 & RD_IPV6_CS) {
  		if ((opts2 & RD_UDP_CS) && !(opts3 & UDPF))
  			checksum = CHECKSUM_UNNECESSARY;
  		else if ((opts2 & RD_TCP_CS) && !(opts3 & TCPF))

--------------4F7B2BE8A3D61E55C54AE471
Content-Type: text/x-patch;
 name="drivers_net_usb_r8152_checksums.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="drivers_net_usb_r8152_checksums.patch"

The r8152 driver has been broken since (approx) 3.6.16,
when support was added for hardware rx checksum on newer chip versions.
Symptoms include random segfaults and silent data corruption over NFS.

This does not work on the VER_02 dongle I have here
when used with a slow embedded system CPU.
Google reveals others reporting similar issues on Raspberry Pi.

So, disable hardware rx checksum for VER_02, and fix
an obvious coding error for IPV6 checksums in the same function.

Because this bug results in silent data corruption,
it is a good candidate for back-porting to -stable >= 3.16.xx.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- old/drivers/net/usb/r8152.c	2016-09-30 04:20:43.000000000 -0400
+++ linux/drivers/net/usb/r8152.c	2016-10-26 14:15:44.932517676 -0400
@@ -1645,7 +1645,7 @@
 	u8 checksum = CHECKSUM_NONE;
 	u32 opts2, opts3;
 
-	if (tp->version == RTL_VER_01)
+	if (tp->version == RTL_VER_01 || tp->version == RTL_VER_02)
 		goto return_result;
 
 	opts2 = le32_to_cpu(rx_desc->opts2);
@@ -1660,7 +1660,7 @@
 			checksum = CHECKSUM_NONE;
 		else
 			checksum = CHECKSUM_UNNECESSARY;
-	} else if (RD_IPV6_CS) {
+	} else if (opts2 & RD_IPV6_CS) {
 		if ((opts2 & RD_UDP_CS) && !(opts3 & UDPF))
 			checksum = CHECKSUM_UNNECESSARY;
 		else if ((opts2 & RD_TCP_CS) && !(opts3 & TCPF))

--------------4F7B2BE8A3D61E55C54AE471--
