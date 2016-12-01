From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: warn on bogus MSS and try to amend it
Date: Thu, 01 Dec 2016 15:29:49 -0500 (EST)
Message-ID: <20161201.152949.1953888486413180001.davem@davemloft.net>
References: <0d41deb00d57206f518e6bffae1b0be355bbc726.1480511277.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmaxwell37@gmail.com,
        alexandre.sidorenko@hpe.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        tlfalcon@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        eric.dumazet@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757453AbcLAU3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:29:51 -0500
In-Reply-To: <0d41deb00d57206f518e6bffae1b0be355bbc726.1480511277.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 30 Nov 2016 11:14:32 -0200

> There have been some reports lately about TCP connection stalls caused
> by NIC drivers that aren't setting gso_size on aggregated packets on rx
> path. This causes TCP to assume that the MSS is actually the size of the
> aggregated packet, which is invalid.
> 
> Although the proper fix is to be done at each driver, it's often hard
> and cumbersome for one to debug, come to such root cause and report/fix
> it.
> 
> This patch amends this situation in two ways. First, it adds a warning
> on when this situation occurs, so it gives a hint to those trying to
> debug this. It also limit the maximum probed MSS to the adverised MSS,
> as it should never be any higher than that.
> 
> The result is that the connection may not have the best performance ever
> but it shouldn't stall, and the admin will have a hint on what to look
> for.
> 
> Tested with virtio by forcing gso_size to 0.
> 
> Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

I totally agree with this change, however I think the warning message can
be improved in two ways:

>  	len = skb_shinfo(skb)->gso_size ? : skb->len;
>  	if (len >= icsk->icsk_ack.rcv_mss) {
> -		icsk->icsk_ack.rcv_mss = len;
> +		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> +					       tcp_sk(sk)->advmss);
> +		if (icsk->icsk_ack.rcv_mss != len)
> +			pr_warn_once("Seems your NIC driver is doing bad RX acceleration. TCP performance may be compromised.\n");

We know it's a bad GRO implementation that causes this so let's be specific in the
message, perhaps something like:

	Driver has suspect GRO implementation, TCP performance may be compromised.

Also, we have skb->dev available here most likely, so prefixing the message with
skb->dev->name would make analyzing this situation even easier for someone hitting
this.

I'm not certain if an skb->dev==NULL check is necessary here or not, but it is
definitely something you need to consider.

Thanks!
