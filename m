From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Mon, 02 Mar 2009 14:11:07 -0800
Message-ID: <49AC597B.4090404@candelatech.com>
References: <49A4D5D5.5090602@trash.net>	<20090225061902.GA32430@gondor.apana.org.au>	<49A4E3F8.4050406@trash.net>	<49A4F0D7.20304@trash.net>	<20090225084321.GA1101@gondor.apana.org.au>	<m163ixk9t2.fsf@fess.ebiederm.org>	<20090226062257.GA11511@gondor.apana.org.au>	<m14oyhis31.fsf@fess.ebiederm.org>	<20090226084924.16cb3e08@nehalam>	<49A83063.2060600@candelatech.com> <20090227103812.14af52b3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33564 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbZCBWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:11:23 -0500
In-Reply-To: <20090227103812.14af52b3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 27 Feb 2009 10:26:43 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
>> Stephen Hemminger wrote:
>>
>>> Subject: [PATCH] Avoid race between network down and sysfs
>>>
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>
>>> --- a/net/core/net-sysfs.c	2009-02-26 08:36:18.000000000 -0800
>>> +++ b/net/core/net-sysfs.c	2009-02-26 08:37:51.000000000 -0800
>>> @@ -77,7 +77,9 @@ static ssize_t netdev_store(struct devic
>>>  	if (endp == buf)
>>>  		goto err;
>>>  
>>> -	rtnl_lock();
>>> +	if (!rtnl_trylock())
>>> +		return -ERESTARTSYS;
>>> +
>>>  	if (dev_isalive(net)) {
>>>  		if ((ret = (*set)(net, new)) == 0)
>>>  			ret = len;
>> I can test this to see if it fixes my problem.  Are the above lines the
>> entirety of the patch?
> 
> yes

With both of Stephen's patches included in the latest -rc6 source,
I re-ran the test and it seems to be working (I added printks so
that I would know the new code was being exercised)

I had 2000 or so mac-vlans configured, with 10 of them being
re-configured concurrently, while also deleting groups of 20-100
mac-vlans in my test.  This was locking up reliably before,
and now it seems to be working fine.

Here's the kernel log showing the ERESTARTSYS in action.  I don't
have an easy way to check to see if the VFS (or whatever) retried
the call properly, but will let you all know if I see any indication
that isn't working.

I only saw the ipv6 fixup in my logs, but maybe my test case just
doesn't hit the other...

Mar  2 13:37:41 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:37:41 simech-1 kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Mar  2 13:37:42 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:38:13 simech-1 kernel:last message repeated 42 times
Mar  2 13:39:20 simech-1 kernel:last message repeated 71 times
Mar  2 13:40:13 simech-1 kernel:last message repeated 68 times
Mar  2 13:40:13 simech-1 dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 8
Mar  2 13:40:13 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:40:21 simech-1 kernel:last message repeated 11 times
Mar  2 13:40:21 simech-1 dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 13
Mar  2 13:40:21 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:40:28 simech-1 kernel:last message repeated 16 times
Mar  2 13:40:28 simech-1 kernel: __ratelimit: 3352 callbacks suppressed
Mar  2 13:40:28 simech-1 kernel: Neighbour table overflow.
Mar  2 13:40:28 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:40:34 simech-1 kernel:last message repeated 8 times
Mar  2 13:40:34 simech-1 dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 20
Mar  2 13:40:34 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:40:54 simech-1 kernel:last message repeated 42 times
Mar  2 13:40:54 simech-1 dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 7
Mar  2 13:40:54 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:01 simech-1 kernel:last message repeated 13 times
Mar  2 13:41:01 simech-1 dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 13
Mar  2 13:41:01 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:14 simech-1 kernel:last message repeated 26 times
Mar  2 13:41:14 simech-1 dhclient: No DHCPOFFERS received.
Mar  2 13:41:14 simech-1 dhclient: No working leases in persistent database - sleeping.
Mar  2 13:41:15 simech-1 dhclient: receive_packet failed on eth1: Network is down
Mar  2 13:41:16 simech-1 kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Mar  2 13:41:17 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:24 simech-1 kernel:last message repeated 16 times
Mar  2 13:41:24 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:25 simech-1 kernel:last message repeated 8 times
Mar  2 13:41:25 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:30 simech-1 kernel:last message repeated 11 times
Mar  2 13:41:30 simech-1 kernel: __ratelimit: 7059 callbacks suppressed
Mar  2 13:41:30 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:30 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:30 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:35 simech-1 kernel:last message repeated 10 times
Mar  2 13:41:35 simech-1 kernel: __ratelimit: 7973 callbacks suppressed
Mar  2 13:41:35 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:36 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:36 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:40 simech-1 kernel:last message repeated 7 times
Mar  2 13:41:40 simech-1 kernel: __ratelimit: 10890 callbacks suppressed
Mar  2 13:41:40 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:40 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:40 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:46 simech-1 kernel:last message repeated 13 times
Mar  2 13:41:46 simech-1 kernel: __ratelimit: 6571 callbacks suppressed
Mar  2 13:41:46 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:46 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:46 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:51 simech-1 kernel:last message repeated 7 times
Mar  2 13:41:51 simech-1 kernel: __ratelimit: 15491 callbacks suppressed
Mar  2 13:41:51 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:51 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:51 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:41:56 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:56 simech-1 kernel: __ratelimit: 9658 callbacks suppressed
Mar  2 13:41:56 simech-1 kernel: Neighbour table overflow.
Mar  2 13:41:56 simech-1 kernel:last message repeated 9 times
Mar  2 13:41:56 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:42:01 simech-1 kernel:last message repeated 10 times
Mar  2 13:42:01 simech-1 kernel: __ratelimit: 12678 callbacks suppressed
Mar  2 13:42:01 simech-1 kernel: Neighbour table overflow.
Mar  2 13:42:01 simech-1 kernel:last message repeated 9 times
Mar  2 13:42:01 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:42:06 simech-1 kernel:last message repeated 7 times
Mar  2 13:42:06 simech-1 kernel: __ratelimit: 13401 callbacks suppressed
Mar  2 13:42:06 simech-1 kernel: Neighbour table overflow.
Mar  2 13:42:06 simech-1 kernel:last message repeated 9 times
Mar  2 13:42:06 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:42:11 simech-1 kernel:last message repeated 10 times
Mar  2 13:42:11 simech-1 kernel: __ratelimit: 11875 callbacks suppressed
Mar  2 13:42:11 simech-1 kernel: Neighbour table overflow.
Mar  2 13:42:11 simech-1 kernel:last message repeated 9 times
Mar  2 13:42:11 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.
Mar  2 13:42:16 simech-1 kernel:last message repeated 9 times
Mar  2 13:42:16 simech-1 kernel: __ratelimit: 9362 callbacks suppressed
Mar  2 13:42:16 simech-1 kernel: Neighbour table overflow.
Mar  2 13:42:17 simech-1 kernel:last message repeated 9 times
Mar  2 13:42:17 simech-1 kernel: Returning ERESTARTSYS in ipv6-addrconf-fixup-forwarding to avoid deadlock.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

