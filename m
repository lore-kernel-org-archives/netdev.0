From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v5] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Thu, 17 Aug 2017 00:38:31 -0600
Message-ID: <0bcdb3670a82c3b73567cd3d5e70340b@codeaurora.org>
References: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
 <1502931307-517-4-git-send-email-subashab@codeaurora.org>
 <1502939764.30484.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@aculab.com,
        marcel@holtmann.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42606 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdHQGic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 02:38:32 -0400
In-Reply-To: <1502939764.30484.7.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm probably forgetting a bit of the original context.  Say you have
> one of these "network devices in IP mode".  What happens with the
> device *before* you attach an rmnet child?  Can it pass traffic before
> that point at all, or does the modem expect MAP already?

Hi Dan

All traffic needs to be in MAP format only.

>> +	dev_hold(real_dev);
> 
> I could be entirely wrong, but isn't this mostly handled for you if you
> use netdev_upper_dev_link() like ipvlan and macvlan do?  That looks
> like it provides a couple things: (a) handles the dev_hold() for you
> and (b) provides mechanisms to get the upper device if you need it.
> I'm not actually familiar with the "adjacent device" functionality, but
> it looked similar in purpose.

Does this API modify the data path as well or is it only for 
establishing
a hierarchy between nodes (which I assume should help for easier 
cleanup).
Currently, I register with the real_dev and use the rx_handler to 
intercept
the incoming MAP packets. If netdev_upper_dev_link only modifies the 
device
refcounting, I should be able to easily modify to use it.

> 
>> +	return 0;
>> +}
>> +
>> +static int __rmnet_set_endpoint_config(struct net_device *dev, int
>> config_id,
>> +				       struct rmnet_endpoint *ep)
>> +{
>> +	struct rmnet_endpoint *dev_ep;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	dev_ep = rmnet_get_endpoint(dev, config_id);
>> +
>> +	if (!dev_ep || dev_ep->refcount)
>> +		return -EINVAL;
>> +
>> +	memcpy(dev_ep, ep, sizeof(struct rmnet_endpoint));
>> +	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
>> +		dev_ep->mux_id = 0;
>> +	else
>> +		dev_ep->mux_id = config_id;
> 
> So... if config_id is LOGICAL_ENDPOINT (-1) this sets mux_id to 0.
> 
> But if config_id is 0, it *also* sets mux_id to 0?
> 
> Can you clarify what mux_id = 0 actually means here?  Can you also talk
> a bit about the difference between local_ep and muxed_ep?
> 

mux_id 0 is for the pass through mode (for the testing scenario).
The MAP packets arriving maybe shipped as is to a different net device
(say one exposed by USB).

While transmitting packets from rmnet dev to real_dev, the local_ep
has the information about the rmnet dev. Based on that, the MAP
header is stamped and packet is transmitted.

muxed_ep is for receiving the packets where the MAP header is
stripped off and the packets is passed to the appropriate rmnet dev.

>> +	case NETDEV_UNREGISTER_FINAL:
> I don't see anywhere that RMNET_INGRESS_FIX_ETHERNET can get set?
> Also, can't that be autodetected?
> 
> 
> Just use ETH_HLEN instead of RMNET_ETHERNET_HEADER_LENGTH.
> 
> But really, I can't see where FIX_ETHERNET ever gets set.  And as
> above, can't this be automatically detected?  Can you describe what the
> issue is here in more detail?
> 
> I know for qmi_wwan.c we had to fix up a number of firmware bugs, but
> all that is done automatically.
> 
The ethernet mode was earlier for some experimental configurations.

>> +	int egress_format = RMNET_EGRESS_FORMAT_MUXING |
>> +			    RMNET_EGRESS_FORMAT_MAP;
>> +	struct net_device *real_dev;
>> +	int mode = RMNET_EPMODE_VND;
>> +	u16 mux_id;
>> +
>> +	real_dev = __dev_get_by_index(src_net,
>> nla_get_u32(tb[IFLA_LINK]));
>> +	if (!real_dev || !dev)
>> +		return -ENODEV;
>> +
>> +	if (!data[IFLA_VLAN_ID])
> 
> Also, I wasn't thinking to actually *use* IFLA_VLAN_ID, but I'll let
> others weigh in.  It does fit in this case, I think, but maybe creating
> an RMNET-specific attribute would be better?
> 

I have implemented a single message for setting up the device based on 
mux
in this patchset so this suffices for me :) . Stephen had suggested to 
reuse
existing structs as much as possible.

>> +struct rmnet_map_control_command {
>> +	u8  command_name;
>> +	u8  cmd_type:2;
>> +	u8  reserved:6;
>> +	u16 reserved2;
>> +	u32 transaction_id;
>> +	union {
>> +		u8  data[65528];
> 
> Um....  that seems really, really odd.  Typically this would go below
> the flow_control struct, and actually be:
> 
> u8 data[0];
> 
> To indicate that the struct member should exist and that you can use
> it, but that it has no specific size (since the size will be determined
> by the skb size or by a protocol field instead).
> 
> Thats all for now...
> 
> Dan
> 

I will change this to u8 data[0];
