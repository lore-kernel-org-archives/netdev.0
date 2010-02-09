From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 17/23 v3] mlx4_core: Randomize Mac addresses for slaves
Date: Tue, 09 Feb 2010 17:22:17 +0000
Message-ID: <1265736137.2126.121.camel@achroite.uk.solarflarecom.com>
References: <49BFC313.1030901@mellanox.co.il>
	 <4B6AEE38.4010207@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58533 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab0BIRWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 12:22:21 -0500
In-Reply-To: <4B6AEE38.4010207@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-04 at 17:56 +0200, Yevgeny Petrilin wrote:
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/fw.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
> index 6e3e1d1..202a256 100644
> --- a/drivers/net/mlx4/fw.c
> +++ b/drivers/net/mlx4/fw.c
> @@ -32,6 +32,7 @@
>   * SOFTWARE.
>   */
>  
> +#include <linux/etherdevice.h>
>  #include <linux/mlx4/cmd.h>
>  #include <linux/cache.h>
>  
> @@ -149,11 +150,19 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
>  						       struct mlx4_cmd_mailbox *outbox)
>  {
>  	struct mlx4_caps *caps = outbox->buf;
> +	u8 rand_mac[6];
> +	int i, j;
>  
>  	memcpy(caps, &dev->caps, sizeof *caps);
>  
>  	/* The Master function is in charge for qp1 of al slaves */
>  	caps->sqp_demux = 0;
> +	for (i = 1; i <= dev->caps.num_ports; ++i) {
> +		random_ether_addr(rand_mac);
> +		caps->def_mac[i] = 0;
> +		for (j = 0; j < ETH_ALEN - 1; j++)
> +			caps->def_mac[i] |= ((u64)(rand_mac[j]) << 8 * j);
[...]

Do you really want the last byte to be 0 always?

Assuming you don't, you can avoid the inner loop by writing:

	union {
		u8 bytes[ETH_ALEN];
		__le64 qword;
	} rand_mac = {
		.qword = 0
	};
	...
		random_ether_addr(rand_mac.bytes);
		caps->def_mac[i] = le64_to_cpup(&rand_mac.qword);

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

