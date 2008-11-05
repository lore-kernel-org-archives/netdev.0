From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/01: netns ct: walk netns list under RTNL
Date: Wed, 05 Nov 2008 11:56:08 +0100
Message-ID: <49117BC8.3010000@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070204040009080305070707"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070204040009080305070707
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

following is a single netfilter fix from Alexey Dobriyan,
fixing an oops caused by a race between netfilter module
unloading and namespace exit.

Please apply, thanks.


--------------070204040009080305070707
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit f42a27d7fea2ed832ca74a340a362eb665f929e5
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Wed Nov 5 11:12:48 2008 +0100

    netfilter: netns ct: walk netns list under RTNL
    
    netns list (just list) is under RTNL. But helper and proto unregistration
    happen during rmmod when RTNL is not held, and that's how it was tested:
    modprobe/rmmod vs clone(CLONE_NEWNET)/exit.
    
    BUG: unable to handle kernel paging request at 0000000000100100	<===
    IP: [<ffffffffa009890f>] nf_conntrack_l4proto_unregister+0x96/0xae [nf_conntrack]
    PGD 15e300067 PUD 15e1d8067 PMD 0
    Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
    last sysfs file: /sys/kernel/uevent_seqnum
    CPU 0
    Modules linked in: nf_conntrack_proto_sctp(-) nf_conntrack_proto_dccp(-) af_packet iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables xt_tcpudp ip6table_filter ip6_tables x_tables ipv6 sr_mod cdrom [last unloaded: nf_conntrack_proto_sctp]
    Pid: 16758, comm: rmmod Not tainted 2.6.28-rc2-netns-xfrm #3
    RIP: 0010:[<ffffffffa009890f>]  [<ffffffffa009890f>] nf_conntrack_l4proto_unregister+0x96/0xae [nf_conntrack]
    RSP: 0018:ffff88015dc1fec8  EFLAGS: 00010212
    RAX: 0000000000000000 RBX: 00000000001000f8 RCX: 0000000000000000
    RDX: ffffffffa009575c RSI: 0000000000000003 RDI: ffffffffa00956b5
    RBP: ffff88015dc1fed8 R08: 0000000000000002 R09: 0000000000000000
    R10: 0000000000000000 R11: ffff88015dc1fe48 R12: ffffffffa0458f60
    R13: 0000000000000880 R14: 00007fff4c361d30 R15: 0000000000000880
    FS:  00007f624435a6f0(0000) GS:ffffffff80521580(0000) knlGS:0000000000000000
    CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
    CR2: 0000000000100100 CR3: 0000000168969000 CR4: 00000000000006e0
    DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
    Process rmmod (pid: 16758, threadinfo ffff88015dc1e000, task ffff880179864218)
    Stack:
     ffffffffa0459100 0000000000000000 ffff88015dc1fee8 ffffffffa0457934
     ffff88015dc1ff78 ffffffff80253fef 746e6e6f635f666e 6f72705f6b636172
     00707463735f6f74 ffffffff8024cb30 00000000023b8010 0000000000000000
    Call Trace:
     [<ffffffffa0457934>] nf_conntrack_proto_sctp_fini+0x10/0x1e [nf_conntrack_proto_sctp]
     [<ffffffff80253fef>] sys_delete_module+0x19f/0x1fe
     [<ffffffff8024cb30>] ? trace_hardirqs_on_caller+0xf0/0x114
     [<ffffffff803ea9b2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
     [<ffffffff8020b52b>] system_call_fastpath+0x16/0x1b
    Code: 13 35 e0 e8 c4 6c 1a e0 48 8b 1d 6d c6 46 e0 eb 16 48 89 df 4c 89 e2 48 c7 c6 fc 85 09 a0 e8 61 cd ff ff 48 8b 5b 08 48 83 eb 08 <48> 8b 43 08 0f 18 08 48 8d 43 08 48 3d 60 4f 50 80 75 d3 5b 41
    RIP  [<ffffffffa009890f>] nf_conntrack_l4proto_unregister+0x96/0xae [nf_conntrack]
     RSP <ffff88015dc1fec8>
    CR2: 0000000000100100
    ---[ end trace bde8ac82debf7192 ]---
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 9c06b9f..c39b6a9 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -21,6 +21,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
+#include <linux/rtnetlink.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -167,10 +168,12 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	 */
 	synchronize_rcu();
 
+	rtnl_lock();
 	spin_lock_bh(&nf_conntrack_lock);
 	for_each_net(net)
 		__nf_conntrack_helper_unregister(me, net);
 	spin_unlock_bh(&nf_conntrack_lock);
+	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index a59a307..592d733 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -22,6 +22,7 @@
 #include <linux/notifier.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -221,8 +222,10 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
+	rtnl_lock();
 	for_each_net(net)
 		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
+	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -333,8 +336,10 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
+	rtnl_lock();
 	for_each_net(net)
 		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 

--------------070204040009080305070707--
