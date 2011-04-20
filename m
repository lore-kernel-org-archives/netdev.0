From: Patrick McHardy <kaber@trash.net>
Subject: Re: A patch you wrote some time ago (aka: "[patch 41/54] ICMP: Fix
 icmp_errors_use_inbound_ifaddr sysctl")
Date: Wed, 20 Apr 2011 10:24:04 +0200
Message-ID: <4DAE9824.10802@trash.net>
References: <20110419165411.GO9569@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexander Hoogerhuis <alexh@boxed.no>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110419165411.GO9569@sequoia.sous-sol.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.04.2011 18:54, Chris Wright wrote:
> * Alexander Hoogerhuis (alexh@boxed.no) wrote:
>> I hope you (or anyone else) can spare half a minute to have a quick
>> look at a patch you wrote a few years ago:
>>
>>> http://lkml.org/lkml/2007/6/8/124
> 
> I actually did not write that patch, rather added it to the -stable tree.
> Patrick (CCd) wrote it.

I actually only fixed it, it was added in 1c2fb7f9 by J. Simonetti
<jeroen@simonetti.nl>. Anyways ...

>> I've been tracking down a case of ICMP Redirects originating from
>> the wrong IPs, and as far I can tell, you patch is the last to touch
>> this code (net/ipv4/icmp.c:507):
>>
>>> if (rt->fl.iif && net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
>>>        dev = dev_get_by_index_rcu(net, rt->fl.iif);
>>>
>>> if (dev)
>>>        saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
>>> else
>>>        saddr = 0;
>>
>> In a plain world this would work, but I have come across a case that
>> seems to be not handled by this.
>>
>> I have two machines set up with VRRP to act as routers out of a
>> subnet, and they have IPs x.x.x.13/28 and x.x.x.14/28, with VRRP
>> holding on to x.x.x.1/28.
>>
>> If a node in x.x.x.0/28 needs to get a ICMP redirect from x.x.x.1/28
>> (to reach another subnet behind a  different gateway in x.x.x.0/28),
>> then the source IP on the ICMP redirect is chosen as the primary IP
>> on the interface that the packet arrived at.
>>
>> This is as far as I can tell from RFCs and colleagues fine for most
>> things after you're routed one hop or more, but in the case of ICMP
>> redirect it means that the redirect is not adhered to by the client,
>> as it will get the reidrect from x.x.x.13/28, not x.x.x.1/28.
>>
>> inet_select_addr seems to be explicitly looking for the primary IP
>> in all cases (./net/ipv4/devinet.c:875), and in the case of sending
>> ICMP recdirect when in an VRRP setup, that would not work well. It
>> should try to match the actual inbound IP.

>From what I understand, its explicitly meant to behave this way.
This is what the original commit stated:

    The new behaviour (when the sysctl variable is toggled on), it will send
    the message with the ip of the interface that received the packet that
    caused the icmp error. This is the behaviour network administrators will
    expect from a router. It makes debugging complicated network layouts
    much easier. Also, all 'vendor routers' I know of have the later
    behaviour.

>> Judging by the comments from your patch I am not sure if the source
>> IP that triggers the ICMP redirect is available at this point any
>> more.
>>
>> The way I understand it should pick adress is this way:
>>
>>>  if (rt->fl.iif && net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
>>>         dev = dev_get_by_index_rcu(net, rt->fl.iif);
>>>
>>> if (dev == fl.iif)
>>>         saddr = iph->daddr;
>>>
>>> if (dev != fl.iif)
>>>         saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
>>> else
>>>         saddr = 0;
>>
>> I.e. if we are replying to something that is from a local network
>> segment, then iph->daddr would be a more correct source. My C skill
>> is prehistoric so what I've written likely is far from correct, but
>> the general gist is that there is a special case for replying to
>> something local.

That might be a possibility to fix this for your case. But I'm
wondering why you're turning this on at all and not have routing
decide the correct source address?
