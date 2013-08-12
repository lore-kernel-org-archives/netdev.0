From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net] bnx2x: guard stats_pending with stats_lock in all cases
Date: Mon, 12 Aug 2013 23:52:46 +0300
Message-ID: <CAM8tLiPUO2EHMM7AZJrj=LfZqCBnpKMbHT9wWomBAp6v_18YYg@mail.gmail.com>
References: <1376334499-25192-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Havard Skinnemoen <hskinnemoen@google.com>,
	Sanjay Hortikar <horti@google.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:51632 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3HLUwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 16:52:47 -0400
Received: by mail-vc0-f182.google.com with SMTP id hf12so3171963vcb.41
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 13:52:47 -0700 (PDT)
In-Reply-To: <1376334499-25192-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 10:08 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> As 9bcb8018cf ("bnx2x: Fix the race on bp->stats_pending") noted, we
> can have a race on bp->stats_pending between the timer and a
> STATS_EVENT_LINK_UP event handler.
>
> But it seems we can also have the following two races on
> bp->stats_pending between the timer and a STATS_EVENT_STOP handler:
>
> Scenario A:
> -----------
>
> thread 1:  bnx2x_timer() thread in bnx2x_storm_stats_post():
>                 /* send FW stats ramrod */
>                 rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
>                                    U64_HI(bp->fw_stats_req_mapping),
>                                    U64_LO(bp->fw_stats_req_mapping),
>                                    NONE_CONNECTION_TYPE);
>                 if (rc == 0)
>
> thread 2: ethtool thread:
> bnx2x_stats_handle(bp, STATS_EVENT_STOP)
>   -> bnx2x_stats_stop()
>     -> bnx2x_storm_stats_update()
>         bp->stats_pending = 0;
>
> thread 1:  bnx2x_timer() thread in bnx2x_storm_stats_post():
>                         bp->stats_pending = 1;
>
> If the action interleaves in this way we end up with a
> bp->stats_pending value of 1 when there are no stats pending.
>
> Scenario B:
> -----------
> thread 1:  bnx2x_timer() thread in bnx2x_stats_update():
>                 if (bnx2x_storm_stats_update(bp)) {
>                         if (bp->stats_pending == 3) { // false
>                         reg1 = bp->stats_pending      // reg1=1
>
> thread 2: ethtool thread:
> bnx2x_stats_handle(bp, STATS_EVENT_STOP)
>   -> bnx2x_stats_stop()
>     -> bnx2x_storm_stats_update()
>         bp->stats_pending = 0;
>
> thread 1:  bnx2x_timer() thread in bnx2x_stats_update():
>                         reg1++                          // reg1=2
>                         bp->stats_pending = reg1;       // stats_pending=2
>                         return;
>
> If the action interleaves in this way we end up with a non-zero
> bp->stats_pending value when there are no stats pending.
>
> -----------
>
> These are suspected as possible contributors to occasional
> bnx2x_panic() dumps we see of the form:
>
>  storm stats were not updated for 3 times
>
> When these panic messages happen we see the NIC hang.
>
> The proposed fix is for all, not just some, of the reads and writes to
> stats_pending to be guarded by stats_lock. So now all accesses to
> stats_pending and stats_couner are guarded by stats_lock.
>
Neal, thanks for looking into this.

There's another race, where two flows
stats_update() and stats_start() may send two queries in parallel
which will cause FW to assert.

I'm preparing the set for net, which includes the fix  for this race
also(will be out in a couple of hours)

I will be more than happy if you will take a look.

Thanks
Dmitry


> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Vladislav Zolotarov <vladz@broadcom.com>
> Cc: Yaniv Rosner <yanivr@broadcom.com>
> Cc: Merav Sicron <meravs@broadcom.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Havard Skinnemoen <hskinnemoen@google.com>
> Cc: Sanjay Hortikar <horti@google.com>
> Change-Id: Ic389c4355ef4a3e01da8f1f4c2019e75dbb5ddf6
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 47 +++++++++++++----------
>  1 file changed, 27 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> index 98366ab..d72a630 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> @@ -123,16 +123,11 @@ static void bnx2x_dp_stats(struct bnx2x *bp)
>   */
>  static void bnx2x_storm_stats_post(struct bnx2x *bp)
>  {
> +       spin_lock_bh(&bp->stats_lock);
> +
>         if (!bp->stats_pending) {
>                 int rc;
>
> -               spin_lock_bh(&bp->stats_lock);
> -
> -               if (bp->stats_pending) {
> -                       spin_unlock_bh(&bp->stats_lock);
> -                       return;
> -               }
> -
>                 bp->fw_stats_req->hdr.drv_stats_counter =
>                         cpu_to_le16(bp->stats_counter++);
>
> @@ -151,8 +146,9 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
>                 if (rc == 0)
>                         bp->stats_pending = 1;
>
> -               spin_unlock_bh(&bp->stats_lock);
>         }
> +
> +       spin_unlock_bh(&bp->stats_lock);
>  }
>
>  static void bnx2x_hw_stats_post(struct bnx2x *bp)
> @@ -888,9 +884,7 @@ static int bnx2x_storm_stats_validate_counters(struct bnx2x *bp)
>         /* Make sure we use the value of the counter
>          * used for sending the last stats ramrod.
>          */
> -       spin_lock_bh(&bp->stats_lock);
>         cur_stats_counter = bp->stats_counter - 1;
> -       spin_unlock_bh(&bp->stats_lock);
>
>         /* are storm stats valid? */
>         if (le16_to_cpu(counters->xstats_counter) != cur_stats_counter) {
> @@ -923,7 +917,8 @@ static int bnx2x_storm_stats_validate_counters(struct bnx2x *bp)
>         return 0;
>  }
>
> -static int bnx2x_storm_stats_update(struct bnx2x *bp)
> +static int bnx2x_storm_stats_update(struct bnx2x *bp,
> +                                   bool track_pending)
>  {
>         struct tstorm_per_port_stats *tport =
>                                 &bp->fw_stats_data->port.tstorm_port_statistics;
> @@ -934,9 +929,24 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
>         struct bnx2x_eth_stats_old *estats_old = &bp->eth_stats_old;
>         int i;
>
> +       spin_lock_bh(&bp->stats_lock);
> +
>         /* vfs stat counter is managed by pf */
> -       if (IS_PF(bp) && bnx2x_storm_stats_validate_counters(bp))
> +       if (IS_PF(bp) && bnx2x_storm_stats_validate_counters(bp)) {
> +               bool pending_timeout = false;
> +
> +               if (track_pending && (bp->stats_pending++ == 3))
> +                       pending_timeout = true;
> +
> +               spin_unlock_bh(&bp->stats_lock);
> +
> +               if (pending_timeout) {
> +                       BNX2X_ERR("storm stats were not updated for 3 times\n");
> +                       bnx2x_panic();
> +               }
> +
>                 return -EAGAIN;
> +       }
>
>         estats->error_bytes_received_hi = 0;
>         estats->error_bytes_received_lo = 0;
> @@ -1118,6 +1128,8 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
>
>         bp->stats_pending = 0;
>
> +       spin_unlock_bh(&bp->stats_lock);
> +
>         return 0;
>  }
>
> @@ -1237,18 +1249,13 @@ static void bnx2x_stats_update(struct bnx2x *bp)
>                 if (bp->port.pmf)
>                         bnx2x_hw_stats_update(bp);
>
> -               if (bnx2x_storm_stats_update(bp)) {
> -                       if (bp->stats_pending++ == 3) {
> -                               BNX2X_ERR("storm stats were not updated for 3 times\n");
> -                               bnx2x_panic();
> -                       }
> +               if (bnx2x_storm_stats_update(bp, true))
>                         return;
> -               }
>         } else {
>                 /* vf doesn't collect HW statistics, and doesn't get completions
>                  * perform only update
>                  */
> -               bnx2x_storm_stats_update(bp);
> +               bnx2x_storm_stats_update(bp, false);
>         }
>
>         bnx2x_net_stats_update(bp);
> @@ -1337,7 +1344,7 @@ static void bnx2x_stats_stop(struct bnx2x *bp)
>         if (bp->port.pmf)
>                 update = (bnx2x_hw_stats_update(bp) == 0);
>
> -       update |= (bnx2x_storm_stats_update(bp) == 0);
> +       update |= (bnx2x_storm_stats_update(bp, false) == 0);
>
>         if (update) {
>                 bnx2x_net_stats_update(bp);
> --
> 1.8.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




-- 
Best regards,
Dmitry
