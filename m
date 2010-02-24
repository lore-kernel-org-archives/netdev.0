From: "Tung, Chien Tin" <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [net-next-2.6 PATCH] infiniband: convert to use
 netdev_for_each_mc_addr
Date: Wed, 24 Feb 2010 12:46:24 -0700
Message-ID: <603F8A3875DCE940BA37B49D0A6EA0AE842606EE@azsmsx501.amr.corp.intel.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100224151108.GD2663-YzwxZg+R7evMbnheQZGK0N5OCZ2W11yPFxja6HXR22MAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

I am having trouble applying your patch.  It is erroring out on hunk #5.
Current nes_nic.c does not have this line:

>-		  netdev_mc_count(netdev), !!(netdev->flags & IFF_PROMISC),

Did I miss an old patch?

Chien

For reference:

>diff --git a/drivers/infiniband/hw/nest/nes_nic.c b/drivers/infiniband/hw/nest/nes_nic.c
>index c04f8fc..9384f5d 100644
>--- a/drivers/infiniband/hw/nes/nes_nic.c
>+++ b/drivers/infiniband/hw/nest/nes_nic.c
[...]
>@@ -862,19 +871,30 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
> 	}
>
> 	nes_debug(NES_DBG_NIC_RX, "Number of MC entries = %d, Promiscous = %d, All Multicast = %d.\n",
>-		  netdev_mc_count(netdev), !!(netdev->flags & IFF_PROMISC),
>+		  mc_count, !!(netdev->flags & IFF_PROMISC),
> 		  !!(netdev->flags & IFF_ALLMULTI));
> 	if (!mc_all_on) {
>-		multicast_addr = netdev->mc_list;
>+		char *addrs;
>+		int i;
>+		struct dev_mc_list *mcaddr;
>+
>+		addrs = kmalloc(ETH_ALEN * mc_count, GFP_ATOMIC);
>+		if (!addrs) {
>+			set_allmulti(nesdev, nic_active_bit);
>+			goto unlock;
>+		}
>+		i = 0;
>+		netdev_for_each_mc_addr(mcaddr, netdev)
>+			memcpy(get_addr(addrs, i++),
>+			       mcaddr->dmi_addr, ETH_ALEN);
>+
> 		perfect_filter_register_address = NES_IDX_PERFECT_FILTER_LOW +
> 						pft_entries_preallocated * 0x8;
>-		for (mc_index = 0; mc_index < max_pft_entries_avaiable;
>-		mc_index++) {
>-			while (multicast_addr && nesvnic->mcrq_mcast_filter &&
>+		for (i = 0, mc_index = 0; mc_index < max_pft_entries_avaiable;
>+		     mc_index++) {
>+			while (i < mc_count && nesvnic->mcrq_mcast_filter &&
> 			((mc_nic_index = nesvnic->mcrq_mcast_filter(nesvnic,
>-					multicast_addr->dmi_addr)) == 0)) {
>-				multicast_addr = multicast_addr->next;
>-			}
>+					get_addr(addrs, i++))) == 0));
> 			if (mc_nic_index < 0)
> 				mc_nic_index = nesvnic->nic_index;
> 			while (nesadapter->pft_mcast_map[mc_index] < 16 &&
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
