From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 1/4] announce self after vm start
Date: Sat, 22 Oct 2011 13:38:37 +0800
Message-ID: <20111022053837.21526.60734.stgit@dhcp-8-146.nay.redhat.com>
References: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
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

We send gratituous packets to let switch to update its mac address
table, this is only done after migration currently because guest may
move to the host with another port connect to switch.

Unfortunately this kind of notification is also needed for continue a
stopped vm as the mac address table entry may not existed because of
aging. This patch solve this by call qemu_announce_self() in
vm_start() instead of in process_incoming_migration(). Through this,
gratituous packets were sent each time when vm starts.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 migration.c |    1 -
 vl.c        |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/migration.c b/migration.c
index 77a51ad..3326b02 100644
--- a/migration.c
+++ b/migration.c
@@ -67,7 +67,6 @@ void process_incoming_migration(QEMUFile *f)
         fprintf(stderr, "load of migration failed\n");
         exit(0);
     }
-    qemu_announce_self();
     DPRINTF("successfully loaded vm state\n");
 
     if (autostart) {
diff --git a/vl.c b/vl.c
index dbf7778..e4408e0 100644
--- a/vl.c
+++ b/vl.c
@@ -1262,6 +1262,7 @@ void vm_start(void)
         vm_state_notify(1, RUN_STATE_RUNNING);
         resume_all_vcpus();
         monitor_protocol_event(QEVENT_RESUME, NULL);
+        qemu_announce_self();
     }
 }
 
