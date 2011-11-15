From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v3 5/9] forcedeth: implement ndo_get_stats64()
 API
Date: Mon, 14 Nov 2011 17:10:39 -0800
Message-ID: <20111114171039.34a04369@nehalam.linuxnetplumber.net>
References: <cover.1321313729.git.david.decotigny@google.com>
	<e2dd16618bc1bd5108e6dea3c7531ee229e4c699.1321313729.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e2dd16618bc1bd5108e6dea3c7531ee229e4c699.1321313729.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Nov 2011 16:11:15 -0800
David Decotigny <david.decotigny@google.com> wrote:

> This commit implements the ndo_get_stats64() API for forcedeth. Since
> these stats are being updated from different contexts (process and
> timer), this commit adds protection (locking + atomic variables).
> 
> Tested:
>   - 16-way SMP x86_64 ->
>     RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)
>   - pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/tx_packets
> 
> 
> 
> Signed-off-by: David Decotigny <david.decotigny@google.com>
> ---
>  drivers/net/ethernet/nvidia/forcedeth.c |  182 ++++++++++++++++++++++++-------
>  1 files changed, 141 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index ee8cce5..a67c1f4 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -692,6 +692,21 @@ struct nv_ethtool_stats {
>  #define NV_DEV_STATISTICS_V2_COUNT (NV_DEV_STATISTICS_V3_COUNT - 3)
>  #define NV_DEV_STATISTICS_V1_COUNT (NV_DEV_STATISTICS_V2_COUNT - 6)
>  
> +/* driver statistics */
> +struct nv_driver_stat {
> +	atomic_t delta;  /* increase since last nv_update_stats() */
> +	u64 total;  /* cumulative, requires netdev_priv(dev)->stats_lock */
> +};

Please existing u64_stats_sync rather than inventing your own
method. The u64_stats_sync is faster and does require locking.
