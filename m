From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Just one more byte, it is wafer thin...
Date: Thu, 21 Jul 2011 15:28:37 -0700
Message-ID: <4E28A815.7030603@hp.com>
References: <4E2764A0.90003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:48692 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab1GUW2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:28:40 -0400
In-Reply-To: <4E2764A0.90003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 04:28 PM, Rick Jones wrote:
> and just to be completely pedantic about it, set rx-usecs-high to 0:
>
> # HDR="-P 1";for r in 4344 4345; do netperf -H mumble.3.21 -t TCP_RR
> $HDR -- -r ${r},1; HDR="-P 0"; done
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
> to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : first burst 0
> Local /Remote
> Socket Size Request Resp. Elapsed Trans.
> Send Recv Size Size Time Rate
> bytes Bytes bytes bytes secs. per sec
>
> 16384 87380 4344 1 10.00 14274.03
> 16384 87380
> 16384 87380 4345 1 10.00 13697.11
> 16384 87380
>
> and got a somewhat unexpected result - I've no idea why then they both
> went up - perhaps it was sensing "high" occasionally even in the 4344
> byte request case. Still, is this suggesting that perhaps the adaptive
> bits are being a bit to aggressive about sensing high? Over what
> interval is that measurement supposed to be happening?

So, from a 2.6.38 tree in drivers/net/mlx4/en_netdev:

        /* Apply auto-moderation only when packet rate exceeds a rate that
          * it matters */
         if (rate > MLX4_EN_RX_RATE_THRESH) {
                 /* If tx and rx packet rates are not balanced, assume that
                  * traffic is mainly BW bound and apply maximum moderation.
                  * Otherwise, moderate according to packet rate */
                 if (2 * tx_pkt_diff > 3 * rx_pkt_diff &&
                     rx_pkt_diff / rx_byte_diff <
                     MLX4_EN_SMALL_PKT_SIZE)
                         moder_time = priv->rx_usecs_low;
                 else if (2 * rx_pkt_diff > 3 * tx_pkt_diff)
                         moder_time = priv->rx_usecs_high;
                 else {
                         if (rate < priv->pkt_rate_low)
                                 moder_time = priv->rx_usecs_low;
                         else if (rate > priv->pkt_rate_high)
                                 moder_time = priv->rx_usecs_high;
                         else
                                 moder_time = (rate - priv->pkt_rate_low) *
                                         (priv->rx_usecs_high - 
priv->rx_usecs_low) /
                                         (priv->pkt_rate_high - 
priv->pkt_rate_low) +
                                         priv->rx_usecs_low;
                 }
         } else {
                 /* When packet rate is low, use default moderation 
rather than
                  * 0 to prevent interrupt storms if traffic suddenly 
increases */
                 moder_time = priv->rx_usecs;
         }

It would seem that the assume is involved here.  The TCP_RR test I was 
running (or NFS Read, or NFS Write, or I suspect SMB/CIFS reads and 
writes etc) will have either request much larger than response or vice 
versa.  That leaves the tx and rx packet rates decidedly not balanced 
even when the traffic is not BW bound, particularly when there will not 
be all that many requests outstanding at one time.  And it becomes even 
more unbalanced when LRO/GRO stretches the ACKs.

rick jones
