From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 1/4] Prefix List against 2.5.73
Date: Mon, 14 Jul 2003 15:35:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307141300520.5140-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
   <kuznet@ms2.inr.ac.ru>, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I am sending the latest patches against 2.5.73 and 2.4.21 with the changes
mentioned in my previous mail. I have also split the patch based on the
functionalities - prefix list and O/M flags of an RA.

At the bottom of this mail contains the patch for setting/getting O/M
flags against 2.5.73. The next three mails contain patches for prefix list
against 2.5.73, and both of these patches against 2.4.21. Please apply the
O/M flags patch before the prefix list patch.

Thanks,

- KK

---------------------------------------------------------------------------

> You do not explain why we (or kernel) NEED(s) this.
> It is not so important how SMALL it is
> though it may cause problems how LARGE it is.

I had explained the reasons for having prefix list i/f in my previous
mail. To recap :
-  User don't need to know what the definition of a prefix is, all he has
   to do is ask the kernel and get the list. Otherwise different user apps
   will have to know the definition of a prefix and parse the entry themselves.
   The parsing is non-trivial (eg the address should not LL or MC, there should
   be no nexthop and it should be added via an RA, etc).
-  The kernel code to get the prefix list is small, the top level
   inet6_dump_fib uses  either the dump_node or the dump_prefix, the
   latter being the new user interface. Having a user interface makes it easier
   to get the prefix list without significant bloat to the kernel.

> This is design issue; how we should provide L3 per-interface
> information to userspace; eg. in_device and/or inet6_dev things
> including per-interface statistics.
>
> Since I think it is not appropriate to provide per-interface
> statistics via RTM_xxxROUTE, so I don't agree to provide
> the RA infomation (i.e. Manage/Otherconf Flags) via
> RTM_xxxROUTE.
>
> Options:
>  - use RTM_xxxLINK for L3 operation
>  - introduce RTM_xxxIFACE for L3 per-interface operations

Yes, there are a couple of different ways to do this. One is as you have
suggested, but there is a problem with it. The existing RTM_GETLINK
interface returns very generic elements of the dev (mtu, hardware address,
dev statistics), while the change you suggested is specific to ipv6. I am
not sure if this is a good design to implement. Either we could use the
current (submitted) way or use a different RTM_GETADDR interface in
inet6_fill_ifaddr (and introduce RTM_IFACEFLAGS). This will be specific to
IPv6. Are you agreeable to this ?

> Well, on moving forward; you can split your patch up to 3 things:
>   1. fix routing flags
>   2. provide Managed/Otherconf flags API
>  (3. provide the prefix list API (if it IS required))
>
> I'm not against the first item.
> We need to discuss on the design related to the 2nd item.
> I don't think that we really need 3rd item.

- I am ok with 1 :-)
- I have suggested changes for 2, please let me know what you think, whether
  we can go with the old way or make the change suggested above.
- I believe we need #3 for the reasons given above.

Thanks,

- KK

----------------------- PATCH for O/M against 2.5.73 --------------------
diff -ruN linux-2.5.73.org/include/linux/rtnetlink.h PATCHES/linux-2.5.73/include/linux/rtnetlink.h
--- linux-2.5.73.org/include/linux/rtnetlink.h	2003-06-22 11:33:07.000000000 -0700
+++ PATCHES/linux-2.5.73/include/linux/rtnetlink.h	2003-07-14 12:11:51.000000000 -0700
@@ -330,6 +330,7 @@
 	IFA_LABEL,
 	IFA_BROADCAST,
 	IFA_ANYCAST,
+	IFA_IFFLAGS,
 	IFA_CACHEINFO
 };

diff -ruN linux-2.5.73.org/include/net/if_inet6.h PATCHES/linux-2.5.73/include/net/if_inet6.h
--- linux-2.5.73.org/include/net/if_inet6.h	2003-06-22 11:33:32.000000000 -0700
+++ PATCHES/linux-2.5.73/include/net/if_inet6.h	2003-07-14 10:30:59.000000000 -0700
@@ -17,6 +17,8 @@

 #include <net/snmp.h>

+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10

diff -ruN linux-2.5.73.org/net/ipv6/addrconf.c PATCHES/linux-2.5.73/net/ipv6/addrconf.c
--- linux-2.5.73.org/net/ipv6/addrconf.c	2003-06-22 11:33:17.000000000 -0700
+++ PATCHES/linux-2.5.73/net/ipv6/addrconf.c	2003-07-14 12:22:07.000000000 -0700
@@ -2359,6 +2359,7 @@
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 			     u32 pid, u32 seq, int event)
 {
+	int flags;
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	struct ifa_cacheinfo ci;
@@ -2389,6 +2390,8 @@
 		}
 		RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
 	}
+	flags = ifa->idev->if_flags;
+	RTA_PUT(skb, IFA_IFFLAGS, sizeof(flags), &flags);
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;

diff -ruN linux-2.5.73.org/net/ipv6/ndisc.c PATCHES/linux-2.5.73/net/ipv6/ndisc.c
--- linux-2.5.73.org/net/ipv6/ndisc.c	2003-06-22 11:32:56.000000000 -0700
+++ PATCHES/linux-2.5.73/net/ipv6/ndisc.c	2003-07-14 10:30:59.000000000 -0700
@@ -1036,6 +1036,16 @@
 		 */
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}
+	/*
+	 * Remember the managed/otherconf flags from most recently
+	 * receieved RA message (RFC 2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED|
+				IF_RA_OTHERCONF)) |
+				(ra_msg->icmph.icmp6_addrconf_managed ?
+					IF_RA_MANAGED : 0) |
+				(ra_msg->icmph.icmp6_addrconf_other ?
+					IF_RA_OTHERCONF : 0);

 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);

------------------------------------------------------------------------
