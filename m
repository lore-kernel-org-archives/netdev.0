From: cliff white <cliffw@osdl.org>
Subject: Re: Constant errors with pktgen
Date: Tue, 15 Mar 2005 11:04:14 -0800
Message-ID: <20050315110414.3310bf96@es175>
References: <20050314133404.2528647f@es175>
	<16951.422.818446.117190@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
In-Reply-To: <16951.422.818446.117190@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 16:39:18 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> cliff white writes:
> 
>  > My test rig is two machines with an e100 card, connected by crossover 
>  > cable.
>  > 
>  > When i run pktgen, the error counter == packet count, always. 
> 
>  I see. Try the patch patch below it cleans up the code a bit and
>  restores the old meaning of error. It also has the minor fix from 
>  Adrian Bunk
> 
Works for me
Current:
     pkts-sofar: 7400227  errors: 0
( now i have to force some errors... )
cliffw

> 						--ro
> 
> --- net/core/pktgen.c.050315	2005-03-11 10:48:43.000000000 +0100
> +++ net/core/pktgen.c	2005-03-15 16:16:01.000000000 +0100
> @@ -151,7 +151,7 @@
>  #include <asm/timex.h>
>  
>  
> -#define VERSION  "pktgen v2.60: Packet Generator for packet performance testing.\n"
> +#define VERSION  "pktgen v2.61: Packet Generator for packet performance testing.\n"
>  
>  /* #define PG_DEBUG(a) a */
>  #define PG_DEBUG(a) 
> @@ -2590,7 +2590,7 @@
>          thread_unlock();
>  }
>  
> -__inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
> +static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  {
>  	struct net_device *odev = NULL;
>  	__u64 idle_start = 0;
> @@ -2654,7 +2654,6 @@
>  	
>  	spin_lock_bh(&odev->xmit_lock);
>  	if (!netif_queue_stopped(odev)) {
> -		u64 now;
>  
>  		atomic_inc(&(pkt_dev->skb->users));
>  retry_now:
> @@ -2678,24 +2677,18 @@
>  			
>  			pkt_dev->errors++;
>  			pkt_dev->last_ok = 0;
> -			pkt_dev->next_tx_us = getCurUs(); /* TODO */
> -			pkt_dev->next_tx_ns = 0;
>  		}
>  
> +		pkt_dev->next_tx_us = getCurUs();
> +		pkt_dev->next_tx_ns = 0;
> +
>  		pkt_dev->next_tx_us += pkt_dev->delay_us;
>  		pkt_dev->next_tx_ns += pkt_dev->delay_ns;
> +
>  		if (pkt_dev->next_tx_ns > 1000) {
>  			pkt_dev->next_tx_us++;
>  			pkt_dev->next_tx_ns -= 1000;
>  		}
> -
> -		now = getCurUs();
> -		if (now > pkt_dev->next_tx_us) {
> -			/* TODO: this code is slightly wonky.  */
> -			pkt_dev->errors++;
> -			pkt_dev->next_tx_us = now - pkt_dev->delay_us;
> -			pkt_dev->next_tx_ns = 0;
> -		}
>  	} 
>  
>  	else {  /* Retry it next time */
> 


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
