From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 1/3] wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
Date: Wed,  7 Jan 2009 09:18:45 -0800
Message-ID: <7e92a3e498e02567876f901eba29c59c294a417b.1231348339.git.inaky@linux.intel.com>
References: <cover.1231348339.git.inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, wimax@linuxwimax.org,
	greg@kroah.com, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com, linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1231348339.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Reported by Randy Dunlap:

> Also, this warning needs to be fixed:
>
> linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> forbids mixed declarations and code

Move the return on #defined(CONFIG_BUG) below the variable
declarations so it doesn't violate ISO C90.

On wimax_id_table_release() we want to do a debug check if CONFIG_BUG
is enabled. However, we also want the debug code to be always compiled
to ensure there is no bitrot. It will be optimized out by the compiler
when CONFIG_BUG is disabled.

Added a note to the function header stating this.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/id-table.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
index d3b8855..5e685f7 100644
--- a/net/wimax/id-table.c
+++ b/net/wimax/id-table.c
@@ -123,15 +123,17 @@ void wimax_id_table_rm(struct wimax_dev *wimax_dev)
 /*
  * Release the gennetlink family id / mapping table
  *
- * On debug, verify that the table is empty upon removal.
+ * On debug, verify that the table is empty upon removal. We want the
+ * code always compiled, to ensure it doesn't bit rot. It will be
+ * compiled out if CONFIG_BUG is disabled.
  */
 void wimax_id_table_release(void)
 {
+	struct wimax_dev *wimax_dev;
+
 #ifndef CONFIG_BUG
 	return;
 #endif
-	struct wimax_dev *wimax_dev;
-
 	spin_lock(&wimax_id_table_lock);
 	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
 		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
-- 
1.5.6.5
