From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v2 4/4] Documentation: update notes on checksum offloading
Date: Tue, 28 Feb 2017 11:32:48 +0100
Message-ID: <6be6b03bc09e4c15a9fd3c05847b22d4d3debff9.1488199633.git.dcaratti@redhat.com>
References: <1488202783.2713.67.camel@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58946 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751989AbdB1Kkd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 05:40:33 -0500
In-Reply-To: <1488202783.2713.67.camel@redhat.com>
In-Reply-To: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
References: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add description of skb_sctp_csum_help in networking/checksum-offload.txt,
and document its usage in combination with skb->csum_not_inet. While at
it, remove reference to skb_csum_off_chk* functions, since they have been
removed from Linux source tree since commit cf53b1da73bd ("Revert "net:
Add driver helper functions to determine checksum""), and add missing
explaination of CHECKSUM_UNNECESSARY for FCOE protocol.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 Documentation/networking/checksum-offloads.txt |  7 ++++---
 include/linux/skbuff.h                         | 25 ++++++++++++-------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
index 56e3686..81534e9 100644
--- a/Documentation/networking/checksum-offloads.txt
+++ b/Documentation/networking/checksum-offloads.txt
@@ -49,8 +49,8 @@ A driver declares its offload capabilities in netdev->hw_features; see
  and csum_offset given in the SKB; if it tries to deduce these itself in
  hardware (as some NICs do) the driver should check that the values in the
  SKB match those which the hardware will deduce, and if not, fall back to
- checksumming in software instead (with skb_checksum_help or one of the
- skb_csum_off_chk* functions as mentioned in include/linux/skbuff.h).  This
+ checksumming in software instead (with skb_checksum_help or
+ skb_sctp_csum_help functions as mentioned in include/linux/skbuff.h). This
  is a pain, but that's what you get when hardware tries to be clever.
 
 The stack should, for the most part, assume that checksum offload is
@@ -60,7 +60,8 @@ The stack should, for the most part, assume that checksum offload is
  may include other offloads besides TX Checksum Offload) and, if they are
  not supported or enabled on the device (determined by netdev->features),
  performs the corresponding offload in software.  In the case of TX
- Checksum Offload, that means calling skb_checksum_help(skb).
+ Checksum Offload, that means calling skb_sctp_csum_help(skb) for SCTP
+ packets, and skb_checksum_help(skb) for other packets.
 
 
 LCO: Local Checksum Offload
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 236b7d9..12d3625 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -108,6 +108,7 @@
  *       may perform further validation in this case.
  *     GRE: only if the checksum is present in the header.
  *     SCTP: indicates the CRC in SCTP header has been validated.
+ *     FCOE: indicates the CRC in FC frame has been validated.
  *
  *   skb->csum_level indicates the number of consecutive checksums found in
  *   the packet minus one that have been verified as CHECKSUM_UNNECESSARY.
@@ -161,14 +162,13 @@
  *
  *   NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM are being deprecated in favor of
  *   NETIF_F_HW_CSUM. New devices should use NETIF_F_HW_CSUM to indicate
- *   checksum offload capability. If a	device has limited checksum capabilities
- *   (for instance can only perform NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM as
- *   described above) a helper function can be called to resolve
- *   CHECKSUM_PARTIAL. The helper functions are skb_csum_off_chk*. The helper
- *   function takes a spec argument that describes the protocol layer that is
- *   supported for checksum offload and can be called for each packet. If a
- *   packet does not match the specification for offload, skb_checksum_help
- *   is called to resolve the checksum.
+ *   checksum offload capability. If a device has limited checksum capabilities
+ *   (for instance it can't perform NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM as
+ *   described above) a helper function (namely skb_csum_hwoffload_help) can
+ *   be called to resolve CHECKSUM_PARTIAL. This function uses netdev_features_t
+ *   to have the Internet Checksum computed by HW, in case any feature belonging
+ *   to NETIF_F_CSUM_MASK is set, or by software using skb_checksum_help().
+ *   See also Section D.
  *
  * CHECKSUM_NONE:
  *
@@ -189,11 +189,10 @@
  *   NETIF_F_SCTP_CRC - This feature indicates that a device is capable of
  *     offloading the SCTP CRC in a packet. To perform this offload the stack
  *     will set ip_summed to CHECKSUM_PARTIAL and set csum_start and csum_offset
- *     accordingly. Note the there is no indication in the skbuff that the
- *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
- *     both IP checksum offload and SCTP CRC offload must verify which offload
- *     is configured for a packet presumably by inspecting packet headers; in
- *     case, skb_sctp_csum_help is provided to compute CRC on SCTP packets.
+ *     accordingly. skb->csum_not_inet is an indication in the skbuff that the
+ *     CHECKSUM_PARTIAL refers to an SCTP checksum: a driver can use it to
+ *     decide whether skb_checksum_help() or skb_sctp_csum_help() have to be
+ *     called on a sk_buff having ip_summed set to CHECKSUM_PARTIAL.
  *
  *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
  *     offloading the FCOE CRC in a packet. To perform this offload the stack
-- 
2.7.4
