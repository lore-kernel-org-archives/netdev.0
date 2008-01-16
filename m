From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] TUN/TAP GSO/partial csum support
Date: Wed, 16 Jan 2008 23:06:27 +1100
Message-ID: <200801162306.27767.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_DNfjHb/IPn+Bnxq"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Max Krasnyansky <maxk@qualcomm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52760 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbYAPMHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 07:07:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_DNfjHb/IPn+Bnxq
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

OK, revised with help from Herbert.  Also, I have attached a test program and
a script to run it (it short-circuits two tun devices, so you can run it with
the patch applied and see big packets flowing).

This implements partial checksum and GSO support for tun/tap.

We use the virtio_net_hdr: it is an ABI already and designed to
encapsulate such metadata as GSO and partial checksums.

lguest performance (160MB sendfile, worst/best/avg, 20 runs):
	Before: 5.06/3.39/3.82
	After:  4.69/0.84/2.84

Note that there is no easy way to detect if GSO is supported: see next
patch.

Questions:
1) Should we rename/move virtio_net_hdr to something more generic?
2) Is this the right way to build a paged skb from user pages?

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |  250 +++++++++++++++++++++++++++++++++++++++++++------
 include/linux/if_tun.h |    2 
 2 files changed, 225 insertions(+), 27 deletions(-)

diff -r ba3c0eb8741a drivers/net/tun.c
--- a/drivers/net/tun.c	Wed Jan 16 17:35:25 2008 +1100
+++ b/drivers/net/tun.c	Wed Jan 16 22:11:11 2008 +1100
@@ -62,6 +62,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
+#include <linux/virtio_net.h>
 #include <net/net_namespace.h>
 
 #include <asm/system.h>
@@ -238,35 +239,189 @@ static unsigned int tun_chr_poll(struct 
 	return mask;
 }
 
+static struct sk_buff *copy_user_skb(size_t align, struct iovec *iv, size_t len)
+{
+	struct sk_buff *skb;
+
+	if (!(skb = alloc_skb(len + align, GFP_KERNEL)))
+		return ERR_PTR(-ENOMEM);
+
+	if (align)
+		skb_reserve(skb, align);
+
+	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
+		kfree_skb(skb);
+		return ERR_PTR(-EFAULT);
+	}
+	return skb;
+}
+
+/* This will fail if they give us a crazy iovec, but that's their own fault. */
+static int get_user_skb_frags(const struct iovec *iv, size_t count,
+			      struct skb_frag_struct *f)
+{
+	unsigned int i, j, num_pg = 0;
+	int err;
+	struct page *pages[MAX_SKB_FRAGS];
+
+	down_read(&current->mm->mmap_sem);
+	for (i = 0; i < count; i++) {
+		int n, npages;
+		unsigned long base, len;
+		base = (unsigned long)iv[i].iov_base;
+		len = (unsigned long)iv[i].iov_len;
+
+		if (len == 0)
+			continue;
+
+		/* How many pages will this take? */
+		npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;
+		if (unlikely(num_pg + npages > MAX_SKB_FRAGS)) {
+			err = -ENOSPC;
+			goto fail;
+		}
+		n = get_user_pages(current, current->mm, base, npages,
+				   0, 0, pages, NULL);
+		if (unlikely(n < 0)) {
+			err = n;
+			goto fail;
+		}
+
+		/* Transfer pages to the frag array */
+		for (j = 0; j < n; j++) {
+			f[num_pg].page = pages[j];
+			if (j == 0) {
+				f[num_pg].page_offset = offset_in_page(base);
+				f[num_pg].size = min(len, PAGE_SIZE -
+						     f[num_pg].page_offset);
+			} else {
+				f[num_pg].page_offset = 0;
+				f[num_pg].size = min(len, PAGE_SIZE);
+			}
+			len -= f[num_pg].size;
+			base += f[num_pg].size;
+			num_pg++;
+		}
+
+		if (unlikely(n != npages)) {
+			err = -EFAULT;
+			goto fail;
+		}
+	}
+	up_read(&current->mm->mmap_sem);
+	return num_pg;
+
+fail:
+	for (i = 0; i < num_pg; i++)
+		put_page(f[i].page);
+	up_read(&current->mm->mmap_sem);
+	return err;
+}
+
+
+static struct sk_buff *map_user_skb(const struct virtio_net_hdr *gso,
+				    size_t align, struct iovec *iv,
+				    size_t count, size_t len)
+{
+	struct sk_buff *skb;
+	struct skb_shared_info *sinfo;
+	int err;
+
+	if (!(skb = alloc_skb(gso->gso_hdr_len + align, GFP_KERNEL)))
+		return ERR_PTR(-ENOMEM);
+
+	if (align)
+		skb_reserve(skb, align);
+
+	sinfo = skb_shinfo(skb);
+	sinfo->gso_size = gso->gso_size;
+	sinfo->gso_type = SKB_GSO_DODGY;
+	switch (gso->gso_type) {
+	case VIRTIO_NET_HDR_GSO_TCPV4_ECN:
+		sinfo->gso_type |= SKB_GSO_TCP_ECN;
+		/* fall through */
+	case VIRTIO_NET_HDR_GSO_TCPV4:
+		sinfo->gso_type |= SKB_GSO_TCPV4;
+		break;
+	case VIRTIO_NET_HDR_GSO_TCPV6:
+		sinfo->gso_type |= SKB_GSO_TCPV6;
+		break;
+	case VIRTIO_NET_HDR_GSO_UDP:
+		sinfo->gso_type |= SKB_GSO_UDP;
+		break;
+	default:
+		err = -EINVAL;
+		goto fail;
+	}
+
+	/* Copy in the header. */
+	if (memcpy_fromiovec(skb_put(skb, gso->gso_hdr_len), iv,
+			     gso->gso_hdr_len)) {
+		err = -EFAULT;
+		goto fail;
+	}
+
+	err = get_user_skb_frags(iv, count, sinfo->frags);
+	if (err < 0)
+		goto fail;
+
+	sinfo->nr_frags = err;
+	skb->len += len;
+	skb->data_len += len;
+	
+	return skb;
+
+fail:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+
+static inline size_t iov_total(const struct iovec *iv, unsigned long count)
+{
+	unsigned long i;
+	size_t len;
+
+	for (i = 0, len = 0; i < count; i++)
+		len += iv[i].iov_len;
+
+	return len;
+}
+
 /* Get packet from user space buffer */
-static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
+static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t num)
 {
 	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
+	struct virtio_net_hdr gso = { 0, VIRTIO_NET_HDR_GSO_NONE };
 	struct sk_buff *skb;
-	size_t len = count, align = 0;
+	size_t tot_len = iov_total(iv, num);
+	size_t len = tot_len, align = 0;
 
 	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) > count)
+		if ((len -= sizeof(pi)) > tot_len)
 			return -EINVAL;
 
 		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
+			return -EFAULT;
+	}
+	if (tun->flags & TUN_GSO_HDR) {
+		if ((len -= sizeof(gso)) > tot_len)
+			return -EINVAL;
+
+		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
 			return -EFAULT;
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV)
 		align = NET_IP_ALIGN;
 
-	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
+	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE)
+		skb = map_user_skb(&gso, align, iv, num, len);
+	else
+		skb = copy_user_skb(align, iv, len);
+
+	if (IS_ERR(skb)) {
 		tun->dev->stats.rx_dropped++;
-		return -ENOMEM;
-	}
-
-	if (align)
-		skb_reserve(skb, align);
-	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
-		tun->dev->stats.rx_dropped++;
-		kfree_skb(skb);
-		return -EFAULT;
+		return PTR_ERR(skb);
 	}
 
 	switch (tun->flags & TUN_TYPE_MASK) {
@@ -280,7 +435,13 @@ static __inline__ ssize_t tun_get_user(s
 		break;
 	};
 
-	if (tun->flags & TUN_NOCHECKSUM)
+	if (gso.flags & (1 << VIRTIO_NET_F_NO_CSUM)) {
+		if (!skb_partial_csum_set(skb,gso.csum_start,gso.csum_offset)) {
+			tun->dev->stats.rx_dropped++;
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+	} else if (tun->flags & TUN_NOCHECKSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx_ni(skb);
@@ -289,18 +450,7 @@ static __inline__ ssize_t tun_get_user(s
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
 
-	return count;
-}
-
-static inline size_t iov_total(const struct iovec *iv, unsigned long count)
-{
-	unsigned long i;
-	size_t len;
-
-	for (i = 0, len = 0; i < count; i++)
-		len += iv[i].iov_len;
-
-	return len;
+	return tot_len;
 }
 
 static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
@@ -313,7 +463,7 @@ static ssize_t tun_chr_aio_write(struct 
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	return tun_get_user(tun, (struct iovec *) iv, iov_total(iv, count));
+	return tun_get_user(tun, (struct iovec *) iv, count);
 }
 
 /* Put packet to the user space buffer */
@@ -336,6 +486,42 @@ static __inline__ ssize_t tun_put_user(s
 		if (memcpy_toiovec(iv, (void *) &pi, sizeof(pi)))
 			return -EFAULT;
 		total += sizeof(pi);
+	}
+	if (tun->flags & TUN_GSO_HDR) {
+		struct virtio_net_hdr gso;
+		struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+		if (skb_is_gso(skb)) {
+			gso.gso_hdr_len = skb_transport_header(skb) - skb->data;
+			gso.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4_ECN;
+			else if (sinfo->gso_type & SKB_GSO_TCPV4)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+		} else
+			gso.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+		
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			gso.csum_start = skb->csum_start - skb_headroom(skb);
+			gso.csum_offset = skb->csum_offset;
+		} else {
+			gso.flags = 0;
+			gso.csum_offset = gso.csum_start = 0;
+		}
+
+		if ((len -= sizeof(gso)) < 0)
+			return -EINVAL;
+
+		if (memcpy_toiovec(iv, (void *)&gso, sizeof(gso)))
+			return -EFAULT;
+		total += sizeof(gso);
 	}
 
 	len = min_t(int, skb->len, len);
@@ -523,6 +709,13 @@ static int tun_set_iff(struct file *file
 
 		tun_net_init(dev);
 
+		/* GSO?  One of everything, please. */
+		if (ifr->ifr_flags & IFF_GSO_HDR)
+			dev->features = (NETIF_F_SG | NETIF_F_HW_CSUM
+					 | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST
+					 | NETIF_F_TSO | NETIF_F_UFO
+					 | NETIF_F_TSO_ECN | NETIF_F_TSO6);
+
 		if (strchr(dev->name, '%')) {
 			err = dev_alloc_name(dev, dev->name);
 			if (err < 0)
@@ -543,6 +736,9 @@ static int tun_set_iff(struct file *file
 
 	if (ifr->ifr_flags & IFF_ONE_QUEUE)
 		tun->flags |= TUN_ONE_QUEUE;
+
+	if (ifr->ifr_flags & IFF_GSO_HDR)
+		tun->flags |= TUN_GSO_HDR;
 
 	file->private_data = tun;
 	tun->attached = 1;
diff -r ba3c0eb8741a include/linux/if_tun.h
--- a/include/linux/if_tun.h	Wed Jan 16 17:35:25 2008 +1100
+++ b/include/linux/if_tun.h	Wed Jan 16 22:11:11 2008 +1100
@@ -70,6 +70,7 @@ struct tun_struct {
 #define TUN_NO_PI	0x0040
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
+#define TUN_GSO_HDR 	0x0200	
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -79,6 +80,7 @@ struct tun_struct {
 #define IFF_TAP		0x0002
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
+#define IFF_GSO_HDR	0x4000
 
 struct tun_pi {
 	unsigned short flags;

--Boundary-00=_DNfjHb/IPn+Bnxq
Content-Type: text/x-csrc;
  charset="utf-8";
  name="tun_gso_pipe.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tun_gso_pipe.c"

#include <signal.h>
#include <stddef.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>
#include <netinet/tcp.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <stdio.h>
#include <string.h>
#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/uio.h>
#include <linux/sockios.h>
#include <linux/if_tun.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

typedef uint32_t u32;
typedef uint16_t u16;
typedef uint8_t u8;

#ifndef TUNGETFEATURES
#define TUNGETFEATURES  _IOR('T', 207, unsigned int)
#endif
#ifndef IFF_GSO_HDR
#define IFF_GSO_HDR	0x4000
#endif

static bool use_gso = true;

static bool write_all(int fd, const void *data, unsigned long size)
{
	while (size) {
		int done;

		done = write(fd, data, size);
		if (done < 0 && errno == EINTR)
			continue;
		if (done <= 0)
			return false;
		data += done;
		size -= done;
	}

	return true;
}

static bool read_all(int fd, void *data, unsigned long size)
{
	while (size) {
		int done;

		done = read(fd, data, size);
		if (done < 0 && errno == EINTR)
			continue;
		if (done <= 0)
			return false;
		data += done;
		size -= done;
	}

	return true;
}

static uint32_t str2ip(const char *ipaddr)
{
	unsigned int byte[4];

	sscanf(ipaddr, "%u.%u.%u.%u", &byte[0], &byte[1], &byte[2], &byte[3]);
	return (byte[0] << 24) | (byte[1] << 16) | (byte[2] << 8) | byte[3];
}

static void configure_device(int fd, const char *devname, uint32_t ipaddr)
{
	struct ifreq ifr;
	struct sockaddr_in *sin = (struct sockaddr_in *)&ifr.ifr_addr;

	/* Don't read these incantations.  Just cut & paste them like I did! */
	memset(&ifr, 0, sizeof(ifr));
	strcpy(ifr.ifr_name, devname);
	sin->sin_family = AF_INET;
	sin->sin_addr.s_addr = htonl(ipaddr);
	if (ioctl(fd, SIOCSIFADDR, &ifr) != 0)
		err(1, "Setting %s interface address", devname);
	ifr.ifr_flags = IFF_UP;
	if (ioctl(fd, SIOCSIFFLAGS, &ifr) != 0)
		err(1, "Bringing interface %s up", devname);
}

static int setup_tun_net(uint32_t ip)
{
	struct ifreq ifr;
	int netfd, ipfd;
	unsigned int features;

	/* We open the /dev/net/tun device and tell it we want a tap device.  A
	 * tap device is like a tun device, only somehow different.  To tell
	 * the truth, I completely blundered my way through this code, but it
	 * works now! */
	netfd = open("/dev/net/tun", O_RDWR);
	if (netfd < 0)
		err(1, "Opening /dev/net/tun");

	if (use_gso &&
	    (ioctl(netfd, TUNGETFEATURES, &features) != 0
	     || !(features & IFF_GSO_HDR))) {
		fprintf(stderr, "No GSO support!\n");
		use_gso = false;
	}

	memset(&ifr, 0, sizeof(ifr));
	ifr.ifr_flags = IFF_TAP | IFF_NO_PI | (use_gso ? IFF_GSO_HDR : 0);
	strcpy(ifr.ifr_name, "tap%d");
	if (ioctl(netfd, TUNSETIFF, &ifr) != 0)
		err(1, "configuring /dev/net/tun");

	/* We need a socket to perform the magic network ioctls to bring up the
	 * tap interface, connect to the bridge etc.  Any socket will do! */
	ipfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (ipfd < 0)
		err(1, "opening IP socket");

	/* We are peer 0, ie. first slot, so we hand dev->mem to this routine
	 * to write the MAC address at the start of the device memory.  */
	configure_device(ipfd, ifr.ifr_name, ip);
	close(ipfd);

	return netfd;
}

static void two_way_popen(char *const argv[])
{
	int pid;
	int pipe1[2], pipe2[2];

	if (pipe(pipe1) != 0 || pipe(pipe2) != 0)
		err(1, "creating pipe");

	pid = fork();
	if (pid == -1)
		err(1, "forking");

	if (pid == 0) {
		/* We are the child. */
		close(pipe1[1]);
		close(pipe2[0]);
		dup2(pipe1[0], STDIN_FILENO);
		dup2(pipe2[1], STDOUT_FILENO);

		execvp(argv[0], argv);
		fprintf(stderr, "Failed to exec '%s': %m\n", argv[0]);
		kill(getppid(), SIGKILL);
	}

	/* We are parent. */
	close(pipe1[0]);
	close(pipe2[1]);
	dup2(pipe1[1], STDOUT_FILENO);
	dup2(pipe2[0], STDIN_FILENO);
}

struct virtio_net_hdr
{
#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
	__u8 flags;
#define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
#define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
/* FIXME: Do we need this?  If they said they can handle ECN, do they care? */
#define VIRTIO_NET_HDR_GSO_TCPV4_ECN	2	// GSO frame, IPv4 TCP w/ ECN
#define VIRTIO_NET_HDR_GSO_UDP		3	// GSO frame, IPv4 UDP (UFO)
#define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
	__u8 gso_type;
	__u16 gso_hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
	__u16 gso_size;		/* Bytes to append to gso_hdr_len per frame */
	__u16 csum_start;	/* Position to start checksumming from */
	__u16 csum_offset;	/* Offset after that to place checksum */
};

struct packet
{
	struct virtio_net_hdr gso;
	struct ether_header mac;
	struct iphdr ip;
	union {
		struct icmphdr icmp;
		struct tcphdr tcp;
		struct udphdr udp;
		char pad[65535 - 34];
	};
} __attribute__((packed));

static inline unsigned short from32to16(unsigned long x)
{
	/* add up 16-bit and 16-bit for 16+c bit */
	x = (x & 0xffff) + (x >> 16);
	/* add up carry.. */
	x = (x & 0xffff) + (x >> 16);
	return x;
}

static unsigned int csum_fold(unsigned int sum)
{
	return ~from32to16(sum);
}

static unsigned long do_csum(const unsigned char * buff, int len)
{
	int odd, count;
	unsigned long result = 0;

	if (len <= 0)
		return 0;

	odd = 1 & (unsigned long) buff;
	if (odd) {
		result = *buff;
		len--;
		buff++;
	}
	count = len >> 1;		/* nr of 16-bit words.. */
	if (count) {
		if (2 & (unsigned long) buff) {
			result += *(unsigned short *) buff;
			count--;
			len -= 2;
			buff += 2;
		}
		count >>= 1;		/* nr of 32-bit words.. */
		if (count) {
		        unsigned long carry = 0;
			do {
				unsigned int w = *(unsigned int *) buff;
				count--;
				buff += 4;
				result += carry;
				result += w;
				carry = (w > result);
			} while (count);
			result += carry;
			result = (result & 0xffff) + (result >> 16);
		}
		if (len & 2) {
			result += *(unsigned short *) buff;
			buff += 2;
		}
	}
	if (len & 1)
		result += (*buff << 8);
	result = from32to16(result);
	if (odd)
		result = ((result >> 8) & 0xff) | ((result & 0xff) << 8);

	return result;
}

static unsigned int csum_partial(const void * buff, int len, unsigned int sum)
{
	unsigned int result = do_csum(buff, len);

	/* add in old sum, and carry.. */
	result += sum;
	if (sum > result)
		result += 1;
	return result;
}

static void csum_replace(__u16 *sum, u32 from, u32 to)
{
	u32 diff[] = { ~from, to };
	*sum = csum_fold(csum_partial(diff, sizeof(diff), *sum ^ 0xFFFF));
}

#define NIPQUAD(addr) \
	((unsigned char *)&addr)[0], \
	((unsigned char *)&addr)[1], \
	((unsigned char *)&addr)[2], \
	((unsigned char *)&addr)[3]

/* Change destination IP address */
static void nat_packet(struct packet *packet, u32 src, u32 dst)
{
	u32 oldsrc, olddst;

	if (packet->mac.ether_type != htons(ETHERTYPE_IP))
		return;

	oldsrc = packet->ip.saddr;
	olddst = packet->ip.daddr;
	packet->ip.saddr = src;
	packet->ip.daddr = dst;
	csum_replace(&packet->ip.check, oldsrc, src);
	csum_replace(&packet->ip.check, olddst, dst);

	switch (packet->ip.protocol) {
	case IPPROTO_TCP:
		csum_replace(&packet->tcp.check, oldsrc, src);
		csum_replace(&packet->tcp.check, olddst, dst);
		break;
	case IPPROTO_UDP:
		csum_replace(&packet->udp.check, oldsrc, src);
		csum_replace(&packet->udp.check, olddst, dst);
		break;
	}
}

int main(int argc, char *argv[])
{
	int netfd;
	__u32 natdst, natsrc;
	int size;
	struct packet packet;
	void *buf;

	if (argv[1] && strcmp(argv[1], "--no-gso") == 0) {
		argv++;
		argc--;
		use_gso = false;
	}

	if (argc < 4)
		errx(1, "Usage: %s [--no-gso] ip-addr src-nat-addr dst-nat-addr [command-to-open...]", argv[0]);

	netfd = setup_tun_net(str2ip(argv[1]));
	natsrc = htonl(str2ip(argv[2]));
	natdst = htonl(str2ip(argv[3]));

	/* Eg. ssh othermachine /root/tun_gso_pipe 192.168.1.2 192.168.5.2 192.158.5.1 */
	if (argc > 4)
		two_way_popen(argv+4);

	if (use_gso)
		buf = &packet;
	else
		buf = &packet.mac;

	for (;;) {
		fd_set fds;

		FD_ZERO(&fds);
		FD_SET(netfd, &fds);
		FD_SET(STDIN_FILENO, &fds);
		select(netfd+1, &fds, NULL, NULL, NULL);
		if (FD_ISSET(netfd, &fds)) {
			size = read(netfd, buf, sizeof(packet));
			if (size <= 0)
				err(1, "Reading netfd");
			if (use_gso)
				fprintf(stderr, "Read %u, gso = %u/%u\n", size,
					packet.gso.gso_type,
					packet.gso.gso_size);
			nat_packet(&packet, natsrc, natdst);
			if (!write_all(STDOUT_FILENO, &size, sizeof(size))
			    || !write_all(STDOUT_FILENO, buf, size))
				err(1, "Writing data to stdout");
		}
		if (FD_ISSET(STDIN_FILENO, &fds)) {
			int ret;
			if (!read_all(STDIN_FILENO, &size, sizeof(size)))
				err(1, "Reading stdin");
			if (!read_all(STDIN_FILENO, buf, size))
				err(1, "Reading %u byte packet", size);
			fprintf(stderr, "Writing %u, gso = %u/%u\n", size,
				packet.gso.gso_type,
				packet.gso.gso_size);
			ret = write(netfd, buf, size);
			if (ret != size)
				err(1, "Writing data to netfd gave %i/%i",
				    ret, size);
		}
	}
}

--Boundary-00=_DNfjHb/IPn+Bnxq
Content-Type: application/x-shellscript;
  name="tun_gso_pipe-setup.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tun_gso_pipe-setup.sh"

#! /bin/sh
# Test script to wire in tun <-> tun pipe.

TUN0IP=192.168.1.1
TUN1IP=192.168.1.2

# Nat packets out tun0 (ie. going to tun1) to seem to come from here.
FAKETUN1=192.168.3.1
# Nat packets out tun1 (ie. going to tun0) to seem to come from here.
FAKETUN0=192.168.2.1

hwaddrof()
{
    ifconfig $1 | sed -n 's/.*HWaddr //p'
}

# Need job control for fg at end
set -m

# Create natting pipe
./tun_gso_pipe $TUN0IP $FAKETUN1 $TUN1IP ./tun_gso_pipe $TUN1IP $FAKETUN0 $TUN0IP &

# Wait for that to create interfaces.
sleep 2

# Route so that tun1 and tun0 think those nets are out there.
route add $FAKETUN1 dev tap1
route add $FAKETUN0 dev tap0        

# Finally wire in arp entries so they're accepted on other side.
arp -s $FAKETUN1 `hwaddrof tap0`
arp -s $FAKETUN0 `hwaddrof tap1`

fg

--Boundary-00=_DNfjHb/IPn+Bnxq--
