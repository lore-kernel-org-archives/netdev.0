From: Dongdong Deng <dongdong.deng@windriver.com>
Subject: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Sun, 21 Feb 2010 15:24:38 +0800
Message-ID: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dongdong.deng@windriver.com, jason.wessel@windriver.com,
	lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The param_set_fn() function will get a parameter which is a NULL
pointer when insmod module with params via following method:

$insmod module.ko module_params

BTW: the normal method usually as following format:
$insmod module.ko module_params=example

If the param_set_fn() function didn't check that parameter and used
it directly, it could caused an OOPS due to NULL pointer dereference.

The solution is simple:
Just checking the parameter before using in param_set_fn().

Example:
int set_module_params(const char *val, struct kernel_param *kp)
{
	/*Checking the val parameter before using */
	if (!val)
		return -EINVAL;
	...
}
module_param_call(module_params, set_module_params, NULL, NULL, 0644);

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
CC: Jason Wessel <jason.wessel@windriver.com>
CC: Len Brown <lenb@kernel.org>
CC: David Woodhouse <dwmw2@infradead.org>
CC: Matthew Dharm <mdharm-usb@one-eyed-alien.net>
CC: "J. Bruce Fields" <bfields@fieldses.org>
CC: Robert Richter <robert.richter@amd.com>

---
 arch/powerpc/platforms/pseries/cmm.c          |    7 ++++++-
 arch/x86/oprofile/nmi_int.c                   |    3 +++
 drivers/acpi/debug.c                          |    3 +++
 drivers/ide/ide.c                             |   13 ++++++++++++-
 drivers/infiniband/hw/ipath/ipath_init_chip.c |    3 +++
 drivers/md/md.c                               |    9 ++++++++-
 drivers/misc/kgdbts.c                         |    7 ++++++-
 drivers/mtd/devices/block2mtd.c               |    3 +++
 drivers/mtd/devices/phram.c                   |    3 +++
 drivers/pci/pcie/aspm.c                       |    3 +++
 drivers/serial/kgdboc.c                       |    7 ++++++-
 drivers/usb/storage/libusual.c                |    3 +++
 fs/lockd/svc.c                                |    5 ++++-
 fs/nfs/idmap.c                                |    9 +++++++--
 net/netfilter/nf_conntrack_core.c             |    3 +++
 net/sunrpc/svc.c                              |    3 +++
 16 files changed, 76 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/cmm.c b/arch/powerpc/platforms/pseries/cmm.c
index a277f2e..4f87813 100644
--- a/arch/powerpc/platforms/pseries/cmm.c
+++ b/arch/powerpc/platforms/pseries/cmm.c
@@ -721,7 +721,12 @@ static void cmm_exit(void)
  **/
 static int cmm_set_disable(const char *val, struct kernel_param *kp)
 {
-	int disable = simple_strtoul(val, NULL, 10);
+	int disable;
+
+	if (!val)
+		return -EINVAL;
+
+	disable = simple_strtoul(val, NULL, 10);
 
 	if (disable != 0 && disable != 1)
 		return -EINVAL;
diff --git a/arch/x86/oprofile/nmi_int.c b/arch/x86/oprofile/nmi_int.c
index 3347f69..561e2fe 100644
--- a/arch/x86/oprofile/nmi_int.c
+++ b/arch/x86/oprofile/nmi_int.c
@@ -560,6 +560,9 @@ static int __init p4_init(char **cpu_type)
 static int force_arch_perfmon;
 static int force_cpu_type(const char *str, struct kernel_param *kp)
 {
+	if (!str)
+		return -EINVAL;
+
 	if (!strcmp(str, "arch_perfmon")) {
 		force_arch_perfmon = 1;
 		printk(KERN_INFO "oprofile: forcing architectural perfmon\n");
diff --git a/drivers/acpi/debug.c b/drivers/acpi/debug.c
index cc421b7..fbceafd 100644
--- a/drivers/acpi/debug.c
+++ b/drivers/acpi/debug.c
@@ -150,6 +150,9 @@ static int param_set_trace_state(const char *val, struct kernel_param *kp)
 {
 	int result = 0;
 
+	if (!val)
+		return -EINVAL;
+
 	if (!strncmp(val, "enable", strlen("enable") - 1)) {
 		result = acpi_debug_trace(trace_method_name, trace_debug_level,
 					  trace_debug_layer, 0);
diff --git a/drivers/ide/ide.c b/drivers/ide/ide.c
index 16d0569..ce66d34 100644
--- a/drivers/ide/ide.c
+++ b/drivers/ide/ide.c
@@ -181,7 +181,12 @@ MODULE_PARM_DESC(pci_clock, "PCI bus clock frequency (in MHz)");
 static int ide_set_dev_param_mask(const char *s, struct kernel_param *kp)
 {
 	int a, b, i, j = 1;
-	unsigned int *dev_param_mask = (unsigned int *)kp->arg;
+	unsigned int *dev_param_mask;
+
+	if (!s || !kp)
+		return -EINVAL;
+
+	dev_param_mask = (unsigned int *)kp->arg;
 
 	/* controller . device (0 or 1) [ : 1 (set) | 0 (clear) ] */
 	if (sscanf(s, "%d.%d:%d", &a, &b, &j) != 3 &&
@@ -244,6 +249,9 @@ static int ide_set_disk_chs(const char *str, struct kernel_param *kp)
 {
 	int a, b, c = 0, h = 0, s = 0, i, j = 1;
 
+	if (!str)
+		return -EINVAL;
+
 	/* controller . device (0 or 1) : Cylinders , Heads , Sectors */
 	/* controller . device (0 or 1) : 1 (use CHS) | 0 (ignore CHS) */
 	if (sscanf(str, "%d.%d:%d,%d,%d", &a, &b, &c, &h, &s) != 5 &&
@@ -328,6 +336,9 @@ static int ide_set_ignore_cable(const char *s, struct kernel_param *kp)
 {
 	int i, j = 1;
 
+	if (!s)
+		return -EINVAL;
+
 	/* controller (ignore) */
 	/* controller : 1 (ignore) | 0 (use) */
 	if (sscanf(s, "%d:%d", &i, &j) != 2 && sscanf(s, "%d", &i) != 1)
diff --git a/drivers/infiniband/hw/ipath/ipath_init_chip.c b/drivers/infiniband/hw/ipath/ipath_init_chip.c
index 077879c..2e21679 100644
--- a/drivers/infiniband/hw/ipath/ipath_init_chip.c
+++ b/drivers/infiniband/hw/ipath/ipath_init_chip.c
@@ -1035,6 +1035,9 @@ static int ipath_set_kpiobufs(const char *str, struct kernel_param *kp)
 	unsigned short val;
 	int ret;
 
+	if (!str)
+		return -EINVAL;
+
 	ret = ipath_parse_ushort(str, &val);
 
 	spin_lock_irqsave(&ipath_devs_lock, flags);
diff --git a/drivers/md/md.c b/drivers/md/md.c
index a20a71e..61bc893 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -4200,9 +4200,14 @@ static int add_named_array(const char *val, struct kernel_param *kp)
 	 * We allocate an array with a large free minor number, and
 	 * set the name to val.  val must not already be an active name.
 	 */
-	int len = strlen(val);
+	int len;
 	char buf[DISK_NAME_LEN];
 
+	if (!val)
+		return -EINVAL;
+
+	len = strlen(val);
+
 	while (len && val[len-1] == '\n')
 		len--;
 	if (len >= DISK_NAME_LEN)
@@ -7177,6 +7182,8 @@ static int get_ro(char *buffer, struct kernel_param *kp)
 static int set_ro(const char *val, struct kernel_param *kp)
 {
 	char *e;
+	if (!val)
+		return -EINVAL;
 	int num = simple_strtoul(val, &e, 10);
 	if (*val && (*e == '\0' || *e == '\n')) {
 		start_readonly = num;
diff --git a/drivers/misc/kgdbts.c b/drivers/misc/kgdbts.c
index fcb6ec1..982abd1 100644
--- a/drivers/misc/kgdbts.c
+++ b/drivers/misc/kgdbts.c
@@ -1062,7 +1062,12 @@ static void kgdbts_put_char(u8 chr)
 
 static int param_set_kgdbts_var(const char *kmessage, struct kernel_param *kp)
 {
-	int len = strlen(kmessage);
+	int len;
+
+	if (!kmessage || !(len = strlen(kmessage))) {
+		printk(KERN_ERR "kgdbts: config string too short\n");
+		return -ENOSPC;
+	}
 
 	if (len >= MAX_CONFIG_LEN) {
 		printk(KERN_ERR "kgdbts: config string too long\n");
diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index 8c295f4..1dd9140 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -383,6 +383,9 @@ static int block2mtd_setup2(const char *val)
 	size_t erase_size = PAGE_SIZE;
 	int i, ret;
 
+	if (!val)
+		parse_err("no argument");
+
 	if (strnlen(val, sizeof(buf)) >= sizeof(buf))
 		parse_err("parameter too long");
 
diff --git a/drivers/mtd/devices/phram.c b/drivers/mtd/devices/phram.c
index 1696bbe..c3447f1 100644
--- a/drivers/mtd/devices/phram.c
+++ b/drivers/mtd/devices/phram.c
@@ -241,6 +241,9 @@ static int phram_setup(const char *val, struct kernel_param *kp)
 	uint32_t len;
 	int i, ret;
 
+	if (!val)
+		parse_err("not arguments\n");
+
 	if (strnlen(val, sizeof(buf)) >= sizeof(buf))
 		parse_err("parameter too long\n");
 
diff --git a/drivers/pci/pcie/aspm.c b/drivers/pci/pcie/aspm.c
index be53d98..04770db 100644
--- a/drivers/pci/pcie/aspm.c
+++ b/drivers/pci/pcie/aspm.c
@@ -728,6 +728,9 @@ static int pcie_aspm_set_policy(const char *val, struct kernel_param *kp)
 	int i;
 	struct pcie_link_state *link;
 
+	if (!val)
+		return -EINVAL;
+
 	for (i = 0; i < ARRAY_SIZE(policy_str); i++)
 		if (!strncmp(val, policy_str[i], strlen(policy_str[i])))
 			break;
diff --git a/drivers/serial/kgdboc.c b/drivers/serial/kgdboc.c
index eadc1ab..8832b7a 100644
--- a/drivers/serial/kgdboc.c
+++ b/drivers/serial/kgdboc.c
@@ -108,7 +108,12 @@ static void kgdboc_put_char(u8 chr)
 
 static int param_set_kgdboc_var(const char *kmessage, struct kernel_param *kp)
 {
-	int len = strlen(kmessage);
+	int len;
+
+	if (!kmessage || !(len = strlen(kmessage))) {
+		printk(KERN_ERR "kgdboc: config string too short\n");
+		return -ENOSPC;
+	}
 
 	if (len >= MAX_CONFIG_LEN) {
 		printk(KERN_ERR "kgdboc: config string too long\n");
diff --git a/drivers/usb/storage/libusual.c b/drivers/usb/storage/libusual.c
index fe3ffe1..5eeb768 100644
--- a/drivers/usb/storage/libusual.c
+++ b/drivers/usb/storage/libusual.c
@@ -209,6 +209,9 @@ static int usu_set_bias(const char *bias_s, struct kernel_param *kp)
 	int len;
 	int bias_n = 0;
 
+	if (!bias_s)
+		return -EINVAL;
+
 	len = strlen(bias_s);
 	if (len == 0)
 		return -EDOM;
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index e50cfa3..cbf2d5a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -451,7 +451,10 @@ static ctl_table nlm_sysctl_root[] = {
 static int param_set_##name(const char *val, struct kernel_param *kp)	\
 {									\
 	char *endp;							\
-	__typeof__(type) num = which_strtol(val, &endp, 0);		\
+	__typeof__(type) num;						\
+	if (!val)						\
+		return -EINVAL;						\
+	num = which_strtol(val, &endp, 0);		\
 	if (endp == val || *endp || num < (min) || num > (max))		\
 		return -EINVAL;						\
 	*((int *) kp->arg) = num;					\
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 21a84d4..7e8c0c6 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -60,8 +60,13 @@ unsigned int nfs_idmap_cache_timeout = 600 * HZ;
 static int param_set_idmap_timeout(const char *val, struct kernel_param *kp)
 {
 	char *endp;
-	int num = simple_strtol(val, &endp, 0);
-	int jif = num * HZ;
+	int num, jif;
+
+	if (!val)
+		return -EINVAL;
+
+	num = simple_strtol(val, &endp, 0);
+	jif = num * HZ;
 	if (endp == val || *endp || num < 0 || jif < num)
 		return -EINVAL;
 	*((int *)kp->arg) = jif;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 4d79e3c..375f5d4 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1196,6 +1196,9 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
 
+	if (!val)
+		return -EINVAL;
+
 	if (current->nsproxy->net_ns != &init_net)
 		return -EOPNOTSUPP;
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 538ca43..b33a6dd 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -70,6 +70,9 @@ param_set_pool_mode(const char *val, struct kernel_param *kp)
 	struct svc_pool_map *m = &svc_pool_map;
 	int err;
 
+	if (!val)
+		return -EINVAL;
+
 	mutex_lock(&svc_pool_map_mutex);
 
 	err = -EBUSY;
-- 
1.6.0.4
