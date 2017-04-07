From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v3 5/7] net: more accurate checksumming in validate_xmit_skb()
Date: Fri,  7 Apr 2017 16:16:08 +0200
Message-ID: <97dd966d2901534f7c8ce1968affc51c46b9794d.1491562390.git.dcaratti@redhat.com>
References: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933639AbdDGOQk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:16:40 -0400
In-Reply-To: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
In-Reply-To: <cover.1491562390.git.dcaratti@redhat.com>
References: <cover.1491562390.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_csum_hwoffload_help() uses netdev features and skb->csum_algo to
determine if skb needs software computation of Internet Checksum or crc32c
(or nothing, if this computation can be done by the hardware). Use it in
place of skb_checksum_help() in validate_xmit_skb() to avoid corruption
of non-GSO SCTP packets having skb->ip_summed equal to CHECKSUM_PARTIAL.

While at it, remove references to skb_csum_off_chk* functions, since they
are not present anymore in Linux since commit cf53b1da73bd ('Revert "net:
Add driver helper functions to determine checksum"').

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 Documentation/networking/checksum-offloads.txt | 12 ++++++++----
 include/linux/netdevice.h                      |  3 +++
 include/linux/skbuff.h                         | 11 ++++-------
 net/core/dev.c                                 | 14 ++++++++++++--
 4 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
index 56e3686..95a49aa 100644
--- a/Documentation/networking/checksum-offloads.txt
+++ b/Documentation/networking/checksum-offloads.txt
@@ -35,6 +35,10 @@ This interface only allows a single checksum to be offloaded.  Where
  encapsulation is used, the packet may have multiple checksum fields in
  different header layers, and the rest will have to be handled by another
  mechanism such as LCO or RCO.
+CRC can also be offloaded using this interface, by means of filling
+ skb->csum_start and skb->csum_offset as described above, and setting
+ skb->csum_algo to values different than INTERNET_CHECKSUM: see skbuff.h
+ comment (section 'D') for more details.
 No offloading of the IP header checksum is performed; it is always done in
  software.  This is OK because when we build the IP header, we obviously
  have it in cache, so summing it isn't expensive.  It's also rather short.
@@ -49,9 +53,9 @@ A driver declares its offload capabilities in netdev->hw_features; see
  and csum_offset given in the SKB; if it tries to deduce these itself in
  hardware (as some NICs do) the driver should check that the values in the
  SKB match those which the hardware will deduce, and if not, fall back to
- checksumming in software instead (with skb_checksum_help or one of the
- skb_csum_off_chk* functions as mentioned in include/linux/skbuff.h).  This
- is a pain, but that's what you get when hardware tries to be clever.
+ checksumming in software instead (with skb_csum_hwoffload_help() or one of
+ the skb_checksum_help() / skb_crc32c_csum_help functions, as mentioned in
+ include/linux/skbuff.h).
 
 The stack should, for the most part, assume that checksum offload is
  supported by the underlying device.  The only place that should check is
@@ -60,7 +64,7 @@ The stack should, for the most part, assume that checksum offload is
  may include other offloads besides TX Checksum Offload) and, if they are
  not supported or enabled on the device (determined by netdev->features),
  performs the corresponding offload in software.  In the case of TX
- Checksum Offload, that means calling skb_checksum_help(skb).
+ Checksum Offload, that means calling skb_csum_hwoffload_help(skb, features).
 
 
 LCO: Local Checksum Offload
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 960f6ab..e4ceb36 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3898,6 +3898,9 @@ void netdev_rss_key_fill(void *buffer, size_t len);
 int dev_get_nest_level(struct net_device *dev);
 int skb_checksum_help(struct sk_buff *skb);
 int skb_crc32c_csum_help(struct sk_buff *skb);
+int skb_csum_hwoffload_help(struct sk_buff *skb,
+			    const netdev_features_t features);
+
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 527be47..4d2a6ec 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -162,13 +162,10 @@
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
+ *   checksum offload capability.
+ *   skb_csum_hwoffload_help() can be called to resolve CHECKSUM_PARTIAL based
+ *   on network device checksumming capabilities: if a packet does not match
+ *   them, skb_checksum_help/skb_crc32c_help (based on csum_algo, see item D.)
  *   is called to resolve the checksum.
  *
  * CHECKSUM_NONE:
diff --git a/net/core/dev.c b/net/core/dev.c
index c6a4281..223aa16 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2988,6 +2988,17 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 	return skb;
 }
 
+int skb_csum_hwoffload_help(struct sk_buff *skb,
+			    const netdev_features_t features)
+{
+	if (skb->csum_algo == CRC32C_CHECKSUM)
+		return !!(features & NETIF_F_SCTP_CRC) ? 0 :
+			skb_crc32c_csum_help(skb);
+
+	return !!(features & NETIF_F_CSUM_MASK) ? 0 : skb_checksum_help(skb);
+}
+EXPORT_SYMBOL(skb_csum_hwoffload_help);
+
 static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	netdev_features_t features;
@@ -3023,8 +3034,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 			else
 				skb_set_transport_header(skb,
 							 skb_checksum_start_offset(skb));
-			if (!(features & NETIF_F_CSUM_MASK) &&
-			    skb_checksum_help(skb))
+			if (skb_csum_hwoffload_help(skb, features))
 				goto out_kfree_skb;
 		}
 	}
-- 
2.7.4
