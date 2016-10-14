From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net 4/5] net/ncsi: Choose hot channel as active one if necessary
Date: Fri, 14 Oct 2016 16:32:36 +1030
Message-ID: <CACPK8XfPxORiE91uyNVivC9pw2dP+gnfzB5WUeGiGBKc-KTtEg@mail.gmail.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com> <1476413614-24586-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:34660 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755622AbcJNGD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:03:57 -0400
Received: by mail-vk0-f66.google.com with SMTP id 2so4584172vkb.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 23:02:57 -0700 (PDT)
In-Reply-To: <1476413614-24586-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 1:23 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> The issue was found on BCM5718 which has two NCSI channels in one
> package: C0 and C1. C0 is in link-up state while C1 is in link-down
> state. C0 is chosen as active channel until unplugging and plugging
> C0's cable:  On unplugging C0's cable, LSC (Link State Change) AEN
> packet received on C0 to report link-down event. After that, C1 is
> chosen as active channel. LSC AEN for link-up event is lost on C0
> when plugging C0's cable back. We lose the network even C0 is usable.

Why do we lose the LCS AEN packet?

Is this a bug in the BCM5718? If so, we shouldn't put it in the common
ncsi code without adding a quirk for that hardware.

>
> This resolves the issue by recording the (hot) channel that was ever
> chosen as active one. The hot channel is chosen to be active one
> if none of available channels in link-up state. With this, C0 is still
> the active one after unplugging C0's cable. LSC AEN packet received
> on C0 when plugging its cable back.
>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
>  net/ncsi/internal.h    |  1 +
>  net/ncsi/ncsi-manage.c | 22 +++++++++++++++++++---
>  2 files changed, 20 insertions(+), 3 deletions(-)
>
> diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
> index eac4858..1308a56 100644
> --- a/net/ncsi/internal.h
> +++ b/net/ncsi/internal.h
> @@ -265,6 +265,7 @@ struct ncsi_dev_priv {
>  #endif
>         unsigned int        package_num;     /* Number of packages         */
>         struct list_head    packages;        /* List of packages           */
> +       struct ncsi_channel *hot_channel;    /* Channel was ever active    */
>         struct ncsi_request requests[256];   /* Request table              */
>         unsigned int        request_id;      /* Last used request ID       */
>  #define NCSI_REQ_START_IDX     1
> diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
> index e959979..cccedcf 100644
> --- a/net/ncsi/ncsi-manage.c
> +++ b/net/ncsi/ncsi-manage.c
> @@ -625,6 +625,7 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
>         struct net_device *dev = nd->dev;
>         struct ncsi_package *np = ndp->active_package;
>         struct ncsi_channel *nc = ndp->active_channel;
> +       struct ncsi_channel *hot_nc = NULL;
>         struct ncsi_cmd_arg nca;
>         unsigned char index;
>         unsigned long flags;
> @@ -730,12 +731,20 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
>                 break;
>         case ncsi_dev_state_config_done:
>                 spin_lock_irqsave(&nc->lock, flags);
> -               if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1)
> +               if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
> +                       hot_nc = nc;
>                         nc->state = NCSI_CHANNEL_ACTIVE;
> -               else
> +               } else {
> +                       hot_nc = NULL;
>                         nc->state = NCSI_CHANNEL_INACTIVE;
> +               }
>                 spin_unlock_irqrestore(&nc->lock, flags);
>
> +               /* Update the hot channel */
> +               spin_lock_irqsave(&ndp->lock, flags);
> +               ndp->hot_channel = hot_nc;
> +               spin_unlock_irqrestore(&ndp->lock, flags);
> +
>                 ncsi_start_channel_monitor(nc);
>                 ncsi_process_next_channel(ndp);
>                 break;
> @@ -753,10 +762,14 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
>  static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
>  {
>         struct ncsi_package *np;
> -       struct ncsi_channel *nc, *found;
> +       struct ncsi_channel *nc, *found, *hot_nc;
>         struct ncsi_channel_mode *ncm;
>         unsigned long flags;
>
> +       spin_lock_irqsave(&ndp->lock, flags);
> +       hot_nc = ndp->hot_channel;
> +       spin_unlock_irqrestore(&ndp->lock, flags);
> +
>         /* The search is done once an inactive channel with up
>          * link is found.
>          */
> @@ -774,6 +787,9 @@ static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
>                         if (!found)
>                                 found = nc;
>
> +                       if (nc == hot_nc)
> +                               found = nc;
> +
>                         ncm = &nc->modes[NCSI_MODE_LINK];
>                         if (ncm->data[2] & 0x1) {
>                                 spin_unlock_irqrestore(&nc->lock, flags);
> --
> 2.1.0
>
