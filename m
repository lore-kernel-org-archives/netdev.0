From: David Miller <davem@davemloft.net>
Subject: [PATCH]: af_key procfs OOPS fix
Date: Tue, 26 Feb 2008 22:25:16 -0800 (PST)
Message-ID: <20080226.222516.193700549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54080
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753615AbYB0GZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 01:25:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


FYI, I just checked in the following bug fix.  My workstation would
OOPS every time I'd restart openswan because of this.

commit d9595a7b9c777d45a74774f1428c263a0a47f4c0
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Feb 26 22:20:44 2008 -0800

    [AF_KEY]: Fix oops by converting to proc_net_*().
    
    To make sure the procfs visibility occurs after the ->proc_fs ops are
    setup, use proc_net_fops_create() and proc_net_remove().
    
    This also fixes an OOPS after module unload in that the name string
    for remove was wrong, so it wouldn't actually be removed.  That bug
    was introduced by commit 61145aa1a12401ac71bcc450a58c773dd6e2bfb9
    ("[KEY]: Clean up proc files creation a bit.")
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1c85392..8b5f486 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3807,17 +3807,16 @@ static int pfkey_init_proc(void)
 {
 	struct proc_dir_entry *e;
 
-	e = create_proc_entry("pfkey", 0, init_net.proc_net);
+	e = proc_net_fops_create(&init_net, "pfkey", 0, &pfkey_proc_ops);
 	if (e == NULL)
 		return -ENOMEM;
 
-	e->proc_fops = &pfkey_proc_ops;
 	return 0;
 }
 
 static void pfkey_exit_proc(void)
 {
-	remove_proc_entry("net/pfkey", NULL);
+	proc_net_remove(&init_net, "pfkey");
 }
 #else
 static inline int pfkey_init_proc(void)
