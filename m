From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: HTB accuracy for high speed (and bonding)
Date: Sat, 23 May 2009 13:37:32 +0300
Message-ID: <1243075052.27210.22.camel@hazard2.francoudi.com>
References: <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>
	 <1242688479.9558.60.camel@hazard2.francoudi.com>
	 <1242689267.11814.1.camel@hazard2.francoudi.com>
	 <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com>
	 <20090519201027.GA4751@ami.dom.local>
	 <1242857245.13519.17.camel@hazard2.francoudi.com>
	 <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local>
	 <20090521074400.GA19113@francoudi.com>
	 <20090521082805.GB2892@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:1240 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbZEWKhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 06:37:34 -0400
In-Reply-To: <20090521082805.GB2892@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > > cls_flow, alas not enough documented. Here is some hint:
> > > http://markmail.org/message/h24627xkrxyqxn4k
> > 
> > Can I balance only by destination IP using this approach? 
> > Normal IP flow-based balancing is not good for me, I need 
> > to ensure equality between destination hosts.
> 
> Yes, you need to use flow "dst" key, I guess. (tc filter add flow
> help)

What is the number of DRR classes I need to create, a separate class for
each host? I have around 20000 hosts.

I figured out that WRR does what I want and its documented, so I'm using
a 2.6.27 kernel with WRR now.

I was still hitting a wall with bonding. I played with a lot of
combinations and could not find a way to make it scale to multiple
cores. Cores which handle incoming traffic would get hit to 0-20% idle.

So, I got rid of bonding completely and instead configured PBR on Cisco
+ Linux routing in such a way so that packet gets received and
transmitted using NICs connected to the same pair of cores with common
cache. 65-70% idle on all cores now, compared to 0-30% idle in worst
case scenarios before.

> - gso/tso or other non standard packets sizes - for exceeding the
>   rate.

Just FYI, kernel 2.6.29.1, sub-classes with sfq divisor 1024, tso & gso
off, netdevice.h and tc_core.c patches applied:

class htb 1:2 root rate 775000Kbit ceil 775000Kbit burst 98328b cburst
98328b
Sent 64883444467 bytes 72261124 pkt (dropped 0, overlimits 0 requeues 0)
rate 821332Kbit 112572pps backlog 0b 0p requeues 0
lended: 21736738 borrowed: 0 giants: 0

In any case, exceeding the rate is not big of a problem for me.

Thanks a lot to everyone for their help.

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


