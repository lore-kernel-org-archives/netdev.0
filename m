From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH v2 2/3] rocker: add support for phys_port_name
Date: Tue, 17 Mar 2015 10:11:54 -0600
Message-ID: <5508524A.70807@redfish-solutions.com>
References: <1426562837-13126-1-git-send-email-dsahern@gmail.com> <1426562837-13126-2-git-send-email-dsahern@gmail.com> <5507AD2D.7040905@redfish-solutions.com> <20150317070816.GF2042@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
	Scott Feldman <sfeldma@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:37585 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932146AbbCQQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 12:11:58 -0400
In-Reply-To: <20150317070816.GF2042@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline

On 03/17/2015 01:08 AM, Jiri Pirko wrote:
> Tue, Mar 17, 2015 at 05:27:25AM CET, philipp@redfish-solutions.com wrote:
>> Inline
>>
>> On 03/16/2015 09:27 PM, David Ahern wrote:
>>> Implement the phys_port_name operation. Port names are pulled from the
>>> rocker hardware model in qemu and default to the qemu name + port id.
>>> e.g.,
>>>
>>> sw1p1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
>>>         ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>>>         RX packets 0  bytes 0 (0.0 B)
>>>         RX errors 0  dropped 0  overruns 0  frame 0
>>>         TX packets 0  bytes 0 (0.0 B)
>>>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>>>
>>> where 'sw1' comes from the qemu command line -device rocker,name=sw1, and
>>> 'p1' is port 1.
>>>
>>> Patch is adapted from Scott's phys_port_id patch.
>>>
>>> v2:
>>> - updated per changes in prior patch requested by Jiri
>>>
>>> Signed-off-by: David Ahern <dsahern@gmail.com>
>>> Cc: Scott Feldman <sfeldma@gmail.com>
>>> Cc: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>  drivers/net/ethernet/rocker/rocker.c | 64 ++++++++++++++++++++++++++++++++++++
>>>  drivers/net/ethernet/rocker/rocker.h |  1 +
>>>  2 files changed, 65 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>> index 2511ae22ccd8..e201e7ef9bcf 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>> @@ -30,6 +30,7 @@
>>>  #include <linux/if_vlan.h>
>>>  #include <linux/if_bridge.h>
>>>  #include <linux/bitops.h>
>>> +#include <linux/ctype.h>
>>>  #include <net/switchdev.h>
>>>  #include <net/rtnetlink.h>
>>>  #include <net/ip_fib.h>
>>> @@ -1630,6 +1631,53 @@ rocker_cmd_get_port_settings_macaddr_proc(struct rocker *rocker,
>>>  	return 0;
>>>  }
>>>  
>>> +struct port_name {
>>> +	char *buf;
>>> +	int len;
>> I'd use "unsigned" for the len, since it's never going to be negative.
> It think the best is just to use "size_t" for len

Works for me.

-Philip

>>> +};
>>> +
>>> +static int
>>> +rocker_cmd_get_port_settings_phys_name_proc(struct rocker *rocker,
>>> +					    struct rocker_port *rocker_port,
>>> +					    struct rocker_desc_info *desc_info,
>>> +					    void *priv)
>>> +{
>>> +	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
>>> +	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
>>> +	struct port_name *name = priv;
>>> +	struct rocker_tlv *attr;
>>> +	int i, j = 0, len;
>> I'd make 'i' and 'j' unsigned.
>>
>>
>>> +	char *str;
>>> +
>>> +	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
>>> +	if (!attrs[ROCKER_TLV_CMD_INFO])
>>> +		return -EIO;
>>> +
>>> +	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
>>> +				attrs[ROCKER_TLV_CMD_INFO]);
>>> +	attr = info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_PHYS_NAME];
>>> +	if (!attr)
>>> +		return -EIO;
>>> +
>>> +	len = min_t(int, rocker_tlv_len(attr), name->len);
>>> +	str = rocker_tlv_data(attr);
>>> +
>>> +	/* make sure name only contains alphanumeric characters */
>>> +	for (i = 0; i < len; ++i) {
>> Rather than hiding the initialization of 'j' above, I'd do:
>>
>> i = j = 0;
>>
>> instead.
>>
>>> +		if (isalnum(str[i])) {
>>> +			name->buf[j] = str[i];
>>> +			j++;
>>> +		}
>>> +	}
>>> +
>>> +	if (j == 0)
>>> +		return -EIO;
>>> +
>>> +	name->buf[j] = '\0';
>>> +
>>> +	return 0;
>>> +}
>>> +
>>>  static int
>>>  rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
>>>  					  struct rocker_port *rocker_port,
>>> @@ -4138,6 +4186,21 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>>  				       rocker_port->brport_flags, mask);
>>>  }
>>>  
>>> +static int rocker_port_get_phys_port_name(struct net_device *dev,
>>> +					  char *buf, int len)
>> I'd use unsigned for 'len'.
>>
>>> +{
>>> +	struct rocker_port *rocker_port = netdev_priv(dev);
>>> +	struct port_name name = { .buf = buf, .len = len };
>>> +	int err;
>>> +
>>> +	err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
>>> +			      rocker_cmd_get_port_settings_prep, NULL,
>>> +			      rocker_cmd_get_port_settings_phys_name_proc,
>>> +			      &name, false);
>>> +
>>> +	return err ? -EOPNOTSUPP : 0;
>>> +}
>>> +
>>>  static const struct net_device_ops rocker_port_netdev_ops = {
>>>  	.ndo_open			= rocker_port_open,
>>>  	.ndo_stop			= rocker_port_stop,
>>> @@ -4150,6 +4213,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
>>>  	.ndo_fdb_dump			= rocker_port_fdb_dump,
>>>  	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
>>>  	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
>>> +	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
>>>  };
>>>  
>>>  /********************
>>> diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
>>> index 51e430d25138..a4e9591d7457 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.h
>>> +++ b/drivers/net/ethernet/rocker/rocker.h
>>> @@ -158,6 +158,7 @@ enum {
>>>  	ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,		/* binary */
>>>  	ROCKER_TLV_CMD_PORT_SETTINGS_MODE,		/* u8 */
>>>  	ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,		/* u8 */
>>> +	ROCKER_TLV_CMD_PORT_SETTINGS_PHYS_NAME,		/* binary */
>>>  
>>>  	__ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
>>>  	ROCKER_TLV_CMD_PORT_SETTINGS_MAX =
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
