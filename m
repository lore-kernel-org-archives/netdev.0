From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Thu, 24 Apr 2008 13:01:43 -0700
Message-ID: <OFFE40C097.9EE8B821-ON88257435.0067E798-88257435.006E0467@us.ibm.com>
References: <20080425.034604.40676242.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37247 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760482AbYDXUBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 16:01:52 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3OJxI0b005761
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 15:59:18 -0400
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OK1kRg214296
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:01:46 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.13.1/8.13.3) with ESMTP id m3OK1kVq020010
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:01:46 -0600
In-Reply-To: <20080425.034604.40676242.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[comments in-line, where there are no leading ">", with some deleted, but 
I hope
enough for context]

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/24/2008 
11:46:04 AM:


> commit afdf2703bd9423a62cf7d984bdc88273fa205033
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Tue Apr 22 12:14:20 2008 +0900
> 
>     [IPV6] MCAST: Move mode check for group_source_req{}-sockopt to 
net/ipv6/mcast.c.
> 
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 49c4898..aa81120 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -565,7 +565,7 @@ extern const struct proto_ops inet6_dgram_ops;
>  struct group_source_req;
>  struct group_filter;
> 
> -extern int ip6_mc_source(int add, int omode, struct sock *sk,
> +extern int ip6_mc_source(struct sock *sk, int optname,
>            struct group_source_req *pgsr);
>  extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
>  extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index a53aed4..694e031 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -542,7 +542,6 @@ done:
>     case MCAST_UNBLOCK_SOURCE:
>     {
>        struct group_source_req greqs;
> -      int omode, add;
> 
>        if (optlen < sizeof(struct group_source_req))
>           goto e_inval;
> @@ -550,33 +549,7 @@ done:
>           retv = -EFAULT;
>           break;
>        }
> -      if (greqs.gsr_group.ss_family != AF_INET6 ||
> -          greqs.gsr_source.ss_family != AF_INET6) {
> -         retv = -EADDRNOTAVAIL;
> -         break;
> -      }
> -      if (optname == MCAST_BLOCK_SOURCE) {
> -         omode = MCAST_EXCLUDE;
> -         add = 1;
> -      } else if (optname == MCAST_UNBLOCK_SOURCE) {
> -         omode = MCAST_EXCLUDE;
> -         add = 0;
> -      } else if (optname == MCAST_JOIN_SOURCE_GROUP) {
> -         struct sockaddr_in6 *psin6;
> -
> -         psin6 = (struct sockaddr_in6 *)&greqs.gsr_group;
> -         retv = ipv6_sock_mc_join(sk, greqs.gsr_interface,
> -            &psin6->sin6_addr);
> -         /* prior join w/ different source is ok */
> -         if (retv && retv != -EADDRINUSE)
> -            break;
> -         omode = MCAST_INCLUDE;
> -         add = 1;
> -      } else /* MCAST_LEAVE_SOURCE_GROUP */ {
> -         omode = MCAST_INCLUDE;
> -         add = 0;
> -      }
> -      retv = ip6_mc_source(add, omode, sk, &greqs);
> +      retv = ip6_mc_source(sk, optname, &greqs);
>        break;
>     }
>     case MCAST_MSFILTER:
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 54f91ef..5d8d653 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -355,8 +355,8 @@ void ipv6_sock_mc_close(struct sock *sk)
>     write_unlock_bh(&ipv6_sk_mc_lock);
>  }
> 
> -int ip6_mc_source(int add, int omode, struct sock *sk,
> -   struct group_source_req *pgsr)
> +static int __ip6_mc_source(int add, int omode, struct sock *sk,
> +            struct group_source_req *pgsr)
>  {
>     struct in6_addr *source, *group;
>     struct ipv6_mc_socklist *pmc;
> @@ -496,6 +496,40 @@ done:
>     return err;
>  }
> 
> +int ip6_mc_source(struct sock *sk, int optname,
> +        struct group_source_req *pgsr)
> +{
> +   int omode, add, retv;
> +
> +   if (pgsr->gsr_group.ss_family != AF_INET6 ||
> +       pgsr->gsr_source.ss_family != AF_INET6)
> +      return -EADDRNOTAVAIL;
> +
> +   if (optname == MCAST_BLOCK_SOURCE) {
> +      omode = MCAST_EXCLUDE;
> +      add = 1;
> +   } else if (optname == MCAST_UNBLOCK_SOURCE) {
> +      omode = MCAST_EXCLUDE;
> +      add = 0;
> +   } else if (optname == MCAST_JOIN_SOURCE_GROUP) {
> +      struct sockaddr_in6 *psin6;
> +
> +      psin6 = (struct sockaddr_in6 *)&pgsr->gsr_group;
> +      retv = ipv6_sock_mc_join(sk, pgsr->gsr_interface,
> +                &psin6->sin6_addr);
> +      /* prior join w/ different source is ok */
> +      if (retv && retv != -EADDRINUSE)
> +         return retv;
> +      omode = MCAST_INCLUDE;
> +      add = 1;
> +   } else /* MCAST_LEAVE_SOURCE_GROUP */ {
> +      omode = MCAST_INCLUDE;
> +      add = 0;
> +   }
> +
> +   return __ip6_mc_source(add, omode, sk, pgsr);
> +}
> +
>  int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
>  {
>     struct in6_addr *group;
> 

        I think this part isn't relevant to compat support, right?
I don't see much advantage in moving this, but it should be a
separate patch and discussion, I think.

> +   switch (optname) {
> +   case MCAST_JOIN_SOURCE_GROUP:
> +   case MCAST_LEAVE_SOURCE_GROUP:
> +   case MCAST_BLOCK_SOURCE:
> +   case MCAST_UNBLOCK_SOURCE:
> +       {
> +      struct group_source_req greqs;

        Are you sure we want this on the kernel stack?

> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index b7ae360..30e6ca1 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -744,6 +744,32 @@ compat_do_ipv6_setsockopt(struct sock *sk, int 
level, int optname,
>     int retv;
> 
>     switch (optname) {
> +   case MCAST_JOIN_GROUP:
> +   case MCAST_LEAVE_GROUP:
> +       {
> +      struct group_req greq;

        Big for the kernel stack.


> commit 3c055f969f7f3716f6846037c2ec0fa06e0424b3
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Thu Apr 24 17:32:10 2008 +0900
> 
>     [IPV6] COMPAT: group_filter{}-setsockopt compat layer.
> 
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/linux/in.h b/include/linux/in.h
> index 2fbd7c7..ccbfc76 100644
> --- a/include/linux/in.h
> +++ b/include/linux/in.h
> @@ -182,6 +182,19 @@ struct compat_group_req
>     __u32                gr_interface;
>     struct __compat_sockaddr_storage    gr_group;
>  };
> +
> +struct compat_group_filter
> +{
> +   __u32               gf_interface;
> +   struct __compat_sockaddr_storage   gf_group;
> +   __u32               gf_fmode;
> +   __u32               gf_numsrc;
> +   struct __compat_sockaddr_storage   gf_slist[1];
> +};
> +
> +#define COMPAT_GROUP_FILTER_SIZE(numsrc) \
> +   (sizeof(struct compat_group_filter) - sizeof(struct 
__compat_sockaddr_storage) \
> +   + (numsrc) * sizeof(struct __compat_sockaddr_storage))
>  #endif
>  #endif

        Better to compute this just once, in which case no macro needed.
Suggest a variable and do
"len = GROUP_FILTER_SIZE(numsrc) + sizeof(struct compat_group_filter) - 
sizeof(struct group_filter);"
Also, why put these in an include file when there is only one use?

> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 30e6ca1..0895e7d 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -794,6 +794,57 @@ compat_do_ipv6_setsockopt(struct sock *sk, int 
level, int optname,
>        retv = ip6_mc_source(sk, optname, &greqs);
>        break;
>         }
> +   case MCAST_MSFILTER:
> +       {
> +      extern int sysctl_mld_max_msf;
> +      struct compat_group_filter __user *ugsf = (void __user *)optval;
> +      struct group_filter *gsf;
> +      u32 gf_numsrc;
> +      int i;
> +
> +      if (optlen < COMPAT_GROUP_FILTER_SIZE(0))
> +         return -EINVAL;
> +
> +      if (access_ok(VERIFY_READ, ugsf, COMPAT_GROUP_FILTER_SIZE(0)) ||
> +          __get_user(gf_numsrc, &ugsf->gf_numsrc))
> +         return -EFAULT;
> +
> +      if (COMPAT_GROUP_FILTER_SIZE(gf_numsrc) > optlen)
> +         return -EINVAL;
> +
> +      if (optlen > sysctl_optmem_max ||
> +          gf_numsrc >= 0x1ffffffU ||
> +          gf_numsrc > sysctl_mld_max_msf)
> +         return -ENOBUFS;

        Missing comment from the original that explains the significance
of "0x1ffffffU", and the version I'm looking at doesn't have the
sysctl_optmem_max check. Though it can be raised, without the check,
we can support very large filters too. Maybe ok, but unrelated to
compat support.

> +
> +      optlen = GROUP_FILTER_SIZE(gf_numsrc);
> +      gsf = kmalloc(optlen, GFP_KERNEL);
> +      if (!gsf) {
> +         retv = -ENOBUFS;
> +         break;
> +      }
> +      retv = -EFAULT;
> +      if (__get_user(gsf->gf_interface, &ugsf->gf_interface) ||
> +          __copy_from_user(&gsf->gf_group, &ugsf->gf_group, 
sizeof(gsf->gf_group)) ||
> +          __get_user(gsf->gf_fmode, &ugsf->gf_fmode) ||
> +          access_ok(VERIFY_READ, ugsf->gf_slist,
> +               sizeof(struct __compat_sockaddr_storage) * gf_numsrc))
> +         goto kfree_out;

        Does access_ok() handle (valid) case numsrc==0 correctly?

> +
> +      gsf->gf_numsrc = gf_numsrc;
> +
> +      for (i = 0; i < gf_numsrc; i++) {
> +         if (__copy_from_user(&gsf->gf_slist[i],
> +                    &ugsf->gf_slist[i],
> +                    sizeof(gsf->gf_slist[i])))
> +            goto kfree_out;
> +      }

        This is adding a lot of separate copies that I believe
are unnecessary. sockaddr_storage is the same size, so you
can copy optlen-GROUP_FILTER_SIZE(0) all at once.

> 
> -int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> -   struct group_filter __user *optval, int __user *optlen)
> +int __ip6_mc_msf_lookup(struct sock *sk,
> +         struct in6_addr *group, int interface,
> +         struct ip6_sf_socklist **ppsl)
>  {
> -   int err, i, count, copycount;
> -   struct in6_addr *group;
>     struct ipv6_mc_socklist *pmc;
> -   struct inet6_dev *idev;
> -   struct net_device *dev;
>     struct ipv6_pinfo *inet6 = inet6_sk(sk);
> -   struct ip6_sf_socklist *psl;
> +   struct net_device *dev;
> +   struct inet6_dev *idev;
>     struct net *net = sock_net(sk);
> +   int ret = 0;
> 
> -   group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
> -
> -   if (!ipv6_addr_is_multicast(group))
> -      return -EINVAL;
> -
> -   idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
> +   if (!ipv6_addr_is_multicast(group)) {
> +      ret = -EINVAL;
> +      goto out;
> +   }
> 
> -   if (!idev)
> -      return -ENODEV;
> +   idev = ip6_mc_find_dev(net, group, interface);
> +   if (!idev) {
> +      ret = -ENODEV;
> +      goto out;
> +   }

        Looks unrelated to compat support...? As what follows in
this function.

> 
>     dev = idev->dev;
> 
> -   err = -EADDRNOTAVAIL;
> +   ret = -EADDRNOTAVAIL;
>     /*
>      * changes to the ipv6_mc_list require the socket lock and
>      * a read lock on ip6_sk_mc_lock. We have the socket lock,
>      * so reading the list is safe.
>      */
> 
> -   for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
> -      if (pmc->ifindex != gsf->gf_interface)
> +   for (pmc = inet6->ipv6_mc_list; pmc; pmc = pmc->next) {
> +      if (pmc->ifindex != interface)
>           continue;
>        if (ipv6_addr_equal(group, &pmc->addr))
>           break;
>     }
> -   if (!pmc)      /* must have a prior join */
> -      goto done;
> -   gsf->gf_fmode = pmc->sfmode;
> -   psl = pmc->sflist;
> -   count = psl ? psl->sl_count : 0;
> +   if (pmc) {
> +      *ppsl = pmc->sflist;
> +      ret = pmc->sfmode;
> +   }
> +
>     read_unlock_bh(&idev->lock);
>     in6_dev_put(idev);
>     dev_put(dev);
> +out:
> +   return ret;
> +}
> 
> -   copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
> -   gsf->gf_numsrc = count;
> -   if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
> -       copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
> -      return -EFAULT;
> -   }
> -   /* changes to psl require the socket lock, a read lock on
> -    * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
> -    * have the socket lock, so reading here is safe.
> -    */
> -   for (i=0; i<copycount; i++) {
> -      struct sockaddr_in6 *psin6;
> -      struct sockaddr_storage ss;
> +int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> +   struct group_filter __user *optval, int __user *optlen)
> +{
> +   struct in6_addr *group;
> +   struct ip6_sf_socklist *psl;
> +   int fmode;
> +
> +   group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
> +
> +   fmode = __ip6_mc_msf_lookup(sk, group, gsf->gf_interface, &psl);
> +   if (fmode < 0)
> +      return fmode;
> 
> -      psin6 = (struct sockaddr_in6 *)&ss;
> -      memset(&ss, 0, sizeof(ss));
> -      psin6->sin6_family = AF_INET6;
> -      psin6->sin6_addr = psl->sl_addr[i];
> -      if (copy_to_user(&optval->gf_slist[i], &ss, sizeof(ss)))
> +   if (psl) {
> +      int count = psl ? psl->sl_count : 0;
> +      int i, copycount;
> +      struct sockaddr_in6 sin6;
> +
> +      copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
> +
> +      if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
> +          access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) 
||
> +          __put_user((u32)fmode, &optval->gf_fmode) ||
> +          __put_user((u32)count, &optval->gf_numsrc))
>           return -EFAULT;
> +
> +      /* changes to psl require the socket lock, a read lock on
> +       * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
> +       * have the socket lock, so reading here is safe.
> +       */
> +      memset(&sin6, 0, sizeof(sin6));
> +      sin6.sin6_family = AF_INET6;
> +
> +      for (i = 0; i < copycount; i++) {
> +         struct sockaddr_in6 __user *usin6 = (void __user 
*)&optval->gf_slist[i];
> +
> +         ipv6_addr_copy(&sin6.sin6_addr, &psl->sl_addr[i]);
> +
> +         if (__copy_to_user(usin6, &sin6, sizeof(sin6)) ||
> +             __clear_user(usin6 + 1, sizeof(optval->gf_slist[i]) - 
sizeof(*usin6)))
> +            return -EFAULT;
> +      }
>     }
>     return 0;
> -done:
> -   read_unlock_bh(&idev->lock);
> -   in6_dev_put(idev);
> -   dev_put(dev);
> -   return err;
>  }
> 
>  int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
> 
> ---
> commit e920bd82cbc6e0b83087513a25220e9379b24b49
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Wed Apr 23 18:03:14 2008 +0900
> 
>     [IPV6] MCAST: Make ip6_mc_msfget() more generic.
> 
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index aa81120..103272f 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -568,7 +568,9 @@ struct group_filter;
>  extern int ip6_mc_source(struct sock *sk, int optname,
>            struct group_source_req *pgsr);
>  extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
> -extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> +extern int ip6_mc_msfget(struct sock *sk,
> +          struct in6_addr *group, u32 gf_interface,
> +          u32 gf_srcnum,
>            struct group_filter __user *optval,
>            int __user *optlen);
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 0895e7d..d670078 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -949,8 +949,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int 
level,
> int optname,
>        if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0)))
>           return -EFAULT;
>        lock_sock(sk);
> -      err = ip6_mc_msfget(sk, &gsf,
> -         (struct group_filter __user *)optval, optlen);
> +      err = ip6_mc_msfget(sk,
> +                &((struct sockaddr_in6 *)&gsf.gf_group)->sin6_addr,
> +                gsf.gf_interface, gsf.gf_numsrc,
> +                (struct group_filter __user *)optval, optlen);
>        release_sock(sk);
>        return err;
>     }
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index d32d6a3..b781192 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -670,16 +670,14 @@ out:
>     return ret;
>  }
> 
> -int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> -   struct group_filter __user *optval, int __user *optlen)
> +int ip6_mc_msfget(struct sock *sk,
> +        struct in6_addr *group, u32 gf_interface, u32 gf_numsrc,
> +        struct group_filter __user *optval, int __user *optlen)
>  {
> -   struct in6_addr *group;
>     struct ip6_sf_socklist *psl;
>     int fmode;
> 
> -   group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
> -
> -   fmode = __ip6_mc_msf_lookup(sk, group, gsf->gf_interface, &psl);
> +   fmode = __ip6_mc_msf_lookup(sk, group, gf_interface, &psl);
>     if (fmode < 0)
>        return fmode;
> 
> @@ -688,7 +686,7 @@ int ip6_mc_msfget(struct sock *sk, struct 
group_filter *gsf,
>        int i, copycount;
>        struct sockaddr_in6 sin6;
> 
> -      copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
> +      copycount = count < gf_numsrc ? count : gf_numsrc;
> 
>        if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
>            access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) 
||
> 
> ---
> commit 9153c1a545f2366f57bf46bcd59d5b99d61016f7
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Thu Apr 24 17:51:30 2008 +0900
> 
>     [IPV6] COMPAT: group_filter{}-getsockopt compat layer.
> 
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 103272f..c98c722 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -574,6 +574,16 @@ extern int ip6_mc_msfget(struct sock *sk,
>            struct group_filter __user *optval,
>            int __user *optlen);
> 
> +#ifdef CONFIG_COMPAT
> +struct compat_group_filter;
> +
> +int ip6_mc_compat_msfget(struct sock *sk,
> +          struct in6_addr *group,
> +          u32 gf_interface, u32 gf_numsrc,
> +          struct compat_group_filter __user *optval,
> +          int __user *optlen);
> +#endif
> +
>  #ifdef CONFIG_PROC_FS
>  extern int  ac6_proc_init(struct net *net);
>  extern void ac6_proc_exit(struct net *net);
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index d670078..46bafee 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -1200,7 +1200,33 @@ static int
>  compat_do_ipv6_getsockopt(struct sock *sk, int level, int optname,
>             char __user *optval, int __user *optlen)
>  {
> -   return do_ipv6_getsockopt(sk, level, optname, optval, optlen);
> +   int len, err;
> +
> +   if (get_user(len, optlen))
> +      return -EFAULT;
> +
> +   switch (optname) {
> +   case MCAST_MSFILTER:
> +       {
> +      struct compat_group_filter gsf;
> +      int err;
> +
> +      if (len < COMPAT_GROUP_FILTER_SIZE(0))
> +         return -EINVAL;
> +      if (copy_from_user(&gsf, optval, COMPAT_GROUP_FILTER_SIZE(0)))
> +         return -EFAULT;
> +      lock_sock(sk);
> +      err = ip6_mc_compat_msfget(sk,
> +                  &((struct sockaddr_in6 *)&gsf.gf_group)->sin6_addr,
> +                  gsf.gf_interface, gsf.gf_numsrc,
> +                  (struct compat_group_filter __user *)optval,
> +                  optlen);
> +      release_sock(sk);
> +       }
> +   default:
> +      err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
> +   }
> +   return err;
>  }
> 
>  int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index b781192..bdfabbb 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -714,6 +714,54 @@ int ip6_mc_msfget(struct sock *sk,
>     return 0;
>  }
> 
> +#ifdef CONFIG_COMPAT
> +int ip6_mc_compat_msfget(struct sock *sk,
> +          struct in6_addr *group,
> +          u32 gf_interface, u32 gf_numsrc,
> +          struct compat_group_filter __user *optval,
> +          int __user *optlen)
> +{
> +   struct ip6_sf_socklist *psl;
> +   int fmode;
> +
> +   fmode = __ip6_mc_msf_lookup(sk, group, gf_interface, &psl);
> +   if (fmode < 0)
> +      return fmode;
> +
> +   if (psl) {
> +      int count = psl ? psl->sl_count : 0;
> +      int i, copycount;
> +      struct sockaddr_in6 sin6;
> +
> +      copycount = count < gf_numsrc ? count : gf_numsrc;
> +
> +      if (put_user(COMPAT_GROUP_FILTER_SIZE(copycount), optlen) ||
> +          access_ok(VERIFY_WRITE, optval, 
COMPAT_GROUP_FILTER_SIZE(copycount)) ||

        numsrc == 0 case works?

> +          __put_user((u32)fmode, &optval->gf_fmode) ||
> +          __put_user((u32)count, &optval->gf_numsrc))
> +         return -EFAULT;
> +
> +      /* changes to psl require the socket lock, a read lock on
> +       * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
> +       * have the socket lock, so reading here is safe.
> +       */
> +      memset(&sin6, 0, sizeof(sin6));
> +      sin6.sin6_family = AF_INET6;
> +
> +      for (i = 0; i < copycount; i++) {
> +         struct sockaddr_in6 __user *usin6 = (void __user 
*)&optval->gf_slist[i];
> +
> +         ipv6_addr_copy(&sin6.sin6_addr, &psl->sl_addr[i]);
> +
> +         if (__copy_to_user(usin6, &sin6, sizeof(sin6)) ||
> +             __clear_user(usin6 + 1, sizeof(optval->gf_slist[i]) - 
sizeof(*usin6)))

why explicitly clear the rest of it?

...stopping here; will continue looking at the rest.

                                                +-DLS

