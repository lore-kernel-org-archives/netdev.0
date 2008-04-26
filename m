From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Fri, 25 Apr 2008 21:36:29 -0700
Message-ID: <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42874 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbYDZEgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 00:36:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3Q4aXr5012375
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 00:36:33 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3Q4aX6c192632
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 22:36:33 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3Q4aXoR022421
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 22:36:33 -0600
In-Reply-To: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/25/2008 
08:33:59 PM:

> Please define __compat_sockaddr_storage{} with attribute((aligned(4))).
> If you do that we do not need attribute(packed).  No?

        I just tried it and the compiler seems to do that for this case,
but the gcc documentation says explicitly that you need both packed and
aligned if you want it to be a specific value. aligned(4) is a minimum
only and the compiler would be free to add pad still as long as the
padded value was also 4-byte aligned.
        In this case, we want no pad, so packed is the relevant part. If
had a char followed by a struct as in your previous example, the right
way to get 4-byte alignment is both aligned(4) and packed. Leaving off
packed would allow 8-byte or 16-byte (or 12 :-)) alignment, too.

> 
> > +extern int compat_mc_setsockopt(struct sock *, int, int, char __user 
*, 
> > int);
> > +
> 
> compat_do_inet_mc_setsockopt() or so.
> 
> >  #endif /* NET_COMPAT_H */
> > diff -ruNp linux-2.6.18.ppc64/net/compat.c 
> > linux-2.6.18.ppc64DLS1/net/compat.c
> > --- linux-2.6.18.ppc64/net/compat.c     2008-04-21 13:51:02.000000000 
> > -0700
> > +++ linux-2.6.18.ppc64DLS1/net/compat.c 2008-04-25 08:53:47.000000000 
> > -0700
> 
> net/compat.c is not the right place.
> Please put this in net/ipv4/compat.c or so.
> Or at least, these must be guarded by CONFIG_INET.

        This code is for both v4 and v6, so I'd rather it not be in
net/ipv4/compat.c. I didn't try without CONFIG_INET, -- will look
at that.

> > +struct compat_group_filter {
> > +       __u32                            gf_interface;
> > +       struct __kernel_sockaddr_storage gf_group
> > +               __attribute__ ((aligned(4)));
> > +       __u32                            gf_fmode;
> > +       __u32                            gf_numsrc;
> > +       struct __kernel_sockaddr_storage gf_slist[1]
> > +               __attribute__ ((aligned(4)));
> > +} __attribute__ ((packed));
> > +
> 
> include/linux/in.n.

        I don't understand this comment. If you're suggesting I
put these in an include file, I didn't because this is the only
file that uses them and I don't want them to be visible to any
other code. If you mean something else, please explain.

> 
> __copy_in_user().
> Maybe we can use __copy_in_user for u32?

        I'll look at it.

                                thanks!

                                        +-DLS


