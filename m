From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 13:05:23 -0700 (PDT)
Message-ID: <20070425.130523.44098351.davem@davemloft.net>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
	<20070425195941.GA11699@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993040AbXDYUFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:05:15 -0400
In-Reply-To: <20070425195941.GA11699@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Wed, 25 Apr 2007 12:59:41 -0700

> On Wed, Apr 25, 2007 at 10:38:56PM +0400, Alexey Kuznetsov wrote:
> > Hello!
> > 
> > Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> > which resulted in infinite recursion and stack overflow.
> > 
> > The bug is present in all kernel versions since the feature appeared.
> 
> Any hint on when this feature appeared so that we can notify the distros
> for older releases?

It's been there since Jun 20th, 2005

commit 246955fe4c38bd706ae30e37c64892c94213775d
Author: Robert Olsson <Robert.Olsson@data.slu.se>
Date:   Mon Jun 20 13:36:39 2005 -0700

    [NETLINK]: fib_lookup() via netlink
    
    Below is a more generic patch to do fib_lookup via netlink. For others
    we should say that we discussed this as a way to verify route selection.
    It's also possible there are others uses for this.
    
    In short the fist half of struct fib_result_nl is filled in by caller
    and netlink call fills in the other half and returns it.
    
    In case anyone is interested there is a corresponding user app to compare
    the full routing table this was used to test implementation of the LC-trie.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e38407a..561d4dc 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -14,6 +14,7 @@
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
 #define NETLINK_ARPD		8
 #define NETLINK_AUDIT		9	/* auditing */
+#define NETLINK_FIB_LOOKUP	10	
 #define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
 #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e5a5f6b..a4208a3 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -109,6 +109,20 @@ struct fib_result {
 #endif
 };
 
+struct fib_result_nl {
+	u32		fl_addr;   /* To be looked up*/ 
+	u32		fl_fwmark; 
+	unsigned char	fl_tos;
+	unsigned char   fl_scope;
+	unsigned char   tb_id_in;
+
+	unsigned char   tb_id;      /* Results */
+	unsigned char	prefixlen;
+	unsigned char	nh_sel;
+	unsigned char	type;
+	unsigned char	scope;
+	int             err;      
+};
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 563e7d6..cd8e45a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -516,6 +516,60 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 #undef BRD1_OK
 }
 
+static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb )
+{
+	
+	struct fib_result       res;
+	struct flowi            fl = { .nl_u = { .ip4_u = { .daddr = frn->fl_addr, 
+							    .fwmark = frn->fl_fwmark,
+							    .tos = frn->fl_tos,
+							    .scope = frn->fl_scope } } };
+	if (tb) {
+		local_bh_disable();
+
+		frn->tb_id = tb->tb_id;
+		frn->err = tb->tb_lookup(tb, &fl, &res);
+
+		if (!frn->err) {
+			frn->prefixlen = res.prefixlen;
+			frn->nh_sel = res.nh_sel;
+			frn->type = res.type;
+			frn->scope = res.scope;
+		}
+		local_bh_enable();
+	}
+}
+
+static void nl_fib_input(struct sock *sk, int len)
+{
+	struct sk_buff *skb = NULL;
+        struct nlmsghdr *nlh = NULL;
+	struct fib_result_nl *frn;
+	int err;
+	u32 pid;     
+	struct fib_table *tb;
+	
+	skb = skb_recv_datagram(sk, 0, 0, &err);
+	nlh = (struct nlmsghdr *)skb->data;
+	
+	frn = (struct fib_result_nl *) NLMSG_DATA(nlh);
+	tb = fib_get_table(frn->tb_id_in);
+
+	nl_fib_lookup(frn, tb);
+	
+	pid = nlh->nlmsg_pid;           /*pid of sending process */
+	NETLINK_CB(skb).groups = 0;     /* not in mcast group */
+	NETLINK_CB(skb).pid = 0;         /* from kernel */
+	NETLINK_CB(skb).dst_pid = pid;
+	NETLINK_CB(skb).dst_groups = 0;  /* unicast */
+	netlink_unicast(sk, skb, pid, MSG_DONTWAIT);
+}    
+
+static void nl_fib_lookup_init(void)
+{
+      netlink_kernel_create(NETLINK_FIB_LOOKUP, nl_fib_input);
+}
+
 static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down(0, dev, force))
@@ -604,6 +658,7 @@ void __init ip_fib_init(void)
 
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
+	nl_fib_lookup_init();
 }
 
 EXPORT_SYMBOL(inet_addr_type);
