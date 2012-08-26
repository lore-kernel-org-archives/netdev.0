From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 09/15] userns: Convert process event connector to handle kuids and kgids
Date: Sat, 25 Aug 2012 17:02:59 -0700
Message-ID: <877gsmfrkc.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: David Miller <davem@davemloft.net>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Only allow asking for events from the initial user and pid namespace,
  where we generate the events in.

- Convert kuids and kgids into the initial user namespace to report
  them via the process event connector.

Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: David Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/connector/cn_proc.c |   18 ++++++++++++++----
 init/Kconfig                |    1 -
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 3e92b7d..fce2000 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -30,6 +30,7 @@
 #include <linux/gfp.h>
 #include <linux/ptrace.h>
 #include <linux/atomic.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/unaligned.h>
 
@@ -127,11 +128,11 @@ void proc_id_connector(struct task_struct *task, int which_id)
 	rcu_read_lock();
 	cred = __task_cred(task);
 	if (which_id == PROC_EVENT_UID) {
-		ev->event_data.id.r.ruid = cred->uid;
-		ev->event_data.id.e.euid = cred->euid;
+		ev->event_data.id.r.ruid = from_kuid_munged(&init_user_ns, cred->uid);
+		ev->event_data.id.e.euid = from_kuid_munged(&init_user_ns, cred->euid);
 	} else if (which_id == PROC_EVENT_GID) {
-		ev->event_data.id.r.rgid = cred->gid;
-		ev->event_data.id.e.egid = cred->egid;
+		ev->event_data.id.r.rgid = from_kgid_munged(&init_user_ns, cred->gid);
+		ev->event_data.id.e.egid = from_kgid_munged(&init_user_ns, cred->egid);
 	} else {
 		rcu_read_unlock();
 		return;
@@ -303,6 +304,15 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 	if (msg->len != sizeof(*mc_op))
 		return;
 
+	/* 
+	 * Events are reported with respect to the initial pid
+	 * and user namespaces so ignore requestors from
+	 * other namespaces.
+	 */
+	if ((current_user_ns() != &init_user_ns) ||
+	    (task_active_pid_ns(current) != &init_pid_ns))
+		return;
+
 	mc_op = (enum proc_cn_mcast_op *)msg->data;
 	switch (*mc_op) {
 	case PROC_CN_MCAST_LISTEN:
diff --git a/init/Kconfig b/init/Kconfig
index 6c9d004..7327869 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -932,7 +932,6 @@ config UIDGID_CONVERTED
 	depends on QUOTA = n
 	depends on QUOTACTL = n
 	depends on DRM = n
-	depends on PROC_EVENTS = n
 
 	# Networking
 	depends on NET_9P = n
-- 
1.7.5.4
