From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 10:34:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928003412.GA8755@gondor.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu> <20040927160411.22b44f48.davem@davemloft.net> <20040927233639.GA8333@gondor.apana.org.au> <20040927171356.6a59d039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927171356.6a59d039.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 05:13:56PM -0700, David S. Miller wrote:
> 
> I'm getting really good results here on my tg3<-->tg3 setup using
> this patch.

Yes this looks very good.

Just a few minor things below.

> ===== net/ipv4/tcp_input.c 1.75 vs edited =====
> --- 1.75/net/ipv4/tcp_input.c	2004-09-27 12:00:32 -07:00
> +++ edited/net/ipv4/tcp_input.c	2004-09-27 16:36:29 -07:00
> @@ -2355,6 +2355,60 @@
>  	}
>  }
>  
> +static int tcp_tso_acked(struct tcp_opt *tp, struct sk_buff *skb,
> +			 __u32 now, __s32 *seq_rtt)
> +{
> +	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
> +	__u32 tso_seq = scb->seq + scb->tso_offset;
> +	__u32 mss = tp->mss_cache_std;

In future we should probably record the MSS in the scb just in case
it changes.

> @@ -2373,8 +2427,12 @@
>  		 * discard it as it's confirmed to have arrived at
>  		 * the other end.
>  		 */
> -		if (after(scb->end_seq, tp->snd_una))
> +		if (after(scb->end_seq, tp->snd_una)) {
> +			if (scb->tso_factor)

tso_factor > 1

> ===== net/ipv4/tcp_output.c 1.59 vs edited =====
> --- 1.59/net/ipv4/tcp_output.c	2004-09-27 11:57:52 -07:00
> +++ edited/net/ipv4/tcp_output.c	2004-09-27 15:52:15 -07:00
> @@ -1191,6 +1192,7 @@
>  		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
>  		TCP_SKB_CB(skb)->sacked = 0;
>  		TCP_SKB_CB(skb)->tso_factor = 1;
> +		TCP_SKB_CB(skb)->tso_offset = 1;

Is this a clever trick that I don't understand? :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
