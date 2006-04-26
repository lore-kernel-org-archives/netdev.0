From: Kelly Daly <kelly@au1.ibm.com>
Subject: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 11:47:34 +0000
Message-ID: <200604261147.34221.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:952 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP id S932329AbWDZBrN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 21:47:13 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k3Q1v7qG132680
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:57:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3Q1oIfd213094
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:50:23 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11/8.13.3) with ESMTP id k3Q1kwnv010914
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:46:58 +1000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey guys...  I've been working with Rusty on a VJ Channel implementation.  
Noting Dave's recent release of his implementation, we thought we'd better 
get this "out there" so we can do some early comparison/combining and 
come up with the best possible implementation.

There are three patches in total:
1) vj_core.patch - core files for VJ to userspace
2) vj_udp.patch  - badly hacked up UDP receive implementation - basically just to test what logic may be like!
3) vj_ne2k.patch - modified NE2K and 8390 used for testing on QEMU

Notes:
* channels can have global or local buffers (local for userspace.  Could be used directly by intelligent NIC)
* UDP receive breaks real UDP - doesn't talk anything except VJ Channels anymore.  Needs integration with normal sources.
* Userspace test app (below) uses VJ protocol family to mmap space for local buffers, if it receives buffers in kernel space sends a request for that buffer to be copied to local buffer.
* Default channel converts to skb and feeds through normal receive path.

TODO:
* send not yet implemented
* integrate non vj
* LOTS of fixmes

Cheers,
Kelly



Test userspace app:
/*  Van Jacobson net channels implementation for Linux
    Copyright (C) 2006  Kelly Daly <kdaly@au.ibm.com>  IBM Corporation

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/mman.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include "linux-2.6.16/include/linux/types.h"
#include "linux-2.6.16/include/linux/vjchan.h"

//flowid
#define SADDR 0
#define DADDR 0
#define SPORT 0
#define DPORT 60000
#define IFINDEX 0

#define PF_VJCHAN 27

static struct vj_buffer *get_buffer(struct vj_channel_ring *ring, int desc_num)
{
        printf("desc_num %i\n", desc_num);
        return (void *)ring + (desc_num + 1) * getpagesize();
}
/* return the next buffer, but do not move on */
static struct vj_buffer *vj_peek_next_buffer(struct vj_channel_ring *ring)
{
        if (ring->c.head == ring->p.tail)
                return NULL;
        return get_buffer(ring, ring->q[ring->c.head]);
}

/* move on to next buffer */
static void vj_done_with_buffer(struct vj_channel_ring *ring)
{
        ring->c.head = (ring->c.head+1)%VJ_NET_CHANNEL_ENTRIES;

        printf("done_with_buffer\n\n");
}

int main(int argc, char *argv[])
{
        int sk, cls, bnd, pll;
        void * mmapped;
        struct vj_flowid flowid;
        struct vj_channel_ring *ring;
        struct vj_buffer *buf;
        struct pollfd pfd;

        printf("\nstart of vjchannel socket test app\n");
        sk = socket(PF_VJCHAN, SOCK_DGRAM, IPPROTO_UDP);
        if (sk == -1) {
                perror("Unable to open socket!");
                return -1;
        }
        printf("socket open with ret code %i\n\n", sk);

//create flowid!!!
        flowid.saddr = SADDR;
        flowid.daddr = DADDR;
        flowid.sport = SPORT;
        flowid.dport = htons(DPORT);
        flowid.ifindex = IFINDEX;
        flowid.proto = IPPROTO_UDP;

        printf("flowid created\n");

        bnd = bind(sk, (struct sockaddr *)&flowid, sizeof(struct vj_flowid));
        if (bnd == -1) {
                perror("Unable to bind socket!");
                return -1;
        }
        printf("socket bound with ret code %i\n\n", bnd);

        ring = mmap(0, (getpagesize() * (VJ_NET_CHANNEL_ENTRIES+1)), PROT_READ|PROT_WRITE, MAP_SHARED, sk, 0);
        if (ring == MAP_FAILED) {
                perror ("Unable to mmap socket!");
                return -1;
        }
        printf("socket mmapped to address %lu\n\n", (unsigned long)mmapped);
        
        pfd.fd = sk;
        pfd.events = POLLIN;

        for (;;) {
                pll = poll(&pfd, 1, -1);
                
                if (pll < 0) {
                        perror("polling failed!");
                        return -1;
                }

//consume
                buf = vj_peek_next_buffer(ring);

                printf("buf %p\n", buf);

//print data, not headers
                printf("   Buffer Length = %i\n", buf->data_len);
                printf("   Header Length = %i\n", buf->header_len);
                printf("   Buffer Data: '%.*s'\n", buf->data_len - 28, buf->data + buf->header_len + 28);
                vj_done_with_buffer(ring);
        }

        cls = close(sk);
        if (cls != 0) {
                perror("Unable to close socket!");
                return -2;
        }
        printf("socket closed with ret code %i\n\n", cls);
        return 0;
}




-------------------------
Signed-off-by: Kelly Daly <kelly@au.ibm.com>

Basic infrastructure for Van Jacobson net channels: lockless ringbuffer for buffer transport.  Entries in ring buffer are descriptors for global or local buffers: ring and local buffers are mmapped into userspace.
Channels are registered with the core by flowid, and a thread services the default channel for any non-matching packets.  Drivers get (global) buffers from vj_get_buffer, and dispatch them through vj_netif_rx.
As userspace mmap cannot reach global buffers, select() copies global buffers into local buffers if required.


diff -r 47031a1f466c linux-2.6.16/include/linux/socket.h
--- linux-2.6.16/include/linux/socket.h Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/include/linux/socket.h Mon Apr 24 19:50:46 2006
@@ -186,6 +187,7 @@
 #define AF_PPPOX       24      /* PPPoX sockets                */
 #define AF_WANPIPE     25      /* Wanpipe API Sockets */
 #define AF_LLC         26      /* Linux LLC                    */
+#define AF_VJCHAN      27      /* VJ Channel */
 #define AF_TIPC                30      /* TIPC sockets                 */
 #define AF_BLUETOOTH   31      /* Bluetooth sockets            */
 #define AF_MAX         32      /* For now.. */
@@ -219,7 +221,8 @@
 #define PF_PPPOX       AF_PPPOX
 #define PF_WANPIPE     AF_WANPIPE
 #define PF_LLC         AF_LLC
+#define PF_VJCHAN      AF_VJCHAN
 #define PF_TIPC                AF_TIPC
 #define PF_BLUETOOTH   AF_BLUETOOTH
 #define PF_MAX         AF_MAX

diff -r 47031a1f466c linux-2.6.16/net/Kconfig
--- linux-2.6.16/net/Kconfig    Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/Kconfig    Mon Apr 24 19:50:46 2006
@@ -65,6 +65,12 @@
 source "net/ipv6/Kconfig"
 
 endif # if INET
+
+config VJCHAN
+       bool "Van Jacobson Net Channel Support (EXPERIMENTAL)"
+       depends on EXPERIMENTAL
+       ---help---
+         This adds a userspace-accessible packet receive interface.  Say N.
 
 menuconfig NETFILTER
        bool "Network packet filtering (replaces ipchains)"
diff -r 47031a1f466c linux-2.6.16/net/Makefile
--- linux-2.6.16/net/Makefile   Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/Makefile   Mon Apr 24 19:50:46 2006
@@ -46,6 +46,7 @@
 obj-$(CONFIG_IP_SCTP)          += sctp/
 obj-$(CONFIG_IEEE80211)                += ieee80211/
 obj-$(CONFIG_TIPC)             += tipc/
+obj-$(CONFIG_VJCHAN)           += vjchan/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)           += sysctl_net.o
diff -r 47031a1f466c linux-2.6.16/include/linux/vjchan.h
--- /dev/null   Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/include/linux/vjchan.h Mon Apr 24 19:50:46 2006
@@ -0,0 +1,79 @@
+#ifndef _LINUX_VJCHAN_H
+#define _LINUX_VJCHAN_H
+
+/* num entries in channel q: set so consumer is at offset 1024. */
+#define VJ_NET_CHANNEL_ENTRIES 254
+/* identifies non-local buffers (ie. need kernel to copy to a local) */
+#define VJ_HIGH_BIT 0x80000000
+
+struct vj_producer {
+       __u16 tail;                     /* next element to add */
+       __u8 wakecnt;                   /* do wakeup if != consumer wakecnt */
+       __u8 pad;
+       __u16 old_head;                 /* last cleared buffer posn +1 */
+       __u16 pad2;
+};
+
+struct vj_consumer {
+       __u16 head;                     /* next element to remove */
+       __u8 wakecnt;                   /* increment to request wakeup */
+};
+
+/* mmap returns one of these, followed by 254 pages with a buffer each */
+struct vj_channel_ring {
+       struct vj_producer p;           /* producer's header */
+       __u32 q[VJ_NET_CHANNEL_ENTRIES];
+       struct vj_consumer c;           /* consumer's header */
+};
+
+struct vj_buffer {
+       __u32 data_len;         /* length of actual data in buffer */
+       __u32 header_len;       /* offset eth + ip header (true for now) */
+       __u32 ifindex;          /* interface the packet came in on. */
+       char data[0];
+};
+
+/* Currently assumed IPv4 */
+struct vj_flowid
+{
+       __u32 saddr, daddr;
+       __u16 sport, dport;
+       __u32 ifindex;
+       __u16 proto;
+};
+
+#ifdef __KERNEL__
+struct net_device;
+struct sk_buff;
+
+struct vj_descriptor {
+       unsigned long address;          /* address of net_channel_buffer */
+       unsigned long buffer_len;       /* max length including header */
+};
+
+/* Everything about a vj_channel */
+struct vj_channel
+{
+       struct vj_channel_ring *ring;
+       wait_queue_head_t wq;
+       struct list_head list;
+       struct vj_flowid flowid;
+       int num_local_buffers;
+       struct vj_descriptor *descs;
+        unsigned long * used_descs;
+};
+
+void vj_inc_wakecnt(struct vj_channel *chan);
+struct vj_buffer *vj_get_buffer(int *desc_num);
+void vj_netif_rx(struct vj_buffer *buffer, int desc_num, unsigned short proto);
+int vj_xmit(struct sk_buff *skb, struct net_device *dev);
+struct vj_channel *vj_alloc_chan(int num_buffers);
+void vj_register_chan(struct vj_channel *chan, const struct vj_flowid *flowid);
+void vj_unregister_chan(struct vj_channel *chan);
+void vj_free_chan(struct vj_channel *chan);
+struct vj_buffer *vj_peek_next_buffer(struct vj_channel *chan);
+void vj_done_with_buffer(struct vj_channel *chan);
+unsigned short eth_vj_type_trans(struct vj_buffer *buffer);
+int vj_need_local_buffer(struct vj_channel *chan);
+#endif
+#endif /* _LINUX_VJCHAN_H */
diff -r 47031a1f466c linux-2.6.16/net/vjchan/Makefile
--- /dev/null   Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/vjchan/Makefile    Mon Apr 24 19:50:46 2006
@@ -0,0 +1,3 @@
+#obj-m += vjtest.o
+obj-y += vjnet.o
+obj-y += af_vjchan.o
diff -r 47031a1f466c linux-2.6.16/net/vjchan/af_vjchan.c
--- /dev/null   Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/vjchan/af_vjchan.c Mon Apr 24 19:50:46 2006
@@ -0,0 +1,198 @@
+/*  Van Jacobson net channels implementation for Linux
+    Copyright (C) 2006  Kelly Daly <kdaly@au.ibm.com>  IBM Corporation
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+*/
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/socket.h>
+#include <linux/vjchan.h>
+#include <net/sock.h>
+
+struct vjchan_sock
+{
+       struct sock sk;
+       struct vj_channel *chan;
+       int vj_reg_flag;
+};
+
+static inline struct vjchan_sock *vj_sk(struct sock *sk)
+{
+       return (struct vjchan_sock *)sk;
+}
+
+static struct proto vjchan_proto = {
+       .name = "VJCHAN",
+       .owner = THIS_MODULE,
+       .obj_size = sizeof(struct vjchan_sock),
+};
+
+int vjchan_release(struct socket *sock)
+{
+       struct sock *sk = sock->sk;
+
+       sock_orphan(sk);
+       sock->sk = NULL;
+       sock_put(sk);
+       return 0;
+}
+
+int vjchan_bind(struct socket *sock, struct sockaddr *addr, int sockaddr_len)
+{
+       struct sock *sk = sock->sk;
+       struct vjchan_sock *vjsk;
+       struct vj_flowid *flowid = (struct vj_flowid *)addr;
+
+       /* FIXME: avoid clashing with normal sockets, replace zeroes. */
+       vjsk = vj_sk(sk);
+       vj_register_chan(vjsk->chan, flowid);
+       vjsk->vj_reg_flag = 1;
+
+       return 0;
+}
+
+int vjchan_getname(struct socket *sock, struct sockaddr *addr,
+                  int *sockaddr_len, int peer)
+{
+       /* FIXME: Implement */
+       return 0;
+}
+
+unsigned int vjchan_poll(struct file *file, struct socket *sock,
+                        struct poll_table_struct *wait)
+{
+       struct sock *sk = sock->sk;
+       struct vj_channel *chan = vj_sk(sk)->chan;
+
+       poll_wait(file, &chan->wq, wait);
+       vj_inc_wakecnt(chan);
+
+       if (vj_peek_next_buffer(chan) && vj_need_local_buffer(chan) == 0)
+               return POLLIN | POLLRDNORM;
+
+       return 0;
+}
+
+/* We map the ring first, then one page per buffer. */
+int vjchan_mmap(struct file *file, struct socket *sock,
+               struct vm_area_struct *vma)
+{
+       struct sock *sk = sock->sk;
+       struct vj_channel *chan = vj_sk(sk)->chan;
+       int i, vip;
+       unsigned long pos;
+
+       if (vma->vm_end - vma->vm_start !=
+           (1 + chan->num_local_buffers)*PAGE_SIZE)
+               return -EINVAL;
+
+       pos = vma->vm_start;
+       vip = vm_insert_page(vma, pos, virt_to_page(chan->ring));
+       pos += PAGE_SIZE;
+       for (i = 0; i < chan->num_local_buffers; i++) {
+               vip = vm_insert_page(vma, pos, virt_to_page(chan->descs[i].address));
+               pos += PAGE_SIZE;
+       }
+       return 0;
+}
+
+const struct proto_ops vjchan_ops = {
+       .family = PF_VJCHAN,
+       .owner = THIS_MODULE,
+       .release = vjchan_release,
+       .bind = vjchan_bind,
+       .socketpair = sock_no_socketpair,
+       .accept = sock_no_accept,
+       .getname = vjchan_getname,
+       .poll = vjchan_poll,
+       .ioctl = sock_no_ioctl,
+       .shutdown = sock_no_shutdown,
+       .setsockopt = sock_common_setsockopt,
+       .getsockopt = sock_common_getsockopt,
+       .sendmsg = sock_no_sendmsg,
+       .recvmsg = sock_no_recvmsg,
+       .mmap = vjchan_mmap,
+       .sendpage = sock_no_sendpage
+};
+
+static void vjchan_destruct(struct sock *sk)
+{
+       struct vjchan_sock *vjsk;
+
+       vjsk = vj_sk(sk);
+       if (vjsk->vj_reg_flag) {
+               vj_unregister_chan(vjsk->chan);
+               vjsk->vj_reg_flag = 0;
+       }
+       vj_free_chan(vjsk->chan);
+
+}
+
+static int vjchan_create(struct socket *sock, int protocol)
+{
+       struct sock *sk;
+       struct vjchan_sock *vjsk;
+       int err;
+
+       if (!capable(CAP_NET_RAW))
+               return -EPERM;
+       if (sock->type != SOCK_DGRAM
+           && sock->type != SOCK_RAW
+           && sock->type != SOCK_PACKET)
+               return -ESOCKTNOSUPPORT;
+
+       sock->state = SS_UNCONNECTED;
+
+       err = -ENOBUFS;
+       sk = sk_alloc(PF_VJCHAN, GFP_KERNEL, &vjchan_proto, 1);
+       if (sk == NULL)
+               goto out;
+
+       sock->ops = &vjchan_ops;
+
+       sock_init_data(sock, sk);
+       sk->sk_family = PF_VJCHAN;
+       sk->sk_destruct = vjchan_destruct;
+
+       vjsk = vj_sk(sk);
+       vjsk->chan = vj_alloc_chan(VJ_NET_CHANNEL_ENTRIES);
+       vjsk->vj_reg_flag = 0;
+       if (!vjsk->chan)
+               return -ENOMEM;
+       return 0;
+out:
+       return err;
+}
+
+static struct net_proto_family vjchan_family_ops = {
+       .family =       PF_VJCHAN,
+       .create =       vjchan_create,
+       .owner  =       THIS_MODULE,
+};
+
+static void __exit vjchan_exit(void)
+{
+       sock_unregister(PF_VJCHAN);
+}
+
+static int __init vjchan_init(void)
+{
+       return sock_register(&vjchan_family_ops);
+}
+
+module_init(vjchan_init);
+module_exit(vjchan_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_VJCHAN);
diff -r 47031a1f466c linux-2.6.16/net/vjchan/vjnet.c
--- /dev/null   Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/vjchan/vjnet.c     Mon Apr 24 19:50:46 2006
@@ -0,0 +1,550 @@
+/*  Van Jacobson net channels implementation for Linux
+    Copyright (C) 2006  Kelly Daly <kdaly@au.ibm.com>  IBM Corporation
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+*/
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/kthread.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/spinlock.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/vjchan.h>
+
+#define BUFFER_DATA_LEN 2048
+#define NUM_GLOBAL_DESCRIPTORS 1024
+
+/* All our channels.  FIXME: Lockless funky hash structure please... */
+static LIST_HEAD(channels);
+static spinlock_t chan_lock = SPIN_LOCK_UNLOCKED;
+
+/* Default channel, also holds global buffers (userspace-mapped
+ * channels have local buffers, which they prefer to use). */
+static struct vj_channel *default_chan;
+
+/* need to increment for wake in udp.c wait_for_vj_buffer */
+void vj_inc_wakecnt(struct vj_channel *chan)
+{
+       chan->ring->c.wakecnt++;
+       pr_debug("*** incremented wakecnt - should allow wake up\n");
+}
+EXPORT_SYMBOL(vj_inc_wakecnt);
+
+static int is_empty(struct vj_channel_ring *ring)
+{
+       if (ring->c.head == ring->p.tail)
+               return 1;
+       return 0;
+}
+
+static struct vj_buffer *get_buffer(unsigned int desc_num,
+                                   struct vj_channel *chan)
+{
+       struct vj_buffer *buf;
+
+       if ((desc_num & VJ_HIGH_BIT) || (chan->num_local_buffers == 0)) {
+               desc_num &= ~VJ_HIGH_BIT;
+               BUG_ON(desc_num >= default_chan->num_local_buffers);
+               buf = (struct vj_buffer*)default_chan->descs[desc_num].address;
+       } else {
+               BUG_ON(desc_num >= chan->num_local_buffers);
+               buf = (struct vj_buffer *)chan->descs[desc_num].address;
+       }
+       
+       pr_debug("       received desc_num is %i\n", desc_num);
+       pr_debug("get_buffer %p (%s) %i: %p (len=%li ifind=%i hlen=%li) %#02X %#02X %#02X %#02X %#02X %#02X %#02X %#02X\n",
+                current, current->comm, desc_num, buf, buf->data_len, buf->ifindex, buf->header_len + (sizeof(struct iphdr *) * 4),
+                buf->data[0], buf->data[1], buf->data[2], buf->data[3], buf->data[4], buf->data[5], buf->data[6], buf->data[7]);
+
+       return buf;
+}
+
+static void release_buffer(struct vj_channel *chan, unsigned int descnum)
+{
+       if (descnum & VJ_HIGH_BIT) {
+               BUG_ON(test_bit(descnum & ~VJ_HIGH_BIT,
+                               default_chan->used_descs) == 0);
+               clear_bit(descnum & ~VJ_HIGH_BIT, default_chan->used_descs);
+       } else {
+               BUG_ON(test_bit(descnum, chan->used_descs) == 0);
+               clear_bit(descnum, chan->used_descs);
+       }
+}
+
+/* Free all descriptors for the current channel between where we last
+ * freed to and where the consumer has not yet consumed. chan->c.head
+ * is not cleared because it may not have been consumed, therefore
+ * chan->p.old_head is not cleared.  If chan->p.old_head ==
+ * chan->c.head then nothing more has been consumed since we last
+ * freed the descriptors. 
+ *
+ * Because we're using local and global channels we need to select the
+ * bitmap according to the channel.  Local channels may be pointing to
+ * local or global buffers, so we need to select the bitmap according
+ * to the buffer type */
+
+/* Free descriptors consumer has consumed since last free */
+static void free_descs_for_channel(struct vj_channel *chan)
+{
+       struct vj_channel_ring *ring = chan->ring;
+       int desc_num;
+
+       while (ring->p.old_head != ring->c.head) {
+               printk("ring->p.old_head %i, ring->c.head %i\n", ring->p.old_head, ring->c.head);
+               desc_num = ring->q[ring->p.old_head];
+
+               printk("desc_num %i\n", desc_num);
+
+               /* FIXME: Security concerns: make sure this descriptor
+                * really used by this vjchannel.  Userspace could
+                * have changed it. */
+               release_buffer(chan, desc_num);
+               ring->p.old_head = (ring->p.old_head + 1) % VJ_NET_CHANNEL_ENTRIES;
+               printk("ring->p.old_head %i, ring->c.head %i\n\n", ring->p.old_head, ring->c.head);
+       }
+}
+
+/* return -1 if no descriptor found and none can be freed */
+static int get_free_descriptor(struct vj_channel *chan)
+{
+       int free_desc, bitval;
+
+       BUG_ON(chan->num_local_buffers == 0);
+       do {
+               free_desc = find_first_zero_bit(chan->used_descs,
+                                               chan->num_local_buffers);
+               pr_debug("free_desc = %i\n", free_desc);
+               if (free_desc >= chan->num_local_buffers) {
+                       /* no descriptors, refresh bitmap and try again! */
+                       free_descs_for_channel(chan);
+                       free_desc = find_first_zero_bit(chan->used_descs,
+                                               chan->num_local_buffers);
+                       if (free_desc >= chan->num_local_buffers)
+                               /* still no descriptors */
+                               return -1;
+               }
+               bitval = test_and_set_bit(free_desc, chan->used_descs);
+               pr_debug("bitval = %i\n", bitval);
+       } while (bitval == 1);  //keep going until we get a FREE free bit!
+
+       /* We set high bit to indicate a global channel. */
+       if (chan == default_chan)
+               free_desc |= VJ_HIGH_BIT;
+       return free_desc;
+}
+
+/* This function puts a buffer into a local address space for a
+ * channel that is unable to use a kernel address space.  If address
+ * high bit is set then the buffer is in kernel space - get a free
+ * local buffer and copy it across.  Set local buf to used (done when
+ * finding free buffer), kernel buf to unused. */
+/* FIXME: Loop, do as many as possible at once. */
+int vj_need_local_buffer(struct vj_channel *chan)
+{
+       struct vj_channel_ring *ring = chan->ring;
+       u32 new_desc, k_desc;
+
+       k_desc = ring->q[ring->c.head];
+
+       if (ring->q[ring->c.head] & VJ_HIGH_BIT) {
+               struct vj_buffer *buf, *kbuf;
+
+               kbuf = get_buffer(k_desc, chan);
+               new_desc = get_free_descriptor(chan);
+               if (new_desc == -1)
+                       return -ENOBUFS;
+               buf = get_buffer(new_desc, chan);       
+               memcpy (buf, kbuf, sizeof(struct vj_buffer)
+                       + kbuf->data_len + kbuf->header_len);
+/* clear the old descriptor and set q to new one */
+               k_desc &= ~VJ_HIGH_BIT;
+               clear_bit(k_desc, default_chan->used_descs);    
+               ring->q[ring->c.head] = new_desc;
+       }
+       return 0;
+}
+EXPORT_SYMBOL(vj_need_local_buffer);
+
+struct vj_buffer *vj_get_buffer(int *desc_num)
+{
+       *desc_num = get_free_descriptor(default_chan);
+
+       if (*desc_num == -1) {
+               printk("no free bits!\n");
+               return NULL;  
+       }
+
+       return get_buffer(*desc_num, default_chan);
+}
+EXPORT_SYMBOL(vj_get_buffer);
+
+static void enqueue_buffer(struct vj_channel *chan, struct vj_buffer *buffer, int desc_num)
+{
+       u16 tail, nxt;
+       int i;
+
+       pr_debug("*** in enqueue buffer\n");
+       pr_debug("   desc_num = %i\n", desc_num);
+       pr_debug("   Buffer Data Length = %lu\n", buffer->data_len);
+       pr_debug("   Buffer Header Length = %lu\n", buffer->header_len);
+       pr_debug("   Buffer Data:\n");
+       for (i = 0; i < buffer->data_len; i++) {
+               pr_debug("%i ", buffer->data[i]);
+               if (i % 20 == 0)
+                       pr_debug("\n");
+       }
+       pr_debug("\n");
+
+       tail = chan->ring->p.tail;
+       nxt = (tail + 1) % VJ_NET_CHANNEL_ENTRIES;
+               
+       pr_debug("nxt = %i and chan->c.head = %i\n", nxt, chan->ring->c.head);
+       if (nxt != chan->ring->c.head) {
+               chan->ring->q[tail] = desc_num;
+
+               smp_wmb();
+               chan->ring->p.tail=nxt;
+               pr_debug("chan->p.wakecnt = %i and chan->c.wakecnt = %i\n", chan->ring->p.wakecnt, chan->ring->c.wakecnt);
+               free_descs_for_channel(chan);
+               if (chan->ring->p.wakecnt != chan->ring->c.wakecnt) {
+                       ++chan->ring->p.wakecnt;
+                       /* consume whatever is available */
+                       pr_debug("WAKE UP, CONSUMER!!!\n\n");
+                       wake_up(&chan->wq);
+               }
+       } else //if can't add it to chan, may as well allow it to be reused
+               release_buffer(chan, desc_num);
+}
+
+/* FIXME: If we're going to do wildcards here, we need to do ordering between different partial matches... */
+static struct vj_channel *find_channel(u32 saddr, u32 daddr, u16 proto, u16 sport, u16 dport, u32 ifindex)
+{
+       struct vj_channel *i;
+
+       pr_debug("args saddr %u, daddr %u, sport %u, dport %u, ifindex %u, proto %u\n", saddr, daddr, sport, dport, ifindex, proto);
+
+       list_for_each_entry(i, &channels, list) {
+               pr_debug("saddr %u, daddr %u, sport %u, dport %u, ifindex %u, proto %u\n", i->flowid.saddr, i->flowid.daddr, i->flowid.sport, i->flowid.dport, i->flowid.ifindex, i->flowid.proto);
+       
+               if ((!i->flowid.saddr || i->flowid.saddr == saddr) &&
+                   (!i->flowid.daddr || i->flowid.daddr == daddr) &&
+                   (!i->flowid.proto || i->flowid.proto == proto) &&
+                   (!i->flowid.sport || i->flowid.sport == sport) &&
+                   (!i->flowid.dport || i->flowid.dport == dport) &&
+                   (!i->flowid.ifindex || i->flowid.ifindex == ifindex)) {
+                       pr_debug("Found channel %p\n", i);
+                       return i;
+               }
+       }
+       pr_debug("using default channel %p\n", default_chan);
+       return default_chan;
+}
+
+void vj_netif_rx(struct vj_buffer *buffer, int desc_num, 
+                unsigned short proto)
+{
+       struct vj_channel *chan;
+       struct iphdr *ip;
+       int iphl, offset, real_data_len;
+       u16 *ports;
+       unsigned long flags;
+
+       offset = sizeof(struct iphdr) + sizeof(struct udphdr);
+       real_data_len = buffer->data_len - offset;
+
+
+       pr_debug("data_len = %lu, offset = %i, real data? = %i\n\n\n", buffer->data_len, offset, real_data_len);
+       /* this is always 18 when there's 18 or less characters in buffer->data */
+
+       pr_debug("rx) desc_num = %i\n\n", desc_num);
+
+       spin_lock_irqsave(&chan_lock, flags);
+       if (proto == __constant_htons(ETH_P_IP)) {
+
+               ip = (struct iphdr *)(buffer->data + buffer->header_len);
+               ports = (u16 *)(ip + 1);
+               iphl = ip->ihl * 4;
+               
+               if ((buffer->data_len < (iphl + 4)) || 
+                   (iphl != sizeof(struct iphdr))) {
+                       pr_debug("Bad data, default chan\n");
+                       pr_debug("buffer data_len = %li, header len = %li, ip->ihl = %i\n", buffer->data_len, buffer->header_len, ip->ihl);
+                       chan = default_chan;
+               } else {
+                       chan = find_channel(ip->saddr, ip->daddr, 
+                                           ip->protocol, ports[0], 
+                                           ports[1], buffer->ifindex);
+                       
+               }
+       } else
+               chan = default_chan;
+       enqueue_buffer(chan, buffer, desc_num);
+
+       spin_unlock_irqrestore(&chan_lock, flags);
+}
+EXPORT_SYMBOL(vj_netif_rx);
+
+/*
+ *     Determine the packet's protocol ID. The rule here is that we 
+ *     assume 802.3 if the type field is short enough to be a length.
+ *     This is normal practice and works for any 'now in use' protocol.
+ */
+ 
+unsigned short eth_vj_type_trans(struct vj_buffer *buffer)
+{
+       struct ethhdr *eth;
+       unsigned char *rawp;
+
+       eth = (struct ethhdr *)buffer->data;
+       buffer->header_len = ETH_HLEN;
+
+       BUG_ON(buffer->header_len > buffer->data_len);  
+
+       buffer->data_len -= buffer->header_len;
+       if (ntohs(eth->h_proto) >= 1536)
+               return eth->h_proto;
+               
+       rawp = buffer->data;
+       
+       /*
+        *      This is a magic hack to spot IPX packets. Older Novell breaks
+        *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
+        *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
+        *      won't work for fault tolerant netware but does for the rest.
+        */
+       if (*(unsigned short *)rawp == 0xFFFF)
+               return htons(ETH_P_802_3);
+               
+       /*
+        *      Real 802.2 LLC
+        */
+       return htons(ETH_P_802_2);
+}
+EXPORT_SYMBOL(eth_vj_type_trans);
+
+static void send_to_netif_rx(struct vj_buffer *buffer)
+{
+       struct sk_buff *skb;
+       struct net_device *dev;
+       int i;
+
+       dev = dev_get_by_index(buffer->ifindex);
+       if (!dev)
+               return;
+       skb = dev_alloc_skb(buffer->data_len + 2);
+       if (skb == NULL) {
+               dev_put(dev);
+               return;
+       }
+
+       skb_reserve(skb, 2);
+       skb->dev = dev;
+
+       skb_put(skb, buffer->data_len);
+       memcpy(skb->data, buffer->data, buffer->data_len);
+
+       pr_debug(" *** C buffer data_len = %lu and skb->len = %i\n", buffer->data_len, skb->len);
+       for (i = 0; i < 10; i++)
+               pr_debug("%i\n", skb->data[i]);
+
+       skb->protocol = eth_type_trans(skb, skb->dev);
+
+       netif_receive_skb(skb);
+}
+
+/* handles default_chan (buffers that nobody else wants) */
+static int default_thread(void *unused)
+{
+       int consumed = 0;
+       int woken = 0;
+       struct vj_buffer *buffer;
+       wait_queue_t wait;
+
+       /* When we get woken up, don't want to be removed from waitqueue! */
+//no more wait.task    struct task_struct * task is now void *private
+       wait.private = current;
+       wait.func = default_wake_function;
+       INIT_LIST_HEAD(&wait.task_list);
+
+       add_wait_queue(&default_chan->wq, &wait);
+       set_current_state(TASK_UNINTERRUPTIBLE);
+       while (!kthread_should_stop()) {
+               /* FIXME: if we do this before prepare_to_wait, avoids wmb */
+               default_chan->ring->c.wakecnt++;
+               smp_wmb();
+
+               while (!is_empty(default_chan->ring)) {
+                       smp_read_barrier_depends();
+                       buffer = get_buffer(default_chan->ring->q[default_chan->ring->c.head], default_chan);
+                       pr_debug("calling send_to_netif_rx\n");
+                       send_to_netif_rx(buffer);
+                       smp_rmb();
+                       default_chan->ring->c.head = (default_chan->ring->c.head+1)%VJ_NET_CHANNEL_ENTRIES;
+                       consumed++;
+               }
+
+               schedule();
+               woken++;
+               set_current_state(TASK_INTERRUPTIBLE);
+       }
+       remove_wait_queue(&default_chan->wq, &wait);
+
+       __set_current_state(TASK_RUNNING);
+
+       pr_debug("consumer finished! consumed %i and woke %i\n", consumed, woken);
+       return 0;
+}
+
+/* return the next buffer, but do not move on */
+struct vj_buffer *vj_peek_next_buffer(struct vj_channel *chan)
+{
+       struct vj_channel_ring *ring = chan->ring;
+
+       if (is_empty(ring))
+               return NULL;
+       return get_buffer(ring->q[ring->c.head], chan);
+}
+EXPORT_SYMBOL(vj_peek_next_buffer);
+
+/* move on to next buffer */
+void vj_done_with_buffer(struct vj_channel *chan)
+{
+       struct vj_channel_ring *ring = chan->ring;
+
+       ring->c.head = (ring->c.head+1)%VJ_NET_CHANNEL_ENTRIES;
+
+       pr_debug("done_with_buffer\n\n");
+}
+EXPORT_SYMBOL(vj_done_with_buffer);
+
+struct vj_channel *vj_alloc_chan(int num_buffers)
+{
+       int i;
+       struct vj_channel *chan = kmalloc(sizeof(*chan), GFP_KERNEL);
+
+       if (!chan)
+               return NULL;
+
+       chan->ring = (void *)get_zeroed_page(GFP_KERNEL);
+       if (chan->ring == NULL)
+               goto free_chan;
+
+       init_waitqueue_head(&chan->wq);
+       chan->ring->p.tail = chan->ring->p.wakecnt = chan->ring->p.old_head = chan->ring->c.head = chan->ring->c.wakecnt = 0;
+
+       chan->num_local_buffers = num_buffers;
+       if (chan->num_local_buffers == 0)
+               return chan;
+
+       chan->used_descs = kzalloc(BITS_TO_LONGS(chan->num_local_buffers)
+                                  * sizeof(long), GFP_KERNEL);
+       if (chan->used_descs == NULL)
+               goto free_ring;
+       chan->descs = kmalloc(sizeof(*chan->descs)*num_buffers, GFP_KERNEL);
+       if (chan->descs == NULL)
+               goto free_used_descs;
+       for (i = 0; i < chan->num_local_buffers; i++) {
+               chan->descs[i].buffer_len = PAGE_SIZE;
+               chan->descs[i].address = get_zeroed_page(GFP_KERNEL);
+               if (chan->descs[i].address == 0)
+                       goto free_descs;
+       }
+
+       return chan;
+
+free_descs:
+       for (--i; i >= 0; i--)
+               free_page(chan->descs[i].address);
+       kfree(chan->descs);
+free_used_descs:
+       kfree(chan->used_descs);
+free_ring:
+       free_page((unsigned long)chan->ring);
+free_chan:
+       kfree(chan);
+       return NULL;
+}
+EXPORT_SYMBOL(vj_alloc_chan);
+
+void vj_register_chan(struct vj_channel *chan, const struct vj_flowid *flowid)
+{
+       pr_debug("%p %s: registering channel %p\n",
+              current, current->comm, chan);
+       chan->flowid = *flowid;
+       spin_lock_irq(&chan_lock);
+       list_add(&chan->list, &channels);
+       spin_unlock_irq(&chan_lock);
+}
+EXPORT_SYMBOL(vj_register_chan);
+
+void vj_unregister_chan(struct vj_channel *chan)
+{
+       pr_debug("%p %s: unregistering channel %p\n",
+              current, current->comm, chan);
+       spin_lock_irq(&chan_lock);
+       list_del(&chan->list);
+       spin_unlock_irq(&chan_lock);
+}
+EXPORT_SYMBOL(vj_unregister_chan);
+
+void vj_free_chan(struct vj_channel *chan)
+{
+       pr_debug("%p %s: freeing channel %p\n",
+              current, current->comm, chan);
+       /* FIXME: Mark any buffer still in channel as free! */
+       kfree(chan);
+}
+EXPORT_SYMBOL(vj_free_chan);
+
+
+
+/* not using at the mo - working on rx, not tx */
+int vj_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+       struct vj_buffer *buffer;
+       /* first element in dev priv data must be addr of net_channel */
+//     struct net_channel *chan = *(struct net_channel **) netdev_priv(dev) + 1;
+       int desc_num;
+
+       buffer = vj_get_buffer(&desc_num);
+       buffer->data_len = skb->len;
+       memcpy(buffer->data, skb->data, buffer->data_len);
+//     enqueue_buffer(chan, buffer, desc_num);
+
+       kfree(skb);
+       return 0;
+}
+EXPORT_SYMBOL(vj_xmit);
+
+static int __init init(void)
+{
+       default_chan = vj_alloc_chan(NUM_GLOBAL_DESCRIPTORS);
+       if (!default_chan)
+               return -ENOMEM;
+
+       kthread_run(default_thread, NULL, "kvj_net");
+       return 0;
+}
+
+module_init(init);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("VJ Channel Networking Module.");
+MODULE_AUTHOR("Kelly Daly <kelly@au1.ibm.com>");
