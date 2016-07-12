From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Tue, 12 Jul 2016 14:18:32 -0700 (PDT)
Message-ID: <20160712.141832.634796503160544753.davem@davemloft.net>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbcGLVSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 17:18:53 -0400
In-Reply-To: <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Tue, 12 Jul 2016 00:51:29 -0700

> +	mlx4_en_free_resources(priv);
> +
>  	old_prog = xchg(&priv->prog, prog);
>  	if (old_prog)
>  		bpf_prog_put(old_prog);
>  
> -	return 0;
> +	err = mlx4_en_alloc_resources(priv);
> +	if (err) {
> +		en_err(priv, "Failed reallocating port resources\n");
> +		goto out;
> +	}
> +	if (port_up) {
> +		err = mlx4_en_start_port(dev);
> +		if (err)
> +			en_err(priv, "Failed starting port\n");

A failed configuration operation should _NEVER_ leave the interface in
an inoperative state like these error paths do.

You must instead preallocate the necessary resources, and only change
the chip's configuration and commit to the new settings once you have
successfully allocated those resources.
