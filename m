From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 12:33:59 +0900 (JST)
Message-ID: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
References: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
	<OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33755 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbYDZDeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 23:34:05 -0400
In-Reply-To: <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com> (at Fri, 25 Apr 2008 18:24:28 -0600), David Stevens <dlstevens@us.ibm.com> says:

> I discovered that the aligned attribute is only a minimum, so
> aligned by itself has no effect on padding. GNU documentation
> says you need both aligned and packed to make the pad be
> a certain value.  In this case, because the items that
> are padded are 32 bit, they are identical with and without on all
> architectures, but I stuck in the aligned all the same.

Please define __compat_sockaddr_storage{} with attribute((aligned(4))).
If you do that we do not need attribute(packed).  No?

> +extern int compat_mc_setsockopt(struct sock *, int, int, char __user *, 
> int);
> +

compat_do_inet_mc_setsockopt() or so.

>  #endif /* NET_COMPAT_H */
> diff -ruNp linux-2.6.18.ppc64/net/compat.c 
> linux-2.6.18.ppc64DLS1/net/compat.c
> --- linux-2.6.18.ppc64/net/compat.c     2008-04-21 13:51:02.000000000 
> -0700
> +++ linux-2.6.18.ppc64DLS1/net/compat.c 2008-04-25 08:53:47.000000000 
> -0700

net/compat.c is not the right place.
Please put this in net/ipv4/compat.c or so.
Or at least, these must be guarded by CONFIG_INET.

> @@ -26,6 +26,8 @@
>  
>  #include <net/scm.h>
>  #include <net/sock.h>
> +#include <net/ip.h>
> +#include <net/ipv6.h>
>  #include <asm/uaccess.h>
>  #include <net/compat.h>
>  
> @@ -589,6 +591,122 @@ asmlinkage long compat_sys_getsockopt(in
>         }
>         return err;
>  }
> +
> +struct compat_group_req {
> +       __u32                            gr_interface;
> +       struct __kernel_sockaddr_storage gr_group
> +               __attribute__ ((aligned(4)));
> +} __attribute__ ((packed));
> +
> +struct compat_group_source_req {
> +       __u32                            gsr_interface;
> +       struct __kernel_sockaddr_storage gsr_group
> +               __attribute__ ((aligned(4)));
> +       struct __kernel_sockaddr_storage gsr_source
> +               __attribute__ ((aligned(4)));
> +} __attribute__ ((packed));
> +
> +struct compat_group_filter {
> +       __u32                            gf_interface;
> +       struct __kernel_sockaddr_storage gf_group
> +               __attribute__ ((aligned(4)));
> +       __u32                            gf_fmode;
> +       __u32                            gf_numsrc;
> +       struct __kernel_sockaddr_storage gf_slist[1]
> +               __attribute__ ((aligned(4)));
> +} __attribute__ ((packed));
> +

include/linux/in.n.

> +
> +int compat_mc_setsockopt(struct sock *sock, int level, int optname,
> +       char __user *optval, int optlen)
> +{
> +       char __user     *koptval = optval;
> +       int             koptlen = optlen;
> +
> +       switch (optname) {
> +       case MCAST_JOIN_GROUP:
> +       case MCAST_LEAVE_GROUP:
> +       {
> +               struct compat_group_req __user *gr32 = (void *)optval;
> +               struct group_req __user *kgr =
> +                       compat_alloc_user_space(sizeof(struct group_req));
> +               u32 interface;
> +
> +               if (!access_ok(VERIFY_READ, gr32, sizeof(*gr32)) ||
> +                   !access_ok(VERIFY_WRITE, kgr, sizeof(struct 
> group_req)) ||
> +                   __get_user(interface, &gr32->gr_interface) ||
> +                   __put_user(interface, &kgr->gr_interface) ||
> +                   copy_in_user(&kgr->gr_group, &gr32->gr_group,
> +                               sizeof(kgr->gr_group)))
> +                       return -EFAULT;

__copy_in_user().
Maybe we can use __copy_in_user for u32?

--yoshfuji
