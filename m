From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 6/8] nfp: bpf: add support for XDP_FLAGS_HW_MODE
Date: Tue, 20 Jun 2017 01:50:17 +0200
Message-ID: <59486339.8080003@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com> <20170616235746.16337-7-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, netoptimizer@brouer.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33907 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752579AbdFSXuX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:50:23 -0400
In-Reply-To: <20170616235746.16337-7-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> Respect the XDP_FLAGS_HW_MODE.  When it's set install the program
> on the NIC and skip enabling XDP in the driver.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>   drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> index 68648e312129..c5903b6e58c5 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> @@ -3310,19 +3310,22 @@ static int
>   nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
>   		  struct netlink_ext_ack *extack)
>   {
> -	struct bpf_prog *offload_prog;
> +	struct bpf_prog *drv_prog, *offload_prog;
>   	int err;
>
>   	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
>   		return -EBUSY;
>
> +	drv_prog     = flags & XDP_FLAGS_HW_MODE  ? NULL : prog;
>   	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;

Can you make this assumption here? If dev_change_xdp_fd() is called
without XDP_FLAGS_HW_MODE or XDP_FLAGS_DRV_MODE flags, then we set prog
to both, drv_prog and offload_prog. Is this expected?

Maybe in nfp_net_xdp_setup() check for !hweight32(xdp_flags & XDP_FLAGS_MODES)
and then set flags |= XDP_FLAGS_DRV_MODE before both assignments?

> -	err = nfp_net_xdp_setup_drv(nn, prog, extack);
> +	err = nfp_net_xdp_setup_drv(nn, drv_prog, extack);
>   	if (err)
>   		return err;
>
> -	nfp_app_xdp_offload(nn->app, nn, offload_prog);
> +	err = nfp_app_xdp_offload(nn->app, nn, offload_prog);
> +	if (err && flags & XDP_FLAGS_HW_MODE)
> +		return err;
>
>   	if (nn->xdp_prog)
>   		bpf_prog_put(nn->xdp_prog);
> @@ -3338,6 +3341,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
>
>   	switch (xdp->command) {
>   	case XDP_SETUP_PROG:
> +	case XDP_SETUP_PROG_HW:
>   		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
>   					 xdp->extack);
>   	case XDP_QUERY_PROG:
>
