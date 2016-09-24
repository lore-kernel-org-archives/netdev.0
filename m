From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v2 2/2] i40e: fix setting debug
 parameter early
Date: Fri, 23 Sep 2016 19:51:42 -0700
Message-ID: <CAKgT0UfmZo0a7eQNw9BLk5qcgDsVK5j5G+_Ab7Zo7Mvcys=KDQ@mail.gmail.com>
References: <1474637458-5255-1-git-send-email-sassmann@kpanic.de> <1474637458-5255-3-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36362 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcIXCvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 22:51:44 -0400
Received: by mail-it0-f67.google.com with SMTP id n143so2000006ita.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 19:51:43 -0700 (PDT)
In-Reply-To: <1474637458-5255-3-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 6:30 AM, Stefan Assmann <sassmann@kpanic.de> wrote:
> pf->msg_enable is a bitmask, therefore assigning the value of the
> "debug" parameter is wrong. It is initialized again later in
> i40e_sw_init() so it didn't cause any problem, except that we missed
> early debug messages. Moved the initialization and assigned
> pf->hw.debug_mask the bitmask as that's what the driver actually uses
> in i40e_debug(). Otherwise the debug parameter is just a noop.
>
> Fixes: 5b5faa4 ("i40e: enable debug earlier")
>
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++---------
>  1 file changed, 7 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 56369761..f972f0d 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -8498,11 +8498,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
>         int err = 0;
>         int size;
>
> -       pf->msg_enable = netif_msg_init(debug,
> -                                       NETIF_MSG_DRV    |
> -                                       NETIF_MSG_PROBE  |
> -                                       NETIF_MSG_LINK);
> -
>         /* Set default capability flags */
>         pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
>                     I40E_FLAG_MSI_ENABLED     |
> @@ -10812,10 +10807,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         mutex_init(&hw->aq.asq_mutex);
>         mutex_init(&hw->aq.arq_mutex);
>
> -       if (debug != -1) {
> -               pf->msg_enable = pf->hw.debug_mask;
> -               pf->msg_enable = debug;
> -       }
> +       /* enable debug prints if requested */
> +       pf->msg_enable = netif_msg_init(debug,
> +                                       NETIF_MSG_DRV   |
> +                                       NETIF_MSG_PROBE |
> +                                       NETIF_MSG_LINK);
> +       if (debug != -1)
> +               pf->hw.debug_mask = pf->msg_enable;
>
>         /* do a special CORER for clearing PXE mode once at init */
>         if (hw->revision_id == 0 &&

The patch is broken, mainly because the code was already broken.  The
flags in pf->hw.debug_mask are in no way related to pf->msg_enable.
For now just use the default mask provided to populate
pf->hw.debug_mask and then the msg_enable portion is fine.

- Alex
