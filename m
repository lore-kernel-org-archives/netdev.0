From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: iproute2 not compiling anymore
Date: Fri, 24 Oct 2003 12:34:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024.123401.08140647.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0310050940160.27815-100000@logos.cnet>
	<20031005130044.GA8861@pcw.home.local>
	<20031005071152.49c35297.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031005071152.49c35297.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031005071152.49c35297.davem@redhat.com> (at Sun, 5 Oct 2003 07:11:52 -0700), "David S. Miller" <davem@redhat.com> says:

> On Sun, 5 Oct 2003 15:00:44 +0200
> Willy TARREAU <willy@w.ods.org> wrote:
> 
> > /usr/src/linux/include/linux/in.h:147: field `gsr_group' has incomplete type
> 
> I'll happily fix this, thanks for reporting this.
> 
> Can you please in the future report such things on the networking
> development list netdev@oss.sgi.com?  Thanks.

I believe that 2.6 also needs this fix:

D: [NET]: Fix userland iproute2 build problems introduced by mcast changes.

===== include/linux/in.h 1.7 vs edited =====
--- 1.7/include/linux/in.h	Wed Apr 16 17:45:42 2003
+++ edited/include/linux/in.h	Fri Oct 24 11:39:37 2003
@@ -140,29 +140,29 @@
 
 struct group_req
 {
-	__u32			gr_interface;	/* interface index */
-	struct sockaddr_storage	gr_group;	/* group address */
+	__u32				 gr_interface;	/* interface index */
+	struct __kernel_sockaddr_storage gr_group;	/* group address */
 };
 
 struct group_source_req
 {
-	__u32			gsr_interface;	/* interface index */
-	struct sockaddr_storage	gsr_group;	/* group address */
-	struct sockaddr_storage	gsr_source;	/* source address */
+	__u32				 gsr_interface;	/* interface index */
+	struct __kernel_sockaddr_storage gsr_group;	/* group address */
+	struct __kernel_sockaddr_storage gsr_source;	/* source address */
 };
 
 struct group_filter
 {
-	__u32			gf_interface;	/* interface index */
-	struct sockaddr_storage	gf_group;	/* multicast address */
-	__u32			gf_fmode;	/* filter mode */
-	__u32			gf_numsrc;	/* number of sources */
-	struct sockaddr_storage	gf_slist[1];	/* interface index */
+	__u32				 gf_interface;	/* interface index */
+	struct __kernel_sockaddr_storage gf_group;	/* multicast address */
+	__u32				 gf_fmode;	/* filter mode */
+	__u32				 gf_numsrc;	/* number of sources */
+	struct __kernel_sockaddr_storage gf_slist[1];	/* interface index */
 };
 
 #define GROUP_FILTER_SIZE(numsrc) \
-	(sizeof(struct group_filter) - sizeof(struct sockaddr_storage) \
-	+ (numsrc) * sizeof(struct sockaddr_storage))
+	(sizeof(struct group_filter) - sizeof(struct __kernel_sockaddr_storage) \
+	+ (numsrc) * sizeof(struct __kernel_sockaddr_storage))
 
 struct in_pktinfo
 {
===== include/linux/socket.h 1.9 vs edited =====
--- 1.9/include/linux/socket.h	Tue May 13 06:35:19 2003
+++ edited/include/linux/socket.h	Fri Oct 24 11:42:52 2003
@@ -1,6 +1,21 @@
 #ifndef _LINUX_SOCKET_H
 #define _LINUX_SOCKET_H
 
+/*
+ * Desired design of maximum size and alignment (see RFC2553)
+ */
+#define _K_SS_MAXSIZE	128	/* Implementation specific max size */
+#define _K_SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
+				/* Implementation specific desired alignment */
+
+struct __kernel_sockaddr_storage {
+	unsigned short	ss_family;		/* address family */
+	/* Following field(s) are implementation specific */
+	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
+				/* space to achieve desired size, */
+				/* _SS_MAXSIZE value minus size of ss_family */
+} __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
+
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
 #include <linux/config.h>		/* for CONFIG_COMPAT */
@@ -27,20 +42,7 @@
 	int		l_linger;	/* How long to linger for	*/
 };
 
-/*
- * Desired design of maximum size and alignment (see RFC2553)
- */
-#define _SS_MAXSIZE	128	/* Implementation specific max size */
-#define _SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
-				/* Implementation specific desired alignment */
-
-struct sockaddr_storage {
-	sa_family_t	ss_family;		/* address family */
-	/* Following field(s) are implementation specific */
-	char		__data[_SS_MAXSIZE - sizeof(sa_family_t)];
-				/* space to achieve desired size, */
-				/* _SS_MAXSIZE value minus size of ss_family */
-} __attribute__ ((aligned(_SS_ALIGNSIZE)));	/* force desired alignment */
+#define sockaddr_storage __kernel_sockaddr_storage
 
 /*
  *	As we do 4.4BSD message passing we use a 4.4BSD message passing

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
