From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix ppp_deflate issues with recent zlib_inflate changes
Date: Thu, 3 May 2007 17:11:45 -0700
Message-ID: <20070503171145.aafa29fb.akpm@linux-foundation.org>
References: <1178230689.27450.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Wenk <stefan.wenk@gmx.at>, netdev@vger.kernel.org
To: Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:48264 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423508AbXEDAL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:11:58 -0400
In-Reply-To: <1178230689.27450.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 03 May 2007 23:18:09 +0100
Richard Purdie <rpurdie@rpsys.net> wrote:

> The last zlib_inflate update broke certain corner cases for ppp_deflate
> decompression handling. This patch fixes some logic to make things work
> properly again. Users other than ppp_deflate (the only Z_PACKET_FLUSH
> user) should be unaffected.
> 
> Fixes bug 8405 (confirmed by the reporter).
> 
> Signed-off-by: Richard Purdie <rpurdie@rpsys.net>
> 
> Index: linux/lib/zlib_inflate/inflate.c
> ===================================================================
> --- linux.orig/lib/zlib_inflate/inflate.c	2007-05-03 23:08:27.000000000 +0100
> +++ linux/lib/zlib_inflate/inflate.c	2007-05-03 23:09:39.000000000 +0100
> @@ -743,12 +743,14 @@ int zlib_inflate(z_streamp strm, int flu
>  
>      strm->data_type = state->bits + (state->last ? 64 : 0) +
>                        (state->mode == TYPE ? 128 : 0);
> -    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
> -        ret = Z_BUF_ERROR;
>  
>      if (flush == Z_PACKET_FLUSH && ret == Z_OK &&
> -            (strm->avail_out != 0 || strm->avail_in == 0))
> +            strm->avail_out != 0 && strm->avail_in == 0)
>  		return zlib_inflateSyncPacket(strm);
> +
> +    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
> +        ret = Z_BUF_ERROR;
> +
>      return ret;
>  }
>  

Thanks heaps, guys.  It was a tough one.  I'll tag it for 2.6.21.x too.
