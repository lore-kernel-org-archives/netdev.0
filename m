From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 09:36:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927233639.GA8333@gondor.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu> <20040927160411.22b44f48.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927160411.22b44f48.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 11:04:11PM +0000, David S. Miller wrote:
> 
> If tcp_clean_rtx_queue() doesn't return DATA
> acked then no congestion growth is allowed to occur.  So we only
> get a snd_cwnd bump once for every tso_factor frames, that stinks :)

Yes that'll do it :)
 
> ===== net/ipv4/tcp_input.c 1.75 vs edited =====
> --- 1.75/net/ipv4/tcp_input.c	2004-09-27 12:00:32 -07:00
> +++ edited/net/ipv4/tcp_input.c	2004-09-27 15:35:12 -07:00
> @@ -2373,8 +2373,12 @@
>  		 * discard it as it's confirmed to have arrived at
>  		 * the other end.
>  		 */
> -		if (after(scb->end_seq, tp->snd_una))
> +		if (after(scb->end_seq, tp->snd_una)) {
> +			if (scb->tso_factor &&
> +			    after(tp->snd_una, scb->seq))
> +				acked |= FLAG_DATA_ACKED;
>  			break;

I think you need to at least decrement packets_out here.  Otherwise
the prior_in_flight >= tp->snd_cwnd check in tcp_ack() might become
incorrect for the next ack.

Even better, you could move the skb->data pointer forward and forget
about that segment altogether.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
