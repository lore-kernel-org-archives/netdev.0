From: Andi Kleen <ak@colin2.muc.de>
Subject: [PATCH] Add 32bit emulation for wireless
Date: 19 Jan 2004 13:33:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119123343.GA16292@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 19 Jan 2004 13:33:43 +0100
To: netdev@oss.sgi.com, jt@hpl.hp.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[First version of this mail seems to have gotten lost. Apologies if you
see it twice]

Some distributions call iwconfig at every bootup and I was sick of 
seeing all the unimplemented ioctl messages on AMD64 with a 32bit userland.

This patch implements ioctl emulation for the wireless subsytem.
The only structure that was incompatible from visual inspection was
"iw_point". The rest is just passed through.

It reuses the existing ioctl description table, but renames it to 
export it (standard_ioctls wasn't a good name for a global variable) 

I don't actually have have a working wireless card (only some non supported
Samsung one), so I wasn't able to test it, but at least the messages
are gone.

-Andi

diff -u linux-2.6.1-amd64/net/core/wireless.c-WIRELESS linux-2.6.1-amd64/net/core/wireless.c
--- linux-2.6.1-amd64/net/core/wireless.c-WIRELESS	2003-10-09 00:29:02.000000000 +0200
+++ linux-2.6.1-amd64/net/core/wireless.c	2004-01-17 18:46:58.000000000 +0100
@@ -27,7 +27,7 @@
  *	o Initial dumb commit strategy based on orinoco.c
  *
  * v3 - 19.12.01 - Jean II
- *	o Make sure we don't go out of standard_ioctl[] in ioctl_standard_call
+ *	o Make sure we don't go out of wireless_ioctl[] in ioctl_standard_call
  *	o Add event dispatcher function
  *	o Add event description
  *	o Propagate events as rtnetlink IFLA_WIRELESS option
@@ -91,7 +91,7 @@
  * Meta-data about all the standard Wireless Extension request we
  * know about.
  */
-static const struct iw_ioctl_description standard_ioctl[] = {
+const struct iw_ioctl_description wireless_ioctl[] = {
 	[SIOCSIWCOMMIT	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
 	},
@@ -266,7 +266,7 @@
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
 };
-static const int standard_ioctl_num = (sizeof(standard_ioctl) /
+const int wireless_ioctl_num = (sizeof(wireless_ioctl) /
 				       sizeof(struct iw_ioctl_description));
 
 /*
@@ -593,9 +593,9 @@
 	int					user_size = 0;
 
 	/* Get the description of the IOCTL */
-	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+	if((cmd - SIOCIWFIRST) >= wireless_ioctl_num)
 		return -EOPNOTSUPP;
-	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
+	descr = &(wireless_ioctl[cmd - SIOCIWFIRST]);
 
 #ifdef WE_IOCTL_DEBUG
 	printk(KERN_DEBUG "%s (WE) : Found standard handler for 0x%04X\n",
@@ -1041,8 +1041,8 @@
 	/* Get the description of the IOCTL */
 	if(cmd <= SIOCIWLAST) {
 		cmd_index = cmd - SIOCIWFIRST;
-		if(cmd_index < standard_ioctl_num)
-			descr = &(standard_ioctl[cmd_index]);
+		if(cmd_index < wireless_ioctl_num)
+			descr = &(wireless_ioctl[cmd_index]);
 	} else {
 		cmd_index = cmd - IWEVFIRST;
 		if(cmd_index < standard_event_num)
diff -u linux-2.6.1-amd64/fs/compat_ioctl.c-WIRELESS linux-2.6.1-amd64/fs/compat_ioctl.c
--- linux-2.6.1-amd64/fs/compat_ioctl.c-WIRELESS	2004-01-01 06:25:25.000000000 +0100
+++ linux-2.6.1-amd64/fs/compat_ioctl.c	2004-01-17 19:02:44.000000000 +0100
@@ -65,6 +65,8 @@
 #include <linux/ncp_fs.h>
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
 
 #include <net/sock.h>          /* siocdevprivate_ioctl */
 #include <net/bluetooth/bluetooth.h>
@@ -706,6 +708,69 @@
 	return err;
 }
 
+#ifdef CONFIG_NET_RADIO
+
+extern const struct iw_ioctl_description wireless_ioctl[];
+extern int wireless_ioctl_num;
+
+/* assumes no padding */
+struct iw_point32 { 
+	compat_uptr_t pointer;
+	u16 length;
+	u16 flags; 
+}; 
+
+struct iwreq32 { 
+	char ifrn_name[IFNAMSIZ]; 
+	struct iw_point32 iw_point; 
+};
+
+static int wireless_ioctl32(unsigned int fd, unsigned int cmd, unsigned long arg)
+{ 
+	int num = cmd - SIOCIWFIRSTPRIV;
+	if (num >= wireless_ioctl_num) { 
+		printk(KERN_DEBUG "%s: unknown wireless ioctl %x\n", current->comm, cmd);
+		return -EINVAL;
+	}
+
+	/* only iw_point needs conversion right now. If any others do add them
+	   to this switch. */ 
+
+	switch (wireless_ioctl[num].header_type) { 
+	case IW_HEADER_TYPE_POINT: { 
+		int err;
+		compat_uptr_t ptr;
+		struct iwreq32 *i32 = (struct iwreq32 *)arg;
+		struct iwreq i, *iu = compat_alloc_user_space(sizeof(struct iwreq));
+
+		if (!access_ok(VERIFY_READ, i32, sizeof(struct iwreq32)))
+			return -EFAULT;
+		
+		err = __copy_from_user(i.ifr_ifrn.ifrn_name, i32->ifrn_name,IFNAMSIZ);
+		err |= __get_user(ptr, &i32->iw_point.pointer); 
+		i.u.essid.pointer = compat_ptr(ptr);
+		err |= __get_user(i.u.essid.length, &i32->iw_point.length); 
+		err |= __get_user(i.u.essid.flags, &i32->iw_point.flags);; 
+		if (!err) 
+			err |= copy_to_user(iu, &i, sizeof(struct iwreq));
+		if (err) 
+			return -EFAULT;
+
+		arg = (unsigned long) iu; 			
+		break;
+	}
+	} 
+
+	return sys_ioctl(fd, cmd, arg);
+} 
+#else
+/* stub to avoid warning */
+static int wireless_ioctl32(unsigned int fd, unsigned int cmd, unsigned long arg)
+{ 
+	return -ENOTTY; 
+} 
+#endif
+
 struct rtentry32 {
         u32   		rt_pad1;
         struct sockaddr rt_dst;         /* target address               */
@@ -3133,6 +3198,39 @@
 HANDLE_IOCTL(I2C_FUNCS, w_long)
 HANDLE_IOCTL(I2C_RDWR, do_i2c_rdwr_ioctl)
 HANDLE_IOCTL(I2C_SMBUS, do_i2c_smbus_ioctl)
+/* wireless */
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+0,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+1,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+2,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+3,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+4,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+5,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+6,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+7,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+8,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+9,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+10,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+11,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+12,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+13,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+14,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+15,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+16,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+17,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+18,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+19,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+20,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+21,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+22,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+23,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+24,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+25,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+26,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+27,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+28,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+29,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+30,wireless_ioctl32)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV+31,wireless_ioctl32)
 
 #undef DECLARES
 #endif
