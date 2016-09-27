From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v7 5/8] thunderbolt: Networking state machine
Date: Tue, 27 Sep 2016 16:15:05 +0200
Message-ID: <20160927141505.GD21133@kroah.com>
References: <1474983821-2313-1-git-send-email-amir.jer.levy@intel.com>
 <1474983821-2313-6-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474983821-2313-6-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 04:43:38PM +0300, Amir Levy wrote:
> This patch builds the peer to peer communication path.
> Communication is established by a negotiation process whereby messages are
> sent back and forth between the peers until a connection is established.
> This includes the Thunderbolt Network driver communication with the second
> peer via Intel Connection Manager(ICM) firmware.
>   +--------------------+            +--------------------+
>   |Host 1              |            |Host 2              |
>   |                    |            |                    |
>   |     +-----------+  |            |     +-----------+  |
>   |     |Thunderbolt|  |            |     |Thunderbolt|  |
>   |     |Networking |  |            |     |Networking |  |
>   |     |Driver     |  |            |     |Driver     |  |
>   |     +-----------+  |            |     +-----------+  |
>   |              ^     |            |              ^     |
>   |              |     |            |              |     |
>   | +------------+---+ |            | +------------+---+ |
>   | |Thunderbolt |   | |            | |Thunderbolt |   | |
>   | |Controller  v   | |            | |Controller  v   | |
>   | |         +---+  | |            | |         +---+  | |
>   | |         |ICM|<-+-+------------+-+-------->|ICM|  | |
>   | |         +---+  | |            | |         +---+  | |
>   | +----------------+ |            | +----------------+ |
>   +--------------------+            +--------------------+
> Note that this patch only establishes the link between the two hosts and
> not Network Packet handling - this is dealt with in the next patch.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/icm/Makefile  |   2 +-
>  drivers/thunderbolt/icm/icm_nhi.c | 303 ++++++++++++++-
>  drivers/thunderbolt/icm/net.c     | 793 ++++++++++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/net.h     |  70 ++++
>  4 files changed, 1157 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/thunderbolt/icm/net.c
> 
> diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
> index f0d0fbb..94a2797 100644
> --- a/drivers/thunderbolt/icm/Makefile
> +++ b/drivers/thunderbolt/icm/Makefile
> @@ -1,2 +1,2 @@
>  obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
> -thunderbolt-icm-objs := icm_nhi.o
> +thunderbolt-icm-objs := icm_nhi.o net.o
> diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
> index 984aa7c..578eb14 100644
> --- a/drivers/thunderbolt/icm/icm_nhi.c
> +++ b/drivers/thunderbolt/icm/icm_nhi.c
> @@ -74,6 +74,12 @@ static const struct nla_policy nhi_genl_policy[NHI_ATTR_MAX + 1] = {
>  					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
>  	[NHI_ATTR_MSG_FROM_ICM]		= { .type = NLA_BINARY,
>  					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
> +	[NHI_ATTR_LOCAL_ROUTE_STRING]	= {.len = sizeof(struct route_string)},
> +	[NHI_ATTR_LOCAL_UUID]		= { .len = sizeof(uuid_be) },
> +	[NHI_ATTR_REMOTE_UUID]		= { .len = sizeof(uuid_be) },
> +	[NHI_ATTR_LOCAL_DEPTH]		= { .type = NLA_U8, },
> +	[NHI_ATTR_ENABLE_FULL_E2E]	= { .type = NLA_FLAG, },
> +	[NHI_ATTR_MATCH_FRAME_ID]	= { .type = NLA_FLAG, },
>  };
>  
>  /* NHI genetlink family */
> @@ -522,6 +528,29 @@ int nhi_mailbox(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd, u32 data, bool deinit)
>  	return 0;
>  }
>  
> +static inline bool nhi_is_path_disconnected(u32 cmd, u8 num_ports)
> +{
> +	return (cmd >= DISCONNECT_PORT_A_INTER_DOMAIN_PATH &&
> +		cmd < (DISCONNECT_PORT_A_INTER_DOMAIN_PATH + num_ports));
> +}
> +
> +static int nhi_mailbox_disconn_path(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd)
> +	__releases(&controllers_list_mutex)
> +{
> +	struct port_net_dev *port;
> +	u32 port_num = cmd - DISCONNECT_PORT_A_INTER_DOMAIN_PATH;
> +
> +	port = &(nhi_ctxt->net_devices[port_num]);
> +	mutex_lock(&port->state_mutex);
> +
> +	mutex_unlock(&controllers_list_mutex);
> +	port->medium_sts = MEDIUM_READY_FOR_APPROVAL;
> +	if (port->net_dev)
> +		negotiation_events(port->net_dev, MEDIUM_DISCONNECTED);
> +	mutex_unlock(&port->state_mutex);
> +	return  0;
> +}
> +
>  static int nhi_mailbox_generic(struct tbt_nhi_ctxt *nhi_ctxt, u32 mb_cmd)
>  	__releases(&controllers_list_mutex)
>  {
> @@ -571,13 +600,94 @@ static int nhi_genl_mailbox(__always_unused struct sk_buff *u_skb,
>  		return -ERESTART;
>  
>  	nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
> -	if (nhi_ctxt && !nhi_ctxt->d0_exit)
> -		return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
> +	if (nhi_ctxt && !nhi_ctxt->d0_exit) {
> +
> +		/* rwsem is released later by the below functions */
> +		if (nhi_is_path_disconnected(cmd, nhi_ctxt->num_ports))
> +			return nhi_mailbox_disconn_path(nhi_ctxt, cmd);
> +		else
> +			return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
> +
> +	}
>  
>  	mutex_unlock(&controllers_list_mutex);
>  	return -ENODEV;
>  }
>  
> +static int nhi_genl_approve_networking(__always_unused struct sk_buff *u_skb,
> +				       struct genl_info *info)
> +{
> +	struct tbt_nhi_ctxt *nhi_ctxt;
> +	struct route_string *route_str;
> +	int res = -ENODEV;
> +	u8 port_num;
> +
> +	if (!info || !info->userhdr || !info->attrs ||
> +	    !info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING] ||
> +	    !info->attrs[NHI_ATTR_LOCAL_UUID] ||
> +	    !info->attrs[NHI_ATTR_REMOTE_UUID] ||
> +	    !info->attrs[NHI_ATTR_LOCAL_DEPTH])
> +		return -EINVAL;
> +
> +	/*
> +	 * route_str is an unique topological address
> +	 * used for approving remote controller
> +	 */
> +	route_str = nla_data(info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING]);
> +	/* extracts the port we're connected to */
> +	port_num = PORT_NUM_FROM_LINK(L0_PORT_NUM(route_str->lo));
> +
> +	if (mutex_lock_interruptible(&controllers_list_mutex))
> +		return -ERESTART;
> +
> +	nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
> +	if (nhi_ctxt && !nhi_ctxt->d0_exit) {
> +		struct port_net_dev *port;
> +
> +		if (port_num >= nhi_ctxt->num_ports) {
> +			res = -EINVAL;
> +			goto free_ctl_list;
> +		}
> +
> +		port = &(nhi_ctxt->net_devices[port_num]);
> +
> +		mutex_lock(&port->state_mutex);
> +		mutex_unlock(&controllers_list_mutex);
> +
> +		if (port->medium_sts != MEDIUM_READY_FOR_APPROVAL) {
> +			dev_info(&nhi_ctxt->pdev->dev,
> +				"%s: controller id %#x in state %u <> MEDIUM_READY_FOR_APPROVAL\n",
> +				__func__, nhi_ctxt->id, port->medium_sts);

Why is this needed?  Don't spam the kernel log for a normal device
operation please, only report serious errors when something goes wrong.

And if this is an error, why is it dev_info()?

