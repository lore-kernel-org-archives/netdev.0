From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH] bridge: missing null bridge device check
 causing null pointer dereference (bugfix)
Date: Thu, 06 Nov 2014 16:07:19 +0900
Message-ID: <545B1E27.3080302@lab.ntt.co.jp>
References: <1415255192-13584-1-git-send-email-suhyun.park@ahnlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Su-Hyun Park <suhyun.park@ahnlab.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1415255192-13584-1-git-send-email-suhyun.park@ahnlab.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2014/11/06 15:26, Su-Hyun Park wrote:
> the bridge device can be null if the bridge is being deleted while processing 
> the packet, which causes the null pointer dereference in switch statement.

How can this happen??
It is guarded by rcu.
netdev_rx_handler_unregister() ensures rx_handler_data is non NULL.

Thanks,
Toshiaki Makita

> 
> crash dump snippet:
> 
> <1>BUG: unable to handle kernel NULL pointer dereference at 0000000000000021
> <1>IP: [<ffffffff814179f6>] br_handle_frame+0xe6/0x270
> 
> <0>Code: 4c 0f 44 f0 89 f8 66 33 15 32 52 24 00 66 33 05 29 52 24 00 09 c2 89 
> f0 66 33 05 22 52 24 00 80 e4 f0 66 09 c2 0f 84 eb 00 00 00 <41> 0f b6 46 21 
> 3c 02 74 61 3c 03 74 1d 48 89 df e8 d5 bc f0 ff
> ---
>  net/bridge/br_input.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 6fd5522..7e899ca 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -176,6 +176,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>  		return RX_HANDLER_CONSUMED;
>  
>  	p = br_port_get_rcu(skb->dev);
> +	if (!p)
> +		goto drop;
>  
>  	if (unlikely(is_link_local_ether_addr(dest))) {
>  		u16 fwd_mask = p->br->group_fwd_mask_required;
> 
