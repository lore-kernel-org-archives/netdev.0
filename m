From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v2 1/2] i40e: remove
 superfluous I40E_DEBUG_USER statement
Date: Fri, 23 Sep 2016 19:48:42 -0700
Message-ID: <CAKgT0UfxYzn1uqHLU+=7V4=NnYQX8rxLosxLg4Orsg_qEpGTKw@mail.gmail.com>
References: <1474637458-5255-1-git-send-email-sassmann@kpanic.de> <1474637458-5255-2-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Stefan Assmann <sassmann@kpanic.de>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36048 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcIXCso (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 22:48:44 -0400
Received: by mail-it0-f66.google.com with SMTP id n143so1997805ita.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 19:48:43 -0700 (PDT)
In-Reply-To: <1474637458-5255-2-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 6:30 AM, Stefan Assmann <sassmann@kpanic.de> wrote:
> This debug statement is confusing and never set in the code. Any debug
> output should be guarded by the proper I40E_DEBUG_* statement which can
> be enabled via the debug module parameter or ethtool.
> Remove or convert the I40E_DEBUG_USER cases to I40E_DEBUG_INIT.
>
> v2: re-add setting the debug_mask in i40e_set_msglevel() so that the
> debug level can still be altered via ethtool msglvl.
>
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_common.c  |  3 ---
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  6 -----
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  3 +--
>  drivers/net/ethernet/intel/i40e/i40e_main.c    | 35 +++++++++++++-------------
>  drivers/net/ethernet/intel/i40e/i40e_type.h    |  2 --
>  5 files changed, 18 insertions(+), 31 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index 2154a34..8ccb09c 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -3207,9 +3207,6 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
>                         break;
>                 case I40E_AQ_CAP_ID_MSIX:
>                         p->num_msix_vectors = number;
> -                       i40e_debug(hw, I40E_DEBUG_INIT,
> -                                  "HW Capability: MSIX vector count = %d\n",
> -                                  p->num_msix_vectors);
>                         break;
>                 case I40E_AQ_CAP_ID_VF_MSIX:
>                         p->num_msix_vectors_vf = number;

I'm assuming this is dropped because you considered it redundant with
the dump in i40e_get_capabilities.  If so it would have been nice to
see this called out in your patch description somewhere as it doesn't
jive with the rest of the patch since you are stripping something that
is using I40E_DEBUG_INIT.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> index 05cf9a7..e9c6f1c 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> @@ -1210,12 +1210,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>                 u32 level;
>                 cnt = sscanf(&cmd_buf[10], "%i", &level);
>                 if (cnt) {
> -                       if (I40E_DEBUG_USER & level) {
> -                               pf->hw.debug_mask = level;
> -                               dev_info(&pf->pdev->dev,
> -                                        "set hw.debug_mask = 0x%08x\n",
> -                                        pf->hw.debug_mask);
> -                       }
>                         pf->msg_enable = level;
>                         dev_info(&pf->pdev->dev, "set msg_enable = 0x%08x\n",
>                                  pf->msg_enable);

>From what I can tell the interface is completely redundant as ethtool
can already do this.  I'd say it is okay to just remove this command
and section entirely from the debugfs interface.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index 1835186..02f55ab 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -987,8 +987,7 @@ static void i40e_set_msglevel(struct net_device *netdev, u32 data)
>         struct i40e_netdev_priv *np = netdev_priv(netdev);
>         struct i40e_pf *pf = np->vsi->back;
>
> -       if (I40E_DEBUG_USER & data)
> -               pf->hw.debug_mask = data;
> +       pf->hw.debug_mask = data;
>         pf->msg_enable = data;
>  }
>

So the way I view this is that I40E_DEBUG_USER appears to be a flag
that is being used to differentiate between some proprietary flags and
the standard msg level.  The problem is that msg_enable and debug_mask
are playing off of two completely different bit definitions.  For
example how much sense does it make for NETIF_F_MSG_TX_DONE to map to
I40E_DEBUG_DCB.  If anything what should probably happen here is
instead of dropping the if there probably needs to be an else.

This is one of many things on my list of items to fix since I have
come back to Intel.  It is just a matter of finding the time.
Basically what I would really prefer to see here is us move all of the
flags in i40e_debug_mask so that we didn't have any overlap with the
NETIF_F_MSG_* flags unless there is a relation between the two.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 61b0fc4..56369761 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -6665,16 +6665,19 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
>                 }
>         } while (err);
>
> -       if (pf->hw.debug_mask & I40E_DEBUG_USER)
> -               dev_info(&pf->pdev->dev,
> -                        "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
> -                        pf->hw.pf_id, pf->hw.func_caps.num_vfs,
> -                        pf->hw.func_caps.num_msix_vectors,
> -                        pf->hw.func_caps.num_msix_vectors_vf,
> -                        pf->hw.func_caps.fd_filters_guaranteed,
> -                        pf->hw.func_caps.fd_filters_best_effort,
> -                        pf->hw.func_caps.num_tx_qp,
> -                        pf->hw.func_caps.num_vsis);
> +       i40e_debug(&pf->hw, I40E_DEBUG_INIT,
> +                  "HW Capabilities: PF-id[%d] num_vfs=%d, msix_pf=%d, msix_vf=%d\n",
> +                  pf->hw.pf_id,
> +                  pf->hw.func_caps.num_vfs,
> +                  pf->hw.func_caps.num_msix_vectors,
> +                  pf->hw.func_caps.num_msix_vectors_vf);
> +       i40e_debug(&pf->hw, I40E_DEBUG_INIT,
> +                  "HW Capabilities: PF-id[%d] fd_g=%d, fd_b=%d, pf_max_qp=%d num_vsis=%d\n",
> +                  pf->hw.pf_id,
> +                  pf->hw.func_caps.fd_filters_guaranteed,
> +                  pf->hw.func_caps.fd_filters_best_effort,
> +                  pf->hw.func_caps.num_tx_qp,
> +                  pf->hw.func_caps.num_vsis);
>
>  #define DEF_NUM_VSI (1 + (pf->hw.func_caps.fcoe ? 1 : 0) \
>                        + pf->hw.func_caps.num_vfs)

I'd say don't bother with this.  There isn't any point.

> @@ -8495,14 +8498,10 @@ static int i40e_sw_init(struct i40e_pf *pf)
>         int err = 0;
>         int size;
>
> -       pf->msg_enable = netif_msg_init(I40E_DEFAULT_MSG_ENABLE,
> -                               (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK));
> -       if (debug != -1 && debug != I40E_DEFAULT_MSG_ENABLE) {
> -               if (I40E_DEBUG_USER & debug)
> -                       pf->hw.debug_mask = debug;
> -               pf->msg_enable = netif_msg_init((debug & ~I40E_DEBUG_USER),
> -                                               I40E_DEFAULT_MSG_ENABLE);
> -       }
> +       pf->msg_enable = netif_msg_init(debug,
> +                                       NETIF_MSG_DRV    |
> +                                       NETIF_MSG_PROBE  |
> +                                       NETIF_MSG_LINK);
>
>         /* Set default capability flags */
>         pf->flags = I40E_FLAG_RX_CSUM_ENABLED |

Okay so I think I now see why there is confusion about how debug is
used.  The documentation in the driver is wrong for how it worked.  It
wasn't being passed as a 0-16, somebody implemented this as a 32 bit
bitmask.  So the question becomes how to fix it.  The problem is with
the patch as it is so far we end up with pf->msg_enable being
populated but pf->hw.debug_mask never being populated.  The values you
are passing as the default don't make any sense either since they
don't really map to the same functionality in I40e.  They map to
DEBUG_INIT, DEBUG_RELEASE, and an unused bit.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
> index bd5f13b..7e88e35 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_type.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
> @@ -85,8 +85,6 @@ enum i40e_debug_mask {
>         I40E_DEBUG_AQ_COMMAND           = 0x06000000,
>         I40E_DEBUG_AQ                   = 0x0F000000,
>
> -       I40E_DEBUG_USER                 = 0xF0000000,
> -
>         I40E_DEBUG_ALL                  = 0xFFFFFFFF
>  };
>

This end piece is where the problem really lies.  The problem
statement for this would essentially be that the i40e driver uses the
debug module parameter in a non-standard way.  It is using a tg3 style
bitmask to populate the fields, but then documenting it and coding
part of it like it is expecting the default debug usage.  To top it
off it is doing the same kind of nonsense with the ethtool msg level
interface.

The one piece we probably need with all this in order to really "fix"
the issue and still maintain some sense of functionality would be to
look at adding something that would populate pf->hw.debug_mask.  I'm
half tempted to say that we could try adding another module parameter
named i40e_debug that we could use like tg3 does with tg3_debug and
change the debugfs interface to only modify that instead of messing
with the msg level, but the fact is that would probably just be more
confusing.  For now what I would suggest doing is just splitting
msg_enable and pf->hw.debug_mask and for now just default the value of
pf->hw.debug_mask to I40E_DEFAULT_MSG_ENABLE.  That way in a week or
two after netdev/netconf we will hopefully had a chance to hash this
all out and can find a better way to solve this.

- Alex
