From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 28/29] net/: rename net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 19:21:49 -0500
Message-ID: <20121225002149.GA5235@neilslaptop.think-freely.org>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
 <1356315256-6572-29-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Jesse Gross <jesse@nicira.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, dev@openvswitch.org,
	netdev@vger.kernel.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1356315256-6572-29-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 24, 2012 at 11:14:15AM +0900, Akinobu Mita wrote:
> Use more preferable function name which implies using a pseudo-random
> number generator.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-sctp@vger.kernel.org
> Cc: dev@openvswitch.org
> Cc: netdev@vger.kernel.org
> ---
>  include/net/red.h         | 2 +-
>  net/802/garp.c            | 2 +-
>  net/openvswitch/actions.c | 2 +-
>  net/rds/bind.c            | 2 +-
>  net/sctp/socket.c         | 2 +-
>  net/xfrm/xfrm_state.c     | 2 +-
>  6 files changed, 6 insertions(+), 6 deletions(-)
> 
I'm largely indifferent to this patch, but I kind of feel like its just churn.
Whats the real advantage in making this change?  I grant that it clearly
indicates the type of random number generator we're using at a given call site,
But for those using net_random, you probably don't care too much about
the source of your random bits.  If you did really want true random vs.
pseudo-random data, you need to explicitly use the right call.  You're previous
patch series did good cleanup on differentiating the different random calls, but
this just seems like its removing what is otherwise useful indirection.
Neil

> diff --git a/include/net/red.h b/include/net/red.h
> index ef46058..168bb2f 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -303,7 +303,7 @@ static inline unsigned long red_calc_qavg(const struct red_parms *p,
>  
>  static inline u32 red_random(const struct red_parms *p)
>  {
> -	return reciprocal_divide(net_random(), p->max_P_reciprocal);
> +	return reciprocal_divide(prandom_u32(), p->max_P_reciprocal);
>  }
>  
>  static inline int red_mark_probability(const struct red_parms *p,
> diff --git a/net/802/garp.c b/net/802/garp.c
> index 8456f5d..cf7410d 100644
> --- a/net/802/garp.c
> +++ b/net/802/garp.c
> @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
>  {
>  	unsigned long delay;
>  
> -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
> +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
>  	mod_timer(&app->join_timer, jiffies + delay);
>  }
>  
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index ac2defe..257bc36 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -404,7 +404,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
>  		 a = nla_next(a, &rem)) {
>  		switch (nla_type(a)) {
>  		case OVS_SAMPLE_ATTR_PROBABILITY:
> -			if (net_random() >= nla_get_u32(a))
> +			if (prandom_u32() >= nla_get_u32(a))
>  				return 0;
>  			break;
>  
> diff --git a/net/rds/bind.c b/net/rds/bind.c
> index 637bde5..7f95f4b 100644
> --- a/net/rds/bind.c
> +++ b/net/rds/bind.c
> @@ -118,7 +118,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
>  		rover = be16_to_cpu(*port);
>  		last = rover;
>  	} else {
> -		rover = max_t(u16, net_random(), 2);
> +		rover = max_t(u16, prandom_u32(), 2);
>  		last = rover - 1;
>  	}
>  
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9e65758..95860aa 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -5899,7 +5899,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
>  
>  		inet_get_local_port_range(&low, &high);
>  		remaining = (high - low) + 1;
> -		rover = net_random() % remaining + low;
> +		rover = prandom_u32() % remaining + low;
>  
>  		do {
>  			rover++;
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 3459692..35ddaab 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1546,7 +1546,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
>  	} else {
>  		u32 spi = 0;
>  		for (h=0; h<high-low+1; h++) {
> -			spi = low + net_random()%(high-low+1);
> +			spi = low + prandom_u32() % (high - low + 1);
>  			x0 = xfrm_state_lookup(net, mark, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
>  			if (x0 == NULL) {
>  				x->id.spi = htonl(spi);
> -- 
> 1.7.11.7
> 
> 
