From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH] net: Use ns_capable_noaudit() when determining net sysctl
 permissions
Date: Fri, 30 Sep 2016 15:24:31 -0700
Message-ID: <20160930222431.GA30208@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tyler Hicks <tyhicks@canonical.com>,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        James Morris <james.l.morris@oracle.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36594 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932687AbcI3WYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 18:24:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tyler Hicks <tyhicks@canonical.com>

The capability check should not be audited since it is only being used
to determine the inode permissions. A failed check does not indicate a
violation of security policy but, when an LSM is enabled, a denial audit
message was being generated.

The denial audit message caused confusion for some application authors
because root-running Go applications always triggered the denial. To
prevent this confusion, the capability check in net_ctl_permissions() is
switched to the noaudit variant.

BugLink: https://launchpad.net/bugs/1465724

Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
Signed-off-by: James Morris <james.l.morris@oracle.com>
[dtor: reapplied after e79c6a4fc923 ("net: make net namespace sysctls
belong to container's owner") accidentally reverted the change.]
Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 net/sysctl_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index c5d37f4..9199813 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -44,7 +44,7 @@ static int net_ctl_permissions(struct ctl_table_header *head,
 	struct net *net = container_of(head->set, struct net, sysctls);
 
 	/* Allow network administrator to have same access as root. */
-	if (ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+	if (ns_capable_noaudit(net->user_ns, CAP_NET_ADMIN)) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
 	}
-- 
2.8.0.rc3.226.g39d4020


-- 
Dmitry
