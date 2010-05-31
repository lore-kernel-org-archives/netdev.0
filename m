From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Mon, 31 May 2010 22:12:59 +0300
Message-ID: <1275333179.11744.23.camel@powerslave>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
	 <1275024304.3754.45.camel@powerslave>
	 <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>
	 <1275040724.24490.121.camel@chilepepper>  <4C03DCF3.1080001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Jan Engelhardt <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:28926 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701Ab0EaTUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 15:20:00 -0400
In-Reply-To: <4C03DCF3.1080001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-31 at 17:59 +0200, ext Patrick McHardy wrote:
> Luciano Coelho wrote:
> > On Fri, 2010-05-28 at 10:05 +0200, ext Jan Engelhardt wrote:
> >> On Friday 2010-05-28 07:25, Luciano Coelho wrote:
> >>> Do you have any other suggestion on how I can associate the rules to
> >>> specific interfaces?
> >> -A INPUT -i foo -j do
> >> -A do -j idletimer
> >>
> >> A little funny, but actually this would allow me to keep a timer
> >> for a group of interfaces rather than just per-if.
> > 
> > Yes, this is what our userspace apps are doing.  I've formulated my
> > question in an unclear way.  If you check the rest of the code, I create
> > sysfs files under the interface's directory and use it as an attribute
> > to notify the userspace when the timer has expired.
> > 
> > In short, I need to figure out a way to associate each rule with an
> > interface in sysfs, so I can notify the userspace when the timer has
> > expired.  I couldn't figure out another way to do it.  Any suggestions?
> 
> How about just using an arbitrary user-supplied name? People can
> name them after interfaces, or anything else.

I considered this option, but then I didn't find a proper place where to
include the attribute in sysfs, since I cannot add it as part of the
interface (eg. /sys/class/net/wlan0/idletimer) as I was doing before.
The other option would be to make the idletimer as part of the
xt_IDLETIMER module object in sysfs
(ie. /sys/module/xt_IDLETIMER/<user_supplied_name>), but it looks out of
place.  And I think adding it as /sys/class/net/idletimer is most likely
out of the question.

The latest "solution" I came up with, is to associate the idletimer with
every interface that it hits.  Whenever a packet arrives, I check which
interface it came from and add the timer to it (eg.
in /sys/class/net/wlan0/idletimer if the packet came via wlan0).  This
causes a bit extra processing per packet, but in most cases there
shouldn't be too many interfaces in the list, so the search should be
fairly quick.  And if performance becomes a problem, it can be worked
around by adding only one interface per ruleset, so the list will never
grow bigger than one node.

I think these two solutions would work.  I prefer the second one,
because we don't need to add the idletimer attribute in an artificial
place in sysfs.

The problem that remains with either solution is if the interface is
already idle when the rule created.  In that case, the timer won't start
(or at least will not be associated with that interface).  It will only
start when the first packet hits.  The only solution I see for this is
to add the interface name as an option to the target.  Maybe something
like "--autostart=wlan0"?

I'll send a new RFC patch soon with this ideas implemented, to better
express what I mean (C code can be easier to read than English :P)


-- 
Cheers,
Luca.

