From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 18:13:40 -0400
Message-ID: <1181168020.4064.46.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:40909 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757135AbXFFWNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:13:44 -0400
Received: by py-out-1112.google.com with SMTP id a29so533494pyi
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 15:13:43 -0700 (PDT)
In-Reply-To: <4666CEB7.6030804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 17:11 +0200, Patrick McHardy wrote:

> I haven't followed the entire discussion, but I still don't see a
> alternative to touching the qdisc layer - multiple hardware queues
> need multiple queue states if you want to avoid a busy hardware
> queue stopping the qdisc entirely 

If you start with the above premise then ...

> and thereby preventing the qdisc
> to continue feeding packets to other active HW queues. And to make
> use of the multiple queue states you need multiple queues.

.... you will logically lead to the above conclusion. 

[Which of course leads to the complexity (and not optimizing for the
common - which is single ring NICs)].

The problem is the premise is _innacurate_.
Since you havent followed the discussion, i will try to be brief (which
is hard).
If you want verbosity it is in my previous emails:

Consider a simple example of strict prio qdisc which is mirror
configuration of a specific hardware. 
Then for sake of discussion, assume two prio queues in the qdisc - PSL
and PSH and two hardware queues/rings in a NIC which does strict prio
with queues PHL and PHH.
The mapping is as follows:
PSL --- maps to --- PHL
PSH --- maps to --- PHH

Assume the PxH has a higher prio than PxL.
Strict prio will always favor H over L.

Two scenarios:
a) a lot of packets for PSL arriving on the stack.
They only get sent from PSL -> PHL if and only if there are no
packets from PSH->PHH.
b)a lot of packets for PSH arriving from the stack.
They will always be favored over PSL in sending to the hardware.

>From the above:
The only way PHL will ever shutdown the path to the hardware is when
there are sufficient PHL packets.
Corrollary,
The only way PSL will ever shutdown the path to the hardware is when
there are _NO_ PSH packets.

So there is no need to do per queue control because the schedule will
ensure things work out fine as long as what you have the correct qdisc;
and it is a qdisc that will work just fine with a single ring with zero
mods.
What you need is a driver API to ask it to select the ring given an
index. This is similar to the qdisc filter used to select a queue.

You can extend the use case i described above to N queues. You can
extend it to other schedulers (WRR or any non-work conserving queues)
etc. It is consistent. Of course if you configure CBQ for a hardware
that does strict prio - that is a misconfig etc.

Infact for the wired case i see little value (there is some) in using
multiple rings. In the case of wireless (which is strict prio based) it
provides more value.

> I would love to see your alternative patches.

>From the above you can see they are simple. I am working on a couple of
things (batching and recovering pktgen ipsec patches)- I will work on
those patches soon after.

Iam actually not against the subqueue control - i know Peter needs it
for certain hardware; i am just against the mucking around of the common
case (single ring NIC) just to get that working. 
 
cheers,
jamal

