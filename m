From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/21] net ip6 flowlabel: Make owner a union of struct pid *
	and kuid_t
Date: Mon, 13 Aug 2012 13:18:22 -0700
Message-ID: <1344889115-21610-8-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Correct a long standing omission and use struct pid in the owner
field of struct ip6_flowlabel when the share type is IPV6_FL_S_PROCESS.
This guarantees we don't have issues when pid wraparound occurs.

Use a kuid_t in the owner field of struct ip6_flowlabel when the
share type is IPV6_FL_S_USER to add user namespace support.

In /proc/net/ip6_flowlabel capture the current pid namespace when
opening the file and release the pid namespace when the file is
closed ensuring we print the pid owner value that is meaning to
the reader of the file.  Similarly use from_kuid_munged to print
uid values that are meaningful to the reader of the file.

This requires exporting pid_nr_ns so that ipv6 can continue to built
as a module.  Yoiks what silliness

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/ipv6.h       |    5 +++-
 init/Kconfig             |    1 -
 kernel/pid.c             |    1 +
 net/ipv6/ip6_flowlabel.c |   50 +++++++++++++++++++++++++++++++++++++++------
 4 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 01c34b3..c8a2024 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -222,7 +222,10 @@ struct ip6_flowlabel {
 	struct ipv6_txoptions	*opt;
 	unsigned long		linger;
 	u8			share;
-	u32			owner;
+	union {
+		struct pid *pid;
+		kuid_t uid;
+	} owner;
 	unsigned long		lastuse;
 	unsigned long		expires;
 	struct net		*fl_net;
diff --git a/init/Kconfig b/init/Kconfig
index f857f97..64ff9ce 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -948,7 +948,6 @@ config UIDGID_CONVERTED
 	depends on NETFILTER_XT_MATCH_RECENT = n
 	depends on NETFILTER_XT_TARGET_LOG = n
 	depends on NETFILTER_NETLINK_LOG = n
-	depends on IPV6 = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
 	depends on INET_DIAG = n
diff --git a/kernel/pid.c b/kernel/pid.c
index e86b291a..aebd4f5 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -479,6 +479,7 @@ pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
 	}
 	return nr;
 }
+EXPORT_SYMBOL_GPL(pid_nr_ns);
 
 pid_t pid_vnr(struct pid *pid)
 {
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 9772fbd..c836a6a 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -22,6 +22,7 @@
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/pid_namespace.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -90,6 +91,11 @@ static struct ip6_flowlabel *fl_lookup(struct net *net, __be32 label)
 
 static void fl_free(struct ip6_flowlabel *fl)
 {
+	switch (fl->share) {
+	case IPV6_FL_S_PROCESS:
+		put_pid(fl->owner.pid);
+		break;
+	}
 	if (fl) {
 		release_net(fl->fl_net);
 		kfree(fl->opt);
@@ -394,10 +400,10 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 	case IPV6_FL_S_ANY:
 		break;
 	case IPV6_FL_S_PROCESS:
-		fl->owner = current->pid;
+		fl->owner.pid = get_task_pid(current, PIDTYPE_PID);
 		break;
 	case IPV6_FL_S_USER:
-		fl->owner = current_euid();
+		fl->owner.uid = current_euid();
 		break;
 	default:
 		err = -EINVAL;
@@ -561,7 +567,10 @@ recheck:
 				err = -EPERM;
 				if (fl1->share == IPV6_FL_S_EXCL ||
 				    fl1->share != fl->share ||
-				    fl1->owner != fl->owner)
+				    ((fl1->share == IPV6_FL_S_PROCESS) &&
+				     (fl1->owner.pid == fl->owner.pid)) ||
+				    ((fl1->share == IPV6_FL_S_USER) &&
+				     uid_eq(fl1->owner.uid, fl->owner.uid)))
 					goto release;
 
 				err = -EINVAL;
@@ -621,6 +630,7 @@ done:
 
 struct ip6fl_iter_state {
 	struct seq_net_private p;
+	struct pid_namespace *pid_ns;
 	int bucket;
 };
 
@@ -699,6 +709,7 @@ static void ip6fl_seq_stop(struct seq_file *seq, void *v)
 
 static int ip6fl_seq_show(struct seq_file *seq, void *v)
 {
+	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
 			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
@@ -708,7 +719,11 @@ static int ip6fl_seq_show(struct seq_file *seq, void *v)
 			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
 			   (unsigned int)ntohl(fl->label),
 			   fl->share,
-			   (int)fl->owner,
+			   ((fl->share == IPV6_FL_S_PROCESS) ?
+			    pid_nr_ns(fl->owner.pid, state->pid_ns) :
+			    ((fl->share == IPV6_FL_S_USER) ?
+			     from_kuid_munged(seq_user_ns(seq), fl->owner.uid) :
+			     0)),
 			   atomic_read(&fl->users),
 			   fl->linger/HZ,
 			   (long)(fl->expires - jiffies)/HZ,
@@ -727,8 +742,29 @@ static const struct seq_operations ip6fl_seq_ops = {
 
 static int ip6fl_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_net(inode, file, &ip6fl_seq_ops,
-			    sizeof(struct ip6fl_iter_state));
+	struct seq_file *seq;
+	struct ip6fl_iter_state *state;
+	int err;
+
+	err = seq_open_net(inode, file, &ip6fl_seq_ops,
+			   sizeof(struct ip6fl_iter_state));
+
+	if (!err) {
+		seq = file->private_data;
+		state = ip6fl_seq_private(seq);
+		rcu_read_lock();
+		state->pid_ns = get_pid_ns(task_active_pid_ns(current));
+		rcu_read_unlock();
+	}
+	return err;
+}
+
+static int ip6fl_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
+	put_pid_ns(state->pid_ns);
+	return seq_release_net(inode, file);
 }
 
 static const struct file_operations ip6fl_seq_fops = {
@@ -736,7 +772,7 @@ static const struct file_operations ip6fl_seq_fops = {
 	.open		=	ip6fl_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_net,
+	.release	=	ip6fl_seq_release,
 };
 
 static int __net_init ip6_flowlabel_proc_init(struct net *net)
-- 
1.7.5.4
