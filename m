From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/7] copy socket ioctl code to net/socket.h
Date: Fri,  6 Nov 2009 19:09:07 +0100
Message-ID: <1257530949-9695-6-git-send-email-arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759564AbZKFSLG@vger.kernel.org>
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes an identical copy of the socket compat_ioctl code
from fs/compat_ioctl.c to net/socket.c, as a preparation
for moving the functionality in a way that can be easily
reviewed.

The code is hidden inside of #if 0 and gets activated in the
patch that will make it work.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/socket.c |  717 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 717 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 7565536..74d5816 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2300,6 +2300,723 @@ void socket_seq_show(struct seq_file *seq)
 #endif				/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_COMPAT
+#if 0
+static int do_siocgstamp(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct compat_timeval __user *up = compat_ptr(arg);
+	struct timeval ktv;
+	mm_segment_t old_fs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = sys_ioctl(fd, cmd, (unsigned long)&ktv);
+	set_fs(old_fs);
+	if(!err) {
+		err = put_user(ktv.tv_sec, &up->tv_sec);
+		err |= __put_user(ktv.tv_usec, &up->tv_usec);
+	}
+	return err;
+}
+
+static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct compat_timespec __user *up = compat_ptr(arg);
+	struct timespec kts;
+	mm_segment_t old_fs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = sys_ioctl(fd, cmd, (unsigned long)&kts);
+	set_fs(old_fs);
+	if (!err) {
+		err = put_user(kts.tv_sec, &up->tv_sec);
+		err |= __put_user(kts.tv_nsec, &up->tv_nsec);
+	}
+	return err;
+}
+
+struct ifmap32 {
+	compat_ulong_t mem_start;
+	compat_ulong_t mem_end;
+	unsigned short base_addr;
+	unsigned char irq;
+	unsigned char dma;
+	unsigned char port;
+};
+
+struct ifreq32 {
+#define IFHWADDRLEN     6
+#define IFNAMSIZ        16
+        union {
+                char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
+        } ifr_ifrn;
+        union {
+                struct  sockaddr ifru_addr;
+                struct  sockaddr ifru_dstaddr;
+                struct  sockaddr ifru_broadaddr;
+                struct  sockaddr ifru_netmask;
+                struct  sockaddr ifru_hwaddr;
+                short   ifru_flags;
+                compat_int_t     ifru_ivalue;
+                compat_int_t     ifru_mtu;
+                struct  ifmap32 ifru_map;
+                char    ifru_slave[IFNAMSIZ];   /* Just fits the size */
+		char	ifru_newname[IFNAMSIZ];
+                compat_caddr_t ifru_data;
+	    /* XXXX? ifru_settings should be here */
+        } ifr_ifru;
+};
+
+struct ifconf32 {
+        compat_int_t	ifc_len;                        /* size of buffer       */
+        compat_caddr_t  ifcbuf;
+};
+
+static int dev_ifname32(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifreq __user *uifr;
+	int err;
+
+	uifr = compat_alloc_user_space(sizeof(struct ifreq));
+	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)))
+		return -EFAULT;
+
+	err = sys_ioctl(fd, SIOCGIFNAME, (unsigned long)uifr);
+	if (err)
+		return err;
+
+	if (copy_in_user(compat_ptr(arg), uifr, sizeof(struct ifreq32)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifconf32 ifc32;
+	struct ifconf ifc;
+	struct ifconf __user *uifc;
+	struct ifreq32 __user *ifr32;
+	struct ifreq __user *ifr;
+	unsigned int i, j;
+	int err;
+
+	if (copy_from_user(&ifc32, compat_ptr(arg), sizeof(struct ifconf32)))
+		return -EFAULT;
+
+	if (ifc32.ifcbuf == 0) {
+		ifc32.ifc_len = 0;
+		ifc.ifc_len = 0;
+		ifc.ifc_req = NULL;
+		uifc = compat_alloc_user_space(sizeof(struct ifconf));
+	} else {
+		size_t len =((ifc32.ifc_len / sizeof (struct ifreq32)) + 1) *
+			sizeof (struct ifreq);
+		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
+		ifc.ifc_len = len;
+		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
+		ifr32 = compat_ptr(ifc32.ifcbuf);
+		for (i = 0; i < ifc32.ifc_len; i += sizeof (struct ifreq32)) {
+			if (copy_in_user(ifr, ifr32, sizeof(struct ifreq32)))
+				return -EFAULT;
+			ifr++;
+			ifr32++; 
+		}
+	}
+	if (copy_to_user(uifc, &ifc, sizeof(struct ifconf)))
+		return -EFAULT;
+
+	err = sys_ioctl (fd, SIOCGIFCONF, (unsigned long)uifc);	
+	if (err)
+		return err;
+
+	if (copy_from_user(&ifc, uifc, sizeof(struct ifconf))) 
+		return -EFAULT;
+
+	ifr = ifc.ifc_req;
+	ifr32 = compat_ptr(ifc32.ifcbuf);
+	for (i = 0, j = 0;
+             i + sizeof (struct ifreq32) <= ifc32.ifc_len && j < ifc.ifc_len;
+	     i += sizeof (struct ifreq32), j += sizeof (struct ifreq)) {
+		if (copy_in_user(ifr32, ifr, sizeof (struct ifreq32)))
+			return -EFAULT;
+		ifr32++;
+		ifr++;
+	}
+
+	if (ifc32.ifcbuf == 0) {
+		/* Translate from 64-bit structure multiple to
+		 * a 32-bit one.
+		 */
+		i = ifc.ifc_len;
+		i = ((i / sizeof(struct ifreq)) * sizeof(struct ifreq32));
+		ifc32.ifc_len = i;
+	} else {
+		ifc32.ifc_len = i;
+	}
+	if (copy_to_user(compat_ptr(arg), &ifc32, sizeof(struct ifconf32)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifreq __user *ifr;
+	struct ifreq32 __user *ifr32;
+	u32 data;
+	void __user *datap;
+	
+	ifr = compat_alloc_user_space(sizeof(*ifr));
+	ifr32 = compat_ptr(arg);
+
+	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
+		return -EFAULT;
+
+	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
+		return -EFAULT;
+
+	datap = compat_ptr(data);
+	if (put_user(datap, &ifr->ifr_ifru.ifru_data))
+		return -EFAULT;
+
+	return sys_ioctl(fd, cmd, (unsigned long) ifr);
+}
+
+static int bond_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifreq kifr;
+	struct ifreq __user *uifr;
+	struct ifreq32 __user *ifr32 = compat_ptr(arg);
+	mm_segment_t old_fs;
+	int err;
+	u32 data;
+	void __user *datap;
+
+	switch (cmd) {
+	case SIOCBONDENSLAVE:
+	case SIOCBONDRELEASE:
+	case SIOCBONDSETHWADDR:
+	case SIOCBONDCHANGEACTIVE:
+		if (copy_from_user(&kifr, ifr32, sizeof(struct ifreq32)))
+			return -EFAULT;
+
+		old_fs = get_fs();
+		set_fs (KERNEL_DS);
+		err = sys_ioctl (fd, cmd, (unsigned long)&kifr);
+		set_fs (old_fs);
+
+		return err;
+	case SIOCBONDSLAVEINFOQUERY:
+	case SIOCBONDINFOQUERY:
+		uifr = compat_alloc_user_space(sizeof(*uifr));
+		if (copy_in_user(&uifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
+			return -EFAULT;
+
+		if (get_user(data, &ifr32->ifr_ifru.ifru_data))
+			return -EFAULT;
+
+		datap = compat_ptr(data);
+		if (put_user(datap, &uifr->ifr_ifru.ifru_data))
+			return -EFAULT;
+
+		return sys_ioctl (fd, cmd, (unsigned long)uifr);
+	default:
+		return -EINVAL;
+	};
+}
+
+static int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifreq __user *u_ifreq64;
+	struct ifreq32 __user *u_ifreq32 = compat_ptr(arg);
+	char tmp_buf[IFNAMSIZ];
+	void __user *data64;
+	u32 data32;
+
+	if (copy_from_user(&tmp_buf[0], &(u_ifreq32->ifr_ifrn.ifrn_name[0]),
+			   IFNAMSIZ))
+		return -EFAULT;
+	if (__get_user(data32, &u_ifreq32->ifr_ifru.ifru_data))
+		return -EFAULT;
+	data64 = compat_ptr(data32);
+
+	u_ifreq64 = compat_alloc_user_space(sizeof(*u_ifreq64));
+
+	/* Don't check these user accesses, just let that get trapped
+	 * in the ioctl handler instead.
+	 */
+	if (copy_to_user(&u_ifreq64->ifr_ifrn.ifrn_name[0], &tmp_buf[0],
+			 IFNAMSIZ))
+		return -EFAULT;
+	if (__put_user(data64, &u_ifreq64->ifr_ifru.ifru_data))
+		return -EFAULT;
+
+	return sys_ioctl(fd, cmd, (unsigned long) u_ifreq64);
+}
+
+static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct ifreq ifr;
+	struct ifreq32 __user *uifr32;
+	struct ifmap32 __user *uifmap32;
+	mm_segment_t old_fs;
+	int err;
+	
+	uifr32 = compat_ptr(arg);
+	uifmap32 = &uifr32->ifr_ifru.ifru_map;
+	switch (cmd) {
+	case SIOCSIFMAP:
+		err = copy_from_user(&ifr, uifr32, sizeof(ifr.ifr_name));
+		err |= __get_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
+		err |= __get_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
+		err |= __get_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
+		err |= __get_user(ifr.ifr_map.irq, &uifmap32->irq);
+		err |= __get_user(ifr.ifr_map.dma, &uifmap32->dma);
+		err |= __get_user(ifr.ifr_map.port, &uifmap32->port);
+		if (err)
+			return -EFAULT;
+		break;
+	case SIOCSHWTSTAMP:
+		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
+			return -EFAULT;
+		ifr.ifr_data = compat_ptr(uifr32->ifr_ifru.ifru_data);
+		break;
+	default:
+		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
+			return -EFAULT;
+		break;
+	}
+	old_fs = get_fs();
+	set_fs (KERNEL_DS);
+	err = sys_ioctl (fd, cmd, (unsigned long)&ifr);
+	set_fs (old_fs);
+	if (!err) {
+		switch (cmd) {
+		case SIOCGIFFLAGS:
+		case SIOCGIFMETRIC:
+		case SIOCGIFMTU:
+		case SIOCGIFMEM:
+		case SIOCGIFHWADDR:
+		case SIOCGIFINDEX:
+		case SIOCGIFADDR:
+		case SIOCGIFBRDADDR:
+		case SIOCGIFDSTADDR:
+		case SIOCGIFNETMASK:
+		case SIOCGIFTXQLEN:
+			if (copy_to_user(uifr32, &ifr, sizeof(*uifr32)))
+				return -EFAULT;
+			break;
+		case SIOCGIFMAP:
+			err = copy_to_user(uifr32, &ifr, sizeof(ifr.ifr_name));
+			err |= __put_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
+			err |= __put_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
+			err |= __put_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
+			err |= __put_user(ifr.ifr_map.irq, &uifmap32->irq);
+			err |= __put_user(ifr.ifr_map.dma, &uifmap32->dma);
+			err |= __put_user(ifr.ifr_map.port, &uifmap32->port);
+			if (err)
+				err = -EFAULT;
+			break;
+		}
+	}
+	return err;
+}
+
+struct rtentry32 {
+        u32   		rt_pad1;
+        struct sockaddr rt_dst;         /* target address               */
+        struct sockaddr rt_gateway;     /* gateway addr (RTF_GATEWAY)   */
+        struct sockaddr rt_genmask;     /* target network mask (IP)     */
+        unsigned short  rt_flags;
+        short           rt_pad2;
+        u32   		rt_pad3;
+        unsigned char   rt_tos;
+        unsigned char   rt_class;
+        short           rt_pad4;
+        short           rt_metric;      /* +1 for binary compatibility! */
+        /* char * */ u32 rt_dev;        /* forcing the device at add    */
+        u32   		rt_mtu;         /* per route MTU/Window         */
+        u32   		rt_window;      /* Window clamping              */
+        unsigned short  rt_irtt;        /* Initial RTT                  */
+
+};
+
+struct in6_rtmsg32 {
+	struct in6_addr		rtmsg_dst;
+	struct in6_addr		rtmsg_src;
+	struct in6_addr		rtmsg_gateway;
+	u32			rtmsg_type;
+	u16			rtmsg_dst_len;
+	u16			rtmsg_src_len;
+	u32			rtmsg_metric;
+	u32			rtmsg_info;
+	u32			rtmsg_flags;
+	s32			rtmsg_ifindex;
+};
+
+static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	int ret;
+	void *r = NULL;
+	struct in6_rtmsg r6;
+	struct rtentry r4;
+	char devname[16];
+	u32 rtdev;
+	mm_segment_t old_fs = get_fs();
+	
+	struct socket *mysock = sockfd_lookup(fd, &ret);
+
+	if (mysock && mysock->sk && mysock->sk->sk_family == AF_INET6) { /* ipv6 */
+		struct in6_rtmsg32 __user *ur6 = compat_ptr(arg);
+		ret = copy_from_user (&r6.rtmsg_dst, &(ur6->rtmsg_dst),
+			3 * sizeof(struct in6_addr));
+		ret |= __get_user (r6.rtmsg_type, &(ur6->rtmsg_type));
+		ret |= __get_user (r6.rtmsg_dst_len, &(ur6->rtmsg_dst_len));
+		ret |= __get_user (r6.rtmsg_src_len, &(ur6->rtmsg_src_len));
+		ret |= __get_user (r6.rtmsg_metric, &(ur6->rtmsg_metric));
+		ret |= __get_user (r6.rtmsg_info, &(ur6->rtmsg_info));
+		ret |= __get_user (r6.rtmsg_flags, &(ur6->rtmsg_flags));
+		ret |= __get_user (r6.rtmsg_ifindex, &(ur6->rtmsg_ifindex));
+		
+		r = (void *) &r6;
+	} else { /* ipv4 */
+		struct rtentry32 __user *ur4 = compat_ptr(arg);
+		ret = copy_from_user (&r4.rt_dst, &(ur4->rt_dst),
+					3 * sizeof(struct sockaddr));
+		ret |= __get_user (r4.rt_flags, &(ur4->rt_flags));
+		ret |= __get_user (r4.rt_metric, &(ur4->rt_metric));
+		ret |= __get_user (r4.rt_mtu, &(ur4->rt_mtu));
+		ret |= __get_user (r4.rt_window, &(ur4->rt_window));
+		ret |= __get_user (r4.rt_irtt, &(ur4->rt_irtt));
+		ret |= __get_user (rtdev, &(ur4->rt_dev));
+		if (rtdev) {
+			ret |= copy_from_user (devname, compat_ptr(rtdev), 15);
+			r4.rt_dev = devname; devname[15] = 0;
+		} else
+			r4.rt_dev = NULL;
+
+		r = (void *) &r4;
+	}
+
+	if (ret) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	set_fs (KERNEL_DS);
+	ret = sys_ioctl (fd, cmd, (unsigned long) r);
+	set_fs (old_fs);
+
+out:
+	if (mysock)
+		sockfd_put(mysock);
+
+	return ret;
+}
+
+/* Since old style bridge ioctl's endup using SIOCDEVPRIVATE
+ * for some operations; this forces use of the newer bridge-utils that
+ * use compatiable ioctls
+ */
+static int old_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	u32 tmp;
+
+	if (get_user(tmp, (u32 __user *) arg))
+		return -EFAULT;
+	if (tmp == BRCTL_GET_VERSION)
+		return BRCTL_VERSION + 1;
+	return -EINVAL;
+}
+
+struct atmif_sioc32 {
+        compat_int_t	number;
+        compat_int_t	length;
+        compat_caddr_t	arg;
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
+        unsigned int cmd32;
+        unsigned int cmd;
+} atm_ioctl_map[] = {
+        { ATM_GETLINKRATE32, ATM_GETLINKRATE },
+	{ ATM_GETNAMES32,    ATM_GETNAMES },
+        { ATM_GETTYPE32,     ATM_GETTYPE },
+        { ATM_GETESI32,      ATM_GETESI },
+        { ATM_GETADDR32,     ATM_GETADDR },
+        { ATM_RSTADDR32,     ATM_RSTADDR },
+        { ATM_ADDADDR32,     ATM_ADDADDR },
+        { ATM_DELADDR32,     ATM_DELADDR },
+        { ATM_GETCIRANGE32,  ATM_GETCIRANGE },
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
+static int do_atm_iobuf(unsigned int fd, unsigned int cmd, unsigned long arg)
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
+	err = sys_ioctl(fd, cmd, (unsigned long)iobuf);
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
+static int do_atmif_sioc(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+        struct atmif_sioc   __user *sioc;
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
+	err = sys_ioctl(fd, cmd, (unsigned long) sioc);
+
+	if (!err) {
+		if (copy_in_user(&sioc32->length, &sioc->length,
+				 sizeof(int)))
+			err = -EFAULT;
+	}
+	return err;
+}
+
+static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
+{
+        int i;
+        unsigned int cmd = 0;
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
+		return do_atmif_sioc(fd, cmd32, arg);
+	}
+
+	for (i = 0; i < NR_ATM_IOCTL; i++) {
+		if (cmd32 == atm_ioctl_map[i].cmd32) {
+			cmd = atm_ioctl_map[i].cmd;
+			break;
+		}
+	}
+	if (i == NR_ATM_IOCTL)
+	        return -EINVAL;
+        
+        switch (cmd) {
+	case ATM_GETNAMES:
+		return do_atm_iobuf(fd, cmd, arg);
+	    
+	case ATM_GETLINKRATE:
+        case ATM_GETTYPE:
+        case ATM_GETESI:
+        case ATM_GETADDR:
+        case ATM_RSTADDR:
+        case ATM_ADDADDR:
+        case ATM_DELADDR:
+        case ATM_GETCIRANGE:
+	case ATM_SETCIRANGE:
+	case ATM_SETESI:
+	case ATM_SETESIF:
+	case ATM_GETSTAT:
+	case ATM_GETSTATZ:
+	case ATM_GETLOOP:
+	case ATM_SETLOOP:
+	case ATM_QUERYLOOP:
+                return do_atmif_sioc(fd, cmd, arg);
+        }
+
+        return -EINVAL;
+}
+
+
+/* bridge */
+HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
+HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
+#ifdef CONFIG_NET
+HANDLE_IOCTL(SIOCGIFNAME, dev_ifname32)
+HANDLE_IOCTL(SIOCGIFCONF, dev_ifconf)
+HANDLE_IOCTL(SIOCGIFFLAGS, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFFLAGS, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFMETRIC, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFMETRIC, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFMTU, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFMTU, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFMEM, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFMEM, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFHWADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFHWADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCADDMULTI, dev_ifsioc)
+HANDLE_IOCTL(SIOCDELMULTI, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFINDEX, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFMAP, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
+HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
+
+HANDLE_IOCTL(SIOCDIFADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSARP, dev_ifsioc)
+HANDLE_IOCTL(SIOCDARP, dev_ifsioc)
+
+HANDLE_IOCTL(SIOCGIFBRDADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFBRDADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFDSTADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFDSTADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFNETMASK, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFNETMASK, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFPFLAGS, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFPFLAGS, dev_ifsioc)
+HANDLE_IOCTL(SIOCGIFTXQLEN, dev_ifsioc)
+HANDLE_IOCTL(SIOCSIFTXQLEN, dev_ifsioc)
+HANDLE_IOCTL(SIOCETHTOOL, ethtool_ioctl)
+HANDLE_IOCTL(SIOCBONDENSLAVE, bond_ioctl)
+HANDLE_IOCTL(SIOCBONDRELEASE, bond_ioctl)
+HANDLE_IOCTL(SIOCBONDSETHWADDR, bond_ioctl)
+HANDLE_IOCTL(SIOCBONDSLAVEINFOQUERY, bond_ioctl)
+HANDLE_IOCTL(SIOCBONDINFOQUERY, bond_ioctl)
+HANDLE_IOCTL(SIOCBONDCHANGEACTIVE, bond_ioctl)
+HANDLE_IOCTL(SIOCADDRT, routing_ioctl)
+HANDLE_IOCTL(SIOCDELRT, routing_ioctl)
+HANDLE_IOCTL(SIOCBRADDIF, dev_ifsioc)
+HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
+/* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
+HANDLE_IOCTL(SIOCRTMSG, ret_einval)
+HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
+HANDLE_IOCTL(SIOCGSTAMPNS, do_siocgstampns)
+#endif
+IGNORE_IOCTL(SIOCGIFCOUNT)
+/* Little a */
+COMPATIBLE_IOCTL(ATMSIGD_CTRL)
+COMPATIBLE_IOCTL(ATMARPD_CTRL)
+COMPATIBLE_IOCTL(ATMLEC_CTRL)
+COMPATIBLE_IOCTL(ATMLEC_MCAST)
+COMPATIBLE_IOCTL(ATMLEC_DATA)
+COMPATIBLE_IOCTL(ATM_SETSC)
+COMPATIBLE_IOCTL(SIOCSIFATMTCP)
+COMPATIBLE_IOCTL(SIOCMKCLIP)
+COMPATIBLE_IOCTL(ATMARP_MKIP)
+COMPATIBLE_IOCTL(ATMARP_SETENTRY)
+COMPATIBLE_IOCTL(ATMARP_ENCAP)
+COMPATIBLE_IOCTL(ATMTCP_CREATE)
+COMPATIBLE_IOCTL(ATMTCP_REMOVE)
+COMPATIBLE_IOCTL(ATMMPC_CTRL)
+COMPATIBLE_IOCTL(ATMMPC_DATA)
+HANDLE_IOCTL(ATM_GETLINKRATE32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETNAMES32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETTYPE32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETESI32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETADDR32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_RSTADDR32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_ADDADDR32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_DELADDR32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETCIRANGE32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_SETCIRANGE32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_SETESI32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_SETESIF32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETSTAT32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETSTATZ32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_GETLOOP32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_SETLOOP32, do_atm_ioctl)
+HANDLE_IOCTL(ATM_QUERYLOOP32, do_atm_ioctl)
+HANDLE_IOCTL(SONET_GETSTAT, do_atm_ioctl)
+HANDLE_IOCTL(SONET_GETSTATZ, do_atm_ioctl)
+HANDLE_IOCTL(SONET_GETDIAG, do_atm_ioctl)
+HANDLE_IOCTL(SONET_SETDIAG, do_atm_ioctl)
+HANDLE_IOCTL(SONET_CLRDIAG, do_atm_ioctl)
+HANDLE_IOCTL(SONET_SETFRAMING, do_atm_ioctl)
+HANDLE_IOCTL(SONET_GETFRAMING, do_atm_ioctl)
+HANDLE_IOCTL(SONET_GETFRSENSE, do_atm_ioctl)
+COMPATIBLE_IOCTL(FIOSETOWN)
+COMPATIBLE_IOCTL(SIOCSPGRP)
+COMPATIBLE_IOCTL(FIOGETOWN)
+COMPATIBLE_IOCTL(SIOCGPGRP)
+COMPATIBLE_IOCTL(SIOCATMARK)
+COMPATIBLE_IOCTL(SIOCSIFLINK)
+COMPATIBLE_IOCTL(SIOCSIFNAME)
+COMPATIBLE_IOCTL(SIOCSARP)
+COMPATIBLE_IOCTL(SIOCGARP)
+COMPATIBLE_IOCTL(SIOCDARP)
+COMPATIBLE_IOCTL(SIOCSRARP)
+COMPATIBLE_IOCTL(SIOCGRARP)
+COMPATIBLE_IOCTL(SIOCDRARP)
+COMPATIBLE_IOCTL(SIOCADDDLCI)
+COMPATIBLE_IOCTL(SIOCDELDLCI)
+COMPATIBLE_IOCTL(SIOCGMIIPHY)
+COMPATIBLE_IOCTL(SIOCGMIIREG)
+COMPATIBLE_IOCTL(SIOCSMIIREG)
+COMPATIBLE_IOCTL(SIOCGIFVLAN)
+COMPATIBLE_IOCTL(SIOCSIFVLAN)
+COMPATIBLE_IOCTL(SIOCBRADDBR)
+COMPATIBLE_IOCTL(SIOCBRDELBR)
+#endif
+
 static long compat_sock_ioctl(struct file *file, unsigned cmd,
 			      unsigned long arg)
 {
-- 
1.6.3.3
