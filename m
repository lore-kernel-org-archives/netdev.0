From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Tue, 02 Apr 2013 09:46:43 +0800
Message-ID: <1364867203.17029.7.camel@cr0>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>
		<1364708625-29063-3-git-send-email-amwang@redhat.com>
	 <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
	 <20130401.130223.1527520446382659798.davem@davemloft.net>
	 <OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, stephen@networkplumber.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759037Ab3DBBtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Apr 2013 21:49:32 -0400
In-Reply-To: <OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 14:05 -0400, David Stevens wrote:
> David Miller <davem@davemloft.net> wrote on 04/01/2013 01:02:23 PM:
> 
> > 
> > People avoid using sockaddr because it gets defined both in the kernel
> > exported userland headers and the native libc ones with no easy
> > protection between the two to avoid getting a double definition error.
> > 
> > Once you start including kernel exported headers for things like these
> > network device specific interfaces, you potentially run into that issue.
> > 
> > Therefore I'd rather the subsystem define their own unique type both
> > to avoid this double definition problem and to allow easy extention
> > later.
> 
>         I guess, but in this case, I'm not saying it's like a sockaddr 
> with
> device-specific requirements. Rather, I'm saying it's exactly a sockaddr--
> it is either a sockaddr_in or a sockaddr_in6 and a family field to say
> which.
>         As is, any user/kernel include file conflicts (in the "ip" 
> command,
> presumably) are still present because he's using in6_addr, another 
> structure
> both in user and kernel space.
>         The primary multiple include issue here would be in the "ip" 
> command,
> presumably, but sockaddrs in particular have to agree between user and
> kernel space already and both appear with "ip".
>         This patch also has issues due to NOT copying other fields in the
> sockaddr_in6 structure (scope_id and port).
> 
>         Personally, I don't think it's too difficult to make correct code
> using sockaddr/sockaddr_in/sockaddr_in6 here, but even with a new type,
> the code within vxlan.c could (and I argue should) use something like:
> 
>        union {
>                struct sockaddr_in       vip_un_sin;
>                struct sockaddr_in6      vip_un_sin6;
>                struct sockaddr          vip_un_sa;
>        } vip_sun;
> 
> #define vip_sa  vip_sun.vip_un_sa
> #define vip_sin vip_sun.vip_un_sin
> #define vip_sin6        vip_sun.vip_un.sin6
> 
> and then code like:
> switch (vip->vip_sa.sa_family) {
> case AF_INET:
>         vip->vip_sin.sin_addr.s_addr = blah blah
>         break;
> case AF_INET6:
>         vip->vip_sin6.sin6_addr = blah blah
>         break;
> ...
> }
> 
> ...or whatever appropriate to the context and family.

Well, besides avoid redefining another type, what else could we gain by
using sockaddr_in6?

Look, we would have "vip->vip_sin.sin_addr.s_addr" instead of
"ipa->ip4", much longer than the current one...

So why defining a shorter and less complex struct matters?
