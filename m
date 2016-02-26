From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net] be2net: don't {en,dis}able filters on BE3 when
 transparent tagging is enabled
Date: Fri, 26 Feb 2016 17:06:07 +0530
Message-ID: <CAKvpyk3i6U46-9_63CsbpmaJqOYSWcrHjFSo-BZELLriWqkRMQ@mail.gmail.com>
References: <1456476401-23398-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:32800 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbcBZLgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 06:36:08 -0500
Received: by mail-yk0-f179.google.com with SMTP id z13so34418577ykd.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 03:36:08 -0800 (PST)
In-Reply-To: <1456476401-23398-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 2:16 PM, Ivan Vecera <ivecera@redhat.com> wrote:
> The FILTMGMT privilege is necessary on BE3 chip to manipulare filters
> like MC, UC list management, VLAN filter, promisc mode... This privilege
> is dropped for VFs when transparrent tagging is enabled on them. This
> prevents to make interface up for such VF because be_enable_if_filters()
> called from be_open() fails thus be_open() also fails.
>
> Cc: Sathya Perla <sathya.perla@broadcom.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index f99de36..2e176f6 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3430,7 +3430,8 @@ static int be_close(struct net_device *netdev)
>         if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
>                 return 0;
>
> -       be_disable_if_filters(adapter);
> +       if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter)))
> +               be_disable_if_filters(adapter);
>
>         if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
>                 for_all_evt_queues(adapter, eqo, i) {
> @@ -3571,9 +3572,11 @@ static int be_open(struct net_device *netdev)
>         if (status)
>                 goto err;
>
> -       status = be_enable_if_filters(adapter);
> -       if (status)
> -               goto err;
> +       if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter))) {
> +               status = be_enable_if_filters(adapter);
> +               if (status)
> +                       goto err;

Ivan, in the be_enable_if_filters() routine the VF tries to enable the
basic filtering flags (not promisc mode etc) via the RX_FILTER cmd,
for which the VFs shouldn't need any FILTMGMT privileges. I also don't
expect be_cmd_pmac_add() to fail as the PF would have already
provisioned the mac-addr for the VF.
We should be able to reproduce this first thing Monday morning and see
what's wrong. Also, as the privilege rules are same across all chips,
any fix must be applicable for all chips that be2net supports.

thanks,
-Sathya
