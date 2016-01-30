From: Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [net,2/2] net: i40e: shut up uninitialized variable warnings
Date: Sat, 30 Jan 2016 18:33:26 +0300
Message-ID: <56ACD7C6.1010808@virtuozzo.com>
References: <1453766332-43274-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22794 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991AbcA3PeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jan 2016 10:34:15 -0500
In-Reply-To: <1453766332-43274-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.01.2016 02:58, Jeff Kirsher wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> intel/i40e/i40e_txrx.c: In function 'i40e_xmit_frame_ring':
> intel/i40e/i40e_txrx.c:2367:20: error: 'oiph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> intel/i40e/i40e_txrx.c:2317:16: note: 'oiph' was declared here
> intel/i40e/i40e_txrx.c:2367:17: error: 'oudph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> intel/i40e/i40e_txrx.c:2316:17: note: 'oudph' was declared here

2364                 if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
2365                     (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
2366                     (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
2367                         oudph->check = ~csum_tcpudp_magic(oiph->saddr,
2368                                         oiph->daddr,
2369                                         (skb->len - skb_transport_offset(skb)),
2370                                         IPPROTO_UDP, 0);

if compiler reports that oudph and oiph can be unitialized here,
it's not enough just to set them to NULL.

Do we need probably to check that variables was initialized before access here?
i.e. add  oudph && oiph into condition?

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 720516b..47bd8b3 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -2313,8 +2313,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
>  	struct iphdr *this_ip_hdr;
>  	u32 network_hdr_len;
>  	u8 l4_hdr = 0;
> -	struct udphdr *oudph;
> -	struct iphdr *oiph;
> +	struct udphdr *oudph = NULL;
> +	struct iphdr *oiph = NULL;
>  	u32 l4_tunnel = 0;
>  
>  	if (skb->encapsulation) {
> 
