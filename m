From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Mon, 30 Apr 2007 08:56:10 -0400
Message-ID: <1177937770.7027.61.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902BCE1E4@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:26043 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423228AbXD3M4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 08:56:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1521420wxd
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 05:56:17 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902BCE1E4@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-27-04 at 08:45 -0700, Waskiewicz Jr, Peter P wrote:
> > On Thu, 2007-26-04 at 09:30 -0700, Waskiewicz Jr, Peter P wrote:


> I agree, that to be fair for discussing the code that you should look at
> the patches before drawing conclusions.  
> I appreciate the fact you have
> a different idea for your approach for multiqueue, but without having
> specific things to discuss in terms of implementation, I'm at a loss for
> what you want to see done.  These patches have been released in the
> community for a few months now, and the general approach has been
> accepted for the most part.
> 

Sorry, I (was too busy with real work and) wasnt keeping up with netdev.
And stop whining please if you want me to comment; that is such an
important part of the network subsystem - so your patches need more
scrutiny because their impact is huge. And i know that subsystem enough
that i dont need to look at your patches to know you are going to be hit
by a big truck (by just observing you are crossing a busy highway on
foot).

> That being said, my approach was to provide an API for drivers to
> implement multiqueue support.  We originally went with an idea to do the
> multiqueue support in the driver.  

That is certainly one (brute) approach. This way you meet the
requirement of not changing anything on the qdisc level (user or kernel
level). But i am not sure you need an "API" perse.
 
> However, many questions came up that
> were answered by pulling things into the qdisc / netdev layer.
> Specifically, if all the multiqueue code is in the driver, how would you
> ensure one flow of traffic (say on queue 0) doesn't interfere with
> another flow (say on queue 1)?  If queue 1 on your NIC ran out of
> descriptors, the driver will set dev->queue_lock to __LINK_STATE_XOFF,
> which will cause all entry points into the scheduler to stop (i.e. - no
> more packets going to the NIC).  That will also shut down queue 0.  As
> soon as that happens, that is not multiqueue network support.  The other
> question was how to classify traffic.  We're proposing to use tc filters
> to do it, since the user has control over that; having flexibility to
> meet different network needs is a plus.  We had tried doing queue
> selection in the driver, and it killed performance.  Hence why we pulled
> it into the qdisc layer.

at some point when my thinking was evolving, I had similar thoughts
crossing my mind, but came to the conclusion i was thinking too hard
when i started (until i started to look/think about the OLPC mesh
network challenge).

Lets take baby steps so we can make this a meaningful discussion.
Ignore wireless for a second and talk just about simple wired
interfaces; we can then come back to wireless in a later discussion.

For the first baby steps, lets look at strict prio which if i am not
mistaken is what you e1000 NICs support; but even that were not the
case, strict prio covers a huge amount of multi-queue capability. 
For simplicity, lets pick something with just 2 hardware queues; PH and
PL (PH stands for High Prio and PL low prio). With me so far?

I am making the assumptions that: 
a) you understand the basics of strict prio scheduling
b) You have configured strict prio in the qdisc level and the hardware
levels to be synced i.e if your hardware is capable of only strict prio,
then you better use a matching strict prio qdisc (and not another qdisc
like HTB etc). If your hardware is capable 2 queues, you better have
your qdisc with only two bands.
c) If you programmed a TOS, DSCP , IEEE 802.1p to go to qdisc queue PH
via some classifier, then you will make sure that packets from qdisc
PH end up in hardware queue PH.

Not following #b and #c means it is a misconfiguration; i hope we can
agree on that. i.e you need to have both the exact qdisc that maps to
your hardware qdisc as well as synced configuration between the two
layers.

Ok, so you ask when to shut down the hw tx path?
1) Lets say you had so many PH packets coming into the hardware PH and
that causes the PH-ring to fill up. At that point you shutdown the hw-tx
path. So what are the consequences? none - newer PH packets still come
in and queue at the qdisc level. Newer PL packets? who cares PH is more
important - so they can rot in qdisc level...
2) Lets say you had so many PL packets coming into the hardware PL and
that causes the PL-ring to fill up. At that point you shutdown the hw-tx
path. So what are the consequences? none - newer PH packets still come
in and queue at the qdisc level; the PL packets causing the tx path to
shut down can be considered to be "already sent to the wire".
And if there was any PH packets to begin with, the qdisc PL packets
would never have been able to shut down the PL-ring.

So what am i saying?
You dont need to touch the qdisc code in the kernel. You just need to
instrument a mapping between qdisc-queues and hw-rings. i.e
You need to meet #b and #c above.
Both #b and #c are provable via queueing and feedback control theory. 
Since you said you like implementation and you are coming to OLS (which
i stopped attending last 2 years), visit the ottawa canals not far from
the venue of OLS. Watch how they open the different cascaded gates to
allow the boats in. It is the same engineering challenge as you are
trying to solve here.

I showed 2 queus in a strict prio setup, you can show N queues for that
scheduler. You can then extend it to other schedulers, both work and
non-work conserving.

If what i said above is coherent, come back with a counter example/use
case or we can discuss a different scheduler of your choice.

cheers,
jamal

