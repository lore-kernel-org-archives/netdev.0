From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Tue, 15 Sep 2009 15:57:19 -0700
Message-ID: <20090915155719.22bae41e@nehalam>
References: <20090914093128.4d709ff6@nehalam>
	<20090915081354.GA10037@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephan von Krawczynski <skraw@ithnet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60956 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbZIOW7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 18:59:24 -0400
In-Reply-To: <20090915081354.GA10037@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Sep 2009 08:13:55 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On 14-09-2009 18:31, Stephen Hemminger wrote:
> > On Mon, 14 Sep 2009 17:55:05 +0200
> > Stephan von Krawczynski <skraw@ithnet.com> wrote:
> > 
> >> On Mon, 14 Sep 2009 15:57:03 +0200
> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >>
> >>> Stephan von Krawczynski a A~(c)crit :
> >>>> Hello all,
> ...
> >>> rp_filter - INTEGER
> >>>         0 - No source validation.
> >>>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
> >>>             Each incoming packet is tested against the FIB and if the interface
> >>>             is not the best reverse path the packet check will fail.
> >>>             By default failed packets are discarded.
> >>>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
> >>>             Each incoming packet's source address is also tested against the FIB
> >>>             and if the source address is not reachable via any interface
> >>>             the packet check will fail.
> ...
> > RP filter did not work correctly in 2.6.30. The code added to to the loose
> > mode caused a bug; the rp_filter value was being computed as:
> >   rp_filter = interface_value & all_value;
> > So in order to get reverse path filter both would have to be set.
> > 
> > In 2.6.31 this was change to:
> >    rp_filter = max(interface_value, all_value);
> > 
> > This was the intended behaviour, if user asks all interfaces to have rp
> > filtering turned on, then set /proc/sys/net/ipv4/conf/all/rp_filter = 1
> > or to turn on just one interface, set it for just that interface.
> 
> Alas this max() formula handles also cases where both values are set
> and it doesn't look very natural/"user friendly" to me. Especially
> with something like this: all_value = 2; interface_value = 1
> Why would anybody care to bother with interface_value in such a case?
> 
> "All" suggests "default" in this context, so I'd rather expect
> something like:
>     rp_filter = interface_value ? : all_value;
> which gives "the inteded behaviour" too, plus more...
> 
> We'd only need to add e.g.:
>  0 - Default ("all") validation. (No source validation if "all" is 0).
>  3 - No source validation on this interface.

More values == more confusion.
I chose the maxconf() method to make rp_filter consistent with other
multi valued variables (arp_announce and arp_ignore).

--------
Subject: [PATCH] Document rp_filter behaviour

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/Documentation/networking/ip-sysctl.txt	2009-09-15 15:54:25.844934373 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2009-09-15 15:55:40.709205883 -0700
@@ -744,6 +744,8 @@ rp_filter - INTEGER
 	Default value is 0. Note that some distributions enable it
 	in startup scripts.
 
+	The max value from conf/{all,interface}/rp_filter is used.
+
 arp_filter - BOOLEAN
 	1 - Allows you to have multiple network interfaces on the same
 	subnet, and have the ARPs for each interface be answered







-- 
