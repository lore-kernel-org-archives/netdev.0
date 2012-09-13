From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_red: fix weighted average calculation
Date: Thu, 13 Sep 2012 15:53:51 +0200
Message-ID: <1347544431.13103.1557.camel@edumazet-glaptop>
References: <1347543820-27548-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, david.ward@ll.mit.edu, jdowdal@ti.com,
	paul.gortmaker@windriver.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347543820-27548-1-git-send-email-cyril@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-13 at 09:43 -0400, Cyril Chemparathy wrote:
> This patch fixes an apparent bug in the running weighted average calculation
> used in the RED algorithm.
> 
> Going by the described formula:
> 	   qavg = qavg*(1-W) + backlog*W
> 	=> qavg = qavg + (backlog - qavg) * W
> 
> ... with W converted to a pre-calculated shift, this then becomes:
> 	qavg = qavg + (backlog - qavg) >> logW
> 
> ... giving the modified expression introduced by this patch.
> 
> Signed-off-by: John Dowdal <jdowdal@ti.com>
> ---
>  include/net/red.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/red.h b/include/net/red.h
> index ef46058..05960a4 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -287,7 +287,7 @@ static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p
>  	 *
>  	 * --ANK (980924)
>  	 */
> -	return v->qavg + (backlog - (v->qavg >> p->Wlog));
> +	return v->qavg + (backlog - v->qavg) >> p->Wlog;
>  }
>  
>  static inline unsigned long red_calc_qavg(const struct red_parms *p,

This is going to be a FPP (Frequently Posted Patch)

Current formulae is fine.

Thats because backlog, at start of red_calc_qavg_no_idle_time() is not
yet scaled by p->Wlog. v->avg is scaled, but not backlog.

Have you tested RED after your patch ?
