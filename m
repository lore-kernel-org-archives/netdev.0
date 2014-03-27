From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bridge: Fix crash with vlan filtering and
	tcpdump
Date: Fri, 28 Mar 2014 00:36:10 +0300
Message-ID: <533499CA.9030003@cogentembedded.com>
References: <1395952078-16266-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395952078-16266-1-git-send-email-vyasevic@redhat.com>
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

Hello.

On 03/27/2014 11:27 PM, Vlad Yasevich wrote:

> When the vlan filtering is enabled on the bridge, but
> the filter is not configured on the bridge device itself,
> running tcpdump on the bridge device will result in a
> an Oops with NULL pointer dereference.  The reason
> is that br_pass_frame_up() will bypass the vlan
> check because promisc flag is set.  It will then try
> to get the table pointer and process the packet based
> on the table.  Since the table pointer is NULL, we oops.
> Catch this special condition in br_handle_vlan().

> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
> * Changed to use kfree_skb() instead of kfree_skb_list() to
>    match the reset of bridge code.
>   net/bridge/br_input.c | 11 ++++++-----
>   net/bridge/br_vlan.c  | 14 ++++++++++++++
>   2 files changed, 20 insertions(+), 5 deletions(-)

> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 28d5446..d0cca3c 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
[...]
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 8249ca7..b153cc4 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -144,6 +144,20 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>   	if (!br->vlan_enabled)
>   		goto out;
>
> +	/* Vlan filter table must be configured at this point.  The
> +	 * only exception is the bridge is set in promisc mode and the
> +	 * packet is destined for the bridge device.  In this case
> +	 * pass the packet as is.
> +	 */
> +	if (!pv) {
> +		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev)
> +			goto out;
> +		else {
> +			kfree_skb(skb);
> +			return NULL;
> +		}

    All arms of the *if* statement should have {} if at least one arm as them; 
see Documentation/CodingStyle.

WBR, Sergei
