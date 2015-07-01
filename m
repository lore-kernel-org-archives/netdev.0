From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Wed, 1 Jul 2015 15:59:59 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1507011554060.1691@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett> <5592913C.3000207@mellanox.com> <alpine.LFD.2.11.1506301520180.1799@denkbrett> <55929F2D.9050805@mellanox.com> <alpine.LFD.2.11.1506301615100.1799@denkbrett> <5593E88F.10006@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:58329 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbbGAOAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 10:00:10 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Wed, 1 Jul 2015 15:00:03 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id ADC6D219005C
	for <netdev@vger.kernel.org>; Wed,  1 Jul 2015 14:59:40 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t61E02wr30081144
	for <netdev@vger.kernel.org>; Wed, 1 Jul 2015 14:00:02 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t61E01vU032332
	for <netdev@vger.kernel.org>; Wed, 1 Jul 2015 08:00:01 -0600
In-Reply-To: <5593E88F.10006@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jul 2015, Or Gerlitz wrote:
> On 6/30/2015 5:17 PM, Sebastian Ott wrote:
> > On Tue, 30 Jun 2015, Or Gerlitz wrote:
> > > On 6/30/2015 4:24 PM, Sebastian Ott wrote:
> > > > > > Do you run the VF on the same system/kernel as the PF, or the VF is
> > > > > > probed to
> > > > > > VM which runs the latest kernel and the PF runsolder kernel (which?)
> > > > The latter case. The PF is driven by a much older Kernel running OFED
> > > > 2.3.2.0.0.1
> > > >
> > > Can you try running the inbox PF driver that comes with the PF kernel
> > > (what
> > > kernel is that?) I'd like to see we're OK there.
> > Frankly, I don't know. Plus I also don't know how to build an ofed kernel.
> >
> 
> I didn't want you to build that package, but rather the outer way around,
> namely
> see what happens if uninstalling this package and running with the mlx4 inbox
> PF
> driver from the kernel provided from your distro of choice or an
> upstreamkernel installed
> by you. Anyway, I hope the below patch would provide a quick band-aid and let
> you to continue running upstream VFs over that PF config, let me know (I will
> be
> OOO till Thu-Sun). Once we see how this behaves, will take it from there.

Thanks for the patch. Unfortunately, that didn't work:

[  170.531076] mlx4_core 0000:00:00.0: NOP command IRQ test passed
[  170.531291] mlx4_core 0000:00:00.0: can't allocate counter from old PF driver, using index 255
[  170.531294] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: default counter index 255 for port 1
[  170.531531] mlx4_core 0000:00:00.0: can't allocate counter from old PF driver, using index 255
[  170.531534] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: default counter index 255 for port 2
[  170.531535] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
[  170.587306] mlx4_core: probe of 0000:00:00.0 failed with error -22

Regards,
Sebastian

> 
> Or.
> 
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c
> b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 12fbfcb..a66cc6e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2273,6 +2273,10 @@ static int mlx4_allocate_default_counters(struct
> mlx4_dev *dev)
>                 } else if (err == -ENOENT) {
>                         err = 0;
>                         continue;
> +               } else if (mlx4_is_slave(dev) && err == -EINVAL) {
> +                       priv->def_counter[port] =
> MLX4_SINK_COUNTER_INDEX(dev);
> +                       mlx4_warn(dev, "can't allocate counter from old PF
> driver, using index %d\n",
> + MLX4_SINK_COUNTER_INDEX(dev));
>                 } else {
>                         mlx4_err(dev, "%s: failed to allocate default counter
> port %d err %d\n",
>                                  __func__, port + 1, err);
> 
> 
> 
