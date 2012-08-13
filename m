From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 19/21] userns: xt_owner: Add basic user namespace support.
Date: Mon, 13 Aug 2012 13:18:33 -0700
Message-ID: <1344889115-21610-19-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Only allow adding matches from the initial user namespace
- Add the appropriate conversion functions to handle matches
  against sockets in other user namespaces.

Cc: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig             |    1 -
 net/netfilter/xt_owner.c |   30 ++++++++++++++++++++++++------
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 40f5020..76ffca9 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -943,7 +943,6 @@ config UIDGID_CONVERTED
 
 	# Networking
 	depends on NET_9P = n
-	depends on NETFILTER_XT_MATCH_OWNER = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
 	depends on DNS_RESOLVER = n
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index 772d738..ca2e577 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -17,6 +17,17 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_owner.h>
 
+static int owner_check(const struct xt_mtchk_param *par)
+{
+	struct xt_owner_match_info *info = par->matchinfo;
+
+	/* For now only allow adding matches from the initial user namespace */
+	if ((info->match & (XT_OWNER_UID|XT_OWNER_GID)) &&
+	    (current_user_ns() != &init_user_ns))
+		return -EINVAL;
+	return 0;
+}
+
 static bool
 owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -37,17 +48,23 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return ((info->match ^ info->invert) &
 		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
 
-	if (info->match & XT_OWNER_UID)
-		if ((filp->f_cred->fsuid >= info->uid_min &&
-		    filp->f_cred->fsuid <= info->uid_max) ^
+	if (info->match & XT_OWNER_UID) {
+		kuid_t uid_min = make_kuid(&init_user_ns, info->uid_min);
+		kuid_t uid_max = make_kuid(&init_user_ns, info->uid_max);
+		if ((uid_gte(filp->f_cred->fsuid, uid_min) &&
+		     uid_lte(filp->f_cred->fsuid, uid_max)) ^
 		    !(info->invert & XT_OWNER_UID))
 			return false;
+	}
 
-	if (info->match & XT_OWNER_GID)
-		if ((filp->f_cred->fsgid >= info->gid_min &&
-		    filp->f_cred->fsgid <= info->gid_max) ^
+	if (info->match & XT_OWNER_GID) {
+		kgid_t gid_min = make_kgid(&init_user_ns, info->gid_min);
+		kgid_t gid_max = make_kgid(&init_user_ns, info->gid_max);
+		if ((gid_gte(filp->f_cred->fsgid, gid_min) &&
+		     gid_lte(filp->f_cred->fsgid, gid_max)) ^
 		    !(info->invert & XT_OWNER_GID))
 			return false;
+	}
 
 	return true;
 }
@@ -56,6 +73,7 @@ static struct xt_match owner_mt_reg __read_mostly = {
 	.name       = "owner",
 	.revision   = 1,
 	.family     = NFPROTO_UNSPEC,
+	.checkentry = owner_check,
 	.match      = owner_mt,
 	.matchsize  = sizeof(struct xt_owner_match_info),
 	.hooks      = (1 << NF_INET_LOCAL_OUT) |
-- 
1.7.5.4
