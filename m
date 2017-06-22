From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 12/12] nfp: add VF and PF representors to
 flower app
Date: Thu, 22 Jun 2017 17:50:29 +0300
Message-ID: <CAJ3xEMgBOTO0+8evaE0yOVo3+AiRjGg+kKe3DO1TO=7QYiK2vQ@mail.gmail.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com> <1497994580-6271-13-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:36810 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdFVOua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 10:50:30 -0400
Received: by mail-ot0-f195.google.com with SMTP id r67so2016374ota.3
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 07:50:30 -0700 (PDT)
In-Reply-To: <1497994580-6271-13-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 12:36 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Initialise VF and PF representors in flower app.
>
> Based in part on work by Benjamin LaHaise, Bert van Leeuwen and
> Jakub Kicinski.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  drivers/net/ethernet/netronome/nfp/flower/main.c | 86 +++++++++++++++++++++++-
>  1 file changed, 84 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
> index d1d905727c54..582b7be3e219 100644
> --- a/drivers/net/ethernet/netronome/nfp/flower/main.c
> +++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
> @@ -149,15 +149,81 @@ static const struct net_device_ops nfp_flower_repr_netdev_ops = {
>         .ndo_get_offload_stats  = nfp_repr_get_offload_stats,
>  };
>
> +static void nfp_flower_sriov_disable(struct nfp_app *app)
> +{
> +       nfp_reprs_clean_and_free_by_type(app, NFP_REPR_TYPE_VF);
> +}
> +
> +static int
> +nfp_flower_spawn_vnic_reprs(struct nfp_app *app,
> +                           enum nfp_flower_cmsg_port_vnic_type vnic_type,
> +                           enum nfp_repr_type repr_type, unsigned int cnt)
> +{
> +       u8 nfp_pcie = nfp_cppcore_pcie_unit(app->pf->cpp);
> +       struct nfp_flower_priv *priv = app->priv;
> +       struct nfp_reprs *reprs, *old_reprs;
> +       const u8 queue = 0;
> +       int i, err;
> +
> +       reprs = nfp_reprs_alloc(cnt);
> +       if (!reprs)
> +               return -ENOMEM;
> +
> +       for (i = 0; i < cnt; i++) {
> +               u32 port_id;
> +
> +               reprs->reprs[i] = nfp_repr_alloc(app);
> +               if (!reprs->reprs[i]) {
> +                       err = -ENOMEM;
> +                       goto err_reprs_clean;
> +               }
> +
> +               SET_NETDEV_DEV(reprs->reprs[i], &priv->nn->pdev->dev);

why? these are virtual devices, in the same manner that on para virt use case,
tap devices are. Why we want them all to be linked to the PF PCI entry?

We had that on our code and removed it before upstreaming b/c it made
provisioning
systems (open-stack) to get crazy and didn't provide any benefit.

I would vote -1 for this line, suggest to remove it and see later
if/why you need that.

> +               eth_hw_addr_inherit(reprs->reprs[i], priv->nn->dp.netdev);

-1 vote here too.. having all your reps to carry the PF mac would
create confusion for provisioning
systems, DHCP daemons and such. We are following the para virt way and
set random
mac on the rep, which would be later changed by libvirt as done for tap devices
