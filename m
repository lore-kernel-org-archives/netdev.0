From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Wed, 15 Apr 2015 15:40:29 +0200
Message-ID: <552E6A4D.7040600@ericsson.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:45772 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbbDONkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 09:40:33 -0400
In-Reply-To: <5527892D.4020608@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No reply on this....

in net/core/neighbour.c: neigh_timer_handler I see:

     if (state & NUD_REACHABLE) {
         if (time_before_eq(now,
                    neigh->confirmed + neigh->parms->reachable_time)) {
             neigh_dbg(2, "neigh %p is still alive\n", neigh);
             next = neigh->confirmed + neigh->parms->reachable_time;
         } else if (time_before_eq(now,
                       neigh->used +
                       NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME))) {
             neigh_dbg(2, "neigh %p is delayed\n", neigh);
             neigh->nud_state = NUD_DELAY;
             neigh->updated = jiffies;
             neigh_suspect(neigh);
             next = now + NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME);
         } else {
             neigh_dbg(2, "neigh %p is suspected\n", neigh);
             neigh->nud_state = NUD_STALE;
             neigh->updated = jiffies;
             neigh_suspect(neigh);
             notify = 1;
         }
     } else ...

Why is the second test there in the first place?

In the normal case, "neigh->used" does not get updated until the entry 
is found STALE
in the periodic work.

Why not use "neigh->confirmed" and another sysctl variable?

     if (state & NUD_REACHABLE) {
         if (time_before_eq(now,
                    neigh->confirmed + neigh->parms->reachable_time)) {
             neigh_dbg(2, "neigh %p is still alive\n", neigh);
             next = neigh->confirmed + neigh->parms->reachable_time;
         } else if (time_before_eq(now,
-                     neigh->used +
-                      NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME))) {
+                    neigh->confirmed +
+                     NEIGH_VAR(neigh->parms, DELAY_REPROBE_TIME))) {
             neigh_dbg(2, "neigh %p is delayed\n", neigh);
             neigh->nud_state = NUD_DELAY;
             neigh->updated = jiffies;
             neigh_suspect(neigh);
             next = now + NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME);
         } else {
             neigh_dbg(2, "neigh %p is suspected\n", neigh);
             neigh->nud_state = NUD_STALE;
             neigh->updated = jiffies;
             neigh_suspect(neigh);
             notify = 1;
         }
     } else ...

if DELAY_REPROBE_TIME is larger than "reachable_time", then
     the kernel will send out ARP probes when it is about
     to lose communication with a remote machine.
     This is what we need.

If it is smaller, then
     it will go from REACHABLE to STALE.

The initial value of DELAY_REPROBE_TIME needs to be settable in Kconfig
to allow the selection of functionality.

I am told that setting stuff using sysctl has a performance penalty, when
interfaces are dynamically created and deleted in hundreds.

Best Regards,
Ulf Samuelsson
  

On 04/10/2015 10:26 AM, Ulf Samuelsson wrote:
>
> On 03/12/2015 07:26 PM, David Miller wrote:
>> I hate changes like this.
>>
>> By making this a Kconfig options it cannot be dynamic, and every
>> distribution is going to have to scratch their head and decide
>> what to set this to.
>>
>> That's seriously suboptimal.
>>
>> If you want to change behavior based upon whether userspace is
>> managing the damn table, make it so the user doing so has to
>> ask for the new behavior at _RUN TIME_ via the netlink interface
>> or similar.
>>
>> Picking the guard time itself at compile time is also undesirable.
>>
>> And you don't even want a damn timer, what you want is for the
>> state of the entry to be frozen and for the user to "release"
>> it by either adjusting the state to something else or marking
>> in some other way to allow it to be unfrozen and released again.
>>
>> Why put it to chance with some timeout?  Make things explicit.
>
> The desired functionality is that if communication stops,
> you want to send out ARP probes, before the entry is deleted.
>
> The current (pseudo) code of the neigh timer is:
>
>     if (state & NUD_REACHABLE) {
>         if (now <= "confirmed + "reachable_time")) {
>                     ... /* We are OK */
>         } else if (now < "used" + DELAY_PROBE_TIME) {    /* Never 
> happens */
>                     state = NUD_DELAY;
>         } else {
>             state = NUD_STALE;
>             notify = 1;
>         }
>
> We never see the state beeing changed from REACHABLE to DELAY,
> so the probes are not beeing sent out, instead you always go
> from REACHABLE to STALE.
>
> DELAY_PROBE_TIME is set to (5 x HZ) and "used"
> seems to be only set by the periodic_work routine
> when the neigh entry is in STALE state, and then it is too late.
> It is also set by "arp_find" which is used by "broken" devices.
>
> In practice, the second condition: "(now < "used" + DELAY_PROBE_TIME)" 
> is never used.
> What is the intention of this test?
>
> By adding a new test + parameter, we would get the desired functionality,
> and no need to listen for notifications or doing ARP state updates 
> from applications.
>
>         if (now <= "confirmed + "reachable_time")) {
>                     ... /* We are OK */
> +        else if (now <= "confirmed + "reprobe_time")) {
> +                   state <= NUD_DELAY;
>         } else if (now < "used" + DELAY_PROBE_TIME))) {    /* Never 
> happens */
>                     state <= NUD_DELAY;
>         } else {
>             state = NUD_STALE;
>             notify = 1;
>         }
>
> This way the entry would remain in REACHABLE while normal 
> communication occurs,
> then it would enter DELAY state to probe, and if that fails, it goes 
> to STALE state.
>
> Alternatively, we just change the second test:
>         if (now <= "confirmed + "reachable_time")) {
>                     ... /* We are OK */
> -        } else if (now < "used" + DELAY_PROBE_TIME))) {    /* Never 
> happens */
> +       } else if (now < "confirmed" + DELAY_PROBE_TIME))) {
>                     state <= NUD_DELAY;
>         } else {
>             state = NUD_STALE;
>             notify = 1;
>         }
>
>
> The  DELAY_PROBE_TIME, should preferrably be a kernel Kconfig parameter.
>
> Best Regards,
> Ulf Samuelsson
>
>
>> I'm not applying this patch.
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
