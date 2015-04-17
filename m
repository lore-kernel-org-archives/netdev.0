From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Fri, 17 Apr 2015 10:03:12 +0200
Message-ID: <5530BE40.1000504@ericsson.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com> <552F45AA.6010906@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:60285 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbbDQIDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 04:03:18 -0400
In-Reply-To: <552F45AA.6010906@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/16/2015 07:16 AM, YOSHIFUJI Hideaki wrote:
> Hi,
>
> Ulf Samuelsson wrote:
>
>> The desired functionality is that if communication stops,
>> you want to send out ARP probes, before the entry is deleted.
>>
>> The current (pseudo) code of the neigh timer is:
>>
>>      if (state & NUD_REACHABLE) {
>>          if (now <= "confirmed + "reachable_time")) {
>>                      ... /* We are OK */
>>          } else if (now < "used" + DELAY_PROBE_TIME) {    /* Never happens */
>>                      state = NUD_DELAY;
>>          } else {
>>              state = NUD_STALE;
>>              notify = 1;
>>          }
>>
>> We never see the state beeing changed from REACHABLE to DELAY,
>> so the probes are not beeing sent out, instead you always go
>> from REACHABLE to STALE.
> That's right.
But not acceptable, in telecom.
>
>
>> DELAY_PROBE_TIME is set to (5 x HZ) and "used"
>> seems to be only set by the periodic_work routine
>> when the neigh entry is in STALE state, and then it is too late.
>> It is also set by "arp_find" which is used by "broken" devices.
>>
> In STALE state, neigh->used is set by neigh_event_send(), called
> by neigh_resolve_output() via neigh->output().



>> In practice, the second condition: "(now < "used" + DELAY_PROBE_TIME)" is never used.
>> What is the intention of this test?
> That's right.  It is NOT used in normal condition unless
> reachable time is too short.
>
>
>> By adding a new test + parameter, we would get the desired functionality,
>> and no need to listen for notifications or doing ARP state updates from applications.
>>
>>          if (now <= "confirmed + "reachable_time")) {
>>                      ... /* We are OK */
>> +        else if (now <= "confirmed + "reprobe_time")) {
>> +                   state <= NUD_DELAY;
>>          } else if (now < "used" + DELAY_PROBE_TIME))) {    /* Never happens */
>>                      state <= NUD_DELAY;
>>          } else {
>>              state = NUD_STALE;
>>              notify = 1;
>>          }
>>
>> This way the entry would remain in REACHABLE while normal communication occurs,
>> then it would enter DELAY state to probe, and if that fails, it goes to STALE state.
> No, it is not what REACHABLE and DELAY mean.
>
>  From RFC2461:
>
> |      REACHABLE   Roughly speaking, the neighbor is known to have been
> |                  reachable recently (within tens of seconds ago).
> :
> |      STALE       The neighbor is no longer known to be reachable but
> |                  until traffic is sent to the neighbor, no attempt
> |                  should be made to verify its reachability.
> |      DELAY       The neighbor is no longer known to be reachable, and
> |                  traffic has recently been sent to the neighbor.
> |                  Rather than probe the neighbor immediately, however,
> |                  delay sending probes for a short while in order to
> |                  give upper layer protocols a chance to provide
> |                  reachability confirmation.
>
>

It is all depending on the meaning of the word "recently".
You imply, that if timeouts have been triggered, then it is no longer 
"recent",
but that is not the only interpretation, it is up to the implementer to 
decide
what is "recently".

You can argue, that for REACHABLE they define it as "(within tens of 
seconds ago)",
but in a standards document, that is not enough,
so the definition of STALE is perfectly OK due to this ambiguity.

We have the situation in that machines enter and exit the network, at 
unpredictable times,
and while traffic is sporadic, they still need to be reachable.
They should not enter FAILED state unless they leave the network.

I see also in the RFC2461:
"To reduce unnecessary network traffic, probe messages are only sent to
neighbors to which the node is actively sending packets."

In telecom applications, as long as the neighbour is present on the network,
the node will be sending packets, even if it is not that frequent.

These probes are *neccessary* for the system to work properly,
due to the long time for garbage collection.

The PROBE state need to be entered once, and only when these probes get 
no answer,
the entry should move into STALE.
I think that is compliant with the statement above.

Since they leave at unpredictable times, it is not good to set them to 
PERMANENT.

Therefore, if a timeout occurs due to no traffic, they must be probed before
they are garbage collected.

If this is not acceptable, how do you propose to solve the problem that 
you cannot
make remote units inaccessible for more than a fraction of a second?


Best Regards,
Ulf Samuelsson
