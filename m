From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] bluetooth: Add bt_printk
Date: Thu, 30 Jun 2011 00:19:51 -0700
Message-ID: <f06f1d8f4185db431a038c328c42caf4fe270dd0.1309418368.git.joe@perches.com>
References: <20110630033119.GA3438@joana>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110630033119.GA3438@joana>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a local logging function to emit bluetooth specific
messages.  Using vsprintf extension %pV saves code/text
space.

Convert the current BT_INFO and BT_ERR macros to use bt_printk.
Remove __func__ from BT_ERR macro (and the uses).
Prefix "Bluetooth: " to BT_ERR
Remove __func__ from BT_DBG as function can be prefixed when
using dynamic_debug.

With allyesconfig:

   text	   data	    bss	    dec	    hex	filename
 129956	   8632	  36096	 174684	  2aa5c	drivers/bluetooth/built-in.o.new2
 134402	   8632	  36064	 179098	  2bb9a	drivers/bluetooth/built-in.o.old
  14778	   1012	   3408	  19198	   4afe	net/bluetooth/bnep/built-in.o.new2
  15067	   1012	   3408	  19487	   4c1f	net/bluetooth/bnep/built-in.o.old
 346595	  19163	  86080	 451838	  6e4fe	net/bluetooth/built-in.o.new2
 353751	  19163	  86064	 458978	  700e2	net/bluetooth/built-in.o.old
  18483	   1172	   4264	  23919	   5d6f	net/bluetooth/cmtp/built-in.o.new2
  18927	   1172	   4264	  24363	   5f2b	net/bluetooth/cmtp/built-in.o.old
  19237	   1172	   5152	  25561	   63d9	net/bluetooth/hidp/built-in.o.new2
  19581	   1172	   5152	  25905	   6531	net/bluetooth/hidp/built-in.o.old
  59461	   3884	  14464	  77809	  12ff1	net/bluetooth/rfcomm/built-in.o.new2
  61206	   3884	  14464	  79554	  136c2	net/bluetooth/rfcomm/built-in.o.old

with x86 defconfig (and just bluetooth):

$ size net/bluetooth/built-in.o.defconfig.*
   text	   data	    bss	    dec	    hex	filename
  66358	    933	    100	  67391	  1073f	net/bluetooth/built-in.o.defconfig.new
  66643	    933	    100	  67676	  1085c	net/bluetooth/built-in.o.defconfig.old

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 include/net/bluetooth/bluetooth.h |    9 ++++++---
 net/bluetooth/lib.c               |   19 +++++++++++++++++++
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 7bccaf9..042591c 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -76,9 +76,12 @@ struct bt_power {
 #define BT_POWER_FORCE_ACTIVE_OFF 0
 #define BT_POWER_FORCE_ACTIVE_ON  1
 
-#define BT_INFO(fmt, arg...) printk(KERN_INFO "Bluetooth: " fmt "\n" , ## arg)
-#define BT_ERR(fmt, arg...)  printk(KERN_ERR "%s: " fmt "\n" , __func__ , ## arg)
-#define BT_DBG(fmt, arg...)  pr_debug("%s: " fmt "\n" , __func__ , ## arg)
+__attribute__((format (printf, 2, 3)))
+int bt_printk(const char *level, const char *fmt, ...);
+
+#define BT_INFO(fmt, arg...)	bt_printk(KERN_INFO, pr_fmt(fmt), ##arg)
+#define BT_ERR(fmt, arg...)	bt_printk(KERN_ERR, pr_fmt(fmt), ##arg)
+#define BT_DBG(fmt, arg...)	pr_debug(fmt "\n", ##arg)
 
 /* Connection and socket states */
 enum {
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index b826d1b..fdb3ec3 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -150,3 +150,22 @@ int bt_err(__u16 code)
 	}
 }
 EXPORT_SYMBOL(bt_err);
+
+int bt_printk(const char *level, const char *format, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, format);
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	r = printk("%sbluetooth: %pV\n", level, &vaf);
+
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(bt_printk);
-- 
1.7.6.rc1
