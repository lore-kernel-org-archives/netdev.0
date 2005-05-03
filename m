From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Tue, 3 May 2005 11:40:34 +1000
Message-ID: <20050503014034.GC12682@krispykreme>
References: <200504051836.j35IanDD005402@guinness.s2io.com> <Pine.LNX.4.61.0505021459240.16692@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@neterion.com>,
        muhammad.shafiq@neterion.com, ramkrishna.vepa@neterion.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0505021459240.16692@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi,

> The neterion 10gige driver uses a readq() to flush some PIO writes
> in s2io_xmit(). Using mmiowb() can, in some cases, reduce CPU 
> utilization, and/or allow higher throughput. This is particularly 
> true when TSO is off, and small MTUs are in use. 
> 
> For example, in one test measurement I just did with 2.6.12-rc2
> on an Altix, MTUs were set to 1500 bytes and TSO turned off. 
> With this patch, transmit throughput improved by ~20%. Throughput 
> was ultimately bound by the CPU with or without the patch. With 
> large MTUs (9600 bytes) or with TSO turned on, there was no 
> significant change to throughput or CPU utilization.

I didnt know mmiowb is supposed to be a replacement for PCI write
posting. Most architectures define mmiowb as nothing and so will be
broken with your change.

Anton

> --- linux.orig/drivers/net/s2io.c	2005-05-02 16:40:17.469733509 -0700
> +++ linux/drivers/net/s2io.c	2005-05-02 16:40:25.001043632 -0700
> @@ -2759,8 +2759,8 @@ static int s2io_xmit(struct sk_buff *skb
>  #endif
>  	writeq(val64, &tx_fifo->List_Control);
>  
> -	/* Perform a PCI read to flush previous writes */
> -	val64 = readq(&bar0->general_int_status);
> +	/* Perform a mmiowb() to order previous writes */
> +	mmiowb();
>  
>  	put_off++;
>  	put_off %= mac_control->tx_curr_put_info[queue].fifo_len + 1;
> 
> --
> Arthur
> 
