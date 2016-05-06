From: Tyler Hicks <tyhicks@canonical.com>
Subject: [PATCH 2/2] net: Use ns_capable_noaudit() when determining net sysctl permissions
Date: Fri,  6 May 2016 18:04:14 -0500
Message-ID: <1462575854-4301-3-git-send-email-tyhicks@canonical.com>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
	"David S . Miller" <davem@davemloft.net>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/sysctl_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ed98c1f..46a71c7 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -46,7 +46,7 @@ static int net_ctl_permissions(struct ctl_table_header *head,
 	kgid_t root_gid = make_kgid(net->user_ns, 0);
 
 	/* Allow network administrator to have same access as root. */
-	if (ns_capable(net->user_ns, CAP_NET_ADMIN) ||
+	if (ns_capable_noaudit(net->user_ns, CAP_NET_ADMIN) ||
 	    uid_eq(root_uid, current_euid())) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
-- 
2.7.4
