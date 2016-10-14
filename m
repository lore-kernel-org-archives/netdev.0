From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net 2/5] net/ncsi: Split out logic for ncsi_dev_state_suspend_select
Date: Fri, 14 Oct 2016 16:32:22 +1030
Message-ID: <CACPK8Xe58OE=WKZWL16K33FsY0vXb+i47PNG+nLSdhwmCeWNGw@mail.gmail.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com> <1476413614-24586-3-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33093 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbcJNGSw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:18:52 -0400
Received: by mail-vk0-f65.google.com with SMTP id 83so3516465vkd.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 23:18:34 -0700 (PDT)
In-Reply-To: <1476413614-24586-3-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gavin,

On Fri, Oct 14, 2016 at 1:23 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> This splits out the code that handles ncsi_dev_state_suspend_select
> so that we can add more code to the handler in subsequent patch.
> Apart from adding a error tag to reuse the code in error path,
> no logical changes introduced.
>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
>  net/ncsi/ncsi-manage.c | 38 +++++++++++++++++++++++++-------------
>  1 file changed, 25 insertions(+), 13 deletions(-)
>
> diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
> index 1bc96dc..5758a26 100644
> --- a/net/ncsi/ncsi-manage.c
> +++ b/net/ncsi/ncsi-manage.c
> @@ -540,21 +540,30 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
>                 nd->state = ncsi_dev_state_suspend_select;
>                 /* Fall through */
>         case ncsi_dev_state_suspend_select:
> +               ndp->pending_req_num = 1;
> +
> +               nca.type = NCSI_PKT_CMD_SP;
> +               nca.package = np->id;
> +               nca.channel = NCSI_RESERVED_CHANNEL;
> +               if (ndp->flags & NCSI_DEV_HWA)
> +                       nca.bytes[0] = 0;
> +               else
> +                       nca.bytes[0] = 1;
> +
> +               nd->state = ncsi_dev_state_suspend_dcnt;
> +
> +               ret = ncsi_xmit_cmd(&nca);
> +               if (ret)
> +                       goto error;
> +
> +               break;
>         case ncsi_dev_state_suspend_dcnt:
>         case ncsi_dev_state_suspend_dc:
>         case ncsi_dev_state_suspend_deselect:
>                 ndp->pending_req_num = 1;
>
>                 nca.package = np->id;
> -               if (nd->state == ncsi_dev_state_suspend_select) {
> -                       nca.type = NCSI_PKT_CMD_SP;
> -                       nca.channel = NCSI_RESERVED_CHANNEL;
> -                       if (ndp->flags & NCSI_DEV_HWA)
> -                               nca.bytes[0] = 0;
> -                       else
> -                               nca.bytes[0] = 1;
> -                       nd->state = ncsi_dev_state_suspend_dcnt;
> -               } else if (nd->state == ncsi_dev_state_suspend_dcnt) {
> +               if (nd->state == ncsi_dev_state_suspend_dcnt) {
>                         nca.type = NCSI_PKT_CMD_DCNT;
>                         nca.channel = nc->id;
>                         nd->state = ncsi_dev_state_suspend_dc;

This is a messy switch statement. How about break out out all of the
states as you've done with suspend_select, instead of grouping them
and then doing if ... else if .. else if. I realise there might be one
or two lines duplicated for each state, but I think that's okay at the
expense of readability.

Also, patch 1 could also be merged into this when making this cleanup.

What do you think?

> @@ -570,10 +579,8 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
>                 }
>
>                 ret = ncsi_xmit_cmd(&nca);
> -               if (ret) {
> -                       nd->state = ncsi_dev_state_functional;
> -                       return;
> -               }
> +               if (ret)
> +                       goto error;
>
>                 break;
>         case ncsi_dev_state_suspend_done:
> @@ -587,6 +594,11 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
>                 netdev_warn(nd->dev, "Wrong NCSI state 0x%x in suspend\n",
>                             nd->state);
>         }
> +
> +       return;
> +
> +error:
> +       nd->state = ncsi_dev_state_functional;
>  }
>
>  static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
> --
> 2.1.0
>
