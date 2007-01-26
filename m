From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 1/1] selinux: fix 2.6.20-rc6 build when no xfrm
Date: Fri, 26 Jan 2007 10:58:03 -0600
Message-ID: <45BA331B.9090701@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, eparis@redhat.com, sgrubb@redhat.com,
	sds@tycho.nsa.gov, jmorris@namei.org, chanson@trustedcs.com,
	michal.k.k.piotrowski@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:20699 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161050AbXAZQ6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 11:58:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is an incremental fix to the flow_cache_genid
patch for selinux that breaks the build of 2.6.20-rc6 when
xfrm is not configured.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 security/selinux/include/xfrm.h |    9 +++++++++
 security/selinux/ss/services.c  |    6 +++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 161eb57..31929e3 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -37,6 +37,11 @@ int selinux_xfrm_sock_rcv_skb(u32 sid, s
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad, u8 proto);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
+
+static inline void selinux_xfrm_notify_policyload(void)
+{
+	atomic_inc(&flow_cache_genid);
+}
 #else
 static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad)
@@ -55,6 +60,10 @@ static inline int selinux_xfrm_decode_se
 	*sid = SECSID_NULL;
 	return 0;
 }
+
+static inline void selinux_xfrm_notify_policyload(void)
+{
+}
 #endif
 
 static inline void selinux_skb_xfrm_sid(struct sk_buff *skb, u32 *sid)
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index ff03933..ca9154d 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -1299,7 +1299,7 @@ int security_load_policy(void *data, siz
 		avc_ss_reset(seqno);
 		selnl_notify_policyload(seqno);
 		selinux_netlbl_cache_invalidate();
-		atomic_inc(&flow_cache_genid);
+		selinux_xfrm_notify_policyload();
 		return 0;
 	}
 
@@ -1355,7 +1355,7 @@ #endif
 	avc_ss_reset(seqno);
 	selnl_notify_policyload(seqno);
 	selinux_netlbl_cache_invalidate();
-	atomic_inc(&flow_cache_genid);
+	selinux_xfrm_notify_policyload();
 
 	return 0;
 
@@ -1855,7 +1855,7 @@ out:
 	if (!rc) {
 		avc_ss_reset(seqno);
 		selnl_notify_policyload(seqno);
-		atomic_inc(&flow_cache_genid);
+		selinux_xfrm_notify_policyload();
 	}
 	return rc;
 }
