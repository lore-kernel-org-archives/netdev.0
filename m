From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 net] i40e: Implement ndo_gso_check()
Date: Thu, 04 Dec 2014 22:11:44 +0300
Message-ID: <5480B1F0.9090407@cogentembedded.com>
References: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com,
	shannon.nelson@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, therbert@google.com,
	linux.nics@intel.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/04/2014 09:39 PM, Joe Stringer wrote:

> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an
> implementation for this driver which checks for IPIP, GRE, UDP tunnels.

> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v3: Drop IPIP and GRE (no driver support even though hw supports it).
>      Check for UDP outer protocol for UDP tunnels.
> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>      Add MAX_INNER_LENGTH (as 80).
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c |   26 ++++++++++++++++++++++++++
>   1 file changed, 26 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index c3a7f4a..0d6493a 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -7447,6 +7447,31 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb,
>
>   #endif /* USE_DEFAULT_FDB_DEL_DUMP */
>   #endif /* HAVE_FDB_OPS */

    Need empty line here, I think.

> +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) {
> +		unsigned char *ihdr;
> +
> +		if (skb->protocol != IPPROTO_UDP ||
> +		    skb->inner_protocol_type != ENCAP_TYPE_ETHER)
> +			return false;
> +
> +		if (skb->inner_protocol == htons(ETH_P_TEB))
> +			ihdr = skb_inner_mac_header(skb);
> +		else if (skb->inner_protocol == htons(ETH_P_IP) ||
> +			 skb->inner_protocol == htons(ETH_P_IPV6))
> +			ihdr = skb_inner_network_header(skb);
> +		else
> +			return false;

    The above is asking to be a *switch* instead, no?

> +
> +#define MAX_TUNNEL_HDR_LEN	80

    I'd #define this just above the function, if not at the start of the file...

[...]

WBR, Sergei
