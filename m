From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 07:20:19 +0200
Message-ID: <200911130720.19671.opurdila@ixiacom.com>
References: <200911130701.14847.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19514 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750834AbZKMFXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 00:23:18 -0500
In-Reply-To: <200911130701.14847.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009 07:01:14 you wrote:
> This patch speeds up the network device name allocation for the case
> where a significant number of devices of the same type are created
> consecutively.
> 
> Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
> and sysfs entries disabled:
> 
> Without the patch           With the patch
> 
> real    0m 43.43s	    real    0m 0.49s
> user    0m 0.00s	    user    0m 0.00s
> sys     0m 43.43s	    sys     0m 0.48s
> 

Oops, pasting root prompts (e.g. # modprobe ....) directly into the git commit message is not a good idea :) Here it is again, with the full commit message.

[net-next-2.6 PATCH] net: fast consecutive name allocation

This patch speeds up the network device name allocation for the case
where a significant number of devices of the same type are created
consecutively.

Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
and sysfs entries disabled:

$ time insmod /lib/modules/dummy.ko numdummies=8000

Without the patch           With the patch

real    0m 43.43s	    real    0m 0.49s
user    0m 0.00s	    user    0m 0.00s
sys     0m 43.43s	    sys     0m 0.48s

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/net_namespace.h |    3 +++
 net/core/dev.c              |   23 ++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0addd45..39c65a2 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -56,6 +56,9 @@ struct net {
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
+	/* fast consecutive name allocation (e.g. eth0, eth1, ...) */
+	char                    fcna_name[IFNAMSIZ];
+	int                     fcna_no;
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
diff --git a/net/core/dev.c b/net/core/dev.c
index ad8e320..008e3c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -226,8 +226,12 @@ static int list_netdevice(struct net_device *dev)
  */
 static void unlist_netdevice(struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
+
 	ASSERT_RTNL();
 
+	net->fcna_no = -1;
+
 	/* Unlink dev from the device chain */
 	write_lock_bh(&dev_base_lock);
 	list_del_rcu(&dev->dev_list);
@@ -872,6 +876,16 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
+		/* avoid fast allocation for strange templates like "fan%dcy" */
+		if (net->fcna_no >= 0 && p[2] == 0 &&
+		    net->fcna_name[p - name] == 0 &&
+		    memcmp(name, net->fcna_name, p - name) == 0) {
+			snprintf(buf, IFNAMSIZ, name, ++net->fcna_no);
+			if (!__dev_get_by_name(net, buf))
+				return net->fcna_no;
+			net->fcna_no = -1;
+		}
+
 		/* Use one page as a bit array of possible slots */
 		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
 		if (!inuse)
@@ -894,8 +908,15 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 	}
 
 	snprintf(buf, IFNAMSIZ, name, i);
-	if (!__dev_get_by_name(net, buf))
+	if (!__dev_get_by_name(net, buf)) {
+		if (p[2] == 0) {
+			memcpy(net->fcna_name, name, p - name);
+			net->fcna_name[p - name] = 0;
+			net->fcna_no = i;
+		}  else
+			net->fcna_no = -1;
 		return i;
+	}
 
 	/* It is possible to run out of possible slots
 	 * when the name is long and there isn't enough space left
-- 
1.5.6.5

