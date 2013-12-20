From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next v3 06/16] i40e: Implementation of vxlan ndo's
Date: Fri, 20 Dec 2013 15:25:44 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1312201504460.25549@intel.com>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com> <1387563694-3166-7-git-send-email-jeffrey.t.kirsher@intel.com> <CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com>
 <20131220.164915.1182500137355120095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "or.gerlitz@gmail.com" <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1119 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771Ab3LTXHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 18:07:53 -0500
In-Reply-To: <20131220.164915.1182500137355120095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 20 Dec 2013, David Miller wrote:

> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Fri, 20 Dec 2013 23:06:06 +0200
> 
> > On Fri, Dec 20, 2013 at 8:21 PM, Jeff Kirsher
> > <jeffrey.t.kirsher@intel.com> wrote:
> >> @@ -244,6 +244,7 @@ config IXGBEVF
> >>  config I40E
> >>         tristate "Intel(R) Ethernet Controller XL710 Family support"
> >>         depends on PCI
> >> +       depends on VXLAN || !VXLAN
> 
> I definitely want a clear detailed explanation for this gross
> dependency.

Right now the code in vxlan.h is:

#if IS_ENABLED(CONFIG_VXLAN)
void vxlan_get_rx_port(struct net_device *netdev);
#else
static inline void vxlan_get_rx_port(struct net_device *netdev)
{
}
#endif

so the function can be called from drivers whether vxlan is enabled in 
.config or not. However, the "depends on VXLAN || !VXLAN" is needed when 
the driver is compiled as a built-in, otherwise we get an undefined 
reference for the above function. If this is not the right way to fix the 
dependency please let me know and I will fix it accordingly.


> 
> >> +       i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_add_udp_tunnel);
> >> +
> >> +       cmd->udp_port = cpu_to_le16(udp_port);
> >> +       cmd->header_len = header_len;
> >> +       cmd->protocol_index = protocol_index;
> >> +
> >> +       status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
> > 
> > so i40e_asq_send_command is called with a spinlock held or under
> > rcu_read_lock from the vxlan driver code but might sleep, as it takes
> > a mutex, seems problematic.
> 
> Indeed this looks like a bug.

Ok, the comment makes sense, I will rework this.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
