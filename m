From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Wed, 9 Dec 2009 16:49:26 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C3DED4A@orsmsx508.amr.corp.intel.com>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091208221435.28373.76070.stgit@localhost.localdomain>
 <20091210004530.GG4163@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Simon Horman <horms@verge.net.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65163 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbZLJAtc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:49:32 -0500
In-Reply-To: <20091210004530.GG4163@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:horms@verge.net.au]
>Sent: Wednesday, December 09, 2009 4:46 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V;
>Waskiewicz Jr, Peter P
>Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
>
>> @@ -5767,6 +5954,52 @@ static int __devinit ixgbe_probe(struct pci_dev
>*pdev,
>>  		goto err_sw_init;
>>  	}
>>
>> +#ifdef CONFIG_PCI_IOV
>> +	if (hw->mac.type == ixgbe_mac_82599EB) {
>> +		/* The 82599 supports up to 64 VFs per physical function
>> +		 * but this implementation limits allocation to 63 so that
>> +		 * basic networking resources are still available to the
>> +		 * physical function
>> +		 */
>> +		adapter->num_vfs = (max_vfs > 63) ? 63 : max_vfs;
>> +		if (adapter->num_vfs) {
>> +			adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
>> +			err = pci_enable_sriov(pdev, adapter->num_vfs);
>> +			if (err) {
>> +				DPRINTK(PROBE, ERR,
>> +					"Failed to enable PCI sriov: %d\n",
>> +					err);
>> +				adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
>> +				adapter->num_vfs = 0;
>> +			}
>> +		}
>> +		/* If call to enable VFs succeeded then allocate memory
>> +		 * for per VF control structures.
>> +		 */
>> +		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
>> +			adapter->vfinfo =
>> +				kcalloc(adapter->num_vfs,
>> +					sizeof(struct vf_data_storage),
>> +					GFP_KERNEL);
>> +			if (!adapter->vfinfo) {
>> +				/* Oh oh */
>> +				DPRINTK(PROBE, ERR,
>> +					"Unable to allocate memory for VF "
>> +					"Data Storage - SRIOV disabled\n");
>> +				adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
>> +				adapter->num_vfs = 0;
>
>A call to pci_disable_sriov(pdev) is needed here?
[Rose, Gregory V] 

Good catch.

>
>> +			} else {
>> +				/* Now that we're sure SR-IOV is enabled
>> +				 * set up the mailbox parameters
>> +				 */
>> +				ixgbe_init_mbx_params_pf(hw);
>> +				memcpy(&hw->mbx.ops, ii->mbx_ops,
>> +				       sizeof(hw->mbx.ops));
>> +			}
>> +		}
>> +	}
>> +
>> +#endif /* CONFIG_PCI_IOV */
>>  	netdev->features = NETIF_F_SG |
>>  	                   NETIF_F_IP_CSUM |
>>  	                   NETIF_F_HW_VLAN_TX |
>
>I wonder if it would be easier on the eyes to break the hunk above out
>into
>a ixgbe_probe_vf() function. Something like (compile tested only, I
>don't
>have an 82599):
[Rose, Gregory V] 

I think that was done with the igb driver.  It's a good suggestion.

- Greg

