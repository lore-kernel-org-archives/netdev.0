From: Eric Leblond <eric@inl.fr>
Subject: [PATCH 2/3] netfilter: fix warning in ebt_ulog init function.
Date: Thu, 26 Mar 2009 08:59:55 +0100
Message-ID: <1238054396-9088-2-git-send-email-eric@inl.fr>
References: <1238053819.13879.4.camel@ice-age>
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Eric Leblond <eric@inl.fr>
To: davem@davemloft.net, kaber@trash.net, sfr@canb.auug.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1238053819.13879.4.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ebt_ulog module does not follow the fixed convention about function
return. Loading the module is triggering the following message:

sys_init_module: 'ebt_ulog'->init suspiciously returned 1, it should follow 0/-E convention
sys_init_module: loading module anyway...
Pid: 2334, comm: modprobe Not tainted 2.6.29-rc5edenwall0-00883-g199e57b #146
Call Trace:
 [<c0441b81>] ? printk+0xf/0x16
 [<c02311af>] sys_init_module+0x107/0x186
 [<c0202cfa>] syscall_call+0x7/0xb

The following patch fixes the return treatment in ebt_ulog_init()
function.

Signed-off-by: Eric Leblond <eric@inl.fr>
---
 net/bridge/netfilter/ebt_ulog.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 80c78c5..ac6fa43 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -287,13 +287,13 @@ static struct nf_logger ebt_ulog_logger __read_mostly = {
 
 static int __init ebt_ulog_init(void)
 {
-	bool ret = true;
+	int ret;
 	int i;
 
 	if (nlbufsiz >= 128*1024) {
 		printk(KERN_NOTICE "ebt_ulog: Netlink buffer has to be <= 128kB,"
 		       " please try a smaller nlbufsiz parameter.\n");
-		return false;
+		return -EINVAL;
 	}
 
 	/* initialize ulog_buffers */
@@ -308,12 +308,12 @@ static int __init ebt_ulog_init(void)
 	if (!ebtulognl) {
 		printk(KERN_WARNING KBUILD_MODNAME ": out of memory trying to "
 		       "call netlink_kernel_create\n");
-		ret = false;
-	} else if (xt_register_target(&ebt_ulog_tg_reg) != 0) {
+		ret = -ENOMEM;
+	} else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0) {
 		netlink_kernel_release(ebtulognl);
 	}
 
-	if (ret)
+	if (ret == 0)
 		nf_log_register(NFPROTO_BRIDGE, &ebt_ulog_logger);
 
 	return ret;
-- 
1.5.6.3

