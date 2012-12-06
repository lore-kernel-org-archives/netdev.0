From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Thu, 06 Dec 2012 09:43:46 +0100
Message-ID: <50C05AC2.1050504@6wind.com>
References: <50BE56D3.2030704@6wind.com> <50BF29DA.7020903@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com> <20121205.125453.1457654258131828976.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:58259 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab2LFInv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 03:43:51 -0500
Received: by mail-wg0-f46.google.com with SMTP id dr13so3576460wgb.1
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 00:43:49 -0800 (PST)
In-Reply-To: <20121205.125453.1457654258131828976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/12/2012 18:54, David Miller a =E9crit :
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Wed, 5 Dec 2012 11:41:33 -0000
>
>> Probably worth commenting that the 64bit items might only be 32bit a=
ligned.
>> Just to stop anyone trying to read/write them with pointer casts.
>
> Rather, let's not create this situation at all.
>
> It's totally inappropriate to have special code to handle every singl=
e
> time we want to put 64-bit values into netlink messages.
>
> We need a real solution to this issue.
>
The easiest way is to update *_ALIGNTO values (maybe we can keep NLMSG_=
ALIGNTO=20
to 4). But I think that many userland apps have these values hardcoded =
and, the=20
most important thing, this may increase size of many netlink messages. =
Hence we=20
need probably to find something better.


diff --git a/include/uapi/linux/netfilter/nfnetlink_compat.h=20
b/include/uapi/linux/netfilter/nfnetlink_compat.h
index ffb9503..121e62a 100644
--- a/include/uapi/linux/netfilter/nfnetlink_compat.h
+++ b/include/uapi/linux/netfilter/nfnetlink_compat.h
@@ -33,7 +33,7 @@ struct nfattr {
  #define NFNL_NFA_NEST	0x8000
  #define NFA_TYPE(attr) 	((attr)->nfa_type & 0x7fff)

-#define NFA_ALIGNTO     4
+#define NFA_ALIGNTO     8
  #define NFA_ALIGN(len)	(((len) + NFA_ALIGNTO - 1) & ~(NFA_ALIGNTO - 1=
))
  #define NFA_OK(nfa,len)	((len) > 0 && (nfa)->nfa_len >=3D sizeof(stru=
ct nfattr) \
  	&& (nfa)->nfa_len <=3D (len))
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.=
h
index 78d5b8a..66d2a26 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -75,7 +75,7 @@ struct nlmsghdr {
     Check		NLM_F_EXCL
   */

-#define NLMSG_ALIGNTO	4U
+#define NLMSG_ALIGNTO	8U
  #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-=
1) )
  #define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
  #define NLMSG_LENGTH(len) ((len)+NLMSG_ALIGN(NLMSG_HDRLEN))
@@ -145,7 +145,7 @@ struct nlattr {
  #define NLA_F_NET_BYTEORDER	(1 << 14)
  #define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)

-#define NLA_ALIGNTO		4
+#define NLA_ALIGNTO		8
  #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - =
1))
  #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetl=
ink.h
index 33d29ce..ee898c1 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -146,7 +146,7 @@ struct rtattr {

  /* Macros to handle rtattributes */

-#define RTA_ALIGNTO	4
+#define RTA_ALIGNTO	8
  #define RTA_ALIGN(len) ( ((len)+RTA_ALIGNTO-1) & ~(RTA_ALIGNTO-1) )
  #define RTA_OK(rta,len) ((len) >=3D (int)sizeof(struct rtattr) && \
  			 (rta)->rta_len >=3D sizeof(struct rtattr) && \
@@ -322,7 +322,7 @@ struct rtnexthop {

  /* Macros to handle hexthops */

-#define RTNH_ALIGNTO	4
+#define RTNH_ALIGNTO	8
  #define RTNH_ALIGN(len) ( ((len)+RTNH_ALIGNTO-1) & ~(RTNH_ALIGNTO-1) =
)
  #define RTNH_OK(rtnh,len) ((rtnh)->rtnh_len >=3D sizeof(struct rtnext=
hop) && \
  			   ((int)(rtnh)->rtnh_len) <=3D (len))
