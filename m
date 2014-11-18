From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH net-next 2/4] tuntap: Accept tuntap maximum number of queues as sysctl
Date: Tue, 18 Nov 2014 21:52:56 +0530
Message-ID: <1416327778-17716-3-git-send-email-pagupta@redhat.com>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com,
	wuzhy@linux.vnet.ibm.com.pnq.redhat.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com,
	Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 This patch accepts maximum number of tun/tap queues allocated as
 sysctl entry which a user space application like libvirt
 can make use of to limit maximum number of tuntap queues. 
 Value of sysctl entry is writable dynamically.
 
 If no value is set for sysctl entry 'net.tuntap.max_queues' 
 a default value 256 is used which is equal to maximum number 
 of vCPUS allowed by KVM.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/net/tun.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e3fa65a..b03a745 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -71,6 +71,7 @@
 #include <net/rtnetlink.h>
 #include <net/sock.h>
 #include <linux/seq_file.h>
+#include <linux/sysctl.h>
 #include <linux/uio.h>
 
 #include <asm/uaccess.h>
@@ -117,10 +118,16 @@ struct tap_filter {
  * the netdevice to be fit in one page. So we can make sure the success of
  * memory allocation. TODO: increase the limit. */
 #define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
+#define MIN_TAP_QUEUES 1
 #define MAX_TAP_FLOWS  4096
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
 
+static struct ctl_table_header *tun_sysctl_header;
+static int tun_queues = MAX_TAP_QUEUES;
+static int min_queues = MIN_TAP_QUEUES;
+static int max_queues = MAX_TAP_QUEUES;
+
 /* A tun_file connects an open character device to a tuntap netdevice. It
  * also contains all socket related structures (except sock_fprog and tap_filter)
  * to serve as one transmit queue for tuntap device. The sock_fprog and
@@ -197,6 +204,19 @@ struct tun_struct {
 	u32 flow_count;
 };
 
+static struct ctl_table tun_ctl_table[] = {
+	{
+		.procname       = "tun_max_queues",
+		.data           = &tun_queues,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+		.extra1         = &min_queues,
+		.extra2         = &max_queues
+	},
+	{  }
+};
+
 static inline u32 tun_hashfn(u32 rxhash)
 {
 	return rxhash & 0x3ff;
@@ -547,7 +567,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	err = -E2BIG;
 	if (!tfile->detached &&
-	    tun->numqueues + tun->numdisabled == MAX_TAP_QUEUES)
+	    tun->numqueues + tun->numdisabled == tun_queues)
 		goto out;
 
 	err = 0;
@@ -1624,7 +1644,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		char *name;
 		unsigned long flags = 0;
 		int queues = ifr->ifr_flags & IFF_MULTI_QUEUE ?
-			     MAX_TAP_QUEUES : 1;
+			     tun_queues : 1;
 
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
@@ -2335,6 +2355,13 @@ static int __init tun_init(void)
 	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	pr_info("%s\n", DRV_COPYRIGHT);
 
+	tun_sysctl_header = register_net_sysctl(&init_net, "net/tuntap",
+						tun_ctl_table);
+
+	if (!tun_sysctl_header)
+		pr_err("Can't register tun_ctl_table. Tun device queue"
+		       "setting to default value : %d queues.\n", tun_queues);
+
 	ret = rtnl_link_register(&tun_link_ops);
 	if (ret) {
 		pr_err("Can't register link_ops\n");
@@ -2357,6 +2384,8 @@ static void tun_cleanup(void)
 {
 	misc_deregister(&tun_miscdev);
 	rtnl_link_unregister(&tun_link_ops);
+	if (tun_sysctl_header)
+		unregister_net_sysctl_table(tun_sysctl_header);
 }
 
 /* Get an underlying socket object from tun file.  Returns error unless file is
-- 
1.8.3.1
