From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial
 implementation
Date: Fri, 14 Apr 2017 17:02:54 -0600
Message-ID: <36dd3dd490657d214e034a9c294621db@codeaurora.org>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
 <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
 <20170414091030.2a657c9f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39418 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755432AbdDNXC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 19:02:56 -0400
In-Reply-To: <20170414091030.2a657c9f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/\
>> +dataservices/tree/rmnetctl
> 
> Don't split URL better to have long line.
>> diff --git a/drivers/net/rmnet/Kconfig b/drivers/net/rmnet/Kconfig
> 
> Since this is Qualcomm and Ethernet specific, maybe better to put
> in drivers/net/ethernet/qualcom/rmnet
> 
>> +config RMNET_DEBUG
> 
> Please use network device standard debug mechanism.
> netif_msg_XXX
> 
>> +		buffloc += snprintf(&buffer[buffloc], sizeof(buffer) - buffloc,
>> +					" %02x", skb->data[i]);
> 
> If you really have to do this. Use hex_dump_bytes API.
> 
>> +	skb->mac_header = 0;
>> +	skb->mac_len = 0;
>> +}
> 
> Why not use sbk_set_mac_header(skb, 0)?
> 
>> +static inline struct rmnet_phys_ep_conf_s *_rmnet_get_phys_ep_config
>> +						(struct net_device *dev)
> awkward line break.
> dev could be const
> 
>> +	config = (struct rmnet_phys_ep_conf_s *)
>> +		  rcu_dereference(dev->rx_handler_data);
> 
> Please don't directly reference rx_handler. There is already functions
> like netdev_is_rx_handler_busy() to abstract that API.
> 
>> + * @epconfig:    endpoint configuration structure to set
>> + */
> 
> You are using docbook format here, but this is not a docbook comment.
> ie.
> /**
>  * function - This is a docbook comment
>  * @dev: this is a param
>  */
> 
> Plus these are static functions so there is no point in documentating
> internal API with docbook.
> 
>> +	ASSERT_RTNL();
>> +
>> +	if (!dev || config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
>> +	    config_id >= RMNET_MAX_LOGICAL_EP)
>> +		return -EINVAL;
> 
> For internal API's you should validate parmeters at the external
> entry point not in each call. Otherwise you have a multitude of
> impossible error checks and dead code paths.
> 
>> +	.next = 0,
>> +	.priority = 0
>> +};
> Don't initialize fields that are not used or should be zero.
> 

Hi Stephen

I'll make these changes.

> 
> Could just be:
> 
> static inline int _rmnet_is_physical_endpoint_associated(const struct
> net_device *dev)
> {
> 	rx_handler_func_t *rx_handler
> 		= rcu_dereference(dev->rx_handler);
> 
> 	return rx_handler == rmet_rx_handler;
> }
> 
> But standard practice is to use ndo_ops to identify self in network 
> drivers.
> I.e
> 	return dev->netdev_ops == &rmnet_device_ops;
> 

The netdevice which is associated is the physical (real_dev). This 
device
can vary based on hardware and will have its own netdev_ops associated 
with it.
rmnet_device_ops applies to the rmnet devices only. I'll use the first
option you have suggested.

>> +	if (!data[IFLA_RMNET_MUX_ID])
>> +		return -EINVAL;
> 
> So you are inventing private link netlink attributes.
> Why? Why can't you use device switch, bridge, or other master/slave 
> model.
> 

I would like to eventually add more configuration options for the
ingress & egress data formats as well as the endpoint configuration
(VND mode vs BRIDGE mode). I was able to re-use IFLA_VLAN_ID for
IFLA_RMNET_MUX_ID and test but it wasn't sufficient for the additional
parameters. I'll check the bridge attributes and try to reuse it.
