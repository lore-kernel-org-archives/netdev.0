From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC][net-next-2.6 PATCH 3/4] ethtool: set hard_header_len using
	ETH_FLAG_{TX|RX}VLAN
Date: Thu, 21 Oct 2010 15:10:15 -0700
Message-ID: <20101021221015.22906.3516.stgit@jf-dev1-dcblab>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21238 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751Ab0JUWLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 18:11:43 -0400
In-Reply-To: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
This results in pskb_expand_head() being used unnecessarily.

This add a check in ethtool_op_set_flags to catch the ETH_FLAG_TXVLAN
flag and set the header length.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/ethtool.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 956a9f4..4f7fe26 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -21,6 +21,7 @@
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -151,6 +152,14 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 	if (data & ~supported)
 		return -EINVAL;
 
+	/* is ETH_FLAGS_TXVLAN being toggled */
+	if ((dev->features & ETH_FLAG_TXVLAN) ^ (data & ETH_FLAG_TXVLAN)) {
+		if (data & ETH_FLAG_TXVLAN)
+			dev->hard_header_len -= VLAN_HLEN;
+		else
+			dev->hard_header_len += VLAN_HLEN;
+	}
+
 	dev->features = ((dev->features & ~flags_dup_features) |
 			 (data & flags_dup_features));
 	return 0;

