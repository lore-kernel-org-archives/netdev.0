From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Sun, 21 Jan 2007 13:18:43 +0100
Message-ID: <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
	 <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109130220.GA4060@ff.dom.local>
	 <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
	 <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
	 <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
	 <20070111104220.GA3171@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dale Farnsworth" <dale@farnsworth.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:46263 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbXAUMSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 07:18:46 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1018379nfa
        for <netdev@vger.kernel.org>; Sun, 21 Jan 2007 04:18:44 -0800 (PST)
To: "Jarek Poplawski" <jarkao2@o2.pl>
In-Reply-To: <20070111104220.GA3171@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/11/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
>
> PS: alas I didn't even check compiling - I had no time to
> find all compile dependencies of this driver
> ---
>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> ---
>
> diff -Nurp linux-2.6.20-rc4-/drivers/net/mv643xx_eth.c linux-2.6.20-rc4/drivers/net/mv643xx_eth.c
> --- linux-2.6.20-rc4-/drivers/net/mv643xx_eth.c 2006-12-18 08:57:52.000000000 +0100
> +++ linux-2.6.20-rc4/drivers/net/mv643xx_eth.c  2007-01-11 08:55:34.000000000 +0100
> @@ -312,8 +312,8 @@ int mv643xx_eth_free_tx_descs(struct net
>         int count;
>         int released = 0;
>
> +       spin_lock_irqsave(&mp->lock, flags);
>         while (mp->tx_desc_count > 0) {
> -               spin_lock_irqsave(&mp->lock, flags);
>                 tx_index = mp->tx_used_desc_q;
>                 desc = &mp->p_tx_desc_area[tx_index];
>                 cmd_sts = desc->cmd_sts;
> @@ -348,8 +348,10 @@ int mv643xx_eth_free_tx_descs(struct net
>                         dev_kfree_skb_irq(skb);

Hmm, I think this is guaranteed not to work. In between those lines
the lock is released, while data in the mp structure is still being
accessed. It seems that this bit of code is indeed not race-safe
though, I'm gonna try to figure something.

>                 released = 1;
> +               spin_lock_irqsave(&mp->lock, flags);
>         }
>
> +       spin_unlock_irqrestore(&mp->lock, flags);
>         return released;
>  }

Ugh, this is really unclean... Taking a lock "for nothing" like that
has a perf cost.

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
