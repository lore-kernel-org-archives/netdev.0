From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 01:15:35 -0700
Message-ID: <1371456935.3252.177.camel@edumazet-glaptop>
References: <1371478739.10495.5.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Jun Chen <jun.d.chen@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371478739.10495.5.camel@chenjun-workstation>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-17 at 10:18 -0400, Jun Chen wrote:
> When search the first skb to collapse,the condition of overlap to the next one have been
> reached,but the start is less than TCP_SKB_CB(skb)->seq at this time, then followed process
> will trigger the BUG_ON of the offset(start - TCP_SKB_CB(skb)->seq).
> So this patch add one check (! before(start,TCP_SKB_CB(skb)->seq)) to avoid this ipanic.
> 
> Signed-off-by: Chen Jun <jun.d.chen@intel.com>
> ---
>  net/ipv4/tcp_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 9c62257..4c745c5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4465,7 +4465,8 @@ restart:
>  		 *   overlaps to the next one.
>  		 */
>  		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
> -		    (tcp_win_from_space(skb->truesize) > skb->len ||
> +			((tcp_win_from_space(skb->truesize) > skb->len &&
> +			!before(start, TCP_SKB_CB(skb)->seq)) ||
>  		     before(TCP_SKB_CB(skb)->seq, start))) {
>  			end_of_skbs = false;
>  			break;

Hmm... I must say I do not understand this patch.

If we find a skb with before(TCP_SKB_CB(skb)->seq, start), then the
final condition will be true.

Let's rewrite your code to equivalent one :

 if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
     (before(TCP_SKB_CB(skb)->seq, start) ||
      tcp_win_from_space(skb->truesize) > skb->len)) {

So it seems your patch would not solve the problem for all
possible skbs (aka not bloated) ?

Please tell us how you trigger this bug, and send the stack trace.

Thanks
