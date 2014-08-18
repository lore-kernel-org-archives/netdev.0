From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 2/4] tuntap: Publish tuntap maximum number of queues as module_param
Date: Mon, 18 Aug 2014 19:07:18 +0530
Message-ID: <1408369040-1216-3-git-send-email-pagupta@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbaHRNid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 09:38:33 -0400
In-Reply-To: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch publishes maximum number of tun/tap queues allocated as a
 read_only module parameter which a user space application like libvirt
 can make use of to limit maximum number of queues. Value of read_only
 module parameter can be writable only at module load time. If no value is set
 at module load time a default value 256 is used which is equal to maximum number
 of vCPUS allowed by KVM.

 Administrator can specify maximum number of queues only at the driver
 module load time.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/net/tun.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index acaaf67..1f518e2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -119,6 +119,9 @@ struct tap_filter {
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
 
+static int max_tap_queues = MAX_TAP_QUEUES;
+module_param(max_tap_queues, int, S_IRUGO);
+
 /* A tun_file connects an open character device to a tuntap netdevice. It
  * also contains all socket related structures (except sock_fprog and tap_filter)
  * to serve as one transmit queue for tuntap device. The sock_fprog and
@@ -545,7 +548,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	err = -E2BIG;
 	if (!tfile->detached &&
-	    tun->numqueues + tun->numdisabled == MAX_TAP_QUEUES)
+	    tun->numqueues + tun->numdisabled == max_tap_queues)
 		goto out;
 
 	err = 0;
@@ -1609,7 +1612,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		char *name;
 		unsigned long flags = 0;
 		int queues = ifr->ifr_flags & IFF_MULTI_QUEUE ?
-			     MAX_TAP_QUEUES : 1;
+			     max_tap_queues : 1;
 
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
@@ -2327,6 +2330,12 @@ static int __init tun_init(void)
 	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	pr_info("%s\n", DRV_COPYRIGHT);
 
+	if (max_tap_queues > MAX_TAP_QUEUES || max_tap_queues <= 0) {
+		printk(KERN_WARNING "max_tap_queues parameter value either too large"
+		 " or too small forcing default value: %d\n", MAX_TAP_QUEUES);
+		max_tap_queues = MAX_TAP_QUEUES;
+	}
+
 	ret = rtnl_link_register(&tun_link_ops);
 	if (ret) {
 		pr_err("Can't register link_ops\n");
-- 
1.7.1
