From: root@smtp.nexlab.net
Subject: (no subject)
Date: Tue, 24 May 2005 11:12:21 +0200 (CEST)
Message-ID: <20050524091221.286FBFB49@smtp.nexlab.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: undisclosed-recipients:;
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	by smtp.nexlab.net (Postfix) with ESMTP id E2FB1F9E7

	for <buffer@sniffo.org>; Tue, 24 May 2005 04:13:52 +0200 (CEST)

Received: from oss (localhost [127.0.0.1])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1kGF3003197;

	Mon, 23 May 2005 18:46:16 -0700

Received: with ECARTIS (v1.0.0; list netdev); Mon, 23 May 2005 18:43:59 -0700 (PDT)

Received: from mail.dvmed.net (mail.dvmed.net [216.237.124.58])

	by oss.sgi.com (8.12.10/8.12.10/SuSE Linux 0.7) with ESMTP id j4O1htF3002796

	for <netdev@oss.sgi.com>; Mon, 23 May 2005 18:43:55 -0700

Received: from cpe-065-184-065-144.nc.res.rr.com ([65.184.65.144] helo=[10.10.10.88])

	by mail.dvmed.net with esmtpsa (Exim 4.51 #1 (Red Hat Linux))

	id 1DaORj-00017L-8S; Tue, 24 May 2005 01:43:04 +0000

Message-ID: <429286A3.1060606@pobox.com>

Date: Mon, 23 May 2005 21:42:59 -0400

From: Jeff Garzik <jgarzik@pobox.com>
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.6) Gecko/20050328 Fedora/1.7.6-1.2.5

X-Accept-Language: en-us, en

MIME-Version: 1.0

To: Michael Chan <mchan@broadcom.com>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Subject: Re: [PATCH 1/6] bnx2: Fix excessive stack usage

References: <1116892439.4908.1.camel@rh4> <1116894307.4908.28.camel@rh4>

In-Reply-To: <1116894307.4908.28.camel@rh4>

Content-Type: text/plain; charset=us-ascii; format=flowed

Content-Transfer-Encoding: 7bit

X-archive-position: 1536

X-ecartis-version: Ecartis v1.0.0

Sender: netdev-bounce@oss.sgi.com
Errors-To: netdev-bounce@oss.sgi.com
X-original-sender: jgarzik@pobox.com

Precedence: bulk

X-list: netdev

X-Virus-Scanned: ClamAV 0.83/892/Mon May 23 10:52:19 2005 on oss.sgi.com

X-Virus-Status: Clean



Michael Chan wrote:
> diff -Nru 10/drivers/net/bnx2.c 11/drivers/net/bnx2.c
> --- 10/drivers/net/bnx2.c	2005-05-23 10:20:02.000000000 -0700
> +++ 11/drivers/net/bnx2.c	2005-05-23 10:20:20.000000000 -0700
> @@ -1138,13 +1138,20 @@
>  	}
>  }
>  
> -static void
> +static int
>  bnx2_alloc_bad_rbuf(struct bnx2 *bp)
>  {
> -	u16 good_mbuf[512];
> +	u16 *good_mbuf;
>  	u32 good_mbuf_cnt;
>  	u32 val;
>  
> +	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
> +	if (good_mbuf == NULL) {
> +		printk(KERN_ERR PFX "Failed to allocate memory in "
> +				    "bnx2_alloc_bad_rbuf\n");
> +		return -ENOMEM;
> +	}
> +
>  	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
>  		BNX2_MISC_ENABLE_SET_BITS_RX_MBUF_ENABLE);
>  
> @@ -1178,6 +1185,7 @@
>  
>  		REG_WR_IND(bp, BNX2_RBUF_FW_BUF_FREE, val);
>  	}
> +	return 0;
>  }
>  
>  static void

memleak -- you need to free good_mbuf.

	Jeff
