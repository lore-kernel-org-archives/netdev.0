From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH] iproute2: Add extended info mask to ifinfo dump requests
Date: Sun, 12 Feb 2012 11:16:31 -0800
Message-ID: <20120212191630.2031.61073.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4325 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab2BLTQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Feb 2012 14:16:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creates a new nlattr type IFLA_EXT_MASK which sends a u32 bit mask
along with the ifinfo dump request.  This mask can be used to filter
on types of extended interface information such as VFs.

Tested on 2.6.39 and 3.0.3 kernels to check for backward compatibility.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/if_link.h   |    1 +
 include/linux/netlink.h   |    1 +
 include/linux/rtnetlink.h |   11 +++++++++--
 lib/libnetlink.c          |   14 +++++++++-----
 4 files changed, 20 insertions(+), 7 deletions(-)

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
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 5c4f087..ca1f7fc 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -59,6 +59,7 @@ struct nlmsghdr {
 #define NLM_F_MATCH	0x200	/* return all matching	*/
 #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
 #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
+#define NLM_F_EXT	0x800	/* Get extended interface info such as VFs */
 
 /* Modifiers to NEW request */
 #define NLM_F_REPLACE	0x100	/* Override existing		*/
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 12b19e6..ed0d85b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -597,11 +597,18 @@ struct tcamsg {
 };
 #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
 #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
+#define TCA_ACT_TAB 1 /* attr type must be >=1 */
 #define TCAA_MAX 1
 
-/* End of information exported to user level */
+struct rtnl_req_extended {
+	struct nlmsghdr nlh;
+	struct rtgenmsg g;
+	char ext[RTA_SPACE(sizeof(__u32))];
+};
 
+/* New extended info filters for IFLA_EXT_MASK */
+#define RTEXT_FILTER_VF		(1 << 0)
 
+/* End of information exported to user level */
 
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index c581e11..7d6966c 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -91,18 +91,22 @@ int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions)
 
 int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 {
-	struct {
-		struct nlmsghdr nlh;
-		struct rtgenmsg g;
-	} req;
+	struct rtnl_req_extended req;
+	struct rtattr *ext_req;
+	__u32 *ext_filter_mask;
 
 	memset(&req, 0, sizeof(req));
 	req.nlh.nlmsg_len = sizeof(req);
 	req.nlh.nlmsg_type = type;
-	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
+	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST|NLM_F_EXT;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
 	req.g.rtgen_family = family;
+	ext_req = (struct rtattr *)&req.ext;
+	ext_req->rta_type = IFLA_EXT_MASK;
+	ext_req->rta_len = RTA_LENGTH(sizeof(__u32));
+	ext_filter_mask = RTA_DATA(ext_req);
+	*ext_filter_mask = RTEXT_FILTER_VF;
 
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
