From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: Re: [PATCH 10/10] MLSXFRM-v02: Auto-labeling of child sockets
Date: Thu, 27 Jul 2006 11:53:44 -0500
Message-ID: <44C8EF98.3020507@trustedcs.com>
References: <44BD196C.6000307@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:9739 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751764AbWG0QyF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 12:54:05 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44BD196C.6000307@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch will fix the build problem (encountered by Andrew Morton)
when SECURITY_NETWORK_XFRM is not enabled.

As compared to git-net-selinux_xfrm_decode_session-build-fix.patch in -mm,
this patch sets the return parameter sid to SECSID_NULL in selinux_xfrm_decode_session()
and handles this value in the caller selinux_inet_conn_request() appropriately.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
--- 
NOTE: Not sure what the ideal thing to do is here. The following is incremental
to the original patch. I can send a revision of the entire patch with these changes
if desired.

 security/selinux/hooks.c        |    5 +++++
 security/selinux/include/xfrm.h |    7 ++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

--- linux-2.6.17.child_sock/security/selinux/include/xfrm.h	2006-07-17 16:51:22.000000000 -0500
+++ linux-2.6.17/security/selinux/include/xfrm.h	2006-07-27 11:29:16.000000000 -0500
@@ -20,7 +20,6 @@ int selinux_xfrm_policy_lookup(struct xf
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
 int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm);
-int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *fl, int ckall);
 
 
 /*
@@ -41,6 +40,7 @@ int selinux_xfrm_postroute_last(u32 isec
 			struct avc_audit_data *ad);
 u32 selinux_socket_getpeer_stream(struct sock *sk);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
+int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
 #else
 static inline int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 			struct avc_audit_data *ad)
@@ -63,6 +63,11 @@ static inline int selinux_socket_getpeer
 {
 	return SECSID_NULL;
 }
+static inline int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
+{
+	*sid = SECSID_NULL;
+	return 0;
+}
 #endif
 
 #endif /* _SELINUX_XFRM_H_ */
--- linux-2.6.17.child_sock/security/selinux/hooks.c	2006-07-18 10:33:42.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-27 11:28:53.000000000 -0500
@@ -3595,6 +3595,11 @@ int selinux_inet_conn_request(struct soc
 	err = selinux_xfrm_decode_session(skb, &peersid, 0);
 	BUG_ON(err);
 
+	if (peersid == SECSID_NULL) {
+		req->secid = sksec->sid;
+		return 0;
+	}
+
 	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
 	if (err)
 		return err;

