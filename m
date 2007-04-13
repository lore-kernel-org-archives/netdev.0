From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [UPDATED] Multiqueue network device support
 implementation.
Date: Fri, 13 Apr 2007 04:19:42 +0200
Message-ID: <461EE8BE.7070507@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902A46CB8@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752992AbXDMCTy@vger.kernel.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902A46CB8@orsmsx414.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Still leaks the device
> 
> 
> I explained this in a previous response, and you seemed to be ok with
> the explanation.  Can you elaborate if this is still an issue?


I'm OK with allocating subqueues even for single queue devices, not
with leaking memory on error.

>>I stand by my point, this needs to be explicitly enabled by 
>>the user since it changes the behaviour of prio on multiqueue 
>>capable device.
> 
> 
> The user can enable this by using TC filters. I do understand what you
> mean that PRIO's behavior somewhat changes because of how the queues
> turn off and on, but how is this different than today?  Today, if the
> queue on the NIC shuts down, all the PRIO queues are down.


Right. And if the queue is enabled again, bands continue to be dequeued
in strict priority order.

> This way
> it's actually helping get traffic out.  I don't see how the user can
> control which queue is shut down; that is a function of how congested
> the network is.  So if I can clarify what you're saying, are you asking
> that the user actually setup the band to queue mapping?  Because if so,
> I don't see how that would help since queues today don't have any
> priority, and you would have no control which one stops over another
> one.


No, I'm asking that the users explicitly states that he wants the driver
to control which bands are dequeued (by stopping and starting subqueues)
and not the established strict priority order. You assume everyone using
prio on e1000 wants to use multiple HW queues, which is not necessarily
true. Additionally the prio qdisc might be used as child of a classful
qdisc that assumes it can always dequeue packets as long as q.qlen > 0
(HFSC for example will complain if it can't since that is a
configuration error).

So I'm asking that you only enable this behaviour if the user does
something like this:

tc qdisc add dev eth0 root handle 1: prio bands N multiqueue

Ideally the band2queue mapping would be supplied by userspace as well,
but currently that doesn't seem to be possible in a clean way since
userspace has no way of finding out how many queues the HW supports.
