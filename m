From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, WTF] atm: move all compat_ioctl handling to atm/ioctl.c
Date: Fri, 6 Nov 2009 15:00:01 +0100
Message-ID: <200911061500.01651.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754304AbZKFOAI@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some interesting historic reasons that are not at all clear to me,
we seem to have two implementations of the ATM ioctl compatibility
layer in the kernel, and we use a combination of the two.

For ioctl numbers that have the same identifier on 32 and 64 bit systems,
we go directly through the compat_ioctl socket operation, for those that
differ, we do a conversion in fs/compat_ioctl.c.

This patch moves both variants into the vcc_compat_ioctl() function, while
preserving the current behaviour. It also kills off the COMPATIBLE_IOCTL
definitions that we never use here.
Doing it this way is clearly not a good solution, but I hope it is a
step into the right direction, so that someone is able to clean up this
mess for real.

Found while trying to untangle the compat socket ioctl mess
in fs/compat_ioctl.c.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/compat_ioctl.c |  205 -----------------------------------------------------
 net/atm/ioctl.c   |  172 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 171 insertions(+), 206 deletions(-)


diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index f91fd51..8b78b5f 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1212,170 +1212,6 @@ static int do_smb_getmountuid(unsigned int fd, unsigned int cmd, unsigned long a
 	return err;
 }
 
-struct atmif_sioc32 {
-        compat_int_t	number;
-        compat_int_t	length;
-        compat_caddr_t	arg;
-};
-
-struct atm_iobuf32 {
-	compat_int_t	length;
-	compat_caddr_t	buffer;
-};
-
-#define ATM_GETLINKRATE32 _IOW('a', ATMIOC_ITF+1, struct atmif_sioc32)
-#define ATM_GETNAMES32    _IOW('a', ATMIOC_ITF+3, struct atm_iobuf32)
-#define ATM_GETTYPE32     _IOW('a', ATMIOC_ITF+4, struct atmif_sioc32)
-#define ATM_GETESI32	  _IOW('a', ATMIOC_ITF+5, struct atmif_sioc32)
-#define ATM_GETADDR32	  _IOW('a', ATMIOC_ITF+6, struct atmif_sioc32)
-#define ATM_RSTADDR32	  _IOW('a', ATMIOC_ITF+7, struct atmif_sioc32)
-#define ATM_ADDADDR32	  _IOW('a', ATMIOC_ITF+8, struct atmif_sioc32)
-#define ATM_DELADDR32	  _IOW('a', ATMIOC_ITF+9, struct atmif_sioc32)
-#define ATM_GETCIRANGE32  _IOW('a', ATMIOC_ITF+10, struct atmif_sioc32)
-#define ATM_SETCIRANGE32  _IOW('a', ATMIOC_ITF+11, struct atmif_sioc32)
-#define ATM_SETESI32      _IOW('a', ATMIOC_ITF+12, struct atmif_sioc32)
-#define ATM_SETESIF32     _IOW('a', ATMIOC_ITF+13, struct atmif_sioc32)
-#define ATM_GETSTAT32     _IOW('a', ATMIOC_SARCOM+0, struct atmif_sioc32)
-#define ATM_GETSTATZ32    _IOW('a', ATMIOC_SARCOM+1, struct atmif_sioc32)
-#define ATM_GETLOOP32	  _IOW('a', ATMIOC_SARCOM+2, struct atmif_sioc32)
-#define ATM_SETLOOP32	  _IOW('a', ATMIOC_SARCOM+3, struct atmif_sioc32)
-#define ATM_QUERYLOOP32	  _IOW('a', ATMIOC_SARCOM+4, struct atmif_sioc32)
-
-static struct {
-        unsigned int cmd32;
-        unsigned int cmd;
-} atm_ioctl_map[] = {
-        { ATM_GETLINKRATE32, ATM_GETLINKRATE },
-	{ ATM_GETNAMES32,    ATM_GETNAMES },
-        { ATM_GETTYPE32,     ATM_GETTYPE },
-        { ATM_GETESI32,      ATM_GETESI },
-        { ATM_GETADDR32,     ATM_GETADDR },
-        { ATM_RSTADDR32,     ATM_RSTADDR },
-        { ATM_ADDADDR32,     ATM_ADDADDR },
-        { ATM_DELADDR32,     ATM_DELADDR },
-        { ATM_GETCIRANGE32,  ATM_GETCIRANGE },
-	{ ATM_SETCIRANGE32,  ATM_SETCIRANGE },
-	{ ATM_SETESI32,      ATM_SETESI },
-	{ ATM_SETESIF32,     ATM_SETESIF },
-	{ ATM_GETSTAT32,     ATM_GETSTAT },
-	{ ATM_GETSTATZ32,    ATM_GETSTATZ },
-	{ ATM_GETLOOP32,     ATM_GETLOOP },
-	{ ATM_SETLOOP32,     ATM_SETLOOP },
-	{ ATM_QUERYLOOP32,   ATM_QUERYLOOP }
-};
-
-#define NR_ATM_IOCTL ARRAY_SIZE(atm_ioctl_map)
-
-static int do_atm_iobuf(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct atm_iobuf   __user *iobuf;
-	struct atm_iobuf32 __user *iobuf32;
-	u32 data;
-	void __user *datap;
-	int len, err;
-
-	iobuf = compat_alloc_user_space(sizeof(*iobuf));
-	iobuf32 = compat_ptr(arg);
-
-	if (get_user(len, &iobuf32->length) ||
-	    get_user(data, &iobuf32->buffer))
-		return -EFAULT;
-	datap = compat_ptr(data);
-	if (put_user(len, &iobuf->length) ||
-	    put_user(datap, &iobuf->buffer))
-		return -EFAULT;
-
-	err = sys_ioctl(fd, cmd, (unsigned long)iobuf);
-
-	if (!err) {
-		if (copy_in_user(&iobuf32->length, &iobuf->length,
-				 sizeof(int)))
-			err = -EFAULT;
-	}
-
-	return err;
-}
-
-static int do_atmif_sioc(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-        struct atmif_sioc   __user *sioc;
-	struct atmif_sioc32 __user *sioc32;
-	u32 data;
-	void __user *datap;
-	int err;
-        
-	sioc = compat_alloc_user_space(sizeof(*sioc));
-	sioc32 = compat_ptr(arg);
-
-	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int)) ||
-	    get_user(data, &sioc32->arg))
-		return -EFAULT;
-	datap = compat_ptr(data);
-	if (put_user(datap, &sioc->arg))
-		return -EFAULT;
-
-	err = sys_ioctl(fd, cmd, (unsigned long) sioc);
-
-	if (!err) {
-		if (copy_in_user(&sioc32->length, &sioc->length,
-				 sizeof(int)))
-			err = -EFAULT;
-	}
-	return err;
-}
-
-static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
-{
-        int i;
-        unsigned int cmd = 0;
-        
-	switch (cmd32) {
-	case SONET_GETSTAT:
-	case SONET_GETSTATZ:
-	case SONET_GETDIAG:
-	case SONET_SETDIAG:
-	case SONET_CLRDIAG:
-	case SONET_SETFRAMING:
-	case SONET_GETFRAMING:
-	case SONET_GETFRSENSE:
-		return do_atmif_sioc(fd, cmd32, arg);
-	}
-
-	for (i = 0; i < NR_ATM_IOCTL; i++) {
-		if (cmd32 == atm_ioctl_map[i].cmd32) {
-			cmd = atm_ioctl_map[i].cmd;
-			break;
-		}
-	}
-	if (i == NR_ATM_IOCTL)
-	        return -EINVAL;
-        
-        switch (cmd) {
-	case ATM_GETNAMES:
-		return do_atm_iobuf(fd, cmd, arg);
-	    
-	case ATM_GETLINKRATE:
-        case ATM_GETTYPE:
-        case ATM_GETESI:
-        case ATM_GETADDR:
-        case ATM_RSTADDR:
-        case ATM_ADDADDR:
-        case ATM_DELADDR:
-        case ATM_GETCIRANGE:
-	case ATM_SETCIRANGE:
-	case ATM_SETESI:
-	case ATM_SETESIF:
-	case ATM_GETSTAT:
-	case ATM_GETSTATZ:
-	case ATM_GETLOOP:
-	case ATM_SETLOOP:
-	case ATM_QUERYLOOP:
-                return do_atmif_sioc(fd, cmd, arg);
-        }
-
-        return -EINVAL;
-}
-
 static __used int
 ret_einval(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
@@ -2311,22 +2147,6 @@ COMPATIBLE_IOCTL(RAW_SETBIND)
 COMPATIBLE_IOCTL(RAW_GETBIND)
 /* SMB ioctls which do not need any translations */
 COMPATIBLE_IOCTL(SMB_IOC_NEWCONN)
-/* Little a */
-COMPATIBLE_IOCTL(ATMSIGD_CTRL)
-COMPATIBLE_IOCTL(ATMARPD_CTRL)
-COMPATIBLE_IOCTL(ATMLEC_CTRL)
-COMPATIBLE_IOCTL(ATMLEC_MCAST)
-COMPATIBLE_IOCTL(ATMLEC_DATA)
-COMPATIBLE_IOCTL(ATM_SETSC)
-COMPATIBLE_IOCTL(SIOCSIFATMTCP)
-COMPATIBLE_IOCTL(SIOCMKCLIP)
-COMPATIBLE_IOCTL(ATMARP_MKIP)
-COMPATIBLE_IOCTL(ATMARP_SETENTRY)
-COMPATIBLE_IOCTL(ATMARP_ENCAP)
-COMPATIBLE_IOCTL(ATMTCP_CREATE)
-COMPATIBLE_IOCTL(ATMTCP_REMOVE)
-COMPATIBLE_IOCTL(ATMMPC_CTRL)
-COMPATIBLE_IOCTL(ATMMPC_DATA)
 /* Watchdog */
 COMPATIBLE_IOCTL(WDIOC_GETSUPPORT)
 COMPATIBLE_IOCTL(WDIOC_GETSTATUS)
@@ -2613,31 +2433,6 @@ HANDLE_IOCTL(KDFONTOP, do_kdfontop_ioctl)
 /* One SMB ioctl needs translations. */
 #define SMB_IOC_GETMOUNTUID_32 _IOR('u', 1, compat_uid_t)
 HANDLE_IOCTL(SMB_IOC_GETMOUNTUID_32, do_smb_getmountuid)
-HANDLE_IOCTL(ATM_GETLINKRATE32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETNAMES32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETTYPE32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETESI32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETADDR32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_RSTADDR32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_ADDADDR32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_DELADDR32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETCIRANGE32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_SETCIRANGE32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_SETESI32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_SETESIF32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETSTAT32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETSTATZ32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_GETLOOP32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_SETLOOP32, do_atm_ioctl)
-HANDLE_IOCTL(ATM_QUERYLOOP32, do_atm_ioctl)
-HANDLE_IOCTL(SONET_GETSTAT, do_atm_ioctl)
-HANDLE_IOCTL(SONET_GETSTATZ, do_atm_ioctl)
-HANDLE_IOCTL(SONET_GETDIAG, do_atm_ioctl)
-HANDLE_IOCTL(SONET_SETDIAG, do_atm_ioctl)
-HANDLE_IOCTL(SONET_CLRDIAG, do_atm_ioctl)
-HANDLE_IOCTL(SONET_SETFRAMING, do_atm_ioctl)
-HANDLE_IOCTL(SONET_GETFRAMING, do_atm_ioctl)
-HANDLE_IOCTL(SONET_GETFRSENSE, do_atm_ioctl)
 /* block stuff */
 #ifdef CONFIG_BLOCK
 /* loop */
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 4da8892..163547d 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -191,8 +191,178 @@ int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 }
 
 #ifdef CONFIG_COMPAT
+struct atmif_sioc32 {
+	compat_int_t	number;
+	compat_int_t	length;
+	compat_caddr_t	arg;
+};
+
+struct atm_iobuf32 {
+	compat_int_t	length;
+	compat_caddr_t	buffer;
+};
+
+#define ATM_GETLINKRATE32 _IOW('a', ATMIOC_ITF+1, struct atmif_sioc32)
+#define ATM_GETNAMES32    _IOW('a', ATMIOC_ITF+3, struct atm_iobuf32)
+#define ATM_GETTYPE32     _IOW('a', ATMIOC_ITF+4, struct atmif_sioc32)
+#define ATM_GETESI32	  _IOW('a', ATMIOC_ITF+5, struct atmif_sioc32)
+#define ATM_GETADDR32	  _IOW('a', ATMIOC_ITF+6, struct atmif_sioc32)
+#define ATM_RSTADDR32	  _IOW('a', ATMIOC_ITF+7, struct atmif_sioc32)
+#define ATM_ADDADDR32	  _IOW('a', ATMIOC_ITF+8, struct atmif_sioc32)
+#define ATM_DELADDR32	  _IOW('a', ATMIOC_ITF+9, struct atmif_sioc32)
+#define ATM_GETCIRANGE32  _IOW('a', ATMIOC_ITF+10, struct atmif_sioc32)
+#define ATM_SETCIRANGE32  _IOW('a', ATMIOC_ITF+11, struct atmif_sioc32)
+#define ATM_SETESI32      _IOW('a', ATMIOC_ITF+12, struct atmif_sioc32)
+#define ATM_SETESIF32     _IOW('a', ATMIOC_ITF+13, struct atmif_sioc32)
+#define ATM_GETSTAT32     _IOW('a', ATMIOC_SARCOM+0, struct atmif_sioc32)
+#define ATM_GETSTATZ32    _IOW('a', ATMIOC_SARCOM+1, struct atmif_sioc32)
+#define ATM_GETLOOP32	  _IOW('a', ATMIOC_SARCOM+2, struct atmif_sioc32)
+#define ATM_SETLOOP32	  _IOW('a', ATMIOC_SARCOM+3, struct atmif_sioc32)
+#define ATM_QUERYLOOP32	  _IOW('a', ATMIOC_SARCOM+4, struct atmif_sioc32)
+
+static struct {
+	unsigned int cmd32;
+	unsigned int cmd;
+} atm_ioctl_map[] = {
+	{ ATM_GETLINKRATE32, ATM_GETLINKRATE },
+	{ ATM_GETNAMES32,    ATM_GETNAMES },
+	{ ATM_GETTYPE32,     ATM_GETTYPE },
+	{ ATM_GETESI32,      ATM_GETESI },
+	{ ATM_GETADDR32,     ATM_GETADDR },
+	{ ATM_RSTADDR32,     ATM_RSTADDR },
+	{ ATM_ADDADDR32,     ATM_ADDADDR },
+	{ ATM_DELADDR32,     ATM_DELADDR },
+	{ ATM_GETCIRANGE32,  ATM_GETCIRANGE },
+	{ ATM_SETCIRANGE32,  ATM_SETCIRANGE },
+	{ ATM_SETESI32,      ATM_SETESI },
+	{ ATM_SETESIF32,     ATM_SETESIF },
+	{ ATM_GETSTAT32,     ATM_GETSTAT },
+	{ ATM_GETSTATZ32,    ATM_GETSTATZ },
+	{ ATM_GETLOOP32,     ATM_GETLOOP },
+	{ ATM_SETLOOP32,     ATM_SETLOOP },
+	{ ATM_QUERYLOOP32,   ATM_QUERYLOOP }
+};
+
+#define NR_ATM_IOCTL ARRAY_SIZE(atm_ioctl_map)
+
+static int do_atm_iobuf(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct atm_iobuf   __user *iobuf;
+	struct atm_iobuf32 __user *iobuf32;
+	u32 data;
+	void __user *datap;
+	int len, err;
+
+	iobuf = compat_alloc_user_space(sizeof(*iobuf));
+	iobuf32 = compat_ptr(arg);
+
+	if (get_user(len, &iobuf32->length) ||
+	    get_user(data, &iobuf32->buffer))
+		return -EFAULT;
+	datap = compat_ptr(data);
+	if (put_user(len, &iobuf->length) ||
+	    put_user(datap, &iobuf->buffer))
+		return -EFAULT;
+
+	err = do_vcc_ioctl(sock, cmd, (unsigned long)iobuf, 0);
+
+	if (!err) {
+		if (copy_in_user(&iobuf32->length, &iobuf->length,
+				 sizeof(int)))
+			err = -EFAULT;
+	}
+
+	return err;
+}
+
+static int do_atmif_sioc(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct atmif_sioc   __user *sioc;
+	struct atmif_sioc32 __user *sioc32;
+	u32 data;
+	void __user *datap;
+	int err;
+
+	sioc = compat_alloc_user_space(sizeof(*sioc));
+	sioc32 = compat_ptr(arg);
+
+	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int)) ||
+	    get_user(data, &sioc32->arg))
+		return -EFAULT;
+	datap = compat_ptr(data);
+	if (put_user(datap, &sioc->arg))
+		return -EFAULT;
+
+	err = do_vcc_ioctl(sock, cmd, (unsigned long) sioc, 0);
+
+	if (!err) {
+		if (copy_in_user(&sioc32->length, &sioc->length,
+				 sizeof(int)))
+			err = -EFAULT;
+	}
+	return err;
+}
+
+static int do_atm_ioctl(struct socket *sock, unsigned int cmd32, unsigned long arg)
+{
+	int i;
+	unsigned int cmd = 0;
+
+	switch (cmd32) {
+	case SONET_GETSTAT:
+	case SONET_GETSTATZ:
+	case SONET_GETDIAG:
+	case SONET_SETDIAG:
+	case SONET_CLRDIAG:
+	case SONET_SETFRAMING:
+	case SONET_GETFRAMING:
+	case SONET_GETFRSENSE:
+		return do_atmif_sioc(sock, cmd32, arg);
+	}
+
+	for (i = 0; i < NR_ATM_IOCTL; i++) {
+		if (cmd32 == atm_ioctl_map[i].cmd32) {
+			cmd = atm_ioctl_map[i].cmd;
+			break;
+		}
+	}
+	if (i == NR_ATM_IOCTL)
+		return -EINVAL;
+
+	switch (cmd) {
+	case ATM_GETNAMES:
+		return do_atm_iobuf(sock, cmd, arg);
+
+	case ATM_GETLINKRATE:
+	case ATM_GETTYPE:
+	case ATM_GETESI:
+	case ATM_GETADDR:
+	case ATM_RSTADDR:
+	case ATM_ADDADDR:
+	case ATM_DELADDR:
+	case ATM_GETCIRANGE:
+	case ATM_SETCIRANGE:
+	case ATM_SETESI:
+	case ATM_SETESIF:
+	case ATM_GETSTAT:
+	case ATM_GETSTATZ:
+	case ATM_GETLOOP:
+	case ATM_SETLOOP:
+	case ATM_QUERYLOOP:
+		return do_atmif_sioc(sock, cmd, arg);
+	}
+
+	return -EINVAL;
+}
+
 int vcc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
-	return do_vcc_ioctl(sock, cmd, arg, 1);
+	int ret;
+
+	ret = do_vcc_ioctl(sock, cmd, arg, 1);
+	if (ret != -ENOIOCTLCMD)
+		return ret;
+
+	return do_atm_ioctl(sock, cmd, arg);
 }
 #endif
