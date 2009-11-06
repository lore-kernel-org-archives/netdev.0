From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 6/7] compat: move sockios handling to net/socket.c
Date: Fri,  6 Nov 2009 19:09:08 +0100
Message-ID: <1257530949-9695-7-git-send-email-arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932132AbZKFSJZ@vger.kernel.org>
In-Reply-To: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes the original socket compat_ioctl code
from fs/compat_ioctl.c and converts the code from the copy
in net/socket.c into a single function. We add a few cycles
of runtime to compat_sock_ioctl() with the long switch()
statement, but gain some cycles in return by simplifying
the call chain to get there.

Due to better inlining, save 1.5kb of object size in the
process, and enable further savings:

before:
   text    data     bss     dec     hex filename
  13540   18008    2080   33628    835c obj/fs/compat_ioctl.o
  14565     636      40   15241    3b89 obj/net/socket.o

after:
   text    data     bss     dec     hex filename
   8916   15176    2080   26172    663c obj/fs/compat_ioctl.o
  20725     636      40   21401    5399 obj/net/socket.o

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/compat_ioctl.c |  722 -----------------------------------------------------
 net/socket.c      |  474 ++++++++++++++++++-----------------
 2 files changed, 243 insertions(+), 953 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 50d2a5f..cacf8a8 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -246,422 +246,6 @@ static int do_video_set_spu_palette(unsigned int fd, unsigned int cmd, unsigned
 	return err;
 }
 
-#ifdef CONFIG_NET
-static int do_siocgstamp(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct compat_timeval __user *up = compat_ptr(arg);
-	struct timeval ktv;
-	mm_segment_t old_fs = get_fs();
-	int err;
-
-	set_fs(KERNEL_DS);
-	err = sys_ioctl(fd, cmd, (unsigned long)&ktv);
-	set_fs(old_fs);
-	if(!err) {
-		err = put_user(ktv.tv_sec, &up->tv_sec);
-		err |= __put_user(ktv.tv_usec, &up->tv_usec);
-	}
-	return err;
-}
-
-static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct compat_timespec __user *up = compat_ptr(arg);
-	struct timespec kts;
-	mm_segment_t old_fs = get_fs();
-	int err;
-
-	set_fs(KERNEL_DS);
-	err = sys_ioctl(fd, cmd, (unsigned long)&kts);
-	set_fs(old_fs);
-	if (!err) {
-		err = put_user(kts.tv_sec, &up->tv_sec);
-		err |= __put_user(kts.tv_nsec, &up->tv_nsec);
-	}
-	return err;
-}
-
-struct ifmap32 {
-	compat_ulong_t mem_start;
-	compat_ulong_t mem_end;
-	unsigned short base_addr;
-	unsigned char irq;
-	unsigned char dma;
-	unsigned char port;
-};
-
-struct ifreq32 {
-#define IFHWADDRLEN     6
-#define IFNAMSIZ        16
-        union {
-                char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
-        } ifr_ifrn;
-        union {
-                struct  sockaddr ifru_addr;
-                struct  sockaddr ifru_dstaddr;
-                struct  sockaddr ifru_broadaddr;
-                struct  sockaddr ifru_netmask;
-                struct  sockaddr ifru_hwaddr;
-                short   ifru_flags;
-                compat_int_t     ifru_ivalue;
-                compat_int_t     ifru_mtu;
-                struct  ifmap32 ifru_map;
-                char    ifru_slave[IFNAMSIZ];   /* Just fits the size */
-		char	ifru_newname[IFNAMSIZ];
-                compat_caddr_t ifru_data;
-	    /* XXXX? ifru_settings should be here */
-        } ifr_ifru;
-};
-
-struct ifconf32 {
-        compat_int_t	ifc_len;                        /* size of buffer       */
-        compat_caddr_t  ifcbuf;
-};
-
-static int dev_ifname32(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifreq __user *uifr;
-	int err;
-
-	uifr = compat_alloc_user_space(sizeof(struct ifreq));
-	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)))
-		return -EFAULT;
-
-	err = sys_ioctl(fd, SIOCGIFNAME, (unsigned long)uifr);
-	if (err)
-		return err;
-
-	if (copy_in_user(compat_ptr(arg), uifr, sizeof(struct ifreq32)))
-		return -EFAULT;
-
-	return 0;
-}
-
-static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifconf32 ifc32;
-	struct ifconf ifc;
-	struct ifconf __user *uifc;
-	struct ifreq32 __user *ifr32;
-	struct ifreq __user *ifr;
-	unsigned int i, j;
-	int err;
-
-	if (copy_from_user(&ifc32, compat_ptr(arg), sizeof(struct ifconf32)))
-		return -EFAULT;
-
-	if (ifc32.ifcbuf == 0) {
-		ifc32.ifc_len = 0;
-		ifc.ifc_len = 0;
-		ifc.ifc_req = NULL;
-		uifc = compat_alloc_user_space(sizeof(struct ifconf));
-	} else {
-		size_t len =((ifc32.ifc_len / sizeof (struct ifreq32)) + 1) *
-			sizeof (struct ifreq);
-		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
-		ifc.ifc_len = len;
-		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
-		ifr32 = compat_ptr(ifc32.ifcbuf);
-		for (i = 0; i < ifc32.ifc_len; i += sizeof (struct ifreq32)) {
-			if (copy_in_user(ifr, ifr32, sizeof(struct ifreq32)))
-				return -EFAULT;
-			ifr++;
-			ifr32++; 
-		}
-	}
-	if (copy_to_user(uifc, &ifc, sizeof(struct ifconf)))
-		return -EFAULT;
-
-	err = sys_ioctl (fd, SIOCGIFCONF, (unsigned long)uifc);	
-	if (err)
-		return err;
-
-	if (copy_from_user(&ifc, uifc, sizeof(struct ifconf))) 
-		return -EFAULT;
-
-	ifr = ifc.ifc_req;
-	ifr32 = compat_ptr(ifc32.ifcbuf);
-	for (i = 0, j = 0;
-             i + sizeof (struct ifreq32) <= ifc32.ifc_len && j < ifc.ifc_len;
-	     i += sizeof (struct ifreq32), j += sizeof (struct ifreq)) {
-		if (copy_in_user(ifr32, ifr, sizeof (struct ifreq32)))
-			return -EFAULT;
-		ifr32++;
-		ifr++;
-	}
-
-	if (ifc32.ifcbuf == 0) {
-		/* Translate from 64-bit structure multiple to
-		 * a 32-bit one.
-		 */
-		i = ifc.ifc_len;
-		i = ((i / sizeof(struct ifreq)) * sizeof(struct ifreq32));
-		ifc32.ifc_len = i;
-	} else {
-		ifc32.ifc_len = i;
-	}
-	if (copy_to_user(compat_ptr(arg), &ifc32, sizeof(struct ifconf32)))
-		return -EFAULT;
-
-	return 0;
-}
-
-static int ethtool_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifreq __user *ifr;
-	struct ifreq32 __user *ifr32;
-	u32 data;
-	void __user *datap;
-	
-	ifr = compat_alloc_user_space(sizeof(*ifr));
-	ifr32 = compat_ptr(arg);
-
-	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
-		return -EFAULT;
-
-	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
-		return -EFAULT;
-
-	datap = compat_ptr(data);
-	if (put_user(datap, &ifr->ifr_ifru.ifru_data))
-		return -EFAULT;
-
-	return sys_ioctl(fd, cmd, (unsigned long) ifr);
-}
-
-static int bond_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifreq kifr;
-	struct ifreq __user *uifr;
-	struct ifreq32 __user *ifr32 = compat_ptr(arg);
-	mm_segment_t old_fs;
-	int err;
-	u32 data;
-	void __user *datap;
-
-	switch (cmd) {
-	case SIOCBONDENSLAVE:
-	case SIOCBONDRELEASE:
-	case SIOCBONDSETHWADDR:
-	case SIOCBONDCHANGEACTIVE:
-		if (copy_from_user(&kifr, ifr32, sizeof(struct ifreq32)))
-			return -EFAULT;
-
-		old_fs = get_fs();
-		set_fs (KERNEL_DS);
-		err = sys_ioctl (fd, cmd, (unsigned long)&kifr);
-		set_fs (old_fs);
-
-		return err;
-	case SIOCBONDSLAVEINFOQUERY:
-	case SIOCBONDINFOQUERY:
-		uifr = compat_alloc_user_space(sizeof(*uifr));
-		if (copy_in_user(&uifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
-			return -EFAULT;
-
-		if (get_user(data, &ifr32->ifr_ifru.ifru_data))
-			return -EFAULT;
-
-		datap = compat_ptr(data);
-		if (put_user(datap, &uifr->ifr_ifru.ifru_data))
-			return -EFAULT;
-
-		return sys_ioctl (fd, cmd, (unsigned long)uifr);
-	default:
-		return -EINVAL;
-	};
-}
-
-static int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifreq __user *u_ifreq64;
-	struct ifreq32 __user *u_ifreq32 = compat_ptr(arg);
-	char tmp_buf[IFNAMSIZ];
-	void __user *data64;
-	u32 data32;
-
-	if (copy_from_user(&tmp_buf[0], &(u_ifreq32->ifr_ifrn.ifrn_name[0]),
-			   IFNAMSIZ))
-		return -EFAULT;
-	if (__get_user(data32, &u_ifreq32->ifr_ifru.ifru_data))
-		return -EFAULT;
-	data64 = compat_ptr(data32);
-
-	u_ifreq64 = compat_alloc_user_space(sizeof(*u_ifreq64));
-
-	/* Don't check these user accesses, just let that get trapped
-	 * in the ioctl handler instead.
-	 */
-	if (copy_to_user(&u_ifreq64->ifr_ifrn.ifrn_name[0], &tmp_buf[0],
-			 IFNAMSIZ))
-		return -EFAULT;
-	if (__put_user(data64, &u_ifreq64->ifr_ifru.ifru_data))
-		return -EFAULT;
-
-	return sys_ioctl(fd, cmd, (unsigned long) u_ifreq64);
-}
-
-static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct ifreq ifr;
-	struct ifreq32 __user *uifr32;
-	struct ifmap32 __user *uifmap32;
-	mm_segment_t old_fs;
-	int err;
-	
-	uifr32 = compat_ptr(arg);
-	uifmap32 = &uifr32->ifr_ifru.ifru_map;
-	switch (cmd) {
-	case SIOCSIFMAP:
-		err = copy_from_user(&ifr, uifr32, sizeof(ifr.ifr_name));
-		err |= __get_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
-		err |= __get_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
-		err |= __get_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
-		err |= __get_user(ifr.ifr_map.irq, &uifmap32->irq);
-		err |= __get_user(ifr.ifr_map.dma, &uifmap32->dma);
-		err |= __get_user(ifr.ifr_map.port, &uifmap32->port);
-		if (err)
-			return -EFAULT;
-		break;
-	case SIOCSHWTSTAMP:
-		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
-			return -EFAULT;
-		ifr.ifr_data = compat_ptr(uifr32->ifr_ifru.ifru_data);
-		break;
-	default:
-		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
-			return -EFAULT;
-		break;
-	}
-	old_fs = get_fs();
-	set_fs (KERNEL_DS);
-	err = sys_ioctl (fd, cmd, (unsigned long)&ifr);
-	set_fs (old_fs);
-	if (!err) {
-		switch (cmd) {
-		case SIOCGIFFLAGS:
-		case SIOCGIFMETRIC:
-		case SIOCGIFMTU:
-		case SIOCGIFMEM:
-		case SIOCGIFHWADDR:
-		case SIOCGIFINDEX:
-		case SIOCGIFADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCGIFDSTADDR:
-		case SIOCGIFNETMASK:
-		case SIOCGIFTXQLEN:
-			if (copy_to_user(uifr32, &ifr, sizeof(*uifr32)))
-				return -EFAULT;
-			break;
-		case SIOCGIFMAP:
-			err = copy_to_user(uifr32, &ifr, sizeof(ifr.ifr_name));
-			err |= __put_user(ifr.ifr_map.mem_start, &uifmap32->mem_start);
-			err |= __put_user(ifr.ifr_map.mem_end, &uifmap32->mem_end);
-			err |= __put_user(ifr.ifr_map.base_addr, &uifmap32->base_addr);
-			err |= __put_user(ifr.ifr_map.irq, &uifmap32->irq);
-			err |= __put_user(ifr.ifr_map.dma, &uifmap32->dma);
-			err |= __put_user(ifr.ifr_map.port, &uifmap32->port);
-			if (err)
-				err = -EFAULT;
-			break;
-		}
-	}
-	return err;
-}
-
-struct rtentry32 {
-        u32   		rt_pad1;
-        struct sockaddr rt_dst;         /* target address               */
-        struct sockaddr rt_gateway;     /* gateway addr (RTF_GATEWAY)   */
-        struct sockaddr rt_genmask;     /* target network mask (IP)     */
-        unsigned short  rt_flags;
-        short           rt_pad2;
-        u32   		rt_pad3;
-        unsigned char   rt_tos;
-        unsigned char   rt_class;
-        short           rt_pad4;
-        short           rt_metric;      /* +1 for binary compatibility! */
-        /* char * */ u32 rt_dev;        /* forcing the device at add    */
-        u32   		rt_mtu;         /* per route MTU/Window         */
-        u32   		rt_window;      /* Window clamping              */
-        unsigned short  rt_irtt;        /* Initial RTT                  */
-
-};
-
-struct in6_rtmsg32 {
-	struct in6_addr		rtmsg_dst;
-	struct in6_addr		rtmsg_src;
-	struct in6_addr		rtmsg_gateway;
-	u32			rtmsg_type;
-	u16			rtmsg_dst_len;
-	u16			rtmsg_src_len;
-	u32			rtmsg_metric;
-	u32			rtmsg_info;
-	u32			rtmsg_flags;
-	s32			rtmsg_ifindex;
-};
-
-static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	int ret;
-	void *r = NULL;
-	struct in6_rtmsg r6;
-	struct rtentry r4;
-	char devname[16];
-	u32 rtdev;
-	mm_segment_t old_fs = get_fs();
-	
-	struct socket *mysock = sockfd_lookup(fd, &ret);
-
-	if (mysock && mysock->sk && mysock->sk->sk_family == AF_INET6) { /* ipv6 */
-		struct in6_rtmsg32 __user *ur6 = compat_ptr(arg);
-		ret = copy_from_user (&r6.rtmsg_dst, &(ur6->rtmsg_dst),
-			3 * sizeof(struct in6_addr));
-		ret |= __get_user (r6.rtmsg_type, &(ur6->rtmsg_type));
-		ret |= __get_user (r6.rtmsg_dst_len, &(ur6->rtmsg_dst_len));
-		ret |= __get_user (r6.rtmsg_src_len, &(ur6->rtmsg_src_len));
-		ret |= __get_user (r6.rtmsg_metric, &(ur6->rtmsg_metric));
-		ret |= __get_user (r6.rtmsg_info, &(ur6->rtmsg_info));
-		ret |= __get_user (r6.rtmsg_flags, &(ur6->rtmsg_flags));
-		ret |= __get_user (r6.rtmsg_ifindex, &(ur6->rtmsg_ifindex));
-		
-		r = (void *) &r6;
-	} else { /* ipv4 */
-		struct rtentry32 __user *ur4 = compat_ptr(arg);
-		ret = copy_from_user (&r4.rt_dst, &(ur4->rt_dst),
-					3 * sizeof(struct sockaddr));
-		ret |= __get_user (r4.rt_flags, &(ur4->rt_flags));
-		ret |= __get_user (r4.rt_metric, &(ur4->rt_metric));
-		ret |= __get_user (r4.rt_mtu, &(ur4->rt_mtu));
-		ret |= __get_user (r4.rt_window, &(ur4->rt_window));
-		ret |= __get_user (r4.rt_irtt, &(ur4->rt_irtt));
-		ret |= __get_user (rtdev, &(ur4->rt_dev));
-		if (rtdev) {
-			ret |= copy_from_user (devname, compat_ptr(rtdev), 15);
-			r4.rt_dev = devname; devname[15] = 0;
-		} else
-			r4.rt_dev = NULL;
-
-		r = (void *) &r4;
-	}
-
-	if (ret) {
-		ret = -EFAULT;
-		goto out;
-	}
-
-	set_fs (KERNEL_DS);
-	ret = sys_ioctl (fd, cmd, (unsigned long) r);
-	set_fs (old_fs);
-
-out:
-	if (mysock)
-		sockfd_put(mysock);
-
-	return ret;
-}
-#endif
-
 #ifdef CONFIG_BLOCK
 typedef struct sg_io_hdr32 {
 	compat_int_t interface_id;	/* [i] 'S' for SCSI generic (required) */
@@ -1206,170 +790,6 @@ static int do_smb_getmountuid(unsigned int fd, unsigned int cmd, unsigned long a
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
@@ -1712,21 +1132,6 @@ static int do_i2c_smbus_ioctl(unsigned int fd, unsigned int cmd, unsigned long a
 	return sys_ioctl(fd, cmd, (unsigned long)tdata);
 }
 
-/* Since old style bridge ioctl's endup using SIOCDEVPRIVATE
- * for some operations; this forces use of the newer bridge-utils that
- * use compatible ioctls
- */
-static int old_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	u32 tmp;
-
-	if (get_user(tmp, (u32 __user *) arg))
-		return -EFAULT;
-	if (tmp == BRCTL_GET_VERSION)
-		return BRCTL_VERSION + 1;
-	return -EINVAL;
-}
-
 #define RTC_IRQP_READ32		_IOR('p', 0x0b, compat_ulong_t)
 #define RTC_IRQP_SET32		_IOW('p', 0x0c, compat_ulong_t)
 #define RTC_EPOCH_READ32	_IOR('p', 0x0d, compat_ulong_t)
@@ -2014,28 +1419,6 @@ COMPATIBLE_IOCTL(_IOW('p', 21, int[7])) /* RTCSET */
 COMPATIBLE_IOCTL(MTIOCTOP)
 /* Socket level stuff */
 COMPATIBLE_IOCTL(FIOQSIZE)
-COMPATIBLE_IOCTL(FIOSETOWN)
-COMPATIBLE_IOCTL(SIOCSPGRP)
-COMPATIBLE_IOCTL(FIOGETOWN)
-COMPATIBLE_IOCTL(SIOCGPGRP)
-COMPATIBLE_IOCTL(SIOCATMARK)
-COMPATIBLE_IOCTL(SIOCSIFLINK)
-COMPATIBLE_IOCTL(SIOCSIFNAME)
-COMPATIBLE_IOCTL(SIOCSARP)
-COMPATIBLE_IOCTL(SIOCGARP)
-COMPATIBLE_IOCTL(SIOCDARP)
-COMPATIBLE_IOCTL(SIOCSRARP)
-COMPATIBLE_IOCTL(SIOCGRARP)
-COMPATIBLE_IOCTL(SIOCDRARP)
-COMPATIBLE_IOCTL(SIOCADDDLCI)
-COMPATIBLE_IOCTL(SIOCDELDLCI)
-COMPATIBLE_IOCTL(SIOCGMIIPHY)
-COMPATIBLE_IOCTL(SIOCGMIIREG)
-COMPATIBLE_IOCTL(SIOCSMIIREG)
-COMPATIBLE_IOCTL(SIOCGIFVLAN)
-COMPATIBLE_IOCTL(SIOCSIFVLAN)
-COMPATIBLE_IOCTL(SIOCBRADDBR)
-COMPATIBLE_IOCTL(SIOCBRDELBR)
 #ifdef CONFIG_BLOCK
 /* SG stuff */
 COMPATIBLE_IOCTL(SG_SET_TIMEOUT)
@@ -2291,22 +1674,6 @@ COMPATIBLE_IOCTL(RAW_SETBIND)
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
@@ -2512,60 +1879,6 @@ COMPATIBLE_IOCTL(JSIOCGBUTTONS)
 COMPATIBLE_IOCTL(JSIOCGNAME(0))
 
 /* now things that need handlers */
-#ifdef CONFIG_NET
-HANDLE_IOCTL(SIOCGIFNAME, dev_ifname32)
-HANDLE_IOCTL(SIOCGIFCONF, dev_ifconf)
-HANDLE_IOCTL(SIOCGIFFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMETRIC, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMETRIC, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMTU, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMTU, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMEM, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMEM, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFHWADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFHWADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCADDMULTI, dev_ifsioc)
-HANDLE_IOCTL(SIOCDELMULTI, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFINDEX, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMAP, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
-HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
-
-/* ioctls used by appletalk ddp.c */
-HANDLE_IOCTL(SIOCDIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSARP, dev_ifsioc)
-HANDLE_IOCTL(SIOCDARP, dev_ifsioc)
-
-HANDLE_IOCTL(SIOCGIFBRDADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFBRDADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFDSTADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFDSTADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFNETMASK, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFNETMASK, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFPFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFPFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFTXQLEN, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFTXQLEN, dev_ifsioc)
-HANDLE_IOCTL(SIOCETHTOOL, ethtool_ioctl)
-HANDLE_IOCTL(SIOCBONDENSLAVE, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDRELEASE, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDSETHWADDR, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDSLAVEINFOQUERY, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDINFOQUERY, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDCHANGEACTIVE, bond_ioctl)
-HANDLE_IOCTL(SIOCADDRT, routing_ioctl)
-HANDLE_IOCTL(SIOCDELRT, routing_ioctl)
-HANDLE_IOCTL(SIOCBRADDIF, dev_ifsioc)
-HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
-/* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
-HANDLE_IOCTL(SIOCRTMSG, ret_einval)
-HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
-HANDLE_IOCTL(SIOCGSTAMPNS, do_siocgstampns)
-#endif
 #ifdef CONFIG_BLOCK
 HANDLE_IOCTL(SG_IO,sg_ioctl_trans)
 HANDLE_IOCTL(SG_GET_REQUEST_TABLE, sg_grt_trans)
@@ -2590,31 +1903,6 @@ HANDLE_IOCTL(KDFONTOP, do_kdfontop_ioctl)
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
@@ -2649,11 +1937,7 @@ COMPATIBLE_IOCTL(USBDEVFS_IOCTL32)
 HANDLE_IOCTL(I2C_FUNCS, w_long)
 HANDLE_IOCTL(I2C_RDWR, do_i2c_rdwr_ioctl)
 HANDLE_IOCTL(I2C_SMBUS, do_i2c_smbus_ioctl)
-/* bridge */
-HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
-HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
 /* Not implemented in the native kernel */
-IGNORE_IOCTL(SIOCGIFCOUNT)
 HANDLE_IOCTL(RTC_IRQP_READ32, rtc_ioctl)
 HANDLE_IOCTL(RTC_IRQP_SET32, rtc_ioctl)
 HANDLE_IOCTL(RTC_EPOCH_READ32, rtc_ioctl)
@@ -2808,12 +2092,6 @@ asmlinkage long compat_sys_ioctl(unsigned int fd, unsigned int cmd,
 			goto found_handler;
 	}
 
-#ifdef CONFIG_NET
-	if (S_ISSOCK(filp->f_path.dentry->d_inode->i_mode) &&
-	    cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15)) {
-		error = siocdevprivate_ioctl(fd, cmd, arg);
-	} else
-#endif
 	{
 		static int count;
 
diff --git a/net/socket.c b/net/socket.c
index 74d5816..2621213 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -97,6 +97,20 @@
 #include <net/sock.h>
 #include <linux/netfilter.h>
 
+#include <linux/if_tun.h>
+#include <linux/ipv6_route.h>
+#include <linux/route.h>
+#include <linux/atmdev.h>
+#include <linux/atmarp.h>
+#include <linux/atmsvc.h>
+#include <linux/atmlec.h>
+#include <linux/atmclip.h>
+#include <linux/atmmpc.h>
+#include <linux/atm_tcp.h>
+#include <linux/sonet.h>
+#include <linux/sockios.h>
+#include <linux/atalk.h>
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -886,6 +900,24 @@ void dlci_ioctl_set(int (*hook) (unsigned int, void __user *))
 
 EXPORT_SYMBOL(dlci_ioctl_set);
 
+static long sock_do_ioctl(struct net *net, struct socket *sock,
+				 unsigned int cmd, unsigned long arg)
+{
+	int err;
+	void __user *argp = (void __user *)arg;
+
+	err = sock->ops->ioctl(sock, cmd, arg);
+
+	/*
+	 * If this ioctl is unknown try to hand it down
+	 * to the NIC driver.
+	 */
+	if (err == -ENOIOCTLCMD)
+		err = dev_ioctl(net, cmd, argp);
+
+	return err;
+}
+
 /*
  *	With an ioctl, arg may well be a user mode pointer, but we don't know
  *	what to do with it - that's up to the protocol still.
@@ -959,14 +991,7 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 			mutex_unlock(&dlci_ioctl_mutex);
 			break;
 		default:
-			err = sock->ops->ioctl(sock, cmd, arg);
-
-			/*
-			 * If this ioctl is unknown try to hand it down
-			 * to the NIC driver.
-			 */
-			if (err == -ENOIOCTLCMD)
-				err = dev_ioctl(net, cmd, argp);
+			err = sock_do_ioctl(net, sock, cmd, arg);
 			break;
 		}
 	return err;
@@ -2300,16 +2325,15 @@ void socket_seq_show(struct seq_file *seq)
 #endif				/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_COMPAT
-#if 0
-static int do_siocgstamp(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int do_siocgstamp(struct net *net, struct socket *sock,
+			 unsigned int cmd, struct compat_timeval __user *up)
 {
-	struct compat_timeval __user *up = compat_ptr(arg);
 	struct timeval ktv;
 	mm_segment_t old_fs = get_fs();
 	int err;
 
 	set_fs(KERNEL_DS);
-	err = sys_ioctl(fd, cmd, (unsigned long)&ktv);
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&ktv);
 	set_fs(old_fs);
 	if(!err) {
 		err = put_user(ktv.tv_sec, &up->tv_sec);
@@ -2318,15 +2342,15 @@ static int do_siocgstamp(unsigned int fd, unsigned int cmd, unsigned long arg)
 	return err;
 }
 
-static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int do_siocgstampns(struct net *net, struct socket *sock,
+			 unsigned int cmd, struct compat_timespec __user *up)
 {
-	struct compat_timespec __user *up = compat_ptr(arg);
 	struct timespec kts;
 	mm_segment_t old_fs = get_fs();
 	int err;
 
 	set_fs(KERNEL_DS);
-	err = sys_ioctl(fd, cmd, (unsigned long)&kts);
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&kts);
 	set_fs(old_fs);
 	if (!err) {
 		err = put_user(kts.tv_sec, &up->tv_sec);
@@ -2335,73 +2359,36 @@ static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
 	return err;
 }
 
-struct ifmap32 {
-	compat_ulong_t mem_start;
-	compat_ulong_t mem_end;
-	unsigned short base_addr;
-	unsigned char irq;
-	unsigned char dma;
-	unsigned char port;
-};
-
-struct ifreq32 {
-#define IFHWADDRLEN     6
-#define IFNAMSIZ        16
-        union {
-                char    ifrn_name[IFNAMSIZ];            /* if name, e.g. "en0" */
-        } ifr_ifrn;
-        union {
-                struct  sockaddr ifru_addr;
-                struct  sockaddr ifru_dstaddr;
-                struct  sockaddr ifru_broadaddr;
-                struct  sockaddr ifru_netmask;
-                struct  sockaddr ifru_hwaddr;
-                short   ifru_flags;
-                compat_int_t     ifru_ivalue;
-                compat_int_t     ifru_mtu;
-                struct  ifmap32 ifru_map;
-                char    ifru_slave[IFNAMSIZ];   /* Just fits the size */
-		char	ifru_newname[IFNAMSIZ];
-                compat_caddr_t ifru_data;
-	    /* XXXX? ifru_settings should be here */
-        } ifr_ifru;
-};
-
-struct ifconf32 {
-        compat_int_t	ifc_len;                        /* size of buffer       */
-        compat_caddr_t  ifcbuf;
-};
-
-static int dev_ifname32(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int dev_ifname32(struct net *net, struct compat_ifreq __user *uifr32)
 {
 	struct ifreq __user *uifr;
 	int err;
 
 	uifr = compat_alloc_user_space(sizeof(struct ifreq));
-	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)))
+	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
 		return -EFAULT;
 
-	err = sys_ioctl(fd, SIOCGIFNAME, (unsigned long)uifr);
+	err = dev_ioctl(net, SIOCGIFNAME, uifr);
 	if (err)
 		return err;
 
-	if (copy_in_user(compat_ptr(arg), uifr, sizeof(struct ifreq32)))
+	if (copy_in_user(uifr32, uifr, sizeof(struct compat_ifreq)))
 		return -EFAULT;
 
 	return 0;
 }
 
-static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 {
-	struct ifconf32 ifc32;
+	struct compat_ifconf ifc32;
 	struct ifconf ifc;
 	struct ifconf __user *uifc;
-	struct ifreq32 __user *ifr32;
+	struct compat_ifreq __user *ifr32;
 	struct ifreq __user *ifr;
 	unsigned int i, j;
 	int err;
 
-	if (copy_from_user(&ifc32, compat_ptr(arg), sizeof(struct ifconf32)))
+	if (copy_from_user(&ifc32, uifc32, sizeof(struct compat_ifconf)))
 		return -EFAULT;
 
 	if (ifc32.ifcbuf == 0) {
@@ -2410,35 +2397,35 @@ static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
 		ifc.ifc_req = NULL;
 		uifc = compat_alloc_user_space(sizeof(struct ifconf));
 	} else {
-		size_t len =((ifc32.ifc_len / sizeof (struct ifreq32)) + 1) *
+		size_t len =((ifc32.ifc_len / sizeof (struct compat_ifreq)) + 1) *
 			sizeof (struct ifreq);
 		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
 		ifc.ifc_len = len;
 		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
 		ifr32 = compat_ptr(ifc32.ifcbuf);
-		for (i = 0; i < ifc32.ifc_len; i += sizeof (struct ifreq32)) {
-			if (copy_in_user(ifr, ifr32, sizeof(struct ifreq32)))
+		for (i = 0; i < ifc32.ifc_len; i += sizeof (struct compat_ifreq)) {
+			if (copy_in_user(ifr, ifr32, sizeof(struct compat_ifreq)))
 				return -EFAULT;
 			ifr++;
-			ifr32++; 
+			ifr32++;
 		}
 	}
 	if (copy_to_user(uifc, &ifc, sizeof(struct ifconf)))
 		return -EFAULT;
 
-	err = sys_ioctl (fd, SIOCGIFCONF, (unsigned long)uifc);	
+	err = dev_ioctl(net, SIOCGIFCONF, uifc);
 	if (err)
 		return err;
 
-	if (copy_from_user(&ifc, uifc, sizeof(struct ifconf))) 
+	if (copy_from_user(&ifc, uifc, sizeof(struct ifconf)))
 		return -EFAULT;
 
 	ifr = ifc.ifc_req;
 	ifr32 = compat_ptr(ifc32.ifcbuf);
 	for (i = 0, j = 0;
-             i + sizeof (struct ifreq32) <= ifc32.ifc_len && j < ifc.ifc_len;
-	     i += sizeof (struct ifreq32), j += sizeof (struct ifreq)) {
-		if (copy_in_user(ifr32, ifr, sizeof (struct ifreq32)))
+             i + sizeof (struct compat_ifreq) <= ifc32.ifc_len && j < ifc.ifc_len;
+	     i += sizeof (struct compat_ifreq), j += sizeof (struct ifreq)) {
+		if (copy_in_user(ifr32, ifr, sizeof (struct compat_ifreq)))
 			return -EFAULT;
 		ifr32++;
 		ifr++;
@@ -2449,26 +2436,24 @@ static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
 		 * a 32-bit one.
 		 */
 		i = ifc.ifc_len;
-		i = ((i / sizeof(struct ifreq)) * sizeof(struct ifreq32));
+		i = ((i / sizeof(struct ifreq)) * sizeof(struct compat_ifreq));
 		ifc32.ifc_len = i;
 	} else {
 		ifc32.ifc_len = i;
 	}
-	if (copy_to_user(compat_ptr(arg), &ifc32, sizeof(struct ifconf32)))
+	if (copy_to_user(uifc32, &ifc32, sizeof(struct compat_ifconf)))
 		return -EFAULT;
 
 	return 0;
 }
 
-static int ethtool_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 {
 	struct ifreq __user *ifr;
-	struct ifreq32 __user *ifr32;
 	u32 data;
 	void __user *datap;
-	
+
 	ifr = compat_alloc_user_space(sizeof(*ifr));
-	ifr32 = compat_ptr(arg);
 
 	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
 		return -EFAULT;
@@ -2480,14 +2465,14 @@ static int ethtool_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 	if (put_user(datap, &ifr->ifr_ifru.ifru_data))
 		return -EFAULT;
 
-	return sys_ioctl(fd, cmd, (unsigned long) ifr);
+	return dev_ioctl(net, SIOCETHTOOL, ifr);
 }
 
-static int bond_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int bond_ioctl(struct net *net, unsigned int cmd,
+			 struct compat_ifreq __user *ifr32)
 {
 	struct ifreq kifr;
 	struct ifreq __user *uifr;
-	struct ifreq32 __user *ifr32 = compat_ptr(arg);
 	mm_segment_t old_fs;
 	int err;
 	u32 data;
@@ -2498,12 +2483,12 @@ static int bond_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 	case SIOCBONDRELEASE:
 	case SIOCBONDSETHWADDR:
 	case SIOCBONDCHANGEACTIVE:
-		if (copy_from_user(&kifr, ifr32, sizeof(struct ifreq32)))
+		if (copy_from_user(&kifr, ifr32, sizeof(struct compat_ifreq)))
 			return -EFAULT;
 
 		old_fs = get_fs();
 		set_fs (KERNEL_DS);
-		err = sys_ioctl (fd, cmd, (unsigned long)&kifr);
+		err = dev_ioctl(net, cmd, &kifr);
 		set_fs (old_fs);
 
 		return err;
@@ -2520,16 +2505,16 @@ static int bond_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 		if (put_user(datap, &uifr->ifr_ifru.ifru_data))
 			return -EFAULT;
 
-		return sys_ioctl (fd, cmd, (unsigned long)uifr);
+		return dev_ioctl(net, cmd, uifr);
 	default:
 		return -EINVAL;
 	};
 }
 
-static int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int siocdevprivate_ioctl(struct net *net, unsigned int cmd,
+				 struct compat_ifreq __user *u_ifreq32)
 {
 	struct ifreq __user *u_ifreq64;
-	struct ifreq32 __user *u_ifreq32 = compat_ptr(arg);
 	char tmp_buf[IFNAMSIZ];
 	void __user *data64;
 	u32 data32;
@@ -2552,18 +2537,17 @@ static int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned long
 	if (__put_user(data64, &u_ifreq64->ifr_ifru.ifru_data))
 		return -EFAULT;
 
-	return sys_ioctl(fd, cmd, (unsigned long) u_ifreq64);
+	return dev_ioctl(net, cmd, u_ifreq64);
 }
 
-static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int dev_ifsioc(struct net *net, struct socket *sock,
+			 unsigned int cmd, struct compat_ifreq __user *uifr32)
 {
 	struct ifreq ifr;
-	struct ifreq32 __user *uifr32;
-	struct ifmap32 __user *uifmap32;
+	struct compat_ifmap __user *uifmap32;
 	mm_segment_t old_fs;
 	int err;
 	
-	uifr32 = compat_ptr(arg);
 	uifmap32 = &uifr32->ifr_ifru.ifru_map;
 	switch (cmd) {
 	case SIOCSIFMAP:
@@ -2589,7 +2573,7 @@ static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 	}
 	old_fs = get_fs();
 	set_fs (KERNEL_DS);
-	err = sys_ioctl (fd, cmd, (unsigned long)&ifr);
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long)&ifr);
 	set_fs (old_fs);
 	if (!err) {
 		switch (cmd) {
@@ -2655,7 +2639,8 @@ struct in6_rtmsg32 {
 	s32			rtmsg_ifindex;
 };
 
-static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int routing_ioctl(struct net *net, struct socket *sock,
+			 unsigned int cmd, void __user *argp)
 {
 	int ret;
 	void *r = NULL;
@@ -2665,10 +2650,8 @@ static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 	u32 rtdev;
 	mm_segment_t old_fs = get_fs();
 	
-	struct socket *mysock = sockfd_lookup(fd, &ret);
-
-	if (mysock && mysock->sk && mysock->sk->sk_family == AF_INET6) { /* ipv6 */
-		struct in6_rtmsg32 __user *ur6 = compat_ptr(arg);
+	if (sock && sock->sk && sock->sk->sk_family == AF_INET6) { /* ipv6 */
+		struct in6_rtmsg32 __user *ur6 = argp;
 		ret = copy_from_user (&r6.rtmsg_dst, &(ur6->rtmsg_dst),
 			3 * sizeof(struct in6_addr));
 		ret |= __get_user (r6.rtmsg_type, &(ur6->rtmsg_type));
@@ -2681,7 +2664,7 @@ static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 		
 		r = (void *) &r6;
 	} else { /* ipv4 */
-		struct rtentry32 __user *ur4 = compat_ptr(arg);
+		struct rtentry32 __user *ur4 = argp;
 		ret = copy_from_user (&r4.rt_dst, &(ur4->rt_dst),
 					3 * sizeof(struct sockaddr));
 		ret |= __get_user (r4.rt_flags, &(ur4->rt_flags));
@@ -2705,13 +2688,10 @@ static int routing_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 	}
 
 	set_fs (KERNEL_DS);
-	ret = sys_ioctl (fd, cmd, (unsigned long) r);
+	ret = sock_do_ioctl(net, sock, cmd, (unsigned long) r);
 	set_fs (old_fs);
 
 out:
-	if (mysock)
-		sockfd_put(mysock);
-
 	return ret;
 }
 
@@ -2719,11 +2699,11 @@ out:
  * for some operations; this forces use of the newer bridge-utils that
  * use compatiable ioctls
  */
-static int old_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int old_bridge_ioctl(compat_ulong_t __user *argp)
 {
-	u32 tmp;
+	compat_ulong_t tmp;
 
-	if (get_user(tmp, (u32 __user *) arg))
+	if (get_user(tmp, argp))
 		return -EFAULT;
 	if (tmp == BRCTL_GET_VERSION)
 		return BRCTL_VERSION + 1;
@@ -2784,7 +2764,8 @@ static struct {
 
 #define NR_ATM_IOCTL ARRAY_SIZE(atm_ioctl_map)
 
-static int do_atm_iobuf(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int do_atm_iobuf(struct net *net, struct socket *sock,
+			 unsigned int cmd, unsigned long arg)
 {
 	struct atm_iobuf   __user *iobuf;
 	struct atm_iobuf32 __user *iobuf32;
@@ -2803,7 +2784,7 @@ static int do_atm_iobuf(unsigned int fd, unsigned int cmd, unsigned long arg)
 	    put_user(datap, &iobuf->buffer))
 		return -EFAULT;
 
-	err = sys_ioctl(fd, cmd, (unsigned long)iobuf);
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long)iobuf);
 
 	if (!err) {
 		if (copy_in_user(&iobuf32->length, &iobuf->length,
@@ -2814,7 +2795,8 @@ static int do_atm_iobuf(unsigned int fd, unsigned int cmd, unsigned long arg)
 	return err;
 }
 
-static int do_atmif_sioc(unsigned int fd, unsigned int cmd, unsigned long arg)
+static int do_atmif_sioc(struct net *net, struct socket *sock,
+			 unsigned int cmd, unsigned long arg)
 {
         struct atmif_sioc   __user *sioc;
 	struct atmif_sioc32 __user *sioc32;
@@ -2832,7 +2814,7 @@ static int do_atmif_sioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 	if (put_user(datap, &sioc->arg))
 		return -EFAULT;
 
-	err = sys_ioctl(fd, cmd, (unsigned long) sioc);
+	err = sock_do_ioctl(net, sock, cmd, (unsigned long) sioc);
 
 	if (!err) {
 		if (copy_in_user(&sioc32->length, &sioc->length,
@@ -2842,7 +2824,8 @@ static int do_atmif_sioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 	return err;
 }
 
-static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
+static int do_atm_ioctl(struct net *net, struct socket *sock,
+			 unsigned int cmd32, unsigned long arg)
 {
         int i;
         unsigned int cmd = 0;
@@ -2856,7 +2839,7 @@ static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
 	case SONET_SETFRAMING:
 	case SONET_GETFRAMING:
 	case SONET_GETFRSENSE:
-		return do_atmif_sioc(fd, cmd32, arg);
+		return do_atmif_sioc(net, sock, cmd32, arg);
 	}
 
 	for (i = 0; i < NR_ATM_IOCTL; i++) {
@@ -2870,7 +2853,7 @@ static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
         
         switch (cmd) {
 	case ATM_GETNAMES:
-		return do_atm_iobuf(fd, cmd, arg);
+		return do_atm_iobuf(net, sock, cmd, arg);
 	    
 	case ATM_GETLINKRATE:
         case ATM_GETTYPE:
@@ -2888,134 +2871,160 @@ static int do_atm_ioctl(unsigned int fd, unsigned int cmd32, unsigned long arg)
 	case ATM_GETLOOP:
 	case ATM_SETLOOP:
 	case ATM_QUERYLOOP:
-                return do_atmif_sioc(fd, cmd, arg);
+                return do_atmif_sioc(net, sock, cmd, arg);
         }
 
         return -EINVAL;
 }
 
+static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
+			 unsigned int cmd, unsigned long arg)
+{
+	void __user *argp = compat_ptr(arg);
+	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
+
+	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15))
+		return siocdevprivate_ioctl(net, cmd, argp);
 
-/* bridge */
-HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
-HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
-#ifdef CONFIG_NET
-HANDLE_IOCTL(SIOCGIFNAME, dev_ifname32)
-HANDLE_IOCTL(SIOCGIFCONF, dev_ifconf)
-HANDLE_IOCTL(SIOCGIFFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMETRIC, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMETRIC, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMTU, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMTU, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMEM, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMEM, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFHWADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFHWADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCADDMULTI, dev_ifsioc)
-HANDLE_IOCTL(SIOCDELMULTI, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFINDEX, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFMAP, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
-HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
-
-HANDLE_IOCTL(SIOCDIFADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSARP, dev_ifsioc)
-HANDLE_IOCTL(SIOCDARP, dev_ifsioc)
-
-HANDLE_IOCTL(SIOCGIFBRDADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFBRDADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFDSTADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFDSTADDR, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFNETMASK, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFNETMASK, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFPFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFPFLAGS, dev_ifsioc)
-HANDLE_IOCTL(SIOCGIFTXQLEN, dev_ifsioc)
-HANDLE_IOCTL(SIOCSIFTXQLEN, dev_ifsioc)
-HANDLE_IOCTL(SIOCETHTOOL, ethtool_ioctl)
-HANDLE_IOCTL(SIOCBONDENSLAVE, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDRELEASE, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDSETHWADDR, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDSLAVEINFOQUERY, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDINFOQUERY, bond_ioctl)
-HANDLE_IOCTL(SIOCBONDCHANGEACTIVE, bond_ioctl)
-HANDLE_IOCTL(SIOCADDRT, routing_ioctl)
-HANDLE_IOCTL(SIOCDELRT, routing_ioctl)
-HANDLE_IOCTL(SIOCBRADDIF, dev_ifsioc)
-HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
-/* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
-HANDLE_IOCTL(SIOCRTMSG, ret_einval)
-HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
-HANDLE_IOCTL(SIOCGSTAMPNS, do_siocgstampns)
-#endif
-IGNORE_IOCTL(SIOCGIFCOUNT)
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
-COMPATIBLE_IOCTL(FIOSETOWN)
-COMPATIBLE_IOCTL(SIOCSPGRP)
-COMPATIBLE_IOCTL(FIOGETOWN)
-COMPATIBLE_IOCTL(SIOCGPGRP)
-COMPATIBLE_IOCTL(SIOCATMARK)
-COMPATIBLE_IOCTL(SIOCSIFLINK)
-COMPATIBLE_IOCTL(SIOCSIFNAME)
-COMPATIBLE_IOCTL(SIOCSARP)
-COMPATIBLE_IOCTL(SIOCGARP)
-COMPATIBLE_IOCTL(SIOCDARP)
-COMPATIBLE_IOCTL(SIOCSRARP)
-COMPATIBLE_IOCTL(SIOCGRARP)
-COMPATIBLE_IOCTL(SIOCDRARP)
-COMPATIBLE_IOCTL(SIOCADDDLCI)
-COMPATIBLE_IOCTL(SIOCDELDLCI)
-COMPATIBLE_IOCTL(SIOCGMIIPHY)
-COMPATIBLE_IOCTL(SIOCGMIIREG)
-COMPATIBLE_IOCTL(SIOCSMIIREG)
-COMPATIBLE_IOCTL(SIOCGIFVLAN)
-COMPATIBLE_IOCTL(SIOCSIFVLAN)
-COMPATIBLE_IOCTL(SIOCBRADDBR)
-COMPATIBLE_IOCTL(SIOCBRDELBR)
-#endif
+	switch (cmd) {
+	case SIOCSIFBR:
+	case SIOCGIFBR:
+		return old_bridge_ioctl(argp);
+	case SIOCGIFNAME:
+		return dev_ifname32(net, argp);
+	case SIOCGIFCONF:
+		return dev_ifconf(net, argp);
+	case SIOCETHTOOL:
+		return ethtool_ioctl(net, argp);
+	case SIOCBONDENSLAVE:
+	case SIOCBONDRELEASE:
+	case SIOCBONDSETHWADDR:
+	case SIOCBONDSLAVEINFOQUERY:
+	case SIOCBONDINFOQUERY:
+	case SIOCBONDCHANGEACTIVE:
+		return bond_ioctl(net, cmd, argp);
+	case SIOCADDRT:
+	case SIOCDELRT:
+		return routing_ioctl(net, sock, cmd, argp);
+	case SIOCGSTAMP:
+		return do_siocgstamp(net, sock, cmd, argp);
+	case SIOCGSTAMPNS:
+		return do_siocgstampns(net, sock, cmd, argp);
+/* Note SIOCRTMSG is no longer, so this is safe and
+ * the user would have seen just an -EINVAL anyways. */
+	case SIOCRTMSG:
+	case SIOCGIFCOUNT:
+		return -EINVAL;
+
+	case FIOSETOWN:
+	case SIOCSPGRP:
+	case FIOGETOWN:
+	case SIOCGPGRP:
+	case SIOCBRADDBR:
+	case SIOCBRDELBR:
+	case SIOCGIFVLAN:
+	case SIOCSIFVLAN:
+	case SIOCADDDLCI:
+	case SIOCDELDLCI:
+		return sock_ioctl(file, cmd, arg);
+
+	case SIOCGIFFLAGS:
+	case SIOCSIFFLAGS:
+	case SIOCGIFMETRIC:
+	case SIOCSIFMETRIC:
+	case SIOCGIFMTU:
+	case SIOCSIFMTU:
+	case SIOCGIFMEM:
+	case SIOCSIFMEM:
+	case SIOCGIFHWADDR:
+	case SIOCSIFHWADDR:
+	case SIOCADDMULTI:
+	case SIOCDELMULTI:
+	case SIOCGIFINDEX:
+	case SIOCGIFMAP:
+	case SIOCSIFMAP:
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCSIFHWBROADCAST:
+	case SIOCSHWTSTAMP:
+	case SIOCDIFADDR:
+/*	case SIOCSARP: duplicate */
+/*	case SIOCDARP: duplicate */
+	case SIOCGIFBRDADDR:
+	case SIOCSIFBRDADDR:
+	case SIOCGIFDSTADDR:
+	case SIOCSIFDSTADDR:
+	case SIOCGIFNETMASK:
+	case SIOCSIFNETMASK:
+	case SIOCSIFPFLAGS:
+	case SIOCGIFPFLAGS:
+	case SIOCGIFTXQLEN:
+	case SIOCSIFTXQLEN:
+	case SIOCBRADDIF:
+	case SIOCBRDELIF:
+		return dev_ifsioc(net, sock, cmd, argp);
+	case ATM_GETLINKRATE32:
+	case ATM_GETNAMES32:
+	case ATM_GETTYPE32:
+	case ATM_GETESI32:
+	case ATM_GETADDR32:
+	case ATM_RSTADDR32:
+	case ATM_ADDADDR32:
+	case ATM_DELADDR32:
+	case ATM_GETCIRANGE32:
+	case ATM_SETCIRANGE32:
+	case ATM_SETESI32:
+	case ATM_SETESIF32:
+	case ATM_GETSTAT32:
+	case ATM_GETSTATZ32:
+	case ATM_GETLOOP32:
+	case ATM_SETLOOP32:
+	case ATM_QUERYLOOP32:
+	case SONET_GETSTAT:
+	case SONET_GETSTATZ:
+	case SONET_GETDIAG:
+	case SONET_SETDIAG:
+	case SONET_CLRDIAG:
+	case SONET_SETFRAMING:
+	case SONET_GETFRAMING:
+	case SONET_GETFRSENSE:
+		return do_atm_ioctl(net, sock, cmd, arg);
+
+	case ATMSIGD_CTRL:
+	case ATMARPD_CTRL:
+	case ATMLEC_CTRL:
+	case ATMLEC_MCAST:
+	case ATMLEC_DATA:
+	case ATM_SETSC:
+	case SIOCSIFATMTCP:
+	case SIOCMKCLIP:
+	case ATMARP_MKIP:
+	case ATMARP_SETENTRY:
+	case ATMARP_ENCAP:
+	case ATMTCP_CREATE:
+	case ATMTCP_REMOVE:
+	case ATMMPC_CTRL:
+	case ATMMPC_DATA:
+
+	case SIOCSARP:
+	case SIOCGARP:
+	case SIOCDARP:
+
+	case SIOCATMARK:
+	case SIOCSIFLINK:
+	case SIOCSIFNAME:
+	case SIOCSRARP:
+	case SIOCGRARP:
+	case SIOCDRARP:
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return sock_do_ioctl(net, sock, cmd, arg);
+	}
+
+	return -ENOIOCTLCMD;
+}
 
 static long compat_sock_ioctl(struct file *file, unsigned cmd,
 			      unsigned long arg)
@@ -3035,6 +3044,9 @@ static long compat_sock_ioctl(struct file *file, unsigned cmd,
 	    (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST))
 		ret = compat_wext_handle_ioctl(net, cmd, arg);
 
+	if (ret == -ENOIOCTLCMD)
+		ret = compat_sock_ioctl_trans(file, sock, cmd, arg);
+
 	return ret;
 }
 #endif
-- 
1.6.3.3
