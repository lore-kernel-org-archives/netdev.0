From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/28] proc: Supply PDE attribute setting accessor functions
 [RFC]
Date: Tue, 16 Apr 2013 19:26:06 +0100
Message-ID: <20130416182606.27773.55054.stgit@warthog.procyon.org.uk>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-pci@vger.kernel.org,
 linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org,
 viro@zeniv.linux.org.uk, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Supply accessor functions to set attributes in proc_dir_entry structs.

The following are supplied: proc_set_size() and proc_set_user().

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linuxppc-dev@lists.ozlabs.org
cc: linux-media@vger.kernel.org
cc: netdev@vger.kernel.org
cc: linux-wireless@vger.kernel.org
cc: linux-pci@vger.kernel.org
cc: netfilter-devel@vger.kernel.org
cc: alsa-devel@alsa-project.org
---

 arch/powerpc/kernel/proc_powerpc.c        |    2 +-
 arch/powerpc/platforms/pseries/reconfig.c |    2 +-
 drivers/media/pci/ttpci/av7110_ir.c       |    2 +-
 drivers/net/irda/vlsi_ir.c                |    2 +-
 drivers/net/wireless/airo.c               |   34 +++++++++--------------------
 drivers/pci/proc.c                        |    2 +-
 fs/proc/generic.c                         |   13 +++++++++++
 include/linux/proc_fs.h                   |    5 ++++
 kernel/configs.c                          |    2 +-
 kernel/profile.c                          |    2 +-
 net/netfilter/xt_recent.c                 |    3 +--
 sound/core/info.c                         |    2 +-
 12 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
index 41d8ee9..feb8580 100644
--- a/arch/powerpc/kernel/proc_powerpc.c
+++ b/arch/powerpc/kernel/proc_powerpc.c
@@ -83,7 +83,7 @@ static int __init proc_ppc64_init(void)
 			       &page_map_fops, vdso_data);
 	if (!pde)
 		return 1;
-	pde->size = PAGE_SIZE;
+	proc_set_size(pde, PAGE_SIZE);
 
 	return 0;
 }
diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index d6491bd..f93cdf5 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -452,7 +452,7 @@ static int proc_ppc64_create_ofdt(void)
 
 	ent = proc_create("powerpc/ofdt", S_IWUSR, NULL, &ofdt_fops);
 	if (ent)
-		ent->size = 0;
+		proc_set_size(ent, 0);
 
 	return 0;
 }
diff --git a/drivers/media/pci/ttpci/av7110_ir.c b/drivers/media/pci/ttpci/av7110_ir.c
index eb82286..0e763a7 100644
--- a/drivers/media/pci/ttpci/av7110_ir.c
+++ b/drivers/media/pci/ttpci/av7110_ir.c
@@ -375,7 +375,7 @@ int av7110_ir_init(struct av7110 *av7110)
 	if (av_cnt == 1) {
 		e = proc_create("av7110_ir", S_IWUSR, NULL, &av7110_ir_proc_fops);
 		if (e)
-			e->size = 4 + 256 * sizeof(u16);
+			proc_set_size(e, 4 + 256 * sizeof(u16));
 	}
 
 	tasklet_init(&av7110->ir.ir_tasklet, av7110_emit_key, (unsigned long) &av7110->ir);
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index e22cd4e..5f47584 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1678,7 +1678,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 			IRDA_WARNING("%s: failed to create proc entry\n",
 				     __func__);
 		} else {
-			ent->size = 0;
+			proc_set_size(ent, 0);
 		}
 		idev->proc_entry = ent;
 	}
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 66e398d..21d0233 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -4507,73 +4507,63 @@ static int setup_proc_entry( struct net_device *dev,
 					    airo_entry);
 	if (!apriv->proc_entry)
 		goto fail;
-	apriv->proc_entry->uid = proc_kuid;
-	apriv->proc_entry->gid = proc_kgid;
+	proc_set_user(apriv->proc_entry, proc_kuid, proc_kgid);
 
 	/* Setup the StatsDelta */
 	entry = proc_create_data("StatsDelta", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_statsdelta_ops, dev);
 	if (!entry)
 		goto fail_stats_delta;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the Stats */
 	entry = proc_create_data("Stats", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_stats_ops, dev);
 	if (!entry)
 		goto fail_stats;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the Status */
 	entry = proc_create_data("Status", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_status_ops, dev);
 	if (!entry)
 		goto fail_status;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the Config */
 	entry = proc_create_data("Config", proc_perm,
 				 apriv->proc_entry, &proc_config_ops, dev);
 	if (!entry)
 		goto fail_config;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the SSID */
 	entry = proc_create_data("SSID", proc_perm,
 				 apriv->proc_entry, &proc_SSID_ops, dev);
 	if (!entry)
 		goto fail_ssid;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the APList */
 	entry = proc_create_data("APList", proc_perm,
 				 apriv->proc_entry, &proc_APList_ops, dev);
 	if (!entry)
 		goto fail_aplist;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the BSSList */
 	entry = proc_create_data("BSSList", proc_perm,
 				 apriv->proc_entry, &proc_BSSList_ops, dev);
 	if (!entry)
 		goto fail_bsslist;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
+	proc_set_user(entry, proc_kuid, proc_kgid);
 
 	/* Setup the WepKey */
 	entry = proc_create_data("WepKey", proc_perm,
 				 apriv->proc_entry, &proc_wepkey_ops, dev);
 	if (!entry)
 		goto fail_wepkey;
-	entry->uid = proc_kuid;
-	entry->gid = proc_kgid;
-
+	proc_set_user(entry, proc_kuid, proc_kgid);
 	return 0;
 
 fail_wepkey:
@@ -5695,10 +5685,8 @@ static int __init airo_init_module( void )
 
 	airo_entry = proc_mkdir_mode("driver/aironet", airo_perm, NULL);
 
-	if (airo_entry) {
-		airo_entry->uid = proc_kuid;
-		airo_entry->gid = proc_kgid;
-	}
+	if (airo_entry)
+		proc_set_user(airo_entry, proc_kuid, proc_kgid);
 
 	for (i = 0; i < 4 && io[i] && irq[i]; i++) {
 		airo_print_info("", "Trying to configure ISA adapter at irq=%d "
diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 12e4fb5..7cde7c1 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -419,7 +419,7 @@ int pci_proc_attach_device(struct pci_dev *dev)
 			     &proc_bus_pci_operations, dev);
 	if (!e)
 		return -ENOMEM;
-	e->size = dev->cfg_size;
+	proc_set_size(e, dev->cfg_size);
 	dev->procent = e;
 
 	return 0;
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 1c07cad..5f6f6c3 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -498,6 +498,19 @@ out:
 	return NULL;
 }
 EXPORT_SYMBOL(proc_create_data);
+ 
+void proc_set_size(struct proc_dir_entry *de, loff_t size)
+{
+	de->size = size;
+}
+EXPORT_SYMBOL(proc_set_size);
+
+void proc_set_user(struct proc_dir_entry *de, kuid_t uid, kgid_t gid)
+{
+	de->uid = uid;
+	de->gid = gid;
+}
+EXPORT_SYMBOL(proc_set_user);
 
 static void free_proc_entry(struct proc_dir_entry *de)
 {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 805edac..28a4d7e 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -130,6 +130,9 @@ static inline struct proc_dir_entry *proc_create(const char *name, umode_t mode,
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
+extern void proc_set_size(struct proc_dir_entry *, loff_t);
+extern void proc_set_user(struct proc_dir_entry *, kuid_t, kgid_t);
+
 extern struct file *proc_ns_fget(int fd);
 extern bool proc_ns_inode(struct inode *inode);
 
@@ -158,6 +161,8 @@ static inline struct proc_dir_entry *proc_mkdir(const char *name,
 	struct proc_dir_entry *parent) {return NULL;}
 static inline struct proc_dir_entry *proc_mkdir_mode(const char *name,
 	umode_t mode, struct proc_dir_entry *parent) { return NULL; }
+static inline void proc_set_size(struct proc_dir_entry *de, loff_t size) {}
+static inline void proc_set_user(struct proc_dir_entry *de, kuid_t uid, kgid_t gid) {}
 
 struct tty_driver;
 static inline void proc_tty_register_driver(struct tty_driver *driver) {};
diff --git a/kernel/configs.c b/kernel/configs.c
index 42e8fa0..c18b1f1 100644
--- a/kernel/configs.c
+++ b/kernel/configs.c
@@ -79,7 +79,7 @@ static int __init ikconfig_init(void)
 	if (!entry)
 		return -ENOMEM;
 
-	entry->size = kernel_config_data_size;
+	proc_set_size(entry, kernel_config_data_size);
 
 	return 0;
 }
diff --git a/kernel/profile.c b/kernel/profile.c
index 524ce5e..0bf4007 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -600,7 +600,7 @@ int __ref create_proc_profile(void) /* false positive from hotcpu_notifier */
 			    NULL, &proc_profile_operations);
 	if (!entry)
 		return 0;
-	entry->size = (1+prof_len) * sizeof(atomic_t);
+	proc_set_size(entry, (1 + prof_len) * sizeof(atomic_t));
 	hotcpu_notifier(profile_cpu_callback, 0);
 	return 0;
 }
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 3db2d38..1e657cf 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -401,8 +401,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		ret = -ENOMEM;
 		goto out;
 	}
-	pde->uid = uid;
-	pde->gid = gid;
+	proc_set_user(pde, uid, gid);
 #endif
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &recent_net->tables);
diff --git a/sound/core/info.c b/sound/core/info.c
index 3aa8864..c7f41c3 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -970,7 +970,7 @@ int snd_info_register(struct snd_info_entry * entry)
 			mutex_unlock(&info_mutex);
 			return -ENOMEM;
 		}
-		p->size = entry->size;
+		proc_set_size(p, entry->size);
 	}
 	entry->p = p;
 	if (entry->parent)
