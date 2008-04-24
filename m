From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 05:43:28 +0900 (JST)
Message-ID: <20080425.054328.51438140.yoshfuji@linux-ipv6.org>
References: <20080425.034604.40676242.yoshfuji@linux-ipv6.org>
	<OFFE40C097.9EE8B821-ON88257435.0067E798-88257435.006E0467@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33497 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbYDXUna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 16:43:30 -0400
In-Reply-To: <OFFE40C097.9EE8B821-ON88257435.0067E798-88257435.006E0467@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFFE40C097.9EE8B821-ON88257435.0067E798-88257435.006E0467@us.ibm.com> (at Thu, 24 Apr 2008 13:01:43 -0700), David Stevens <dlstevens@us.ibm.com> says:


> >  int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
> >  {
> >     struct in6_addr *group;
> > 
> 
>         I think this part isn't relevant to compat support, right?
> I don't see much advantage in moving this, but it should be a
> separate patch and discussion, I think.

Otherwise, we will have too much duplicate code.

> 
> > +   switch (optname) {
> > +   case MCAST_JOIN_SOURCE_GROUP:
> > +   case MCAST_LEAVE_SOURCE_GROUP:
> > +   case MCAST_BLOCK_SOURCE:
> > +   case MCAST_UNBLOCK_SOURCE:
> > +       {
> > +      struct group_source_req greqs;
> 
>         Are you sure we want this on the kernel stack?
:
> > +      struct group_req greq;
> 
>         Big for the kernel stack.

I know, and I plan to fix stack usage in the next stage.

> > +
> > +struct compat_group_filter
> > +{
> > +   __u32               gf_interface;
> > +   struct __compat_sockaddr_storage   gf_group;
> > +   __u32               gf_fmode;
> > +   __u32               gf_numsrc;
> > +   struct __compat_sockaddr_storage   gf_slist[1];
> > +};
> > +
> > +#define COMPAT_GROUP_FILTER_SIZE(numsrc) \
> > +   (sizeof(struct compat_group_filter) - sizeof(struct 
> __compat_sockaddr_storage) \
> > +   + (numsrc) * sizeof(struct __compat_sockaddr_storage))
> >  #endif
> >  #endif
> 
>         Better to compute this just once, in which case no macro needed.
> Suggest a variable and do
> "len = GROUP_FILTER_SIZE(numsrc) + sizeof(struct compat_group_filter) - 
> sizeof(struct group_filter);"
> Also, why put these in an include file when there is only one use?

It is much clearer to mirror original logic.

> > +      optlen = GROUP_FILTER_SIZE(gf_numsrc);
> > +      gsf = kmalloc(optlen, GFP_KERNEL);
> > +      if (!gsf) {
> > +         retv = -ENOBUFS;
> > +         break;
> > +      }
> > +      retv = -EFAULT;
> > +      if (__get_user(gsf->gf_interface, &ugsf->gf_interface) ||
> > +          __copy_from_user(&gsf->gf_group, &ugsf->gf_group, 
> sizeof(gsf->gf_group)) ||
> > +          __get_user(gsf->gf_fmode, &ugsf->gf_fmode) ||
> > +          access_ok(VERIFY_READ, ugsf->gf_slist,
> > +               sizeof(struct __compat_sockaddr_storage) * gf_numsrc))
> > +         goto kfree_out;
> 
>         Does access_ok() handle (valid) case numsrc==0 correctly?

Hmm, not sure...

> > +      gsf->gf_numsrc = gf_numsrc;
> > +
> > +      for (i = 0; i < gf_numsrc; i++) {
> > +         if (__copy_from_user(&gsf->gf_slist[i],
> > +                    &ugsf->gf_slist[i],
> > +                    sizeof(gsf->gf_slist[i])))
> > +            goto kfree_out;
> > +      }
> 
>         This is adding a lot of separate copies that I believe
> are unnecessary. sockaddr_storage is the same size, so you
> can copy optlen-GROUP_FILTER_SIZE(0) all at once.

Okay...

> > -int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
> > -   struct group_filter __user *optval, int __user *optlen)
> > +int __ip6_mc_msf_lookup(struct sock *sk,
:
> > +      goto out;
> > +   }
> 
>         Looks unrelated to compat support...? As what follows in
> this function.

For killing duplicates between native / compat code.

> > +
> > +      copycount = count < gf_numsrc ? count : gf_numsrc;
> > +
> > +      if (put_user(COMPAT_GROUP_FILTER_SIZE(copycount), optlen) ||
> > +          access_ok(VERIFY_WRITE, optval, 
> COMPAT_GROUP_FILTER_SIZE(copycount)) ||
> 
>         numsrc == 0 case works?

???

> > +         ipv6_addr_copy(&sin6.sin6_addr, &psl->sl_addr[i]);
> > +
> > +         if (__copy_to_user(usin6, &sin6, sizeof(sin6)) ||
> > +             __clear_user(usin6 + 1, sizeof(optval->gf_slist[i]) - 
> sizeof(*usin6)))
> 
> why explicitly clear the rest of it?

We mirror original behavior, which clears rest of sockaddr_in6{}.

--yoshfuji
