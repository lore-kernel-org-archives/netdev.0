From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 7/10][DCCP]: Use kmemdup
Date: Fri, 17 Nov 2006 13:18:59 -0200
Message-ID: <20061117151859.GH17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:52622 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755708AbWKQPTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:19:10 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/dccp.ko.before /tmp/dccp.ko.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/dccp/feat.c:
  __dccp_feat_init      |  -16
  dccp_feat_change_recv |  -55
  dccp_feat_clone       |  -56
 3 functions changed, 127 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/feat.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 12cde2f..e808c41 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -286,12 +286,11 @@ static int dccp_feat_nn(struct sock *sk,
 	if (opt == NULL)
 		return -ENOMEM;
 
-	copy = kmalloc(len, GFP_ATOMIC);
+	copy = kmemdup(val, len, GFP_ATOMIC);
 	if (copy == NULL) {
 		kfree(opt);
 		return -ENOMEM;
 	}
-	memcpy(copy, val, len);
 
 	opt->dccpop_type = DCCPO_CONFIRM_R; /* NN can only confirm R */
 	opt->dccpop_feat = feature;
@@ -521,20 +520,18 @@ int dccp_feat_clone(struct sock *oldsk, 
 	list_for_each_entry(opt, &olddmsk->dccpms_pending, dccpop_node) {
 		struct dccp_opt_pend *newopt;
 		/* copy the value of the option */
-		u8 *val = kmalloc(opt->dccpop_len, GFP_ATOMIC);
+		u8 *val = kmemdup(opt->dccpop_val, opt->dccpop_len, GFP_ATOMIC);
 
 		if (val == NULL)
 			goto out_clean;
-		memcpy(val, opt->dccpop_val, opt->dccpop_len);
 
-		newopt = kmalloc(sizeof(*newopt), GFP_ATOMIC);
+		newopt = kmemdup(opt, sizeof(*newopt), GFP_ATOMIC);
 		if (newopt == NULL) {
 			kfree(val);
 			goto out_clean;
 		}
 
 		/* insert the option */
-		memcpy(newopt, opt, sizeof(*newopt));
 		newopt->dccpop_val = val;
 		list_add_tail(&newopt->dccpop_node, &newdmsk->dccpms_pending);
 
@@ -565,10 +562,9 @@ static int __dccp_feat_init(struct dccp_
 			    u8 *val, u8 len)
 {
 	int rc = -ENOMEM;
-	u8 *copy = kmalloc(len, GFP_KERNEL);
+	u8 *copy = kmemdup(val, len, GFP_KERNEL);
 
 	if (copy != NULL) {
-		memcpy(copy, val, len);
 		rc = dccp_feat_change(dmsk, type, feat, copy, len, GFP_KERNEL);
 		if (rc)
 			kfree(copy);
-- 
1.4.2.1.g3d5c

