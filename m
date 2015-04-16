From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Thu, 16 Apr 2015 14:16:26 +0900
Message-ID: <552F45AA.6010906@miraclelinux.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>, netdev@emagii.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:33784 "HELO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750971AbbDPFQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 01:16:30 -0400
Received: by mail-pa0-f44.google.com with SMTP id tp1so76452389pab.2
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 22:16:29 -0700 (PDT)
In-Reply-To: <5527892D.4020608@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf Samuelsson wrote:

> The desired functionality is that if communication stops,
> you want to send out ARP probes, before the entry is deleted.
> 
> The current (pseudo) code of the neigh timer is:
> 
>     if (state & NUD_REACHABLE) {
>         if (now <= "confirmed + "reachable_time")) {
>                     ... /* We are OK */
>         } else if (now < "used" + DELAY_PROBE_TIME) {    /* Never happens */
>                     state = NUD_DELAY;
>         } else {
>             state = NUD_STALE;
>             notify = 1;
>         }
> 
> We never see the state beeing changed from REACHABLE to DELAY,
> so the probes are not beeing sent out, instead you always go
> from REACHABLE to STALE.

That's right.


> DELAY_PROBE_TIME is set to (5 x HZ) and "used"
> seems to be only set by the periodic_work routine
> when the neigh entry is in STALE state, and then it is too late.
> It is also set by "arp_find" which is used by "broken" devices.
> 

In STALE state, neigh->used is set by neigh_event_send(), called
by neigh_resolve_output() via neigh->output().


> In practice, the second condition: "(now < "used" + DELAY_PROBE_TIME)" is never used.
> What is the intention of this test?

That's right.  It is NOT used in normal condition unless
reachable time is too short.


> 
> By adding a new test + parameter, we would get the desired functionality,
> and no need to listen for notifications or doing ARP state updates from applications.
> 
>         if (now <= "confirmed + "reachable_time")) {
>                     ... /* We are OK */
> +        else if (now <= "confirmed + "reprobe_time")) {
> +                   state <= NUD_DELAY;
>         } else if (now < "used" + DELAY_PROBE_TIME))) {    /* Never happens */
>                     state <= NUD_DELAY;
>         } else {
>             state = NUD_STALE;
>             notify = 1;
>         }
> 
> This way the entry would remain in REACHABLE while normal communication occurs,
> then it would enter DELAY state to probe, and if that fails, it goes to STALE state.

No, it is not what REACHABLE and DELAY mean.

>From RFC2461:

|      REACHABLE   Roughly speaking, the neighbor is known to have been
|                  reachable recently (within tens of seconds ago).
:
|      STALE       The neighbor is no longer known to be reachable but
|                  until traffic is sent to the neighbor, no attempt
|                  should be made to verify its reachability.
|      DELAY       The neighbor is no longer known to be reachable, and
|                  traffic has recently been sent to the neighbor.
|                  Rather than probe the neighbor immediately, however,
|                  delay sending probes for a short while in order to
|                  give upper layer protocols a chance to provide
|                  reachability confirmation.


-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
