From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] Better handling of transition to NUD_PROBE state
Date: Wed, 20 May 2015 12:42:26 +0900
Message-ID: <CAKD1Yr1F2_Mb=ioW4Y89ZKJTGGDm3sQU9vc=4RWELWCHGgKAGA@mail.gmail.com>
References: <1431945881-14707-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34654 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbbETDmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 23:42:47 -0400
Received: by oiko83 with SMTP id o83so26713160oik.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 20:42:47 -0700 (PDT)
In-Reply-To: <1431945881-14707-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 7:44 PM, Erik Kline <ek@google.com> wrote:
> [1] When entering NUD_PROBE state via neigh_update(), perhaps received
>     from userspace, correctly (re)initialize the probes count to zero.
>
>     This is useful for forcing revalidation of a neighbor (for example
>     if the host is attempting to do DNA [IPv4 4436, IPv6 6059]).
>
> [2] Notify listeners when a neighbor goes into NUD_PROBE state.
>
>     By sending notifications on entry to NUD_PROBE state listeners get
>     more timely warnings of imminent connectivity issues.
>
>     The current notifications on entry to NUD_STALE have somewhat
>     limited usefulness: NUD_STALE is a perfectly normal state, as is
>     NUD_DELAY, whereas notifications on entry to NUD_FAILURE come after
>     a neighbor reachability problem has been confirmed (typically after
>     three probes).
>
> Signed-off-by: Erik Kline <ek@google.com>
> ---
>  net/core/neighbour.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3de6542..3a74df7 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -913,6 +913,7 @@ static void neigh_timer_handler(unsigned long arg)
>                         neigh->nud_state = NUD_PROBE;
>                         neigh->updated = jiffies;
>                         atomic_set(&neigh->probes, 0);
> +                       notify = 1;

+1. Currently, the code notifies when going from REACHABLE into STALE,
which is not necessarily something userspace might want to know about
(all it means is "we haven't sent any packets to this neighbour
recently"), but it doesn't notify when going into PROBE, which is a
more important event (it means "we've been sending this neighbour
packets for (by default) 5 seconds and we still haven't found out if
it's stilll there, so we're probing it").

>                         next = now + NEIGH_VAR(neigh->parms, RETRANS_TIME);
>                 }
>         } else {
> @@ -1144,6 +1145,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>
>         if (new != old) {
>                 neigh_del_timer(neigh);
> +               if (new & NUD_PROBE)
> +                       atomic_set(&neigh->probes, 0);

+1. The normal code path (from STALE to DELAY to PROBE) obviously
already sets the probes to 0. Userspace can put a neighbour into
NUD_PROBE to cause the kernel to probe it, but this only works (by
default) three times because the probe counter is never reset to 0. So
the first three times, the neighbour goes from (say) STALE to PROBE
and then back to REACHABLE (good), but then the fourth time, the
neighbour goes from STALE to PROBE and then immediately to FAILED.

>                 if (new & NUD_IN_TIMER)
>                         neigh_add_timer(neigh, (jiffies +
>                                                 ((new & NUD_REACHABLE) ?
> --
> 2.2.0.rc0.207.ga3a616c
>

Acked-By: Lorenzo Colitti <lorenzo@google.com>
