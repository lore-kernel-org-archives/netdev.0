From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/4] [next-queue]net: i40e: Add
 infrastructure for queue channel support with the TCs and queue
 configurations offloaded via mqprio scheduler
Date: Wed, 24 May 2017 14:45:41 -0700
Message-ID: <CAKgT0UdLNrnjuYxmrkD8V5N0V8gXMGLzGnaq-rRV_g0nE5HTJw@mail.gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
 <149524190808.11022.3222127507844771494.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32771 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032096AbdEXVpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:45:43 -0400
Received: by mail-io0-f195.google.com with SMTP id m4so19400246ioe.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:45:43 -0700 (PDT)
In-Reply-To: <149524190808.11022.3222127507844771494.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 5:58 PM, Amritha Nambiar
<amritha.nambiar@intel.com> wrote:
> This patch sets up the infrastructure for offloading TCs and
> queue configurations to the hardware by creating HW channels(VSI).
> A new channel is created for each of the traffic class
> configuration offloaded via mqprio framework except for the first TC
> (TC0). TC0 for the main VSI is also reconfigured as per user provided
> queue parameters. Queue counts that are not power-of-2 are handled by
> reconfiguring RSS by reprogramming LUTs using the queue count value.
> This patch also handles configuring the TX rings for the channels,
> setting up the RX queue map for channel.
>
> Also, the channels so created are removed and all the queue
> configuration is set to default when the qdisc is detached from the
> root of the device.
>
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h      |   36 +
>  drivers/net/ethernet/intel/i40e/i40e_main.c |  740 +++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h |    2
>  3 files changed, 771 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 395ca94..0915b02 100644

[...]

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 8d1d3b85..e1bea45 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c

[...]

> +/**
> + * i40e_create_queue_channel - function to create channel
> + * @vsi: VSI to be configured
> + * @ch: ptr to channel (it contains channel specific params)
> + *
> + * This function creates channel (VSI) using num_queues specified by user,
> + * reconfigs RSS if needed.
> + **/
> +int i40e_create_queue_channel(struct i40e_vsi *vsi,
> +                             struct i40e_channel *ch)
> +{
> +       struct i40e_pf *pf = vsi->back;
> +       bool reconfig_rss;
> +       int err;
> +
> +       if (!ch)
> +               return -EINVAL;
> +
> +       if (!ch->num_queue_pairs) {
> +               dev_err(&pf->pdev->dev, "Invalid num_queues requested: %d\n",
> +                       ch->num_queue_pairs);
> +               return -EINVAL;
> +       }
> +
> +       /* validate user requested num_queues for channel */
> +       err = i40e_validate_num_queues(pf, ch->num_queue_pairs, vsi,
> +                                      &reconfig_rss);
> +       if (err) {
> +               dev_info(&pf->pdev->dev, "Failed to validate num_queues (%d)\n",
> +                        ch->num_queue_pairs);
> +               return -EINVAL;
> +       }
> +
> +       /* By default we are in VEPA mode, if this is the first VF/VMDq
> +        * VSI to be added switch to VEB mode.
> +        */
> +       if ((!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) ||
> +           (!i40e_is_any_channel(vsi))) {
> +               if (!is_power_of_2(vsi->tc_config.tc_info[0].qcount)) {
> +                       dev_info(&pf->pdev->dev,
> +                                "Failed to create channel. Override queues (%u) not power of 2\n",
> +                                vsi->tc_config.tc_info[0].qcount);
> +                       return -EINVAL;
> +               }
> +
> +               if (vsi->type == I40E_VSI_SRIOV) {
> +                       if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
> +                               dev_info(&pf->pdev->dev,
> +                                        "Expected to be VEB mode by this time\n");
> +                               return -EINVAL;
> +                       }
> +               }
> +               if (!(pf->flags & I40E_FLAG_VEB_MODE_ENABLED)) {
> +                       pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
> +
> +                       if (vsi->type == I40E_VSI_MAIN) {
> +                               if (pf->flags & I40E_FLAG_TC_MQPRIO)
> +                                       i40e_do_reset(pf,
> +                                       BIT_ULL(__I40E_PF_RESET_REQUESTED),
> +                                                     true);
> +                               else
> +                                       i40e_do_reset_safe(pf,
> +                                       BIT_ULL(__I40E_PF_RESET_REQUESTED));

So these BIT_ULL lines are triggering a check in checkpatch, and I
have to say I don't really like this as it really is messed up in
terms of formatting.

If nothing else you might want to look at defining a macro that
replaces the line. That way you could still represent the same data
without having to resort to misaligning things to make it under 80
characters.
