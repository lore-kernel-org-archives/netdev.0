From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 18/21] userns xt_recent: Specify the owner/group of
	ip_list_perms in the initial user namespace
Date: Mon, 13 Aug 2012 13:18:32 -0700
Message-ID: <1344889115-21610-18-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
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

xt_recent creates a bunch of proc files and initializes their uid
and gids to the values of ip_list_uid and ip_list_gid.  When
initialize those proc files convert those values to kuids so they
can continue to reside on the /proc inode.

Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig              |    1 -
 net/netfilter/xt_recent.c |   13 +++++++++++--
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index c8911eb..40f5020 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -944,7 +944,6 @@ config UIDGID_CONVERTED
 	# Networking
 	depends on NET_9P = n
 	depends on NETFILTER_XT_MATCH_OWNER = n
-	depends on NETFILTER_XT_MATCH_RECENT = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
 	depends on DNS_RESOLVER = n
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index ae2ad1e..4635c9b 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -317,6 +317,8 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	struct recent_table *t;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
+	kuid_t uid;
+	kgid_t gid;
 #endif
 	unsigned int i;
 	int ret = -EINVAL;
@@ -372,6 +374,13 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	for (i = 0; i < ip_list_hash_size; i++)
 		INIT_LIST_HEAD(&t->iphash[i]);
 #ifdef CONFIG_PROC_FS
+	uid = make_kuid(&init_user_ns, ip_list_uid);
+	gid = make_kgid(&init_user_ns, ip_list_gid);
+	if (!uid_valid(uid) || !gid_valid(gid)) {
+		kfree(t);
+		ret = -EINVAL;
+		goto out;
+	}
 	pde = proc_create_data(t->name, ip_list_perms, recent_net->xt_recent,
 		  &recent_mt_fops, t);
 	if (pde == NULL) {
@@ -379,8 +388,8 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		ret = -ENOMEM;
 		goto out;
 	}
-	pde->uid = ip_list_uid;
-	pde->gid = ip_list_gid;
+	pde->uid = uid;
+	pde->gid = gid;
 #endif
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &recent_net->tables);
-- 
1.7.5.4
