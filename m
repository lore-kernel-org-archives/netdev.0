From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net 3/5] net/ncsi: Fix stale link state of inactive
 channels on failover
Date: Fri, 14 Oct 2016 16:32:28 +1030
Message-ID: <CACPK8Xf1A2pvE0WCe2araRxZyMu9wkw=L=2-WuXrkBthehdfgw@mail.gmail.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com> <1476413614-24586-4-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:36455 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753352AbcJNGKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:10:17 -0400
Received: by mail-vk0-f51.google.com with SMTP id 2so103606772vkb.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 23:09:13 -0700 (PDT)
In-Reply-To: <1476413614-24586-4-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 1:23 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> The issue was found on BCM5718 which has two NCSI channels in one
> package: C0 and C1. Both of them are connected to different LANs,
> means they are in link-up state and C0 is chosen  as the active
> one until resetting BCM5718 happens as below.
>
> Resetting BCM5718 results in LSC (Link State Change) AEN packet
> received on C0, meaning LSC AEN is missed on C1. When LSC AEN packet
> received on C0 to report link-down, it fails over to C1 because C1
> is in link-up state as software can see. However, C1 is in link-down
> state in hardware. It means the link state is out of synchronization
> between hardware and software, resulting in inappropriate channel (C1)
> selected as active one.
>
> This resolves the issue by sending separate GLS (Get Link Status)
> commands to all channels in the package before trying to do failover.
> The last link state on all channels in the package is retrieved. With
> it, C0 is selected as active one as expected.

I follow this, and can see that happening in the
ncsi_dev_state_suspend_gls state. However, what is

> -               nd->state = ncsi_dev_state_suspend_dcnt;
> +               if (ndp->flags & NCSI_DEV_RESHUFFLE)
> +                       nd->state = ncsi_dev_state_suspend_gls;
> +               else
> +                       nd->state = ncsi_dev_state_suspend_dcnt;

However, what is this doing? I'm not quite sure what
NCSI_DEV_RESHUFFLE is and why we enable it?

>
>                 ret = ncsi_xmit_cmd(&nca);
>                 if (ret)
>                         goto error;
>
>                 break;
> +       case ncsi_dev_state_suspend_gls:
> +               ndp->pending_req_num = np->channel_num;
> +
> +               nca.type = NCSI_PKT_CMD_GLS;
> +               nca.package = np->id;
> +               nd->state = ncsi_dev_state_suspend_dcnt;
> +
> +               NCSI_FOR_EACH_CHANNEL(np, nc) {
> +                       nca.channel = nc->id;
> +                       ret = ncsi_xmit_cmd(&nca);
> +                       if (ret)
> +                               goto error;
> +               }
> +
> +               break;
>         case ncsi_dev_state_suspend_dcnt:
>         case ncsi_dev_state_suspend_dc:
>         case ncsi_dev_state_suspend_deselect:
> --
> 2.1.0
>
