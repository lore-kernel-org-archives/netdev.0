From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.71] Fix module owner for bonding driver
Date: Mon, 16 Jun 2003 15:42:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616154251.28c3e3ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh
 <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The bonding driver does explicit MOD_INC/DEC even though it does a SET_MODULE_OWNER.
So it doesn't changes module use counts on open/close on 2.5 when it shouldn't.
It also has a /proc entry which does not affect the module use counts when it should.

Suggestion: the /proc interface could/should be converted to seq_file.
Volunteers? Janitor project?

diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Jun 16 15:24:37 2003
+++ b/drivers/net/bonding/bond_main.c	Mon Jun 16 15:24:37 2003
@@ -952,8 +952,6 @@
 		add_timer(alb_timer);
 	}
 
-	MOD_INC_USE_COUNT;
-
 	if (miimon > 0) {  /* link check interval, in milliseconds. */
 		init_timer(timer);
 		timer->expires  = jiffies + (miimon * HZ / 1000);
@@ -1027,7 +1025,6 @@
 		bond_alb_deinitialize(bond);
 	}
 
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -3694,6 +3691,8 @@
 		kfree(bond);
 		return -ENOMEM;
 	}
+	bond->bond_proc_dir->owner = THIS_MODULE;
+
 	bond->bond_proc_info_file = 
 		create_proc_info_entry("info", 0, bond->bond_proc_dir, 
 					bond_get_info);
@@ -3705,6 +3704,7 @@
 		kfree(bond);
 		return -ENOMEM;
 	}
+	bond->bond_proc_info_file->owner = THIS_MODULE;
 #endif /* CONFIG_PROC_FS */
 
 	if (first_pass == 1) {
