From: Horms <horms@verge.net.au>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Wed, 8 Aug 2007 18:45:44 +0900
Message-ID: <20070808094542.GA5901@verge.net.au>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Wensong Zhang <wensong@linux-vs.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763510AbXHHJqA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 11:33:00AM +0200, Heiko Carstens wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> For architectures that don't have a volatile atomic_ts constructs like
> while (atomic_read(&something)); might result in endless loops since a
> barrier() is missing which forces the compiler to generate code that
> actually reads memory contents.
> Fix this in ipvs by using the IP_VS_WAIT_WHILE macro which resolves to
> while (expr) { cpu_relax(); }
> (why isn't this open coded btw?)
> 
> Cc: Wensong Zhang <wensong@linux-vs.org>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: David Miller <davem@davemloft.net>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
> 
> Just saw this while grepping for atomic_reads in a while loops.
> Maybe we should re-add the volatile to atomic_t. Not sure.

This looks good to me. A little wile back I noticed a few places
where IP_VS_WAIT_WHILE seemed to be curiously unused, then I got
distracted...

Signed-off-by: Simon Horman <horms@verge.net.au>

> 
>  net/ipv4/ipvs/ip_vs_ctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
> +++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -909,7 +909,7 @@ ip_vs_edit_dest(struct ip_vs_service *sv
>  	write_lock_bh(&__ip_vs_svc_lock);
>  
>  	/* Wait until all other svc users go away */
> -	while (atomic_read(&svc->usecnt) > 1) {};
> +	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
>  
>  	/* call the update_service, because server weight may be changed */
>  	svc->scheduler->update_service(svc);

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/
