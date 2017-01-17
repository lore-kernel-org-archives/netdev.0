From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 17 Jan 2017 11:27:20 -0800
Message-ID: <20170117192720.GA2833@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
 <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
 <20161215184837.GA16552@obsidianresearch.com>
 <20161216012404.GD3785@phlsvsds.ph.intel.com>
 <20161216041727.GA3797@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "ira.weiny" <ira.weiny@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:23516 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751015AbdAQT1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 14:27:25 -0500
Content-Disposition: inline
In-Reply-To: <20161216041727.GA3797@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jason for the valuable inputs.

Here is the new generic interface.

Overview:
Bottom driver defines net_device_ops. The upper driver can override it.
For example, upper driver can implement ndo_open() which calls bottom driver's 
ndo_open() and also do some book keeping.


include/rdma/ib_verbs.h:

/* rdma netdev type - specifies protocol type */
enum rdma_netdev_t {
	RDMA_NETDEV_HFI_VNIC,
};

/* rdma netdev
  * For usecases where netstack interfacing is required.
  */
struct rdma_netdev {
	struct net_device *netdev;
	u8 port_num;

	/* client private data structure */
	void *clnt_priv;

	/* control functions */
	void (*set_id)(struct rdma_netdev *rn, int id);
	void (*set_state)(struct rdma_netdev *rn, int state);
};

struct ib_device {
	...
	...
	/* rdma netdev operations */
	struct net_device *(*alloc_rdma_netdev)(struct ib_device *device,
					u8 port_num,
					enum rdma_netdev_t type,
					const char *name,
					unsigned char name_assign_type,
					void (*setup)(struct net_device *));
	void (*free_rdma_netdev)(struct net_device *netdev);
};


hfi1 driver:

/* rdma netdev's private data structure */
struct hfi1_rdma_netdev {
	struct rdma_netdev  rn;		/* keep this first */
	/* hfi1's vnic private data follows */
};


include/rdma/opa_hfi.h:

/* Client's ndo operations use below function instead of netdev_priv() */
static inline void *hfi_vnic_priv(const struct net_device *dev)
{
	struct rdma_netdev *rn = netdev_priv(dev);

	return rn->clnt_priv;
}

/* Overrides rtnl_link_stats64 to include hfi_vnic stats.
  * ndo_get_stats64() can be used to get the stats
  */
struct hfi_vnic_stats {
	/* standard netdev statistics */
	struct rtnl_link_stats64  netstat;

	/* HFI VNIC statistics */
	u64  tx_mcastbcast;
	u64  tx_untagged;
	u64  tx_vlan;
	u64  tx_64_size;
	u64  tx_65_127;
	u64  tx_128_255;
	u64  tx_256_511;
	u64  tx_512_1023;
	u64  tx_1024_1518;
	u64  tx_1519_max;

	u64  rx_untagged;
	u64  rx_vlan;
	u64  rx_64_size;
	u64  rx_65_127;
	u64  rx_128_255;
	u64  rx_256_511;
	u64  rx_512_1023;
	u64  rx_1024_1518;
	u64  rx_1519_max;

	u64  rx_runt;
	u64  rx_oversize;
};

I have started working on porting hfi_vnic as per this new interface.
I will post RFC v3 later.
Posting the interface definition early for comments.

Thanks,
Niranjana
