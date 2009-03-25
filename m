From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Wed, 25 Mar 2009 11:22:33 -0400
Message-ID: <49CA4C39.7020701@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, linux@kolla.no,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:25958 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbZCYPWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 11:22:38 -0400
In-Reply-To: <49C99315.6070504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich wrote:
> Brian Haley wrote:
>> This is the quick and easy patch to add autoconf and
>> disable_ipv6 module parameters to IPv6.  I don't think anything
>> more complicated is needed, assuming you play with the /etc
>> configuration files.
>>
>> For example, if you wanted to enable IPv6 just on 'lo' you
>> would:
>>
>> 1. Add "ipv6" to /etc/modules (if you don't, step #3 might fail)
>>
>> 2. Add this to /etc/modprobe.conf:
>>
>> 	options ipv6 disable_ipv6=1
>>
>> 3. Add these to /etc/sysctl.conf:
>>
>> 	net.ipv6.conf.all.disable_ipv6=0
>> 	net.ipv6.conf.lo.disable_ipv6=0
> 
> This is kind of confusing.  First you say, disable IPv6, then you say enable IPv6, but
> nothing happens.  Unless you typo-ed the 'all.disable_ipv6 = 0'...

Well, at least on my test system, this worked.  Loading the IPv6 module 
with disable_ipv6=1 sets the .all and .default (and all interfaces) to 
disable, then sysctl turns them back on selectively.  If you don't 
enable the .all.disable_ipv6 knob nothing will actually work - see the 
change in addrconf_prefix_rcv().  You still have to enable it on each 
interface for anything to happen.

> Also, it looks like if someone decides to switch IPv6 back on for a particular
> interface, they would have to wait until the next RA to get an address.  Not an
> optimum solution.

Yes, if someone later-on enables IPv6 on an interface they'll need to 
ifdown/ifup.

>> +	} else {
>> +		/* these will be inherited by all namespaces */
>> +		all->autoconf = dflt->autoconf = ipv6_defaults.autoconf;
>> +		all->disable_ipv6 = dflt->disable_ipv6 =
>> +			ipv6_defaults.disable_ipv6;
> 
> Why set 'all'?  Since no interfaces are created yet, setting dflt accomplishes
> what you want.

Yeah, that's probably not necessary, I assumed if the user passed the 
parameter and saw .all.foo different than .default.foo they might be 
confused.

-Brian
