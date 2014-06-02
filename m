From: crquan@gmail.com
Subject: [PATCH] genetlink: remove superfluous assignment
Date: Mon,  2 Jun 2014 01:18:01 -0700
Message-ID: <1401697081-17093-1-git-send-email-crquan@gmail.com>
References: <1401346448-17105-1-git-send-email-crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:48268 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbaFBISP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 04:18:15 -0400
Received: by mail-pb0-f51.google.com with SMTP id ma3so3970247pbc.38
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 01:18:14 -0700 (PDT)
In-Reply-To: <1401346448-17105-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the local variable ops and n_ops were just read out from family,
and not changed, hence no need to assign back.

Validation functions should operate on const parameters and not
change anything.

Signed-off-by: Cheng Renquan <crquan@gmail.com>
---
 net/netlink/genetlink.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a3ba3ca..76393f2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -309,46 +309,42 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 
 	for (i = 0; i < family->n_mcgrps; i++) {
 		int grp_id = family->mcgrp_offset + i;
 
 		if (grp_id != 1)
 			clear_bit(grp_id, mc_groups);
 		genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, family,
 				&family->mcgrps[i], grp_id);
 	}
 }
 
-static int genl_validate_ops(struct genl_family *family)
+static int genl_validate_ops(const struct genl_family *family)
 {
 	const struct genl_ops *ops = family->ops;
 	unsigned int n_ops = family->n_ops;
 	int i, j;
 
 	if (WARN_ON(n_ops && !ops))
 		return -EINVAL;
 
 	if (!n_ops)
 		return 0;
 
 	for (i = 0; i < n_ops; i++) {
 		if (ops[i].dumpit == NULL && ops[i].doit == NULL)
 			return -EINVAL;
 		for (j = i + 1; j < n_ops; j++)
 			if (ops[i].cmd == ops[j].cmd)
 				return -EINVAL;
 	}
 
-	/* family is not registered yet, so no locking needed */
-	family->ops = ops;
-	family->n_ops = n_ops;
-
 	return 0;
 }
 
 /**
  * __genl_register_family - register a generic netlink family
  * @family: generic netlink family
  *
  * Registers the specified family after validating it first. Only one
  * family may be registered with the same family name or identifier.
  * The family id may equal GENL_ID_GENERATE causing an unique id to
  * be automatically generated and assigned.
