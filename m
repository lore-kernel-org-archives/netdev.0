From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [patch v2] fix stack overflow in pktgen_if_write()
Date: Wed, 27 Oct 2010 19:06:57 -0400
Message-ID: <20101027230657.GT16803@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
 <20101027221234.GN6062@bicker>
 <20101027224302.GQ6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:46083 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab0J0XHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 19:07:01 -0400
Received: by qyk10 with SMTP id 10so1363088qyk.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 16:07:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101027224302.GQ6062@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You want to add a trailing NUL, or else printk will read off the end of the
buffer.

Also, by memdup()ing count + 1 bytes, you're technically reading one more byte
than userspace asked for, which could in principle lead to a spurious EFAULT.

- Nelson

On Thu, Oct 28, 2010 at 12:43:02AM +0200, Dan Carpenter wrote:
> Nelson Elhage says he was able to oops both amd64 and i386 test 
> machines with 8k writes to the pktgen file.  Let's just allocate the
> buffer on the heap instead of on the stack.
> 
> This can only be triggered by root so there are no security issues here.
> 
> Reported-by: Nelson Elhage <nelhage@ksplice.com>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> I saw this on twitter.  Hi Nelson, could you test this?
> 
> V2:  strndup_user() => memdup_user()  
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 2c0df0f..b5d3c70 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -887,12 +887,14 @@ static ssize_t pktgen_if_write(struct file *file,
>  	i += len;
>  
>  	if (debug) {
> -		char tb[count + 1];
> -		if (copy_from_user(tb, user_buffer, count))
> -			return -EFAULT;
> -		tb[count] = 0;
> +		char *tb;
> +
> +		tb = memdup_user(user_buffer, count + 1);
> +		if (IS_ERR(tb))
> +			return PTR_ERR(tb);
>  		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
>  		       (unsigned long)count, tb);
> +		kfree(tb);
>  	}
>  
>  	if (!strcmp(name, "min_pkt_size")) {
> 
