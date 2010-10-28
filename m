From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [patch v3] fix stack overflow in pktgen_if_write()
Date: Thu, 28 Oct 2010 11:22:22 -0400
Message-ID: <20101028152222.GU16803@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
 <20101027221234.GN6062@bicker>
 <20101027224302.GQ6062@bicker>
 <20101027230657.GT16803@ksplice.com>
 <20101028060529.GX6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40847 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760Ab0J1PWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 11:22:25 -0400
Received: by qwf7 with SMTP id 7so1249707qwf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 08:22:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101028060529.GX6062@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You've got a leak if copy_user fails.

While testing this, I realized that printk() won't print more than 1k in a
single call, anyways, so I've sent along a patch that just copies up to 1k onto
the stack, which should prevent the overflow without changing behavior or
needing a heap allocation.

- Nelson

On Thu, Oct 28, 2010 at 08:05:29AM +0200, Dan Carpenter wrote:
> Nelson Elhage says he was able to oops both amd64 and i386 test 
> machines with 8k writes to the pktgen file.  Let's just allocate the
> buffer on the heap instead of on the stack.
> 
> This can only be triggered by root so there are no security issues here.
> 
> Reported-by: Nelson Elhage <nelhage@ksplice.com>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> v3:  just use kmalloc()
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 2c0df0f..c8d3620 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -887,12 +887,17 @@ static ssize_t pktgen_if_write(struct file *file,
>  	i += len;
>  
>  	if (debug) {
> -		char tb[count + 1];
> +		char *tb;
> +
> +		tb = kmalloc(count + 1, GFP_KERNEL);
> +		if (!tb)
> +			return -ENOMEM;
>  		if (copy_from_user(tb, user_buffer, count))
>  			return -EFAULT;
>  		tb[count] = 0;
>  		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
>  		       (unsigned long)count, tb);
> +		kfree(tb);
>  	}
>  
>  	if (!strcmp(name, "min_pkt_size")) {
