From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 1/4] announce self after vm start
Date: Thu, 27 Oct 2011 16:48:36 +0800
Message-ID: <20111027084836.15020.11695.stgit@dhcp-8-146.nay.redhat.com>
References: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	stefanha@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This patch moves qemu_announce_self() to vm_start() and add a new
parameters to control whether sending gratuitous packet is needed.

This is bacause the following reasons:

- Gratuitous packet is also needed when we resume a stopped vm or
  successfuly load a state.
- The ability of sending gratuitous packet by guest may change the
  state of device, so we need to do it after vm is started.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 gdbstub.c   |    2 +-
 migration.c |    4 ++--
 monitor.c   |    4 ++--
 savevm.c    |    2 +-
 sysemu.h    |    2 +-
 vl.c        |    7 +++++--
 6 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/gdbstub.c b/gdbstub.c
index 4009058..5f6238e 100644
--- a/gdbstub.c
+++ b/gdbstub.c
@@ -371,7 +371,7 @@ static inline void gdb_continue(GDBState *s)
 #ifdef CONFIG_USER_ONLY
     s->running_state = 1;
 #else
-    vm_start();
+    vm_start(false);
 #endif
 }
 
diff --git a/migration.c b/migration.c
index bdca72e..8580fa7 100644
--- a/migration.c
+++ b/migration.c
@@ -90,7 +90,7 @@ void process_incoming_migration(QEMUFile *f)
     DPRINTF("successfully loaded vm state\n");
 
     if (autostart) {
-        vm_start();
+        vm_start(true);
     } else {
         runstate_set(RUN_STATE_PRELAUNCH);
     }
@@ -308,7 +308,7 @@ static void migrate_fd_put_ready(void *opaque)
         }
         if (s->state != MIG_STATE_COMPLETED) {
             if (old_vm_running) {
-                vm_start();
+                vm_start(false);
             }
         }
     }
diff --git a/monitor.c b/monitor.c
index ffda0fe..633e2de 100644
--- a/monitor.c
+++ b/monitor.c
@@ -1252,7 +1252,7 @@ static int do_cont(Monitor *mon, const QDict *qdict, QObject **ret_data)
     bdrv_iterate(encrypted_bdrv_it, &context);
     /* only resume the vm if all keys are set and valid */
     if (!context.err) {
-        vm_start();
+        vm_start(true);
         return 0;
     } else {
         return -1;
@@ -2710,7 +2710,7 @@ static void do_loadvm(Monitor *mon, const QDict *qdict)
     vm_stop(RUN_STATE_RESTORE_VM);
 
     if (load_vmstate(name) == 0 && saved_vm_running) {
-        vm_start();
+        vm_start(true);
     }
 }
 
diff --git a/savevm.c b/savevm.c
index f01838f..73ee6e2 100644
--- a/savevm.c
+++ b/savevm.c
@@ -2077,7 +2077,7 @@ void do_savevm(Monitor *mon, const QDict *qdict)
 
  the_end:
     if (saved_vm_running)
-        vm_start();
+        vm_start(false);
 }
 
 int load_vmstate(const char *name)
diff --git a/sysemu.h b/sysemu.h
index 22cd720..686f1ec 100644
--- a/sysemu.h
+++ b/sysemu.h
@@ -34,7 +34,7 @@ void vm_state_notify(int running, RunState state);
 #define VMRESET_SILENT   false
 #define VMRESET_REPORT   true
 
-void vm_start(void);
+void vm_start(bool announce);
 void vm_stop(RunState state);
 void vm_stop_force_state(RunState state);
 
diff --git a/vl.c b/vl.c
index 1ddb17b..e216966 100644
--- a/vl.c
+++ b/vl.c
@@ -1253,7 +1253,7 @@ void vm_state_notify(int running, RunState state)
     }
 }
 
-void vm_start(void)
+void vm_start(bool announce)
 {
     if (!runstate_is_running()) {
         cpu_enable_ticks();
@@ -1261,6 +1261,9 @@ void vm_start(void)
         vm_state_notify(1, RUN_STATE_RUNNING);
         resume_all_vcpus();
         monitor_protocol_event(QEVENT_RESUME, NULL);
+        if (announce) {
+            qemu_announce_self();
+        }
     }
 }
 
@@ -3440,7 +3443,7 @@ int main(int argc, char **argv, char **envp)
             exit(ret);
         }
     } else if (autostart) {
-        vm_start();
+        vm_start(false);
     }
 
     os_setup_post();
