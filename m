From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 11 May 2007 09:58:01 +0800
Message-ID: <1178848682.3045.82.camel@debian.sh.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
	 <1178666902.4055.28.camel@localhost>
	 <1178766140.3045.24.camel@debian.sh.intel.com>
	 <1178800551.4074.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26229 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758119AbXEKB6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 21:58:00 -0400
In-Reply-To: <1178800551.4074.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-10 at 08:35 -0400, jamal wrote:
> So we may be agreeing then?
> In other words, if you had both low prio and high prio in WMM
> scheduler
> (in wireless hardware) then the station favors a higher priority
> packet
> over at low priority packet at ALL times.
> IOW:
> Given the default 802.11e AIFS, CWmin/max and PF (and TXOP) parameters
> used for the different WMM queues there is no way that a lower prio
> packet will ever be allowed to leave when it is competing with a
> higher
> prio packet. 
> This approach is what the strict prio qdisc already does. The slight
> difference is the prio qdisc is deterministic and the WMM is
> statistical
> (strict prio) in nature -  i.e there is a statiscal "luck" possibility
> (not design intent) for an lower prio packet to go out.
> 
> Does this make sense? 

Good, we agree on this. Now let's solve the problem.

When the low priority ring buffer is full in the hardware, will you
suppose the driver call netif_stop_queue() or not? In old ethernet, I
think the answer is yes because the packets in the ring buffer have to
be sent out anyway before there is room for the new packets. But in
wireless (or multiqueue devices), the high priority packets can be sent
out thru high ring buffer although the low ring buffer is full. This is
how wireless MAC differs where we agreed above.

To enable this, we need to manage the device queues separately, i.e.
netif_stop_subqueue() and the Qdisc dequeue methold is able to feed the
device with only high priority packets in the low ring full case.

I think it's possible to do all these changes in a specific Qdisc and
leave all the Qdisc APIs, netif_{start,stop}_queue(), etc untouched. But
it turns out to be what mac80211 QoS is right now. You also call it a
hack, right? I think Peter's patch resovle the problem in a generic way.
This avoids every multiqueue device creates its own Qdisc for doing its
work. Besides, it also duplicates a lot of common code.

Thanks,
-yi
