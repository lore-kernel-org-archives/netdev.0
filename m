From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Mon, 7 Dec 2009 09:17:46 -0800
Message-ID: <20091207091746.51d8958a@nehalam>
References: <4B1A4BC5.3050300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44284 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964833AbZLGRR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 12:17:57 -0500
In-Reply-To: <4B1A4BC5.3050300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 05 Dec 2009 13:02:13 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> atomic_dec_return() is a full memory barrier, we can omit
> the smp_mb__before_atomic_dec() call.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/dst.c |    9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 57bc4d5..cdec1d1 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -262,13 +262,8 @@ again:
>  
>  void dst_release(struct dst_entry *dst)
>  {
> -	if (dst) {
> -               int newrefcnt;
> -
> -		smp_mb__before_atomic_dec();
> -               newrefcnt = atomic_dec_return(&dst->__refcnt);
> -               WARN_ON(newrefcnt < 0);
> -	}
> +	if (dst)
> +		WARN_ON(atomic_dec_return(&dst->__refcnt) < 0);
>  }
>  EXPORT_SYMBOL(dst_release);

I don't like to put actual necessary code in WARN or BUG macro
args because some embedded type developer is likely to build
with

#define WARN_ON(x)

to get rid of all warnings.
