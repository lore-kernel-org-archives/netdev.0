From: Alex Lochmann <alexander.lochmann@uni-dortmund.de>
Subject: Extending struct sk_buff
Date: Thu, 24 Jan 2013 12:13:10 +0100
Message-ID: <51011746.8040100@uni-dortmund.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090605060202070904090101"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.HRZ.Uni-Dortmund.DE ([129.217.128.51]:64466 "EHLO
	unimail.uni-dortmund.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab3AXLdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 06:33:37 -0500
Received: from [129.217.43.101] (kos.cs.uni-dortmund.de [129.217.43.101])
	(authenticated bits=0)
	by unimail.uni-dortmund.de (8.14.6/8.14.5) with ESMTP id r0OBDAHs012568
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 12:13:10 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090605060202070904090101
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

i'm currently writing a patch to annotate a single sendmsg-call with 
meta information - like a maximum amount of time this data could be delayed.
Thus i extended the sendmsg systemcall to handle a recently added 
MSG_MSGMETA flag, which tells the kernel to copy the struct msgmeta as 
well as the struct msghdr from userspace.
This information needs be propagated  to the qdisc, so it can delay a 
single sk_buff until the maximum delay is reached. Therefore i modified 
the tcp subsystem (tcp_sendmsg) to assign the pointer to a kmalloced 
kernelspace to a member of struct sk_buff.
Each time i assign this pointer i increment a referencecounter located 
in the struct msgmeta. After doing so i'm able to decrement it on each 
call to __kfree_skbuff. If the counter reaches zero, i free the 
allocated kernelspace.
Sometimes a skbuff gets freeed during the context of a syscall, 
everything goes fine.

If the kernel tries to access the allocated kernelspace, after returning 
to userspace, the memory area gets corrupted.....
The kernellog says the following:
[  189.445630] [msgmeta] Assign msgmeta(0xf5d516d0) to skb(0xf3c4a480)
[  189.445636] [msgmeta] Assigned msgmeta(0xf5d516d0) to skb(0xf3c4a480) 
- delay is: 0x133700, refcnt is: 0x1
[  189.445646] [msgmeta] Assign msgmeta(0xf5d516d0) to skb(0xf3c4a530)
[  189.445651] [msgmeta] Assigned msgmeta(0xf5d516d0) to skb(0xf3c4a530) 
- delay is: 0x133700, refcnt is: 0x2
[  189.445666] [msgmeta] Assign msgmeta(0xf5d516d0) to skb(0xf4ac4540)
[  189.445671] [msgmeta] Assigned msgmeta(0xf5d516d0) to skb(0xf4ac4540) 
- delay is: 0x133700, refcnt is: 0x3
[  189.445680] [msgmeta] Not freeing msgmeta(0xf5d516d0), there are 
still references to it (0x2). Cloned? 0
[  189.445719] [msgmeta] return to userspace
[  189.445974] [msgmeta] Magic value corrupted! skb = 0xf3c4a480, meta = 
0xf5d516d0, magicA = 0xf5d51e00, delay = 0x133700, magicB = 0xff350011, 
counter = 0x2, phys = 0x35d516d0, function: (null)
[  189.445983] [msgmeta] Not freeing msgmeta(0xf5d516d0), there are 
still references to it (0x1). Cloned? 0

I don't know what's goging wrong. :-(
Can you please help me?

Thanks in advance!

Greetings
Alex

--------------090605060202070904090101
Content-Type: text/x-patch;
 name="msgmeta.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="msgmeta.patch"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f13b52b..c8b8c29 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -332,6 +332,7 @@ struct sk_buff {
 	struct sock		*sk;
 	struct net_device	*dev;
 
+	struct msgmeta *meta_info;
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
@@ -1404,6 +1405,56 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 {
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
 }
+#if MSGMETADEBUG_LVL > 1
+static inline void skb_assert_meta(struct sk_buff *skb,const char *func)
+{
+	if (skb->meta_info) {
+		if (skb->meta_info->magicA != 0xcaffee || skb->meta_info->magicB != ~0xcaffee) {
+			MSGMETADEBUG(1,"Magic value corrupted! skb = 0x%p, meta = 0x%p, magicA = 0x%x, delay = 0x%x, magicB = 0x%x, counter = 0x%d, phys = 0x%x, function: %s\n", skb, skb->meta_info, skb->meta_info->magicA,skb->meta_info->delay_us,skb->meta_info->magicB,skb->meta_info->refcnt.counter,virt_to_phys(skb->meta_info),func);
+		}
+	}
+}
+#else
+#define skb_assert_meta(x,y)
+#endif
+static inline void skb_set_meta_info(struct sk_buff *skb, struct msgmeta *meta)
+{
+	skb_assert_meta(skb,__func__);
+	if (meta) {
+		if (skb->meta_info) {
+			if (skb->meta_info != meta) {
+				MSGMETADEBUG(1,"msgmeta already set, but it is not the same as the supplied one. (set: 0x%p, desired: 0x%p) Resetting it to NULL\n",skb->meta_info,meta);
+				skb->meta_info = NULL;
+				return;
+			} else {
+				MSGMETADEBUG(1,"msgmeta(0x%p) already set on skb(0x%p)\n",skb->meta_info,skb);
+				return;
+			}
+		}
+		MSGMETADEBUG(1,"Assign msgmeta(0x%p) to skb(0x%p)\n",meta,skb);
+		atomic_inc(&meta->refcnt);
+		skb->meta_info = meta;
+		MSGMETADEBUG(1,"Assigned msgmeta(0x%p) to skb(0x%p) - delay is: 0x%x, refcnt is: 0x%x\n",skb->meta_info,skb,skb->meta_info->delay_us,atomic_read(&skb->meta_info->refcnt));
+	}
+}
+
+static inline void skb_free_meta_info(struct sk_buff *skb)
+{
+	skb_assert_meta(skb,__func__);
+	if (skb->meta_info) {
+		if (atomic_read(&skb->meta_info->refcnt) == 0) {
+			MSGMETADEBUG(1,"msgmeta(0x%p) in skb(0x%p) refcnt is already 0\n",skb->meta_info,skb);
+		} else {
+			if (atomic_sub_return(1,&skb->meta_info->refcnt) == 0) {
+				//kfree(skb->meta_info);
+				MSGMETADEBUG(1,"Freed msgmeta(0x%p)\n",skb->meta_info);
+				skb->meta_info = NULL;
+			} else {
+				MSGMETADEBUG(1,"Not freeing msgmeta(0x%p), there are still references to it (0x%x). Cloned? %d\n",skb->meta_info,atomic_read(&skb->meta_info->refcnt),skb->fclone == SKB_FCLONE_CLONE);
+			}
+		}
+	}
+}
 
 /*
  * CPUs often take a performance hit when accessing unaligned memory
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 635c213..195f99a 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -67,6 +67,7 @@ struct msghdr {
 	void 	*	msg_control;	/* Per protocol magic (eg BSD file descriptor passing) */
 	__kernel_size_t	msg_controllen;	/* Length of cmsg list */
 	unsigned	msg_flags;
+	struct msgmeta *msg_meta; /* Has to be at the end of this struct */
 };
 
 /* For recvmmsg/sendmmsg */
@@ -75,6 +76,32 @@ struct mmsghdr {
 	unsigned        msg_len;
 };
 
+#define MSGMETADEBUG_LVL 5
+#ifdef MSGMETADEBUG_LVL
+#if MSGMETADEBUG_LVL > 0
+#define MSGMETADEBUG_TAG "[msgmeta] "
+#define MSGMETADEBUG(prio,args...) do {                    \
+        if ((prio) <= MSGMETADEBUG_LVL) {                          \
+                printk(KERN_INFO MSGMETADEBUG_TAG args );    \
+        }                                               \
+} while(0);
+#else
+#define MSGMETADEBUG(prio,...) do {} while(0);
+#endif
+#else
+#define MSGMETADEBUG(prio,...) do {} while(0);
+#endif
+struct msgmeta {
+#if MSGMETADEBUG_LVL > 1
+	__u32 magicA;
+#endif
+	__u32 delay_us;
+#if MSGMETADEBUG_LVL > 1
+	__u32 magicB;
+#endif
+	atomic_t refcnt;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
@@ -263,6 +290,7 @@ struct ucred {
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_EOF         MSG_FIN
+#define MSG_METAINFO	0x40000
 
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
 					   descriptor received through
@@ -273,7 +301,6 @@ struct ucred {
 #define MSG_CMSG_COMPAT	0		/* We never have 32 bit fixups */
 #endif
 
-
 /* Setsockoptions(2) level. Thanks to BSD these must match IPPROTO_xxx */
 #define SOL_IP		0
 /* #define SOL_ICMP	1	No-no-no! Due to Linux :-) we cannot use SOL_ICMP=1 */
diff --git a/net/compat.c b/net/compat.c
index c578d93..35db4bd 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -73,6 +73,7 @@ int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
 	kmsg->msg_name = compat_ptr(tmp1);
 	kmsg->msg_iov = compat_ptr(tmp2);
 	kmsg->msg_control = compat_ptr(tmp3);
+	kmsg->msg_meta = NULL;
 	return 0;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4821df8..f58718f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -203,6 +203,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
+	skb->meta_info = NULL;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
 #endif
@@ -396,6 +397,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 	skb->tc_verd = 0;
 #endif
 #endif
+	skb_free_meta_info(skb);
 }
 
 /* Free everything but the sk_buff shell. */
@@ -500,6 +502,7 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
 	skb_reset_tail_pointer(skb);
+	skb->meta_info = NULL;
 
 	return true;
 }
@@ -542,6 +545,12 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #endif
 	new->vlan_tci		= old->vlan_tci;
+	
+	if (old->meta_info) {
+		skb_set_meta_info(new,old->meta_info);
+	} else {
+		new->meta_info = NULL;
+	}
 
 	skb_copy_secmark(new, old);
 }
@@ -556,6 +565,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 
 	n->next = n->prev = NULL;
 	n->sk = NULL;
+	n->meta_info = NULL;
 	__copy_skb_header(n, skb);
 
 	C(len);
@@ -614,6 +624,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	struct sk_buff *n;
 
+	skb_assert_meta(skb,__func__);
 	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
@@ -850,6 +861,7 @@ adjust_others:
 	skb->cloned   = 0;
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
+	skb->meta_info = NULL;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b0e5330..d579175 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1004,8 +1004,10 @@ new_segment:
 				if (copy > skb_tailroom(skb))
 					copy = skb_tailroom(skb);
 				err = skb_add_data_nocache(sk, skb, from, copy);
-				if (err)
+				if (err) {
 					goto do_fault;
+				}
+				skb_set_meta_info(skb,msg->msg_meta);
 			} else {
 				int merge = 0;
 				int i = skb_shinfo(skb)->nr_frags;
@@ -1059,6 +1061,7 @@ new_segment:
 					}
 					goto do_error;
 				}
+				skb_set_meta_info(skb,msg->msg_meta);
 
 				/* Update the skb. */
 				if (merge) {
diff --git a/net/socket.c b/net/socket.c
index cf41afc..a0dd6ac 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -844,6 +844,7 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_controllen = 0;
 	msg->msg_iov = (struct iovec *)iov;
 	msg->msg_iovlen = nr_segs;
+	msg->msg_meta = NULL;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
 	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
@@ -884,6 +885,7 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_controllen = 0;
 	msg->msg_iov = (struct iovec *)iov;
 	msg->msg_iovlen = nr_segs;
+	msg->msg_meta = NULL;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 	if (sock->type == SOCK_SEQPACKET)
 		msg->msg_flags |= MSG_EOR;
@@ -1695,6 +1697,8 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_namelen = 0;
+	msg.msg_meta = NULL;
+
 	if (addr) {
 		err = move_addr_to_kernel(addr, addr_len, (struct sockaddr *)&address);
 		if (err < 0)
@@ -1713,6 +1717,7 @@ out:
 	return err;
 }
 
+
 /*
  *	Send a datagram down a socket.
  */
@@ -1723,6 +1728,7 @@ SYSCALL_DEFINE4(send, int, fd, void __user *, buff, size_t, len,
 	return sys_sendto(fd, buff, len, flags, NULL, 0);
 }
 
+
 /*
  *	Receive a frame from the socket and optionally record the address of the
  *	sender. We verify the buffers are writable and if needed move the
@@ -1754,6 +1760,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	iov.iov_base = ubuf;
 	msg.msg_name = (struct sockaddr *)&address;
 	msg.msg_namelen = sizeof(address);
+	msg.msg_meta = NULL;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg, size, flags);
@@ -1888,14 +1895,55 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
+#if MSGMETADEBUG_LVL < 2
+	struct msgmeta __user *u_msgmeta = NULL;
+#endif
 	int err, ctl_len, iov_size, total_len;
 
 	err = -EFAULT;
+	msg_sys->msg_meta = NULL;
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
-	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
-		return -EFAULT;
+	} else if (MSG_METAINFO & flags) {
+		/* the user supplied meta information for this message -- copy the pointer to the struct aswell */
+		if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
+			goto out;
+#if MSGMETADEBUG_LVL < 2
+		u_msgmeta = msg_sys->msg_meta;
+		/* First verify the memory area pointed to by u_msgmeta is readable */
+		if (unlikely(!access_ok(VERIFY_READ, u_msgmeta, sizeof(struct msgmeta) - sizeof(atomic_t)))) {
+            goto out;
+		}
+#endif
+		/* Allocate the kernel space for the struct msgmeta */
+		msg_sys->msg_meta = kmalloc(sizeof(struct msgmeta),GFP_KERNEL|GFP_ATOMIC);
+		if (!msg_sys->msg_meta) {
+			err = -ENOMEM;
+			goto out;
+		}
+#if MSGMETADEBUG_LVL > 1
+		msg_sys->msg_meta->magicA = 0xcaffee;
+		msg_sys->msg_meta->magicB = ~0xcaffee;
+		msg_sys->msg_meta->delay_us = 0x133700;
+#else
+		/* Now copy the struct msgmeta. omit sizeof(atomic_t) bytes. The user does *not*  supply it.*/
+		if (copy_from_user(msg_sys->msg_meta,u_msgmeta,sizeof(struct msgmeta) - sizeof(atomic_t))) {
+			goto out_freemeta;
+		}
+#endif	
+		/* No references to it by any instance of sk_buff */
+		atomic_set(&msg_sys->msg_meta->refcnt,0);
+		MSGMETADEBUG(1,"Copied msgmeta(0x%p) from user - delay is: 0x%x\n",msg_sys->msg_meta,msg_sys->msg_meta->delay_us);
+		
+		//kfree(msg_sys->msg_meta);
+		//msg_sys->msg_meta = NULL;
+	} else {
+		/* Normally the user uses the old struct msghdr which does not contain a pointer to a struct msgmeta */
+		if (copy_from_user(msg_sys, msg, sizeof(struct msghdr) - sizeof(struct msgmeta*)))
+			return -EFAULT;
+		msg_sys->msg_meta = NULL;
+	}
 
 	/* do not move before msg_sys is valid */
 	err = -EMSGSIZE;
@@ -1983,7 +2031,12 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 			memcpy(&used_address->name, msg_sys->msg_name,
 			       used_address->name_len);
 	}
-
+#if MSGMETADEBUG_LVL > 1
+	if (msg_sys->msg_meta) {
+		/* Just for debug purpose print a message right before returning to userspace */
+		MSGMETADEBUG(1,"return to userspace\n");
+	}
+#endif
 out_freectl:
 	if (ctl_buf != ctl)
 		sock_kfree_s(sock->sk, ctl_buf, ctl_len);
@@ -1991,6 +2044,10 @@ out_freeiov:
 	if (iov != iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
 out:
+	if (err != 0 && msg_sys->msg_meta != NULL) {
+		kfree(msg_sys->msg_meta);
+		msg_sys->msg_meta = NULL;
+	}
 	return err;
 }
 
@@ -2065,7 +2122,6 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	}
 
 	fput_light(sock->file, fput_needed);
-
 	/* We only return an error if no datagrams were able to be sent */
 	if (datagrams != 0)
 		return datagrams;

--------------090605060202070904090101--
