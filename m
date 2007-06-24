From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: Scaling Max IP address limitation
Date: Sun, 24 Jun 2007 17:51:33 -0400
Message-ID: <57B9EBB4-64D6-4836-BAD0-2A8C70579B60@mac.com>
References: <467EA7C1.4080006@rossove.com> <D6003DDE-0C36-437B-B70A-D422DFE153D0@mac.com> <Pine.LNX.4.64.0706242153240.11964@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: djones@rossove.com, LKML Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.186]:53694 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbXFXVvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 17:51:43 -0400
In-Reply-To: <Pine.LNX.4.64.0706242153240.11964@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jun 24, 2007, at 15:58:54, Jan Engelhardt wrote:
> On Jun 24 2007 15:08, Kyle Moffett wrote:
>> Do you really need that many IP addresses?  When somebody finally  
>> gets around to implementing REDIRECT support for ip6tables then  
>> you could just redirect them all to the same port on the local  
>> system.
>
> The way I see it, it's: "if someone gets around to implement *IPv6  
> NAT*" (which, if its designers were asked, is contrary to the idea  
> of ipv6).

I totally agree.  On the other hand, you need REDIRECT for things  
like transparent proxies which by definition aren't visible as  
anything other than a router or bridge.

>> Having routing table operations, IPsec transformations, etc just  
>> be another step in the firewall rules would also be useful.  It  
>> would be handy to be able to "-j ROUTE", then "-j IPSEC", then "-j  
>> ROUTE" again, to re-route the now-encapsulated IPsec packets to  
>> their proper destination.
> Absolutely...
>
>> That would also eliminate the sort-of-hacky problems with  
>> destination network interface in the bridging code:
>
> Where's the hack? iptables operates on what it sees, and it sees  
> br0.  The physdev match is justified IMO.

The problem is this:
I want to be able to filter bridged network traffic *both* based on  
the IP layer *and* the physical device it's going to be routed out.   
Due to fundamental problems with a statically-ordered architecture,  
it's impossible to get both, see commit  
68df071a201f06b08cdc07111c6d4af918e64edd (found here: http:// 
lists.netfilter.org/pipermail/netfilter-devel/2006-December/ 
026388.html).  Basically if you want such cross-layer hooks, right  
now your *ONLY* choice is to use marks with 2 drawbacks:  (1)  There  
are a very small number of marks which must be carefully allocated by  
your firewall-setup script  (2)  Marks are inherently extremely  
fragile for passing data between layers.

>> "-j BRIDGE" might be another step in the process, and conceivably  
>> you could have independent bridge MAC tables too.
>
> Whether a packet goes out a bridge (was that the intention of -j  
> BRIDGE?) is determined by the routing table, which, in most cases,  
> is just a matter of destination address.

No, the intent of "-j BRIDGE" would be _after_ "-j ROUTE" and some  
kind of "-j ARP", to actually compute which physical port a given  
packet should go.

>> That would also appear to get rid of the need for all tables other  
>> than
>> "filter" and all predefined chains other than "INPUT" and  
>> "OUTPUT".  Default
>> rules would be these:
>> nettables -A INPUT -j CONNTRACK
>> nettables -A INPUT -j LOCALMATCH
>> nettables -A INPUT --for-this-host -j ACCEPT
>> nettables -A INPUT -j OUTPUT
>
> I'd prefer if Linux outputted its packets by default :)

Well the problem is this:  Do you want the packet accepted locally or  
forwarded.  If forwarded, how do you want it routed, and which  
physical port do you want it to go out?  Without a statically-coded  
ordering for all those things there is no way to say what the  
"default" is.  You would need some way to switch between iptables/ 
ip6tables (for compatibility) and pkttables/nettables (for advanced  
functionality).

> But this idea may have its benefit: by not restricting rules to  
> certain positions like currently, throughput could be achieved.  
> "Evil packets" f.e. could be dropped really early. (Well, you could  
> also drop them early _today_, but a DROP in the mangle table will  
> everyone make their eyes roll

It does give you a million more ways to shoot yourself in the foot.   
Some things would have constraints like "output device must be  
set" (BRIDGE/ARP, for example).  If you accidentally stuck non- 
constrained things in the wrong order you could get totally-non-IP- 
compliant behavior.  On the other hand, it does give you many choices  
about IPsec before or after ROUTING (or after one routing step and  
before another), etc.

Cheers,
Kyle Moffett

