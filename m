From: Santosh Shilimkar <ssantosh@kernel.org>
Subject: [PATCH] softirq: fix tasklet_kill() and its users
Date: Wed, 24 Aug 2016 18:52:30 -0700
Message-ID: <1472089950-2724-1-git-send-email-ssantosh@kernel.org>
Cc: santosh.shilimkar@oracle.com, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        Santosh Shilimkar <ssantosh@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Tadeusz Struk <tadeusz.struk@intel.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Paul Bolle <pebolle@tiscali.nl>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Karsten Keil <isdn@linux-pingi.de>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Semantically the expectation from the tasklet init/kill API
should be as below.

tasklet_init() == Init and Enable scheduling
tasklet_kill() == Disable scheduling and Destroy

tasklet_init() API exibit above behavior but not the
tasklet_kill(). The tasklet handler can still get scheduled
and run even after the tasklet_kill().

There are 2, 3 places where drivers are working around
this issue by calling tasklet_disable() which will add an
usecount and there by avoiding the handlers being called.

tasklet_enable/tasklet_disable is a pair API and expected
to be used together. Usage of tasklet_disable() *just* to
workround tasklet scheduling after kill is probably not the
correct and inteded use of the API as done the API.
We also happen to see similar issue where in shutdown path
the tasklet_handler was getting called even after the
tasklet_kill().

We fix this be making sure tasklet_kill() does right
thing and there by ensuring tasklet handler won't run after
tasklet_kil() with very simple change. Patch fixes the tasklet
code and also few drivers workarounds.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tadeusz Struk <tadeusz.struk@intel.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Giovanni Cabiddu <giovanni.cabiddu@intel.com>
Cc: Salvatore Benedetto <salvatore.benedetto@intel.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
---
Removed RFC tag from last post and dropped atmel serial
driver which seems to have been fixed in 4.8

https://lkml.org/lkml/2016/8/7/7

 drivers/crypto/qat/qat_common/adf_isr.c    | 1 -
 drivers/crypto/qat/qat_common/adf_sriov.c  | 1 -
 drivers/crypto/qat/qat_common/adf_vf_isr.c | 2 --
 drivers/isdn/gigaset/interface.c           | 1 -
 kernel/softirq.c                           | 7 ++++---
 5 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/crypto/qat/qat_common/adf_isr.c b/drivers/crypto/qat/qat_common/adf_isr.c
index 06d4901..fd5e900 100644
--- a/drivers/crypto/qat/qat_common/adf_isr.c
+++ b/drivers/crypto/qat/qat_common/adf_isr.c
@@ -296,7 +296,6 @@ static void adf_cleanup_bh(struct adf_accel_dev *accel_dev)
 	int i;
 
 	for (i = 0; i < hw_data->num_banks; i++) {
-		tasklet_disable(&priv_data->banks[i].resp_handler);
 		tasklet_kill(&priv_data->banks[i].resp_handler);
 	}
 }
diff --git a/drivers/crypto/qat/qat_common/adf_sriov.c b/drivers/crypto/qat/qat_common/adf_sriov.c
index 9320ae1..bc7c2fa 100644
--- a/drivers/crypto/qat/qat_common/adf_sriov.c
+++ b/drivers/crypto/qat/qat_common/adf_sriov.c
@@ -204,7 +204,6 @@ void adf_disable_sriov(struct adf_accel_dev *accel_dev)
 	}
 
 	for (i = 0, vf = accel_dev->pf.vf_info; i < totalvfs; i++, vf++) {
-		tasklet_disable(&vf->vf2pf_bh_tasklet);
 		tasklet_kill(&vf->vf2pf_bh_tasklet);
 		mutex_destroy(&vf->pf2vf_lock);
 	}
diff --git a/drivers/crypto/qat/qat_common/adf_vf_isr.c b/drivers/crypto/qat/qat_common/adf_vf_isr.c
index bf99e11..6e38bff 100644
--- a/drivers/crypto/qat/qat_common/adf_vf_isr.c
+++ b/drivers/crypto/qat/qat_common/adf_vf_isr.c
@@ -191,7 +191,6 @@ static int adf_setup_pf2vf_bh(struct adf_accel_dev *accel_dev)
 
 static void adf_cleanup_pf2vf_bh(struct adf_accel_dev *accel_dev)
 {
-	tasklet_disable(&accel_dev->vf.pf2vf_bh_tasklet);
 	tasklet_kill(&accel_dev->vf.pf2vf_bh_tasklet);
 	mutex_destroy(&accel_dev->vf.vf2pf_lock);
 }
@@ -268,7 +267,6 @@ static void adf_cleanup_bh(struct adf_accel_dev *accel_dev)
 {
 	struct adf_etr_data *priv_data = accel_dev->transport;
 
-	tasklet_disable(&priv_data->banks[0].resp_handler);
 	tasklet_kill(&priv_data->banks[0].resp_handler);
 }
 
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 600c79b..2ce63b6 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -524,7 +524,6 @@ void gigaset_if_free(struct cardstate *cs)
 	if (!drv->have_tty)
 		return;
 
-	tasklet_disable(&cs->if_wake_tasklet);
 	tasklet_kill(&cs->if_wake_tasklet);
 	cs->tty_dev = NULL;
 	tty_unregister_device(drv->tty, cs->minor_index);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 17caf4b..21397eb 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -498,7 +498,7 @@ static void tasklet_action(struct softirq_action *a)
 		list = list->next;
 
 		if (tasklet_trylock(t)) {
-			if (!atomic_read(&t->count)) {
+			if (atomic_read(&t->count) == 1) {
 				if (!test_and_clear_bit(TASKLET_STATE_SCHED,
 							&t->state))
 					BUG();
@@ -534,7 +534,7 @@ static void tasklet_hi_action(struct softirq_action *a)
 		list = list->next;
 
 		if (tasklet_trylock(t)) {
-			if (!atomic_read(&t->count)) {
+			if (atomic_read(&t->count) == 1) {
 				if (!test_and_clear_bit(TASKLET_STATE_SCHED,
 							&t->state))
 					BUG();
@@ -559,7 +559,7 @@ void tasklet_init(struct tasklet_struct *t,
 {
 	t->next = NULL;
 	t->state = 0;
-	atomic_set(&t->count, 0);
+	atomic_set(&t->count, 1);
 	t->func = func;
 	t->data = data;
 }
@@ -576,6 +576,7 @@ void tasklet_kill(struct tasklet_struct *t)
 		} while (test_bit(TASKLET_STATE_SCHED, &t->state));
 	}
 	tasklet_unlock_wait(t);
+	atomic_dec(&t->count);
 	clear_bit(TASKLET_STATE_SCHED, &t->state);
 }
 EXPORT_SYMBOL(tasklet_kill);
-- 
1.9.1
