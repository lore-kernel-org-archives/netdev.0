From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] if_bridge: fix conflict with glibc
Date: Wed, 10 Dec 2014 15:57:45 -0800
Message-ID: <20141210155745.3d375230@urahara>
References: <20141209203007.188651df@urahara>
	<20141209.234954.1634249639621060084.davem@davemloft.net>
	<20141209214122.76b15851@urahara>
	<20141210.133417.152985082992875227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregory.0xf0@gmail.com, f.fainelli@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34947 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073AbaLJX5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 18:57:55 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so3790194pdj.13
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 15:57:55 -0800 (PST)
In-Reply-To: <20141210.133417.152985082992875227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Dec 2014 13:34:17 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 9 Dec 2014 21:41:22 -0800
> 
> > Even though kernel and glibc headers have same effective values
> > Gcc complains about redefinitions. Since this is a header expected
> > to be used by userspace, use glibc header.
> > 
> > This supersedes change in commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7
> > and fixes build of iproute2 with Glibc-2.19. This follows similar usage
> > in include/uapi/linux for l2tp.h
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > --- a/include/uapi/linux/if_bridge.h	2014-12-09 20:25:21.656016605 -0800
> > +++ b/include/uapi/linux/if_bridge.h	2014-12-09 21:32:01.391034756 -0800
> > @@ -15,7 +15,9 @@
> >  
> >  #include <linux/types.h>
> >  #include <linux/if_ether.h>
> > -#include <linux/in6.h>
> > +#ifndef __KERNEL__
> > +#include <netinet/in.h>
> > +#endif
> 
> No, we really want to incluse the linux/in6.h header, as that's where all
> the special GLIBC CPP checks are, such as:
> 
> #if __UAPI_DEF_IN6_ADDR_ALT
> 
> Please research how we have resolved the conflict between GLIBC and the
> kernel's exported headers.  We really need to use linux/in6.h for all of
> this to work.
> 
> I understand that it is upsetting that iproute2 stopped building for you,
> but I'd like to kindly ask that you look more deeply into this and think
> more longer term, rather than having a knee jerk reaction and looking for
> quick fixes.

I don't have the time to understand the intricacies of glibc headers.
The problem is that Gcc warns about duplicate definitions in headers;
this is a useful warning and not something that I want to disable.
Hacks with #undef seem to be heading the wrong way.
