From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Thu, 26 Feb 2009 14:59:31 -0500
Message-ID: <49A6F4A3.5060500@hp.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6ED6D.3090508@hp.com> <F613EEFD-2332-4C75-A486-73CDF2BAADDE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	tytso@mit.edu, Valdis.Kletnieks@vt.edu, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:12474 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbZBZT7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 14:59:36 -0500
In-Reply-To: <F613EEFD-2332-4C75-A486-73CDF2BAADDE@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> On Feb 26, 2009, at Feb 26, 2009, 2:28 PM, Brian Haley wrote:
>> Jay Vosburgh wrote:
>>>>>>     I've been fooling with the disable_ipv6 sysctl, and one issue is
>>>>>> that, at least on the distro I'm testing on (SLES), it's not
>>>>>> picked up
>>>>>> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't
>>>>>> loaded
>>>>>> yet, although I haven't really checked).
>>>>> Correct, that's the problem.
>>>>>
>>>>> We could create a blocker bitmap.  Two sysctls, "block_af" and
>>>>> "unblock_af".  You write the AF_foo value for the protocol there and
>>>>> it sets or clears the assosciated bit in the internal blocker bitmap.
>>>>>
>>>>> Things like sys_socket() et al. key off of this.
>>>> I'm open to suggestions at this point in time, I just don't see how
>>>> this
>>>> will solve the bonding problem since it still wouldn't load, right?
>>>     It would permit users to load ipv6 (thus allowing bonding to
>>> load), but prevent ipv6 from actually doing anything.  (because
>>> sys_socket, e.g., won't open an ipv6 socket if block_af includes ipv6).
>>
>> Right, but it doesn't help someone that changed /etc/modprobe.conf to
>> have "install ipv6 /bin/true" - they'll have to stop doing that.
>>
>> I think changing ipv6 to support a disable_ipv6 module parameter like
>> Vlad suggested would work, as long as we're not worried about someone
>> opening an AF_INET6 socket - even if they do they won't get anywhere.
> 
> In this case, if IPV6ONLY is set on an AF_INET6 listener, it should
> still get AF_INET traffic, correct?

No.  IPV6ONLY means just that, native IPv6 traffic only.  That socket
would sit idle.

-vlad

> 
>> That, along with the patch below to actually not add the addresses,
>> would work (sorry in advance for using an attachment).  I'll get
>> started on that...
>>
>> -Brian
>>
>>
>> -- 
>>
>> The disable_ipv6 knob was meant to be used for the kernel to disable
>> IPv6 on an interface when DAD failed for the link-local address based
>> on the MAC, but we should also be able to administratively disable it
>> on an interface, or the entire system.  This patch fixes the
>> per-interface problem.
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index f8f76d6..90f2a81 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -603,6 +603,11 @@ ipv6_add_addr(struct inet6_dev *idev, const
>> struct in6_addr *addr, int pfxlen,
>>         goto out2;
>>     }
>>
>> +    if (idev->cnf.disable_ipv6) {
>> +        err = -EPERM;
>> +        goto out2;
>> +    }
>> +
>>     write_lock(&addrconf_hash_lock);
>>
>>     /* Ignore adding duplicate addresses on an interface */
> 

