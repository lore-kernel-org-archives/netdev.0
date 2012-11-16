From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 06/17] net: Update the per network namespace sysctls
	to be available to the network namespace owner
Date: Fri, 16 Nov 2012 05:03:01 -0800
Message-ID: <1353070992-5552-6-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

- Allow anyone with CAP_NET_ADMIN rights in the user namespace of the
  the netowrk namespace to change sysctls.
- Allow anyone the uid of the user namespace root the same
  permissions over the network namespace sysctls as the global root.
- Allow anyone with gid of the user namespace root group the same
  permissions over the network namespace sysctl as the global root group.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sysctl_net.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index e98f393..6410436 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -41,11 +41,21 @@ static int is_seen(struct ctl_table_set *set)
 static int net_ctl_permissions(struct ctl_table_header *head,
 			       struct ctl_table *table)
 {
+	struct net *net = container_of(head->set, struct net, sysctls);
+	kuid_t root_uid = make_kuid(net->user_ns, 0);
+	kgid_t root_gid = make_kgid(net->user_ns, 0);
+
 	/* Allow network administrator to have same access as root. */
-	if (capable(CAP_NET_ADMIN)) {
+	if (ns_capable(net->user_ns, CAP_NET_ADMIN) ||
+	    uid_eq(root_uid, current_uid())) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
 	}
+	/* Allow netns root group to have the same assess as the root group */
+	if (gid_eq(root_gid, current_gid())) {
+		int mode = (table->mode >> 3) & 7;
+		return (mode << 3) | (mode << 3) | mode;
+	}
 	return table->mode;
 }
 
-- 
1.7.5.4
