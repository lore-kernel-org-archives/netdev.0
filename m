From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [E1000-devel] [PATCH v3 3/3] ixgbe: Add new ndo to allow VF multicast
 promiscuous mode
Date: Wed, 08 Apr 2015 15:15:18 -0700
Message-ID: <5525A876.2000407@gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>,
	=?windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/07/2015 10:38 PM, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Implements the new netdev op to allow VF multicast promiscuous mode.
>
> The multicast promiscuous mode is not allowed for all VFs by default.
>
> The administrator can allow to VF multicast promiscuous mode for only
> trusted VM. After allowing multicast promiscuous mode from the host,
> we can use over 30 IPv6 addresses on VM.
>  # ip link set dev eth0 vf 1 mc_promisc on
>
> When disallowing multicast promiscuous mode, ixgbevf can only handle 30
> IPv6 addresses at most.
>  # ip link set dev eth0 vf 1 mc_promisc off
>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32 ++++++++++++++++++++++++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 40 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 08e65b6..4a9f74d 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -153,6 +153,7 @@ struct vf_data_storage {
>  	u16 vlan_count;
>  	u8 spoofchk_enabled;
>  	bool rss_query_enabled;
> +	u8 mc_promisc_allowed;
>  	unsigned int vf_api;
>  };
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 2f41403..c0e07c5 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -3663,6 +3663,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
>  		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
>  					      adapter->vfinfo[i].rss_query_enabled);
>  	}
> +
> +	/* Reconfigure multicast promiscuous mode */
> +	for (i = 0; i < adapter->num_vfs; i++) {
> +		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
> +					adapter->vfinfo[i].mc_promisc_allowed);
> +	}
>  }
>  
>  static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)

This doesn't need to be a separate loop.  You can push it up into the
block above since it is already looping through all VFs.

Once that is fixed the rest of this patch and the other two looked fine
to me.

- Alex
