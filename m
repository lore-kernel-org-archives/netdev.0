From: Eric Paris <eparis@parisplace.org>
Subject: [PATCH] Add xfrm policy change auditing to pfkey_spdget
Date: Fri, 02 Mar 2007 13:51:24 -0500
Message-ID: <1172861484.31047.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jmorris@namei.org, vyekkirala@trustedcs.com,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964773AbXCBSvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 13:51:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pfkey_spdget neither had an LSM security hook nor auditing for the
removal of xfrm_policy structs.  The security hook was added when it was
moved into xfrm_policy_byid instead of the callers to that function by
my earlier patch and this patch adds the auditing hooks as well.

Signed-off-by: Eric Paris <eparis@redhat.com>

 net/key/af_key.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 3542435..7cbf0a2 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2537,7 +2537,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
 	unsigned int dir;
-	int err;
+	int err = 0, delete;
 	struct sadb_x_policy *pol;
 	struct xfrm_policy *xp;
 	struct km_event c;
@@ -2549,16 +2549,20 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	if (dir >= XFRM_POLICY_MAX)
 		return -EINVAL;
 
+	delete = (hdr->sadb_msg_type == SADB_X_SPDDELETE2);
 	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, pol->sadb_x_policy_id,
-			      hdr->sadb_msg_type == SADB_X_SPDDELETE2, &err);
+			      delete, &err);
 	if (xp == NULL)
 		return -ENOENT;
 
-	err = 0;
+	if (delete)
+		xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
+			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
 
-	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
-	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
+		if (err)
+			goto out;
+		c.seq = hdr->sadb_msg_seq;
+		c.pid = hdr->sadb_msg_pid;
 		c.data.byid = 1;
 		c.event = XFRM_MSG_DELPOLICY;
 		km_policy_notify(xp, dir, &c);
@@ -2566,6 +2570,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 		err = key_pol_get_resp(sk, xp, hdr, dir);
 	}
 
+out:
 	xfrm_pol_put(xp);
 	return err;
 }


