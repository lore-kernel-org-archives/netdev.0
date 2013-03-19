From: Nick Pegg <npegg@linode.com>
Subject: Re: [PATCH 2/4] xen-netfront: drop skb when skb->len >
 65535
Date: Tue, 19 Mar 2013 16:13:13 -0400
Message-ID: <5148C6D9.6060504@linode.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	<1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, annie.li@oracle.com, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


On 3/18/13 6:35 AM, Wei Liu wrote:
> The `size' field of Xen network wire format is uint16_t, anything bigger than
> 65535 will cause overflow.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 5527663..8c3d065 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	unsigned int len = skb_headlen(skb);
>  	unsigned long flags;
>  
> +	/*
> +	 * wire format of xen_netif_tx_request only supports skb->len
> +	 * < 64K, because size field in xen_netif_tx_request is
> +	 * uint16_t.
> +	 */
> +	if (unlikely(skb->len > (uint16_t)(~0))) {
> +		net_alert_ratelimited(
> +			"xennet: skb->len = %d, too big for wire format\n",
> +			skb->len);
> +		goto drop;
> +	}
> +
>  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> 

I have tested this patch on a 3.7.10 DomU and have confirmed that it
works for the test case that Wei came up with (set MTU to 100 on DomU,
run iperf). I haven't come across any other ways to cause this to
happen, so my testing isn't very thorough.


-Nick
