From: Carlos O'Donell <carlos@systemhalted.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Wed, 16 Jan 2013 21:15:03 -0500
Message-ID: <50F75EA7.4060309@systemhalted.org>
References: <50F6B761.8070106@linux-ipv6.org> <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com> <201301161205.04502.vapier@gentoo.org> <20130116.135744.697469565804508454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, yoshfuji@linux-ipv6.org,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116.135744.697469565804508454.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2013 01:57 PM, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> Date: Wed, 16 Jan 2013 12:04:56 -0500
> 
>> certainly true, but the current expectation is that you don't mix your ABIs.  
>> if you're programming with the C library API, then use the C library headers.  
>> if you're banging directly on the kernel, then use the kernel headers.  not 
>> saying it's a perfect solution, but it works for the vast majority of use 
>> cases.
> 
> This isn't how real life works.
> 
> GLIBC itself brings in some of the kernel headers, as do various library
> headers for libraries other than glibc.
> 
> So you can get these conflicting headers included indirectly, and it is
> of no fault of any of the various parties involved.
> 
> We have to make them work when included at the same time somehow, and
> this is totally unavoidable.
> 

Just to put some code behind the comments I made earlier.

Solution:
=========

- Synchronize linux's `include/uapi/linux/in6.h' 
  with glibc's `inet/netinet/in.h'.
- Synchronize glibc's `inet/netinet/in.h with linux's
  `include/uapi/linux/in6.h'.
- Allow including the headers in either other.
- First header included defines the structures and macros.

Details:
========

The kernel promises not to break the UAPI ABI so I don't 
see why we can't just have the two userspace headers
coordinate?

If you include the kernel headers first you get those,
and if you include the glibc headers first you get those,
and the following patch arranges a coordination and
synchronization between the two.

Let's handle `include/uapi/linux/in6.h' from linux, 
and `inet/netinet/in.h' from glibc and ensure they compile
in any order and preserve the required ABI.

These two patches pass the following compile tests:

cat >> test1.c <<EOF
#include <netinet/in.h>
#include <linux/in6.h>
int main (void) {
  return 0;
}
EOF
gcc -c test1.c

cat >> test2.c <<EOF
#include <linux/in6.h>
#include <netinet/in.h>
int main (void) {
  return 0;
}
EOF
gcc -c test2.c

One wrinkle is that the kernel has a different name for one of
the members in ipv6_mreq. In the kernel patch we create a macro
to cover the uses of the old name, and while that's not entirely
clean it's one of the best solutions (aside from an anonymous
union which has other issues).

I've reviewed the code and it looks to me like the ABI is
assured and everything matches on both sides.

Comments?

Notes:
- You want netinet/in.h to include bits/in.h as early as possible,
  but it needs in_addr so define in_addr early.
- You want bits/in.h included as early as possible so you can use
  the linux specific code to define __USE_KERNEL_DEFS based on 
  the _UAPI_* macro definition and use those to cull in.h.
- glibc was missing IPPROTO_MH, added here.

glibc/

2012-01-16  Carlos O'Donell  <carlos@redhat.com>

	* sysdeps/unix/sysv/linux/bits/in.h
	[_UAPI_LINUX_IN6_H]: Define __USE_KERNEL_IPV6_DEFS.
	* inet/netinet/in.h: Move in_addr definition and bits/in.h inclusion
	before __USE_KERNEL_IPV6_DEFS uses.
	* inet/netinet/in.h [!__USE_KERNEL_IPV6_DEFS]: Define IPPROTO_MH, and
	IPPROTO_BEETPH.
	[__USE_KERNEL_IPV6_DEFS]: Don't define any of IPPROTO_*, in6_addr,
	sockaddr_in6, or ipv6_mreq.

diff --git a/inet/netinet/in.h b/inet/netinet/in.h
index 89e3813..882739d 100644
--- a/inet/netinet/in.h
+++ b/inet/netinet/in.h
@@ -26,6 +26,20 @@
 
 __BEGIN_DECLS
 
+/* Internet address.  */
+typedef uint32_t in_addr_t;
+struct in_addr
+  {
+    in_addr_t s_addr;
+  };
+
+/* Get system-specific definitions.  */
+#include <bits/in.h>
+
+/* If __USER_KERNEL_IPV6_DEFS is defined then the user has included the kernel
+   network headers first and we should use those ABI-identical definitions
+   instead of our own.  */
+#ifndef __USE_KERNEL_IPV6_DEFS
 /* Standard well-defined IP protocols.  */
 enum
   {
@@ -75,6 +89,8 @@ enum
 #define IPPROTO_DSTOPTS		IPPROTO_DSTOPTS
     IPPROTO_MTP = 92,	   /* Multicast Transport Protocol.  */
 #define IPPROTO_MTP		IPPROTO_MTP
+    IPPROTO_BEETPH = 94,   /* IP option pseudo header for BEET.  */
+#define IPPROTO_BEETPH		IPPROTO_BEETPH
     IPPROTO_ENCAP = 98,	   /* Encapsulation Header.  */
 #define IPPROTO_ENCAP		IPPROTO_ENCAP
     IPPROTO_PIM = 103,	   /* Protocol Independent Multicast.  */
@@ -83,13 +99,15 @@ enum
 #define IPPROTO_COMP		IPPROTO_COMP
     IPPROTO_SCTP = 132,	   /* Stream Control Transmission Protocol.  */
 #define IPPROTO_SCTP		IPPROTO_SCTP
+    IPPROTO_MH = 135,      /* IPv6 mobility header.  */
+#define IPPROTO_MH		IPPROTO_MH
     IPPROTO_UDPLITE = 136, /* UDP-Lite protocol.  */
 #define IPPROTO_UDPLITE		IPPROTO_UDPLITE
     IPPROTO_RAW = 255,	   /* Raw IP packets.  */
 #define IPPROTO_RAW		IPPROTO_RAW
     IPPROTO_MAX
   };
-
+#endif /* !__USE_KERNEL_IPV6_DEFS */
 
 /* Type to represent a port.  */
 typedef uint16_t in_port_t;
@@ -134,15 +152,6 @@ enum
     IPPORT_USERRESERVED = 5000
   };
 
-
-/* Internet address.  */
-typedef uint32_t in_addr_t;
-struct in_addr
-  {
-    in_addr_t s_addr;
-  };
-
-
 /* Definitions of the bits in an Internet address integer.
 
    On subnets, host and network parts are found according to
@@ -191,7 +200,7 @@ struct in_addr
 #define INADDR_ALLRTRS_GROUP    ((in_addr_t) 0xe0000002) /* 224.0.0.2 */
 #define INADDR_MAX_LOCAL_GROUP  ((in_addr_t) 0xe00000ff) /* 224.0.0.255 */
 
-
+#ifndef __USE_KERNEL_IPV6_DEFS
 /* IPv6 address */
 struct in6_addr
   {
@@ -209,6 +218,7 @@ struct in6_addr
 # define s6_addr32		__in6_u.__u6_addr32
 #endif
   };
+#endif /* !__USE_KERNEL_IPV6_DEFS */
 
 extern const struct in6_addr in6addr_any;        /* :: */
 extern const struct in6_addr in6addr_loopback;   /* ::1 */
@@ -218,7 +228,6 @@ extern const struct in6_addr in6addr_loopback;   /* ::1 */
 #define INET_ADDRSTRLEN 16
 #define INET6_ADDRSTRLEN 46
 
-
 /* Structure describing an Internet socket address.  */
 struct sockaddr_in
   {
@@ -233,6 +242,7 @@ struct sockaddr_in
 			   sizeof (struct in_addr)];
   };
 
+#ifndef __USE_KERNEL_IPV6_DEFS
 /* Ditto, for IPv6.  */
 struct sockaddr_in6
   {
@@ -242,7 +252,7 @@ struct sockaddr_in6
     struct in6_addr sin6_addr;	/* IPv6 address */
     uint32_t sin6_scope_id;	/* IPv6 scope-id */
   };
-
+#endif /* !__USE_KERNEL_IPV6_DEFS */
 
 #if defined __USE_MISC || defined __USE_GNU
 /* IPv4 multicast request.  */
@@ -268,7 +278,7 @@ struct ip_mreq_source
   };
 #endif
 
-
+#ifndef __USE_KERNEL_IPV6_DEFS
 /* Likewise, for IPv6.  */
 struct ipv6_mreq
   {
@@ -278,7 +288,7 @@ struct ipv6_mreq
     /* local interface */
     unsigned int ipv6mr_interface;
   };
-
+#endif /* !__USE_KERNEL_IPV6_DEFS */
 
 #if defined __USE_MISC || defined __USE_GNU
 /* Multicast group request.  */
@@ -349,10 +359,6 @@ struct group_filter
 				      * sizeof (struct sockaddr_storage)))
 #endif
 
-
-/* Get system-specific definitions.  */
-#include <bits/in.h>
-
 /* Functions to convert between host and network byte order.
 
    Please note that these functions normally take `unsigned long int' or
diff --git a/sysdeps/unix/sysv/linux/bits/in.h b/sysdeps/unix/sysv/linux/bits/in.h
index e959b33..36bb72b 100644
--- a/sysdeps/unix/sysv/linux/bits/in.h
+++ b/sysdeps/unix/sysv/linux/bits/in.h
@@ -21,6 +21,15 @@
 # error "Never use <bits/in.h> directly; include <netinet/in.h> instead."
 #endif
 
+/* If the application has already included linux/in6.h from a linux-based
+   kernel then we will not define IPPROTO_* defines, in6_addr (nor the 
+   defines), sockaddr_in6, or ip_mreq.  The ABI used by the linux-kernel
+   and glibc match exactly.  Neither the linux kernel nor glibc should 
+   break this ABI without coordination.  */
+#ifdef _UAPI_LINUX_IN6_H
+# define __USE_KERNEL_IPV6_DEFS 
+#endif
+
 /* Options for use with `getsockopt' and `setsockopt' at the IP level.
    The first word in the comment at the right is the data type used;
    "bool" means a boolean value stored in an `int'.  */
---

linux/

Compile tested and inspected.

Signed-off-by: Carlos O'Donell <carlos@redhat.com>

 include/uapi/linux/in.h      |   32 +-----------------------
 include/uapi/linux/in6.h     |   50 +++++++++++++++++++++++++++++++------
 include/uapi/linux/ipproto.h |    0 
 include/uapi/linux/ipproto.h |   57 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 38 deletions(-)

diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 9edb441..998ecb2 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -21,36 +21,8 @@
 #include <linux/types.h>
 #include <linux/socket.h>
 
-/* Standard well-defined IP protocols.  */
-enum {
-  IPPROTO_IP = 0,		/* Dummy protocol for TCP		*/
-  IPPROTO_ICMP = 1,		/* Internet Control Message Protocol	*/
-  IPPROTO_IGMP = 2,		/* Internet Group Management Protocol	*/
-  IPPROTO_IPIP = 4,		/* IPIP tunnels (older KA9Q tunnels use 94) */
-  IPPROTO_TCP = 6,		/* Transmission Control Protocol	*/
-  IPPROTO_EGP = 8,		/* Exterior Gateway Protocol		*/
-  IPPROTO_PUP = 12,		/* PUP protocol				*/
-  IPPROTO_UDP = 17,		/* User Datagram Protocol		*/
-  IPPROTO_IDP = 22,		/* XNS IDP protocol			*/
-  IPPROTO_DCCP = 33,		/* Datagram Congestion Control Protocol */
-  IPPROTO_RSVP = 46,		/* RSVP protocol			*/
-  IPPROTO_GRE = 47,		/* Cisco GRE tunnels (rfc 1701,1702)	*/
-
-  IPPROTO_IPV6	 = 41,		/* IPv6-in-IPv4 tunnelling		*/
-
-  IPPROTO_ESP = 50,            /* Encapsulation Security Payload protocol */
-  IPPROTO_AH = 51,             /* Authentication Header protocol       */
-  IPPROTO_BEETPH = 94,	       /* IP option pseudo header for BEET */
-  IPPROTO_PIM    = 103,		/* Protocol Independent Multicast	*/
-
-  IPPROTO_COMP   = 108,                /* Compression Header protocol */
-  IPPROTO_SCTP   = 132,		/* Stream Control Transport Protocol	*/
-  IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
-
-  IPPROTO_RAW	 = 255,		/* Raw IP packets			*/
-  IPPROTO_MAX
-};
-
+/* Include IPPROTO_* defines. */
+#include <linux/ipproto.h>
 
 /* Internet address. */
 struct in_addr {
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index f79c372..a2b16a5 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -23,6 +23,13 @@
 
 #include <linux/types.h>
 
+/* If a glibc-based userspace has already included in.h, then we will not 
+ * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq. The
+ * ABI used by the kernel and by glibc match exactly. Neither the kernel
+ * nor glibc should break this ABI without coordination.
+ */
+#ifndef _NETINET_IN_H
+
 /*
  *	IPv6 address structure
  */
@@ -30,12 +37,20 @@
 struct in6_addr {
 	union {
 		__u8		u6_addr8[16];
+#if !defined(__GLIBC__) \
+    || (defined(__GLIBC__) && (defined(__USE_MISC) || defined(__USE_GNU))) \
+    || defined(__KERNEL__)
 		__be16		u6_addr16[8];
 		__be32		u6_addr32[4];
+#endif
 	} in6_u;
+#if !defined(__GLIBC__) \
+    || (defined(__GLIBC__) && (defined(__USE_MISC) || defined(__USE_GNU))) \
+    || defined(__KERNEL__)
 #define s6_addr			in6_u.u6_addr8
 #define s6_addr16		in6_u.u6_addr16
 #define s6_addr32		in6_u.u6_addr32
+#endif
 };
 
 /* IPv6 Wildcard Address (::) and Loopback Address (::1) defined in RFC2553
@@ -56,9 +71,12 @@ struct ipv6_mreq {
 	struct in6_addr ipv6mr_multiaddr;
 
 	/* local IPv6 address of interface */
-	int		ipv6mr_ifindex;
+	int		ipv6mr_interface;
+#define ipv6mr_ifindex	ipv6mr_interface
 };
 
+#endif /* !_NET_INET_H */
+
 #define ipv6mr_acaddr	ipv6mr_multiaddr
 
 struct in6_flowlabel_req {
@@ -116,16 +134,32 @@ struct in6_flowlabel_req {
 #define IPV6_PRIORITY_14		0x0e00
 #define IPV6_PRIORITY_15		0x0f00
 
+
+#ifndef _NETINET_IN_H
+#if defined (__GLIBC__)
+/* Include all of the other IPPROTO_* defines for userspace. */
+#include <linux/ipproto.h>
+#endif
 /*
  *	IPV6 extension headers
  */
-#define IPPROTO_HOPOPTS		0	/* IPv6 hop-by-hop options	*/
-#define IPPROTO_ROUTING		43	/* IPv6 routing header		*/
-#define IPPROTO_FRAGMENT	44	/* IPv6 fragmentation header	*/
-#define IPPROTO_ICMPV6		58	/* ICMPv6			*/
-#define IPPROTO_NONE		59	/* IPv6 no next header		*/
-#define IPPROTO_DSTOPTS		60	/* IPv6 destination options	*/
-#define IPPROTO_MH		135	/* IPv6 mobility header		*/
+enum {
+  IPPROTO_HOPOPTS = 0,		/* IPv6 hop-by-hop options      */
+#define IPPROTO_HOPOPTS		IPPROTO_HOPOPTS
+  IPPROTO_ROUTING = 43,		/* IPv6 routing header          */
+#define IPPROTO_ROUTING		IPPROTO_ROUTING
+  IPPROTO_FRAGMENT = 44,	/* IPv6 fragmentation header    */
+#define IPPROTO_FRAGMENT	IPPROTO_FRAGMENT
+  IPPROTO_ICMPV6 = 58,		/* ICMPv6                       */
+#define IPPROTO_ICMPV6		IPPROTO_ICMPV6
+  IPPROTO_NONE = 59,		/* IPv6 no next header          */
+#define IPPROTO_NONE		IPPROTO_NONE
+  IPPROTO_DSTOPTS = 60,		/* IPv6 destination options     */
+#define IPPROTO_DSTOPTS		IPPROTO_DSTOPTS
+  IPPROTO_MH = 135,		/* IPv6 mobility header         */
+#define IPPROTO_MH		IPPROTO_MH
+};
+#endif /* !_NETINET_IN_H */
 
 /*
  *	IPv6 TLV options.
diff --git a/include/uapi/linux/ipproto.h b/include/uapi/linux/ipproto.h
new file mode 100644
index 0000000..5a183e6
--- /dev/null
+++ b/include/uapi/linux/ipproto.h
@@ -0,0 +1,57 @@
+#ifndef _UAPI_LINUX_IPPROTO_H
+#define _UAPI_LINUX_IPPROTO_H
+
+/* Standard well-defined IP protocols. */
+enum {
+  IPPROTO_IP = 0,		/* Dummy protocol for TCP. */
+#define IPPROTO_IP		IPPROTO_IP
+  IPPROTO_ICMP = 1,		/* Internet Control Message Protocol. */
+#define IPPROTO_ICMP		IPPROTO_ICMP
+  IPPROTO_IGMP = 2,		/* Internet Group Management Protocol. */
+#define IPPROTO_IGMP		IPPROTO_IGMP
+  IPPROTO_IPIP = 4,		/* IPIP tunnels (older KA9Q tunnels use 94). */
+#define IPPROTO_IPIP		IPPROTO_IPIP
+  IPPROTO_TCP = 6,		/* Transmission Control Protocol. */
+#define IPPROTO_TCP		IPPROTO_TCP
+  IPPROTO_EGP = 8,		/* Exterior Gateway Protocol. */
+#define IPPROTO_EGP		IPPROTO_EGP
+  IPPROTO_PUP = 12,		/* PUP protocol. */
+#define IPPROTO_PUP		IPPROTO_PUP
+  IPPROTO_UDP = 17,		/* User Datagram Protocol. */
+#define IPPROTO_UDP		IPPROTO_UDP
+  IPPROTO_IDP = 22,		/* XNS IDP protocol. */
+#define IPPROTO_IDP		IPPROTO_IDP
+  IPPROTO_TP = 29,		/* SO Transport Protocol Class 4. */
+#define IPPROTO_TP		IPPROTO_TP
+  IPPROTO_DCCP = 33,		/* Datagram Congestion Control Protocol. */
+#define IPPROTO_DCCP		IPPROTO_DCCP
+  IPPROTO_IPV6 = 41,		/* IPv6 header. */
+#define IPPROTO_IPV6		IPPROTO_IPV6
+  IPPROTO_RSVP = 46,		/* Reservation Protocol. */
+#define IPPROTO_RSVP		IPPROTO_RSVP
+  IPPROTO_GRE = 47,		/* General Routing Encapsulation. */
+#define IPPROTO_GRE		IPPROTO_GRE
+  IPPROTO_ESP = 50,		/* encapsulating security payload. */
+#define IPPROTO_ESP		IPPROTO_ESP
+  IPPROTO_AH = 51,		/* authentication header. */
+#define IPPROTO_AH		IPPROTO_AH
+  IPPROTO_MTP = 92,		/* Multicast Transport Protocol. */
+#define IPPROTO_MTP		IPPROTO_MTP
+  IPPROTO_BEETPH = 94,		/* IP option pseudo header for BEET. */
+#define IPPROTO_BEETPH		IPPROTO_BEETPH
+  IPPROTO_ENCAP = 98,		/* Encapsulation Header. */
+#define IPPROTO_ENCAP		IPPROTO_ENCAP
+  IPPROTO_PIM = 103,		/* Protocol Independent Multicast. */
+#define IPPROTO_PIM		IPPROTO_PIM
+  IPPROTO_COMP = 108,		/* Compression Header Protocol. */
+#define IPPROTO_COMP		IPPROTO_COMP
+  IPPROTO_SCTP = 132,		/* Stream Control Transmission Protocol. */
+#define IPPROTO_SCTP		IPPROTO_SCTP
+  IPPROTO_UDPLITE = 136,	/* UDP-Lite protocol. */
+#define IPPROTO_UDPLITE		IPPROTO_UDPLITE
+  IPPROTO_RAW = 255,		/* Raw IP packets. */
+#define IPPROTO_RAW		IPPROTO_RAW
+  IPPROTO_MAX
+};
+
+#endif /* _UAPI_LINUX_IPPROTO_H */
---

Cheers,
Carlos.
