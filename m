From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Wed, 13 Jul 2016 08:40:59 -0700
Message-ID: <20160713154058.GA3320@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
 <20160712.141832.634796503160544753.davem@davemloft.net>
 <20160713005424.GB13865@gmail.com>
 <3d0c7f78-0647-e927-94dd-76cbe4ddcb28@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, saeedm@dev.mellanox.co.il, kafai@fb.com,
	brouer@redhat.com, as754m@att.com, alexei.starovoitov@gmail.com,
	gerlitz.or@gmail.com, john.fastabend@gmail.com,
	hannes@stressinduktion.org, tgraf@suug.ch, tom@herbertland.com,
	daniel@iogearbox.net
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33313 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbcGMPli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 11:41:38 -0400
Received: by mail-pa0-f45.google.com with SMTP id ks6so18943258pab.0
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 08:41:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3d0c7f78-0647-e927-94dd-76cbe4ddcb28@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 10:17:26AM +0300, Tariq Toukan wrote:
> 
> On 13/07/2016 3:54 AM, Brenden Blanco wrote:
> >On Tue, Jul 12, 2016 at 02:18:32PM -0700, David Miller wrote:
> >>From: Brenden Blanco <bblanco@plumgrid.com>
> >>Date: Tue, 12 Jul 2016 00:51:29 -0700
> >>
> >>>+	mlx4_en_free_resources(priv);
> >>>+
> >>>  	old_prog = xchg(&priv->prog, prog);
> >>>  	if (old_prog)
> >>>  		bpf_prog_put(old_prog);
> >>>-	return 0;
> >>>+	err = mlx4_en_alloc_resources(priv);
> >>>+	if (err) {
> >>>+		en_err(priv, "Failed reallocating port resources\n");
> >>>+		goto out;
> >>>+	}
> >>>+	if (port_up) {
> >>>+		err = mlx4_en_start_port(dev);
> >>>+		if (err)
> >>>+			en_err(priv, "Failed starting port\n");
> >>A failed configuration operation should _NEVER_ leave the interface in
> >>an inoperative state like these error paths do.
> >>
> >>You must instead preallocate the necessary resources, and only change
> >>the chip's configuration and commit to the new settings once you have
> >>successfully allocated those resources.
> >I'll see what I can do here.
> That's exactly what we're doing in a patchset that will be submitted
> to net very soon (this week).
Thanks Tariq!
As an example, I had originally tried to integrate this code into
mlx4_en_set_channels, which seems to have the same problem.
> It fixes/refactors these failure flows just like Dave described,
> something like:
> 
>     err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
>     if (err)
>         goto out;
> 
>     if (priv->port_up) {
>         port_up = 1;
>         mlx4_en_stop_port(dev, 1);
>     }
> 
>     mlx4_en_safe_replace_resources(priv, tmp);
> 
>     if (port_up) {
>         err = mlx4_en_start_port(dev);
>         if (err)
>             en_err(priv, "Failed starting port\n");
>     }
> 
> I suggest you keep your code aligned with current net-next driver,
> and later I will take it and fix it (once merged with net).
Another option is to avoid entirely the tx_ring_num change, so as to
keep the majority of the initialized state valid. We would only allocate
a new set of pages and refill the rx rings once we have confirmed there
are enough resources.

So others can follow the discussion, there are multiple reasons to
reconfigure the rings.
1. The rx frags should be page-per-packet
2. The pages should be mapped DMA_BIDIRECTIONAL
3. Each rx ring should have a dedicated tx ring, which is off limits
from the upper stack
4. The dedicated tx ring will have a pointer back to its rx ring for
recycling

#1 and #2 can be done to the side ahead of time, as you are also
suggesting.

Currently, to achieve #3, we increase tx_ring_num while keeping
num_tx_rings_p_up the same. This precipitates a round of
free/alloc_resources, which takes some time and has many opportunities
for failure.
However, we could resurrect an earlier approach that keeps the
tx_ring_num unchanged, and instead just do a
netif_set_real_num_tx_queues(tx_ring_num - rsv_tx_rings) to hide it from
the stack. This would require that there be enough rings ahead of time,
with a simple bounds check like:
if (tx_ring_num < rsv_tx_rings + MLX4_EN_MAX_TX_RING_P_UP) {
	en_err(priv, "XDP requires minimum %d + %d rings\n", rsv_tx_rings,
		MLX4_EN_MAX_TX_RING_P_UP);
	return -EINVAL;
}
The default values for tx_ring_num and rx_ring_num will only hit this
case when operating in a low memory environment, in which case the user
must increase the number of channels manually. I think that is a fair
tradeoff.

The rest of #1, #2, and #4 can be done in a guaranteed fashion once the
buffers are allocated, since it would just be a few loops to refresh the
rx_desc and recycle_ring.
> 
> Regards,
> Tariq
