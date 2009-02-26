From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Thu, 26 Feb 2009 15:57:41 -0500
Message-ID: <49A70245.9010405@hp.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6ED6D.3090508@hp.com> <7418.1235679608@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:12213 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbZBZU5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:57:47 -0500
In-Reply-To: <7418.1235679608@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Brian Haley <brian.haley@hp.com> wrote:
> 
>> Jay Vosburgh wrote:
>>>>>> 	I've been fooling with the disable_ipv6 sysctl, and one issue is
>>>>>> that, at least on the distro I'm testing on (SLES), it's not picked up
>>>>>> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
>>>>>> yet, although I haven't really checked).
>>>>> Correct, that's the problem.
>>>>>
>>>>> We could create a blocker bitmap.  Two sysctls, "block_af" and
>>>>> "unblock_af".  You write the AF_foo value for the protocol there and
>>>>> it sets or clears the assosciated bit in the internal blocker bitmap.
>>>>>
>>>>> Things like sys_socket() et al. key off of this.
>>>> I'm open to suggestions at this point in time, I just don't see how this
>>>> will solve the bonding problem since it still wouldn't load, right?
>>> 	It would permit users to load ipv6 (thus allowing bonding to
>>> load), but prevent ipv6 from actually doing anything.  (because
>>> sys_socket, e.g., won't open an ipv6 socket if block_af includes ipv6).
>> Right, but it doesn't help someone that changed /etc/modprobe.conf to have
>> "install ipv6 /bin/true" - they'll have to stop doing that.
> 

Hi Jay

> 	Yes.  There's no reasonable solution that won't require some
> change for users that have aliased out ipv6.
> 
>> I think changing ipv6 to support a disable_ipv6 module parameter like Vlad
>> suggested would work, as long as we're not worried about someone opening
>> an AF_INET6 socket - even if they do they won't get anywhere.  That, along
>> with the patch below to actually not add the addresses, would work (sorry
>> in advance for using an attachment).  I'll get started on that...
> 
> 	I agree that it would work, and could even be set up such that
> opening sockets doesn't work, either (if ipv6 never registered via
> sock_register, for example).  I'm sticking some on the opening sockets
> failure behavior because it's the current behavior if ipv6 is aliased
> out.  It just seems like a logical place for the permission denial to
> occur, rather than later, and is consistent with what happens if ipv6
> isn't loaded at all or is not configured in the kernel.
> 
> 	I still tend to like the bitmask to disable address family
> gizmo.  It's not specific to one particular protocol (although it would
> likely need a check in the protocols for things like addrconf).  As
> somebody pointed out, there are likely to be (if not now, then
> relatively soon) users somewhere that want to turn off ipv4 and run ipv6
> only.

Yes.  The bitmask to disable certain family can be useful, but it's orthogonal
the issue of IPv6 support.  As you said, it can be used to disable
any address family that user wishes.  The slight issue with this might
be, should the settings affect already create sockets?

I guess it comes down how many levels of control to do we want to provide.
Things that have been suggested so far:
	1) Global on/off switch (i.e module parameter)
	2) Per interface on/off switch (currently exists, but has bugs).
	3) Socket on/off switch (i.e blocker bitmask)

I think numbers 1 and 2 turn off the IPv6 protocol on the wire, while number
3 turns off the interface to the user.  The two can be done independent.

-vlad

> 
>> -Brian
>>
>>
>> --
>>
>> The disable_ipv6 knob was meant to be used for the kernel to disable IPv6
>> on an interface when DAD failed for the link-local address based on the
>> MAC, but we should also be able to administratively disable it on an
>> interface, or the entire system.  This patch fixes the per-interface
>> problem.
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index f8f76d6..90f2a81 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -603,6 +603,11 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
>> 		goto out2;
>> 	}
>>
>> +	if (idev->cnf.disable_ipv6) {
>> +		err = -EPERM;
>> +		goto out2;
>> +	}
>> +
>> 	write_lock(&addrconf_hash_lock);
>>
>> 	/* Ignore adding duplicate addresses on an interface */
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

