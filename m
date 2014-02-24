From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/2] ixgbe,
	make interrupt allocations NUMA aware
Date: Mon, 24 Feb 2014 11:26:32 -0800
Message-ID: <530B9CE8.2070800@intel.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
	<1393267913-28212-2-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	agospoda@redhat.com, John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1393267913-28212-2-git-send-email-prarit@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 02/24/2014 10:51 AM, Prarit Bhargava wrote:
> The ixgbe driver creates one queue/cpu on the system in order to spread
> work out on all cpus rather than restricting work to a single cpu.  This
> model, while efficient, does not take into account the NUMA configuration
> of the system.
>
> This patch introduces ixgbe_num_cpus() which returns
> the number of online cpus if the adapter's PCI device has no NUMA
> restrictions, and the number of cpus in the node if the PCI device is
> allocated to a specific node.
>
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: nhorman@redhat.com
> Cc: agospoda@redhat.com
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   28 +++++++++++++++++++++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +++--
>  4 files changed, 33 insertions(+), 8 deletions(-)
>

[...]

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 18076c4..b68a6e9 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -4953,13 +4953,13 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
>  	hw->subsystem_device_id = pdev->subsystem_device;
>  
>  	/* Set common capability flags and settings */
> -	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
> +	rss = min_t(int, IXGBE_MAX_RSS_INDICES, ixgbe_num_cpus(adapter));
>  	adapter->ring_feature[RING_F_RSS].limit = rss;
>  	adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
>  	adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
>  	adapter->max_q_vectors = MAX_Q_VECTORS_82599;
>  	adapter->atr_sample_rate = 20;
> -	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, num_online_cpus());
> +	fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, ixgbe_num_cpus(adapter));
>  	adapter->ring_feature[RING_F_FDIR].limit = fdir;
>  	adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
>  #ifdef CONFIG_IXGBE_DCA

This is the one bit I object to in this patch.  The flow director queue
count should be equal to the number of online CPUs, or at least as close
to it as the hardware can get.  Otherwise ATR is completely useless.

Thanks,

Alex

------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
