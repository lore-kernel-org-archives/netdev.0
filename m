From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Mon, 20 Apr 2015 14:48:56 +0200
Message-ID: <5534F5B8.1030405@ericsson.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com> <552F45AA.6010906@miraclelinux.com> <5530BE40.1000504@ericsson.com> <55346580.6060801@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:43036 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbbDTMtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 08:49:13 -0400
In-Reply-To: <55346580.6060801@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/20/2015 04:33 AM, YOSHIFUJI Hideaki wrote:
> Hi,
>
> Ulf Samuelsson wrote:
>>>   From RFC2461:
>>>
>>> |      REACHABLE   Roughly speaking, the neighbor is known to have been
>>> |                  reachable recently (within tens of seconds ago).
>>> :
>>> |      STALE       The neighbor is no longer known to be reachable but
>>> |                  until traffic is sent to the neighbor, no attempt
>>> |                  should be made to verify its reachability.
>>> |      DELAY       The neighbor is no longer known to be reachable, and
>>> |                  traffic has recently been sent to the neighbor.
>>> |                  Rather than probe the neighbor immediately, however,
>>> |                  delay sending probes for a short while in order to
>>> |                  give upper layer protocols a chance to provide
>>> |                  reachability confirmation.
>>>
>>>
>> It is all depending on the meaning of the word "recently".
>> You imply, that if timeouts have been triggered, then it is no longer "recent",
>> but that is not the only interpretation, it is up to the implementer to decide
>> what is "recently".
> That quoted text is just a "brief" description.  The document has detailed
> state machine.
>

It is not *mandatory* to follow the state machine strictly, Page 85:

    "This appendix contains a summary of the rules specified in Sections
    7.2 and 7.3.  This document does not mandate that implementations
    adhere to this model as long as their external behavior is consistent
    with that described in this document."

The kernel does not follow the state machine today.
The kernel already have a test which compares

     "neigh->used" + timeout with current time,
     and move the entry to DELAY.

This is not documented in the state machine so there is already
a precedent to compare

     "neigh->compared" + timeout with current time
     and move the entry into DELAY state.

Obviously, some people would not want you to send probes before going STALE,
so it needs to be configurable.
>> Therefore, if a timeout occurs due to no traffic, they must be probed before
>> they are garbage collected.
> It is what we do in PROBE state.
Yes, but you have to start by moving it into DELAY state first, to init 
the probe counter.
If you move the entry from REACHABLE to DELAY, then the probe counter
may be any value.

>
>> If this is not acceptable, how do you propose to solve the problem that you cannot
>> make remote units inaccessible for more than a fraction of a second?
> How many neighbors do you want to maintain?
> I guess you have to increase the number of gc_thresh1.
The current use cases have up to 2048 entries.
This is expected to grow in the future.
The 3.4 kernel used in the system today is limited to 1024,
but that has been raised to about 10k.

The gc_thresh1 test is not implemented in 3.4 but can be backported,
but still not convinced it is a good idea.

To complicate things, one requirement is that for some interfaces
you always want to keep things alive, if connected, but
for other interfaces you want things to be removed
to conserve memory.
Actually you would want to do this selection on a subnet level.

Internal discussions resulted in a proposal to change the patch,
so that you have a "keepalive" flag which is tested after
it has been decided to exit the REACHABLE state.

if the "keepalive" flag is set, you always go to DELAY state from REACHABLE.


Best Regards,
Ulf Samuelsson
