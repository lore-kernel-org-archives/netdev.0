From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 23:04:36 -0800
Message-ID: <45E67B04.2060702@linux-foundation.org>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>	<45E62C29.7010203@candelatech.com> <20070228195611.24cf19ee@deepthought> <45E650F6.4030404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58240 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932715AbXCAHEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 02:04:52 -0500
In-Reply-To: <45E650F6.4030404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Stephen Hemminger wrote:
>> On Wed, 28 Feb 2007 17:28:09 -0800
>> Ben Greear <greearb@candelatech.com> wrote:
>>
>>  
>>> Stephen Hemminger wrote:
>>>    
>>>> I was measuring bridging/routing performance and noticed this.
>>>>
>>>> The current code runs the "all packet" type handlers before calling
>>>> the bridge hook.  If an application (like some DHCP clients) is
>>>> using AF_PACKET, this means that each received packet gets run
>>>> through the Berkeley Packet Filter code in sk_run_filter (slow).
>>>>
>>>> By moving the bridging hook to run first, the packets flowing
>>>> through the bridge get filtered out there. This results in a 14%
>>>> improvement in performance, but it does mean that some snooping
>>>> applications would miss packets if being used on a bridge.  The
>>>> correct way to see all packets on a bridge is to set the bridge
>>>> pseudo-device to promiscuous mode.
>>>>       
>>> Seems it would be better to fix these clients to be more selective as
>>> to where they bind.
>>>     
>>
>> The problem is any use of BPF is a lose, if it has to be done to all
>> traffic.
>>   
> Right, but couldn't you have the dhcp client bind to eth0, eth7, and 
> br0 (ie, skipping the eth1-6 that comprise the bridge group?)
>
> The only difficulty I see is having the client know when new devices 
> come and go, but there are probably
> ways to know that without keeping a whole lot of state or probing the 
> /proc/net/dev (like my own bloated app does :))
>
> I envision the client args to be something like --skip-devices "eth1 
> eth2 eth3 ..."
>
> I know you can bind raw packet sockets to individual devices, though I 
> don't know much about BPF, so it's
> possible I'm wrong...
>
The kernel has to deal with busted applications all the time. And each 
damn distro and configuration
seems to invent it's own new way of doing network configuration. If an 
normal application has
to use something like raw packet filtering, it seems there is a missing 
API.


>>> This breaks the case where you want to see packets on a particular
>>> interface, not just the entire bridge, right?
>>>     
>>
>> It might be possible to use promisc counter to handle this.
>>   
> Not really, it's perfectly valid to sniff a port in non-promiscuous 
> mode...
>
The non-promiscuous mode packets still make it in through the normal 
receive path.
The only packets that don't make up the stack are those that are being 
bridged.

