From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH net] vmxnet3: Don't enable vlan filters in promiscuous
 mode.
Date: Tue, 9 Aug 2011 14:32:21 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1108091426010.27839@sbhatewara-dev1.eng.vmware.com>
References: <1312794947-3163-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Goldman <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:29432 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751257Ab1HIVcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 17:32:18 -0400
In-Reply-To: <1312794947-3163-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 8 Aug 2011, Jesse Gross wrote:

> @@ -1929,14 +1929,17 @@ static void
>  vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
>  {
>  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> -	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
> -	unsigned long flags;
>  
> -	VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
> -	spin_lock_irqsave(&adapter->cmd_lock, flags);
> -	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> -			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
> -	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
> +	if (!(netdev->flags & IFF_PROMISC)) {
> +		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
> +		unsigned long flags;
> +
> +		VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
> +		spin_lock_irqsave(&adapter->cmd_lock, flags);
> +		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> +				       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
> +		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
> +	}
>  

If this is done, the driver will ignore all vlan tag registrations (and 
deletions) while the interface is in promiscuous mode. Better solution
would be to send UPDATE_VLAN_FILTERS command alone inside the promiscuous 
condition. vfTable can be set/unset unconditionally as before. By doing 
this, when the interface comes out of promiscuous mode, the restored vlan 
state will have all the added/removed vlan tags into effect.
