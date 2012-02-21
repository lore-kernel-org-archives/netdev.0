From: Greg Rose <gregory.v.rose@intel.com>
Subject: [PATCH] iproute2: Add netlink attribute to filter dump requests
Date: Tue, 21 Feb 2012 12:43:09 -0800
Message-ID: <20120221204309.22274.53890.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43996 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755532Ab2BUUnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 15:43:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new netlink attribute type to the dump request to allow
filtering of the information returned for the respective matching
interfaces.  At this time the only filter defined is to request
virtual function (VF) device info for interfaces that attached VFs.

It will also be possible to extend the request with other yet to be
defined netlink attributes in the future.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/if_link.h   |    1 +
 include/linux/rtnetlink.h |    5 +++--
 lib/libnetlink.c          |    7 +++++++
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d3bc04c..06a3a47 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,7 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
 	__IFLA_MAX
 };
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 12b19e6..1d30f85 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -600,8 +600,9 @@ struct tcamsg {
 #define TCA_ACT_TAB 1 /* attr type must be >=1 */	
 #define TCAA_MAX 1
 
-/* End of information exported to user level */
-
+/* New extended info filters for IFLA_EXT_MASK */
+#define RTEXT_FILTER_VF		(1 << 0)
 
+/* End of information exported to user level */
 
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index c581e11..878911e 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -94,6 +94,9 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	struct {
 		struct nlmsghdr nlh;
 		struct rtgenmsg g;
+		__u16 align_rta;	/* attribute has to be 32bit aligned */
+		struct rtattr ext_req;
+		__u32 ext_filter_mask;
 	} req;
 
 	memset(&req, 0, sizeof(req));
@@ -104,6 +107,10 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
 	req.g.rtgen_family = family;
 
+	req.ext_req.rta_type = IFLA_EXT_MASK;
+	req.ext_req.rta_len = RTA_LENGTH(sizeof(__u32));
+	req.ext_filter_mask = RTEXT_FILTER_VF;
+
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
 
