From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 20/21] userns: Make the airo wireless driver use kuids for
	proc uids and gids
Date: Mon, 13 Aug 2012 13:18:34 -0700
Message-ID: <1344889115-21610-20-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/wireless/airo.c |   48 +++++++++++++++++++++++++-----------------
 init/Kconfig                |    2 -
 2 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index f9f15bb..c586f78 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -232,8 +232,10 @@ static int adhoc;
 
 static int probe = 1;
 
+static kuid_t proc_kuid;
 static int proc_uid /* = 0 */;
 
+static kgid_t proc_kgid;
 static int proc_gid /* = 0 */;
 
 static int airo_perm = 0555;
@@ -4499,78 +4501,79 @@ struct proc_data {
 static int setup_proc_entry( struct net_device *dev,
 			     struct airo_info *apriv ) {
 	struct proc_dir_entry *entry;
+
 	/* First setup the device directory */
 	strcpy(apriv->proc_name,dev->name);
 	apriv->proc_entry = proc_mkdir_mode(apriv->proc_name, airo_perm,
 					    airo_entry);
 	if (!apriv->proc_entry)
 		goto fail;
-	apriv->proc_entry->uid = proc_uid;
-	apriv->proc_entry->gid = proc_gid;
+	apriv->proc_entry->uid = proc_kuid;
+	apriv->proc_entry->gid = proc_kgid;
 
 	/* Setup the StatsDelta */
 	entry = proc_create_data("StatsDelta", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_statsdelta_ops, dev);
 	if (!entry)
 		goto fail_stats_delta;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the Stats */
 	entry = proc_create_data("Stats", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_stats_ops, dev);
 	if (!entry)
 		goto fail_stats;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the Status */
 	entry = proc_create_data("Status", S_IRUGO & proc_perm,
 				 apriv->proc_entry, &proc_status_ops, dev);
 	if (!entry)
 		goto fail_status;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the Config */
 	entry = proc_create_data("Config", proc_perm,
 				 apriv->proc_entry, &proc_config_ops, dev);
 	if (!entry)
 		goto fail_config;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the SSID */
 	entry = proc_create_data("SSID", proc_perm,
 				 apriv->proc_entry, &proc_SSID_ops, dev);
 	if (!entry)
 		goto fail_ssid;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the APList */
 	entry = proc_create_data("APList", proc_perm,
 				 apriv->proc_entry, &proc_APList_ops, dev);
 	if (!entry)
 		goto fail_aplist;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the BSSList */
 	entry = proc_create_data("BSSList", proc_perm,
 				 apriv->proc_entry, &proc_BSSList_ops, dev);
 	if (!entry)
 		goto fail_bsslist;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	/* Setup the WepKey */
 	entry = proc_create_data("WepKey", proc_perm,
 				 apriv->proc_entry, &proc_wepkey_ops, dev);
 	if (!entry)
 		goto fail_wepkey;
-	entry->uid = proc_uid;
-	entry->gid = proc_gid;
+	entry->uid = proc_kuid;
+	entry->gid = proc_kgid;
 
 	return 0;
 
@@ -5697,11 +5700,16 @@ static int __init airo_init_module( void )
 {
 	int i;
 
+	proc_kuid = make_kuid(&init_user_ns, proc_uid);
+	proc_kgid = make_kgid(&init_user_ns, proc_gid);
+	if (!uid_valid(proc_kuid) || !gid_valid(proc_kgid))
+		return -EINVAL;
+
 	airo_entry = proc_mkdir_mode("driver/aironet", airo_perm, NULL);
 
 	if (airo_entry) {
-		airo_entry->uid = proc_uid;
-		airo_entry->gid = proc_gid;
+		airo_entry->uid = proc_kuid;
+		airo_entry->gid = proc_kgid;
 	}
 
 	for (i = 0; i < 4 && io[i] && irq[i]; i++) {
diff --git a/init/Kconfig b/init/Kconfig
index 76ffca9..eac23a6 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1003,8 +1003,6 @@ config UIDGID_CONVERTED
 	depends on !UML || HOSTFS = n
 
 	# The rare drivers that won't build
-	depends on AIRO = n
-	depends on AIRO_CS = n
 	depends on TUN = n
 	depends on INFINIBAND_QIB = n
 	depends on BLK_DEV_LOOP = n
-- 
1.7.5.4
