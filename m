From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 08 May 2007 17:33:56 +0800
Message-ID: <1178616837.3385.85.camel@debian.sh.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
	 <1178313748.7408.41.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	hadi@cyberus.ca, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20630 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934620AbXEHJdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 05:33:51 -0400
In-Reply-To: <1178313748.7408.41.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 23:22 +0200, Johannes Berg wrote:
> On Fri, 2007-05-04 at 13:43 -0700, Waskiewicz Jr, Peter P wrote:
> > If hardware exists that wants the granularity to
> > start/stop queues independent of each other and continue to have
> > traffic
> > flow, I really think it should be able to do that. 
> 
> Not much of an if there, I'm pretty sure at least some wireless hardware
> can do that. We've been watching this multiqueue stuff for a while now
> with some interest but haven't hashed out yet how we could use it.

Right.

Jamal, as you said, the wireless subsystem uses an interim workaround
(the extra netdev approach) to achieve hardware packets scheduling. But
with Peter's patch, the wireless stack doesn't need the workaround
anymore. This is the actual fix.


On Wed, 02 May 2007 08:43:49 -0400, jamal wrote:

> You feel the need to keep all the rings busy even when one is
> shutdown; I claim by having a synced up qdisc of the same scheduler 
> type you dont need to worry about that. Both approaches are correct;
> what iam proposing is many factors simpler.

Let me explain why this is not true for wireless. The wireless priority
happens in the MAC level. That is, packets priority not only compete
each other in the host, they also compete in the network. For example,
once the wireless medium becomes idle from busy, the higher priority
packet seizes the channel after waiting for a shorter time period (which
makes the channel unavailable again). Both the high and low priority
packets have to be queued in the hardware queues before they are sent
out so that the hardware knows how to kick off its timers when it
detects the medium is idle. If the Qdisc stops feeding all packets just
because the hardware low prio queue is full (as it cannot seize the
channel in the network), it is unfair to the local high prio packets.
The host is too "nice(2)" to NOT let local high prio packets complete
with the ones in the other hosts. BTW, you cannot write a smiliar
scheduler in the Qdisc since it requires hard real time in microsecond
level.

After a second thought, this is not wireless specific. It can be
generalized as hardware level packet scheduling. I think kernel needs
such kind of support. And Peter's patch address this well.

Thanks,
-yi

