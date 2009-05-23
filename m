From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed (and bonding)
Date: Sat, 23 May 2009 16:34:32 +0200
Message-ID: <20090523143432.GA2766@ami.dom.local>
References: <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local> <20090521074400.GA19113@francoudi.com> <20090521082805.GB2892@ami.dom.local> <1243075052.27210.22.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:40167 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbZEWOfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 10:35:13 -0400
Received: by bwz22 with SMTP id 22so2167106bwz.37
        for <netdev@vger.kernel.org>; Sat, 23 May 2009 07:35:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243075052.27210.22.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 01:37:32PM +0300, Vladimir Ivashchenko wrote:
> 
> > > > cls_flow, alas not enough documented. Here is some hint:
> > > > http://markmail.org/message/h24627xkrxyqxn4k
> > > 
> > > Can I balance only by destination IP using this approach? 
> > > Normal IP flow-based balancing is not good for me, I need 
> > > to ensure equality between destination hosts.
> > 
> > Yes, you need to use flow "dst" key, I guess. (tc filter add flow
> > help)
> 
> What is the number of DRR classes I need to create, a separate class for
> each host? I have around 20000 hosts.

One class per divisor.

> I figured out that WRR does what I want and its documented, so I'm using
> a 2.6.27 kernel with WRR now.

OK if it works for you.
 
> I was still hitting a wall with bonding. I played with a lot of
> combinations and could not find a way to make it scale to multiple
> cores. Cores which handle incoming traffic would get hit to 0-20% idle.
> 
> So, I got rid of bonding completely and instead configured PBR on Cisco
> + Linux routing in such a way so that packet gets received and
> transmitted using NICs connected to the same pair of cores with common
> cache. 65-70% idle on all cores now, compared to 0-30% idle in worst
> case scenarios before.

As a matter of fact I don't understand this bonding idea vs. smp: I
guess Eric Dumazet wrote why it's wrong wrt. locking. I'm not an smp
expert but I think the most efficient use is with separate NICs per
cpu (so with separate HTB qdiscs if possible), or multiqueue NICs -
but they would currently need a common HTB etc., so again a common
locking/cache problem.

> > - gso/tso or other non standard packets sizes - for exceeding the
> >   rate.
> 
> Just FYI, kernel 2.6.29.1, sub-classes with sfq divisor 1024, tso & gso
> off, netdevice.h and tc_core.c patches applied:
> 
> class htb 1:2 root rate 775000Kbit ceil 775000Kbit burst 98328b cburst
> 98328b
> Sent 64883444467 bytes 72261124 pkt (dropped 0, overlimits 0 requeues 0)
> rate 821332Kbit 112572pps backlog 0b 0p requeues 0
> lended: 21736738 borrowed: 0 giants: 0
> 
> In any case, exceeding the rate is not big of a problem for me.

Anyway, I'd be interested with the full tc -s class & qdisc report.

Thanks,
Jarek P.
