From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH] macvtap: Destroy minor_idr on module_exit
Date: Wed,  8 Jul 2015 17:16:49 +0200
Message-ID: <1436368609-30777-1-git-send-email-jthumshirn@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Thumshirn <jthumshirn@suse.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Destroy minor_idr on module_exit, reclaiming the allocated memory.

This was detected by the following semantic patch (written by Luis Rodriguez
<mcgrof@suse.com>)
<SmPL>
@ defines_module_init @
declarer name module_init, module_exit;
declarer name DEFINE_IDR;
identifier init;
@@

module_init(init);

@ defines_module_exit @
identifier exit;
@@

module_exit(exit);

@ declares_idr depends on defines_module_init && defines_module_exit @
identifier idr;
@@

DEFINE_IDR(idr);

@ on_exit_calls_destroy depends on declares_idr && defines_module_exit @
identifier declares_idr.idr, defines_module_exit.exit;
@@

exit(void)
{
 ...
 idr_destroy(&idr);
 ...
}

@ missing_module_idr_destroy depends on declares_idr && defines_module_exit && !on_exit_calls_destroy @
identifier declares_idr.idr, defines_module_exit.exit;
@@

exit(void)
{
 ...
 +idr_destroy(&idr);
}
</SmPL>

Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
---
 drivers/net/macvtap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index f837080..3b933bb 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1355,6 +1355,7 @@ static void macvtap_exit(void)
 	class_unregister(macvtap_class);
 	cdev_del(&macvtap_cdev);
 	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
+	idr_destroy(&minor_idr);
 }
 module_exit(macvtap_exit);
 
-- 
2.4.3
