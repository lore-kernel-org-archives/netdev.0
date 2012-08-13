From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 21/21] userns: Convert tun/tap to use kuid and kgid where
	appropriate
Date: Mon, 13 Aug 2012 13:18:35 -0700
Message-ID: <1344889115-21610-21-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Maxim Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Cc: Maxim Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/tun.c |   46 ++++++++++++++++++++++++++++++++--------------
 init/Kconfig      |    1 -
 2 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 926d4db..a9bd9f3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -120,8 +120,8 @@ struct tun_sock;
 struct tun_struct {
 	struct tun_file		*tfile;
 	unsigned int 		flags;
-	uid_t			owner;
-	gid_t			group;
+	kuid_t			owner;
+	kgid_t			group;
 
 	struct net_device	*dev;
 	netdev_features_t	set_features;
@@ -1032,8 +1032,8 @@ static void tun_setup(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	tun->owner = -1;
-	tun->group = -1;
+	tun->owner = INVALID_UID;
+	tun->group = INVALID_GID;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = tun_free_netdev;
@@ -1156,14 +1156,20 @@ static ssize_t tun_show_owner(struct device *dev, struct device_attribute *attr,
 			      char *buf)
 {
 	struct tun_struct *tun = netdev_priv(to_net_dev(dev));
-	return sprintf(buf, "%d\n", tun->owner);
+	return uid_valid(tun->owner)?
+		sprintf(buf, "%u\n",
+			from_kuid_munged(current_user_ns(), tun->owner)):
+		sprintf(buf, "-1\n");
 }
 
 static ssize_t tun_show_group(struct device *dev, struct device_attribute *attr,
 			      char *buf)
 {
 	struct tun_struct *tun = netdev_priv(to_net_dev(dev));
-	return sprintf(buf, "%d\n", tun->group);
+	return gid_valid(tun->group) ?
+		sprintf(buf, "%u\n",
+			from_kgid_munged(current_user_ns(), tun->group)):
+		sprintf(buf, "-1\n");
 }
 
 static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
@@ -1190,8 +1196,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		else
 			return -EINVAL;
 
-		if (((tun->owner != -1 && cred->euid != tun->owner) ||
-		     (tun->group != -1 && !in_egroup_p(tun->group))) &&
+		if (((uid_valid(tun->owner) && !uid_eq(cred->euid, tun->owner)) ||
+		     (gid_valid(tun->group) && !in_egroup_p(tun->group))) &&
 		    !capable(CAP_NET_ADMIN))
 			return -EPERM;
 		err = security_tun_dev_attach(tun->socket.sk);
@@ -1375,6 +1381,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	void __user* argp = (void __user*)arg;
 	struct sock_fprog fprog;
 	struct ifreq ifr;
+	kuid_t owner;
+	kgid_t group;
 	int sndbuf;
 	int vnet_hdr_sz;
 	int ret;
@@ -1448,16 +1456,26 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 	case TUNSETOWNER:
 		/* Set owner of the device */
-		tun->owner = (uid_t) arg;
-
-		tun_debug(KERN_INFO, tun, "owner set to %d\n", tun->owner);
+		owner = make_kuid(current_user_ns(), arg);
+		if (!uid_valid(owner)) {
+			ret = -EINVAL;
+			break;
+		}
+		tun->owner = owner;
+		tun_debug(KERN_INFO, tun, "owner set to %d\n",
+			  from_kuid(&init_user_ns, tun->owner));
 		break;
 
 	case TUNSETGROUP:
 		/* Set group of the device */
-		tun->group= (gid_t) arg;
-
-		tun_debug(KERN_INFO, tun, "group set to %d\n", tun->group);
+		group = make_kgid(current_user_ns(), arg);
+		if (!gid_valid(group)) {
+			ret = -EINVAL;
+			break;
+		}
+		tun->group = group;
+		tun_debug(KERN_INFO, tun, "group set to %d\n",
+			  from_kgid(&init_user_ns, tun->group));
 		break;
 
 	case TUNSETLINK:
diff --git a/init/Kconfig b/init/Kconfig
index eac23a6..b445d6f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1003,7 +1003,6 @@ config UIDGID_CONVERTED
 	depends on !UML || HOSTFS = n
 
 	# The rare drivers that won't build
-	depends on TUN = n
 	depends on INFINIBAND_QIB = n
 	depends on BLK_DEV_LOOP = n
 	depends on ANDROID_BINDER_IPC = n
-- 
1.7.5.4
