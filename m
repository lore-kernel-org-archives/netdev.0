From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 14:30:05 -0700
Message-ID: <C811BD6D.312C4%scofeldm@cisco.com>
References: <4BEC63DB.2090306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>, <arnd@arndb.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:15491 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab0EMVaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 17:30:07 -0400
In-Reply-To: <4BEC63DB.2090306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/10 1:40 PM, "Patrick McHardy" <kaber@trash.net> wrote:

> Scott Feldman wrote:
>> +struct ifla_vf_port_vsi {
>> + __u8 vsi_mgr_id;
>> + __u8 vsi_type_id[3];
>> + __u8 vsi_type_version;
>> + __u8 pad[3];
>> +};
> 
> Where is this actually used? The only use I could find is in the
> size calculation.

This is provisioned for VDP use.  The enic implementation (patch 2/2)
doesn't use these members.
 
> Please keep the style used in that file consistent and align arguments
> to the beginning of the opening '('.

I'll fix.
 
>> +{
>> + struct nlattr *data;
>> + int err;
>> +
>> + data = nla_nest_start(skb, IFLA_VF_PORT);
>> + if (!data)
>> +  return -EMSGSIZE;
>> +
>> + if (vf >= 0)
>> +  nla_put_u32(skb, IFLA_VF_PORT_VF, vf);
>> +
>> + err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
>> + if (err == -EMSGSIZE) {
>> +  nla_nest_cancel(skb, data);
>> +  return -EMSGSIZE;
>> + } else if (err) {
>> +  nla_nest_cancel(skb, data);
>> +  return 0;
> 
> Why is the error not returned in this case?

I was think the netdev could fail the call if the operation wasn't
supported.  I better choice would be to not set the netdev->op in the first
place.  Let me fix this.

>> +  if (err)
>> +   goto nla_put_failure;
>> + }
>> +
>> + return 0;
>> +
>> +nla_put_failure:
>> + return -EMSGSIZE;
>> +}
>> +
>>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>>    int type, u32 pid, u32 seq, u32 change,
>>    unsigned int flags)
>> @@ -747,17 +825,23 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct
>> net_device *dev,
>> goto nla_put_failure;
>> copy_rtnl_link_stats64(nla_data(attr), stats);
>>  
>> + if (dev->dev.parent)
>> +  NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
> 
> Should this attribute really be included even if the number is zero?

The previous code would write zero also.  I moved it out of the
get_vf_config check so it could be used for get_vf_port as well.
 
> This is oddly indented, please align .len to .type as in the
> existing attributes.

I'll fix, but bumping into 80 char issues...
 
>> + [IFLA_VF_PORT_VSI_TYPE]  = { .type = NLA_BINARY,
>> +    .len = sizeof(struct ifla_vf_port_vsi)},
>> + [IFLA_VF_PORT_INSTANCE_UUID] = { .type = NLA_BINARY,
>> +    .len = VF_PORT_UUID_MAX },
>> + [IFLA_VF_PORT_HOST_UUID] = { .type = NLA_STRING,
>> +    .len = VF_PORT_UUID_MAX },
>> + [IFLA_VF_PORT_REQUEST]  = { .type = NLA_U8, },
>> + [IFLA_VF_PORT_RESPONSE]  = { .type = NLA_U16, },
>> +};
>> +
>>  struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
>>  {
>> struct net *net;
>> @@ -1028,6 +1127,27 @@ static int do_setlink(struct net_device *dev, struct
>> ifinfomsg *ifm,
>> }
>> err = 0;
>>  
>> + if (tb[IFLA_VF_PORT]) {
>> +  struct nlattr *vf_port[IFLA_VF_PORT_MAX+1];
>> +  int vf = -1;
>> +
>> +  err = nla_parse_nested(vf_port, IFLA_VF_PORT_MAX,
>> +   tb[IFLA_VF_PORT], ifla_vf_port_policy);
>> +  if (err < 0)
>> +   goto errout;
>> +
>> +  if (vf_port[IFLA_VF_PORT_VF])
>> +   vf = nla_get_u32(vf_port[IFLA_VF_PORT_VF]);
>> +  err = -EOPNOTSUPP;
>> +  if (ops->ndo_set_vf_port)
>> +   err = ops->ndo_set_vf_port(dev, vf, vf_port);
> 
> This appears to be addressing a single VF to issue commands.
> I already explained this during the last set of VF patches,
> messages are supposed to by symetrical, since you're dumping
> state for all existing VFs, you also need to accept configuration
> for multiple VFs. Basically, the kernel must be able to receive
> a message it created during a dump and fully recreate the state.

This was modeled same as existing IFLA_VF_ cmd where single VF is addressed
on set, but all VFs for PF are dumped on get.

