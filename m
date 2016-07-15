From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Fri, 15 Jul 2016 14:52:46 -0700
Message-ID: <20160715215242.GA980@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
 <20160712.141832.634796503160544753.davem@davemloft.net>
 <20160713005424.GB13865@gmail.com>
 <3d0c7f78-0647-e927-94dd-76cbe4ddcb28@gmail.com>
 <20160713154058.GA3320@gmail.com>
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
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35836 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGOVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 17:52:50 -0400
Received: by mail-pf0-f174.google.com with SMTP id c2so45019647pfa.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 14:52:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160713154058.GA3320@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 08:40:59AM -0700, Brenden Blanco wrote:
> On Wed, Jul 13, 2016 at 10:17:26AM +0300, Tariq Toukan wrote:
> > 
> > On 13/07/2016 3:54 AM, Brenden Blanco wrote:
> > >On Tue, Jul 12, 2016 at 02:18:32PM -0700, David Miller wrote:
> > >>From: Brenden Blanco <bblanco@plumgrid.com>
> > >>Date: Tue, 12 Jul 2016 00:51:29 -0700
> > >>
> > >>>+	mlx4_en_free_resources(priv);
> > >>>+
> > >>>  	old_prog = xchg(&priv->prog, prog);
> > >>>  	if (old_prog)
> > >>>  		bpf_prog_put(old_prog);
> > >>>-	return 0;
> > >>>+	err = mlx4_en_alloc_resources(priv);
> > >>>+	if (err) {
> > >>>+		en_err(priv, "Failed reallocating port resources\n");
> > >>>+		goto out;
> > >>>+	}
> > >>>+	if (port_up) {
> > >>>+		err = mlx4_en_start_port(dev);
> > >>>+		if (err)
> > >>>+			en_err(priv, "Failed starting port\n");
> > >>A failed configuration operation should _NEVER_ leave the interface in
> > >>an inoperative state like these error paths do.
> > >>
> > >>You must instead preallocate the necessary resources, and only change
> > >>the chip's configuration and commit to the new settings once you have
> > >>successfully allocated those resources.
> > >I'll see what I can do here.
> > That's exactly what we're doing in a patchset that will be submitted
> > to net very soon (this week).
> Thanks Tariq!
> As an example, I had originally tried to integrate this code into
> mlx4_en_set_channels, which seems to have the same problem.
> > It fixes/refactors these failure flows just like Dave described,
> > something like:
> > 
> >     err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
> >     if (err)
> >         goto out;
> > 
> >     if (priv->port_up) {
> >         port_up = 1;
> >         mlx4_en_stop_port(dev, 1);
> >     }
> > 
> >     mlx4_en_safe_replace_resources(priv, tmp);
> > 
> >     if (port_up) {
> >         err = mlx4_en_start_port(dev);
> >         if (err)
> >             en_err(priv, "Failed starting port\n");
> >     }
> > 
> > I suggest you keep your code aligned with current net-next driver,
> > and later I will take it and fix it (once merged with net).
So, I took Dave's suggestion to heart, and spent the last 2 days seeing
what was possible to implement with just xdp as the focus, rather than
an overall cleanup which Tariq will be looking at.

Unfortunately, this turned out to a be a bit of a rat hole.

What I wanted to do was to pre-allocate all the required pages before
reaching the point of no return. Doing this isn't all that hard, since
it should just be a few loops. However, I ended with a bit more
duplicated code than one would like, since I had to tease out the
various sections that assume exclusive access to hardware.

But, more than that, is that I don't see a way to fill these pages into
the rings safely while hardware still has ability to write into the old
ones. There was no "pause" API that I could find besides
mlx4_en_stop_port(). That function is fairly destructive and requires
the resource allocation in mlx4_en_start_port() to succeed to recover
the port status.

One option that I considered would be to drain buffers from the rx ring,
and just let mlx4_en_recover_from_oom() do its job once we update the
page template in frag_info[]. This, however, also requires the queues to
be paused safely, so we again have to rely on mlx4_en_stop_port().

One change I can make is to avoid allocating additional tx rings, which
means that we can skip the calls to mlx4_en_free/alloc_resources().

The resulting code would then mirror what mlx4_en_change_mtu() does:

	if (port_up) {
		err = mlx4_en_start_port(dev);
		if (err)
			queue_work(mdev->workqueue, &priv->watchdog_task);
	}

I intend to respin the patchset with this approach, and a few other
changes as requested elsewhere. If the above is still unacceptable, feel
free to let me know and I will avoid spamming the list.
> Another option is to avoid entirely the tx_ring_num change, so as to
> keep the majority of the initialized state valid. We would only allocate
> a new set of pages and refill the rx rings once we have confirmed there
> are enough resources.
> 
> So others can follow the discussion, there are multiple reasons to
> reconfigure the rings.
> 1. The rx frags should be page-per-packet
> 2. The pages should be mapped DMA_BIDIRECTIONAL
> 3. Each rx ring should have a dedicated tx ring, which is off limits
> from the upper stack
> 4. The dedicated tx ring will have a pointer back to its rx ring for
> recycling
> 
> #1 and #2 can be done to the side ahead of time, as you are also
> suggesting.
> 
> Currently, to achieve #3, we increase tx_ring_num while keeping
> num_tx_rings_p_up the same. This precipitates a round of
> free/alloc_resources, which takes some time and has many opportunities
> for failure.
> However, we could resurrect an earlier approach that keeps the
> tx_ring_num unchanged, and instead just do a
> netif_set_real_num_tx_queues(tx_ring_num - rsv_tx_rings) to hide it from
> the stack. This would require that there be enough rings ahead of time,
> with a simple bounds check like:
> if (tx_ring_num < rsv_tx_rings + MLX4_EN_MAX_TX_RING_P_UP) {
> 	en_err(priv, "XDP requires minimum %d + %d rings\n", rsv_tx_rings,
> 		MLX4_EN_MAX_TX_RING_P_UP);
> 	return -EINVAL;
> }
> The default values for tx_ring_num and rx_ring_num will only hit this
> case when operating in a low memory environment, in which case the user
> must increase the number of channels manually. I think that is a fair
> tradeoff.
> 
> The rest of #1, #2, and #4 can be done in a guaranteed fashion once the
> buffers are allocated, since it would just be a few loops to refresh the
> rx_desc and recycle_ring.
> > 
> > Regards,
> > Tariq
Thanks,
Brenden
