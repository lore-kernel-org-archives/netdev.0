From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next] vxlan: Provide means for obtaining port information
Date: Wed, 27 Mar 2013 14:33:11 -0700
Message-ID: <20130327212842.13367.68803.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, jeffrey.t.kirsher@intel.com,
	shemminger@vyatta.com, joseph.gasparakis@intel.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab3C0VfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 17:35:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a very simple means for device drivers to obtain access to
the VXLAN destination port number configuration.  This information is needed
in order to provide devices with a means of determining if a given UDP flow is
a VXLAN flow or if it is a standard flow for offload purposes.

The main disadvantage with this approach is that loading a driver that calls
this interface will mean that it will also load the vxlan module and any other
modules it depends on.  To that end I really hope at some point the value
becomes static as we could then avoid this extra overhead.  The alternative to
this though is significantly more complicated as it would likely require
registering notifiers to capture when the vxlan module is loaded and then
updating the value.

This patch adds a new header, if_vxlan.h which I suspect will slowly be
populated with more details such as the header layout as more devices end up
needing to figure out how to parse VXLAN for various offloads.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/vxlan.c      |    7 +++++++
 include/linux/if_vxlan.h |   28 ++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/if_vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 62a4438..5b3bb9a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -898,6 +898,13 @@ static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 	return (((u64) hash * range) >> 32) + vxlan->port_min;
 }
 
+/* simple accessor function for getting VXLAN destination port number */
+int vxlan_dst_port(void)
+{
+	return vxlan_port;
+}
+EXPORT_SYMBOL_GPL(vxlan_dst_port);
+
 static int handle_offloads(struct sk_buff *skb)
 {
 	if (skb_is_gso(skb)) {
diff --git a/include/linux/if_vxlan.h b/include/linux/if_vxlan.h
new file mode 100644
index 0000000..b997eac
--- /dev/null
+++ b/include/linux/if_vxlan.h
@@ -0,0 +1,28 @@
+/*
+ * VXLAN: Virtual eXtensible Local Area Network
+ *
+ * Copyright (c) 2013, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ */
+
+#if IS_ENABLED(CONFIG_VXLAN)
+extern int vxlan_dst_port(void);
+#else
+static inline int vxlan_dst_port(void)
+{
+	return 0;
+}
+#endif
