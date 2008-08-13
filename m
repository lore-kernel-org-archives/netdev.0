From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 1/1] tun: TUNGETIFF interface to query name and flags
Date: Wed, 13 Aug 2008 15:30:16 +0100
Message-ID: <1218637816.29159.31.camel@muff>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>
To: Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYHMOau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:30:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty/Max,

While adding support to KVM for IFF_VNET_HDR it became apparent that we
need some way of querying a file descriptor for whether IFF_VNET_HDR has
been set.

Basically, some apps like libvirt open the tap fd, connect the interface
to the appropriate bridge and pass the fd to kvm via the command line. 

So, those apps need to set IFF_VNET_HDR and KVM needs to be able to
detect that and handle it correctly.

A very simple approach is attached; I did consider doing a TUNGETFLAGS
that would return tun->flags, but I think it's nicer to have a companion
to TUNGETIFF since it also allows one to query the interface name from
the file descriptor.

Cheers,
Mark.

Subject: [PATCH 1/1] tun: TUNGETIFF interface to query name and flags

Add a TUNGETIFF interface so that userspace can query a
tun/tap descriptor for its name and flags.

This is needed because it is common for one app to create
a tap interface, exec another app and pass it the file
descriptor for the interface. Without TUNGETIFF the spawned
app has no way of detecting wheter the interface has e.g.
IFF_VNET_HDR set.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/tun.c      |   39 +++++++++++++++++++++++++++++++++++++++
 include/linux/if_tun.h |    1 +
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e6bbc63..95931a5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -748,6 +748,36 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	return err;
 }
 
+static int tun_get_iff(struct net *net, struct file *file, struct ifreq *ifr)
+{
+	struct tun_struct *tun = file->private_data;
+
+	if (!tun)
+		return -EBADFD;
+
+	DBG(KERN_INFO "%s: tun_get_iff\n", tun->dev->name);
+
+	strcpy(ifr->ifr_name, tun->dev->name);
+
+	ifr->ifr_flags = 0;
+
+	if (ifr->ifr_flags & TUN_TUN_DEV)
+		ifr->ifr_flags |= IFF_TUN;
+	else
+		ifr->ifr_flags |= IFF_TAP;
+
+	if (tun->flags & TUN_NO_PI)
+		ifr->ifr_flags |= IFF_NO_PI;
+
+	if (tun->flags & TUN_ONE_QUEUE)
+		ifr->ifr_flags |= IFF_ONE_QUEUE;
+
+	if (tun->flags & TUN_VNET_HDR)
+		ifr->ifr_flags |= IFF_VNET_HDR;
+
+	return 0;
+}
+
 /* This is like a cut-down ethtool ops, except done via tun fd so no
  * privs required. */
 static int set_offload(struct net_device *dev, unsigned long arg)
@@ -833,6 +863,15 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 	DBG(KERN_INFO "%s: tun_chr_ioctl cmd %d\n", tun->dev->name, cmd);
 
 	switch (cmd) {
+	case TUNGETIFF:
+		ret = tun_get_iff(current->nsproxy->net_ns, file, &ifr);
+		if (ret)
+			return ret;
+
+		if (copy_to_user(argp, &ifr, sizeof(ifr)))
+			return -EFAULT;
+		break;
+
 	case TUNSETNOCSUM:
 		/* Disable/Enable checksum */
 		if (arg)
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 4c6307a..8529f57 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -45,6 +45,7 @@
 #define TUNGETFEATURES _IOR('T', 207, unsigned int)
 #define TUNSETOFFLOAD  _IOW('T', 208, unsigned int)
 #define TUNSETTXFILTER _IOW('T', 209, unsigned int)
+#define TUNGETIFF      _IOR('T', 210, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
1.5.4.1

