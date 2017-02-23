From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] netfilter: ctnetlink: Fix regression in CTA_HELP processing
Date: Thu, 23 Feb 2017 12:14:04 +0100
Message-ID: <1487848449-2731-4-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kevin Cernekee <cernekee@chromium.org>

Prior to Linux 4.4, it was usually harmless to send a CTA_HELP attribute
containing the name of the current helper.  That is no longer the case:
as of Linux 4.4, if ctnetlink_change_helper() returns an error from
the ct->master check, processing of the request will fail, skipping the
NFQA_EXP attribute (if present).

This patch changes the behavior to improve compatibility with user
programs that expect the kernel interface to work the way it did prior
to Linux 4.4.  If a user program specifies CTA_HELP but the argument
matches the current conntrack helper name, ignore it instead of generating
an error.

Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index bf04b7e9d6f7..6806b5e73567 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1478,14 +1478,23 @@ static int ctnetlink_change_helper(struct nf_conn *ct,
 	struct nlattr *helpinfo = NULL;
 	int err;
 
-	/* don't change helper of sibling connections */
-	if (ct->master)
-		return -EBUSY;
-
 	err = ctnetlink_parse_help(cda[CTA_HELP], &helpname, &helpinfo);
 	if (err < 0)
 		return err;
 
+	/* don't change helper of sibling connections */
+	if (ct->master) {
+		/* If we try to change the helper to the same thing twice,
+		 * treat the second attempt as a no-op instead of returning
+		 * an error.
+		 */
+		if (help && help->helper &&
+		    !strcmp(help->helper->name, helpname))
+			return 0;
+		else
+			return -EBUSY;
+	}
+
 	if (!strcmp(helpname, "")) {
 		if (help && help->helper) {
 			/* we had a helper before ... */
-- 
2.1.4

