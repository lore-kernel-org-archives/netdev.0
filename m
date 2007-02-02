From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 02 Feb 2007 18:57:37 -0500
Message-ID: <45C3CFF1.3040600@hp.com>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <45C3ACE1.8010800@hp.com> <45C3B59A.6010802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>,
	sri@us.ibm.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:3056 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946156AbXBCAZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 19:25:30 -0500
In-Reply-To: <45C3B59A.6010802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vlad,

Vlad Yasevich wrote:
> Brian Haley wrote:
>> Hi Neil,
>>
>>> @@ -830,7 +836,8 @@ retry:
>>>      ift = !max_addresses ||
>>>            ipv6_count_addresses(idev) < max_addresses ?         
>>> ipv6_add_addr(idev, &addr, tmp_plen,
>>> -                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
>>> IFA_F_TEMPORARY) : NULL;
>>> +                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
>>> +                  IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> 
> Hi Brian
> 
>> So why are you always adding these as optimistic now?  Shouldn't this be
>> triggering off idev->cnf.optimistic_dad?  I know you're clearing it in
>> ipv6_add_addr(), but I liked Vlad's suggestion of not setting it
>> initially since this way seems backwards.
> 
> The troubling case seems to manually configured addresses (inet6_addr_add()).
> If we can clearly and easily distinguish between this case of address
> and all the other ones, then we can simply set the flag in ipv6_add_addr, like
> we set the tentative flag.

Right, I guess maybe I'm trying to figure out what 
idev->cnf.optimistic_dad means:

1. Interface supports OPTIMISTIC addresses
2. All auto-configured addresses on interface are OPTIMISTIC
3. ???

All other addresses are created w/out OPTIMISTIC set.

I think manually-configured addresses can be tagged as OPTIMISTIC just 
like MIPv6 Home Addresses are if we just change this line in 
inet6_rtm_newaddr():

< ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
--
 > ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS | 
IFA_F_OPTIMISTIC);

and tweak the rest of the code, but that doesn't cover the 
addrconf_add_ifaddr() codepath via ioctl(SIOCSIFADDR).

I can generate a patch based-on Neil's, but it will take me until Monday 
to get it out.

-Brian
