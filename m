From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net] net: xgene: Check negative return value of xgene_enet_get_ring_size()
Date: Fri, 15 Aug 2014 11:45:42 -0700
Message-ID: <CAKh23F=q8G6QUWXQo0qF-oPks--8CsbRg2fsTg_oXZFR8=DwjA@mail.gmail.com>
References: <1408017582-1133-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Keyur Chudgar <kchudgar@apm.com>, Ravi Patel <rapatel@apm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og106.obsmtp.com ([64.18.0.182]:38799 "HELO
	exprod5og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751122AbaHOSpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:45:44 -0400
Received: by mail-la0-f52.google.com with SMTP id b17so2583058lan.39
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:45:42 -0700 (PDT)
In-Reply-To: <1408017582-1133-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 4:59 AM, Tobias Klauser <tklauser@distanz.ch> wrote:
> xgene_enet_get_ring_size() returns a negative value in case of an error,
> but its only caller in xgene_enet_create_desc_ring() currently uses the
> return value directly as u32. Instead, check for a negative value first and
> error out in case. Also move the call to xgene_enet_get_ring_size() before
> devm_kzalloc() so we don't need to free anything in the error path.
>
> This fixes the following issue reported by the Coverity Scanner:
>
> ** CID 1231336:  Improper use of negative value  (NEGATIVE_RETURNS)
> /drivers/net/ethernet/apm/xgene/xgene_enet_main.c: 596 in xgene_enet_create_desc_ring()
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index af7c40a..e1a8f4e 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -581,7 +581,11 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>         struct xgene_enet_desc_ring *ring;
>         struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>         struct device *dev = ndev_to_dev(ndev);
> -       u32 size;
> +       int size;
> +
> +       size = xgene_enet_get_ring_size(dev, cfgsize);
> +       if (size < 0)
> +               return NULL;
>
>         ring = devm_kzalloc(dev, sizeof(struct xgene_enet_desc_ring),
>                             GFP_KERNEL);
> @@ -593,7 +597,6 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>         ring->cfgsize = cfgsize;
>         ring->id = ring_id;
>
> -       size = xgene_enet_get_ring_size(dev, cfgsize);
>         ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
>                                               GFP_KERNEL);
>         if (!ring->desc_addr) {
> --
> 2.0.1
>
>

I am sorry I wasn't able to see this until today.

Thanks for addressing the problem.  Even though the patch has already
been applied, here is my ACK.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
