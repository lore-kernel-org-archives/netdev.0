From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Sat, 3 Feb 2007 10:05:36 -0500
Message-ID: <20070203150536.GB32659@hmsreliant.homelinux.net>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <45C3ACE1.8010800@hp.com> <45C3B59A.6010802@hp.com> <45C3CFF1.3040600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>,
	sri@us.ibm.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3120 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946230AbXBCPN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Feb 2007 10:13:26 -0500
Content-Disposition: inline
In-Reply-To: <45C3CFF1.3040600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 02, 2007 at 06:57:37PM -0500, Brian Haley wrote:
> Hi Vlad,
> 
> Vlad Yasevich wrote:
> >Brian Haley wrote:
> >>Hi Neil,
> >>
> >>>@@ -830,7 +836,8 @@ retry:
> >>>     ift = !max_addresses ||
> >>>           ipv6_count_addresses(idev) < max_addresses ?         
> >>>ipv6_add_addr(idev, &addr, tmp_plen,
> >>>-                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
> >>>IFA_F_TEMPORARY) : NULL;
> >>>+                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
> >>>+                  IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> >
> >Hi Brian
> >
> >>So why are you always adding these as optimistic now?  Shouldn't this be
> >>triggering off idev->cnf.optimistic_dad?  I know you're clearing it in
> >>ipv6_add_addr(), but I liked Vlad's suggestion of not setting it
> >>initially since this way seems backwards.
> >
> >The troubling case seems to manually configured addresses 
> >(inet6_addr_add()).
> >If we can clearly and easily distinguish between this case of address
> >and all the other ones, then we can simply set the flag in ipv6_add_addr, 
> >like
> >we set the tentative flag.
> 
> Right, I guess maybe I'm trying to figure out what 
> idev->cnf.optimistic_dad means:
> 
> 1. Interface supports OPTIMISTIC addresses
> 2. All auto-configured addresses on interface are OPTIMISTIC
> 3. ???
> 
The flag means that the interface supports optimistic DAD for all addresses
which are eligible to take advantage of RFC 4429.  As Vlad mentioned manually
configured addresses are excluded from that set.

> All other addresses are created w/out OPTIMISTIC set.
> 
> I think manually-configured addresses can be tagged as OPTIMISTIC just 
> like MIPv6 Home Addresses are if we just change this line in 
> inet6_rtm_newaddr():
> 
> < ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
> --
> > ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS | 
> IFA_F_OPTIMISTIC);
> 
> and tweak the rest of the code, but that doesn't cover the 
> addrconf_add_ifaddr() codepath via ioctl(SIOCSIFADDR).
> 
> I can generate a patch based-on Neil's, but it will take me until Monday 
> to get it out.
> 
Please, if you think you can find a way for us to do optimistic dad flags as
opt-in, rather than masked out, I'm all for it.  Thanks!
Neil

> -Brian
