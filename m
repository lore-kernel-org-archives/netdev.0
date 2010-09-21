From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Tue, 21 Sep 2010 10:05:01 -0400
Message-ID: <20100921140501.GA21572@elliptictech.com>
References: <20100920174443.GA5515@elliptictech.com>
 <1285006844.2323.17.camel@edumazet-laptop>
 <20100920195256.GA14330@elliptictech.com>
 <1285013853.2323.148.camel@edumazet-laptop>
 <1285018272.2323.243.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285018272.2323.243.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-09-20 23:31 +0200, Eric Dumazet wrote:
> Could you try following patch ?
>
> [PATCH] ip : fix truesize mismatch in ip fragmentation
[...]
> @@ -658,13 +657,15 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
>  				goto slow_path;
>  
>  			BUG_ON(frag->sk);
> -			if (skb->sk) {
> +		}
> +		if (skb->sk) {
> +			skb_walk_frags(skb, frag) {
>  				frag->sk = skb->sk;
>  				frag->destructor = sock_wfree;
> -				truesizes += frag->truesize;
> +				skb->truesize -= frag->truesize;
>  			}
>  		}
> -
> +				

This hunk introduces some whitespace damage.

Anyway, I tried this with ESP on both IPv4 and IPv6 and it appears to
correct the issue.  Thanks!

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
