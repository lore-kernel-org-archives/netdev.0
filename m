From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Fix for a race in socket transmit with flow
 control.
Date: Tue, 06 Mar 2012 16:35:49 -0500 (EST)
Message-ID: <20120306.163549.910213928154338805.davem@davemloft.net>
References: <1330886358-4857-1-git-send-email-abi.dmitryt@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: abi.dmitryt@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758546Ab2CFVfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:35:53 -0500
In-Reply-To: <1330886358-4857-1-git-send-email-abi.dmitryt@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Tarnyagin <abi.dmitryt@gmail.com>
Date: Sun,  4 Mar 2012 19:39:18 +0100

> @@ -224,8 +224,12 @@ noxoff:
>  	rcu_read_unlock_bh();
>  
>  	err = dev_queue_xmit(skb);
> -	if (err > 0)
> -		err = -EIO;
> +	if (unlikely(err > 0)) {
> +		if (err == NET_XMIT_DROP)
> +			err = -EAGAIN;
> +		else
> +			err = -EIO;
> +	}
>  
>  	return err;
>  }

If there is a packet scheduler classifier rule saying to drop all
packets that match a certain criteria, this will always return -EAGAIN
for certain SKBs.

> +		ret = transmit_skb(skb, cf_sk, noblock, timeo);
> +	} while (ret == -EAGAIN);

And therefore this will loop forever.

I think this is just a bad way to handle it, drops are drops and they
can happen anywhere not just the place that signals things like
NET_XMIT_DROP.

Just simply ignore positive return values from dev_queue_xmit() and
traslate them into zero.  Then you need to make no other changes at
all.
