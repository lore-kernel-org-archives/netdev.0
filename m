From: Patrick McHardy <kaber@trash.net>
Subject: Re: -j MARK in raw vs. mangle (was Re: xfrm by MARK: tcp problems
 when mark for in and out differ)
Date: Fri, 15 Oct 2010 09:04:11 +0200
Message-ID: <4CB7FCEB.5070804@trash.net>
References: <201010141616.58795.lists@egidy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201010141616.58795.lists@egidy.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.10.2010 16:16, Gerd v. Egidy wrote:
> Hi Jamal,
> 
> thanks for your help.
> 
>>> So it seems like the fl->mark is never initialized with the packet mark
>>> in the first place. What would be the correct stage in the kernel
>>> network stack to do that?
>>
>> Can you try a simple setup without xfrm/ipsec and see if this reverse
>> path works? Was there a kernel where it worked?
> 
> I just tried opening a simple tcp connection without any xfrm or other weird 
> stuff. I just had one iptables rule in place:
> 
> -t raw -A OUTPUT -d 192.168.5.200 -j MARK --set-mark 99
> 
> 192.168.5.200 is the other system I open the tcp connection from. So this 
> should mark all response packets to the client.
> 
> But the moment __xfrm_lookup is called (this is where my debug printk sits), 
> fl->mark is always 0.
> 
> By chance I changed the rule over to the mangle table:
> 
> -t mangle -A OUTPUT -d 192.168.5.200 -j MARK --set-mark 99
> 
> Now it works, the mark in the flow is 99!
> 
> So it seems this has nothing to do with xfrm, but that the MARK target has 
> different effects when used in raw than in mangle. I was using raw because I 
> had to set conntrack zones too and it was more conveniant to do both in one 
> place.
> 
> Can one of the netfilter guys comment on this? Is using MARK in raw not fully 
> supported or has known deficiencies?

No, the problem is most likely that for outgoing packets, the XFRM
lookup is done with the route lookup before the packet is even sent,
so once it hits the raw or mangle table, it is too late. mangle however
performs rerouting when the mark value changes, at which point a new
XFRM lookup is performed.

