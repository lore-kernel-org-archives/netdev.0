From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Wed, 4 Oct 2017 00:03:01 +0900
Message-ID: <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
 <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
 <20171003121636.GB13548@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        David Miller <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37409 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbdJCPDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 11:03:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id e69so9386539pfg.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 08:03:10 -0700 (PDT)
In-Reply-To: <20171003121636.GB13548@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/10/03 (火) 21:16, Andrew Lunn wrote:
> On Tue, Oct 03, 2017 at 12:29:56PM +0900, Toshiaki Makita wrote:
>> On 2017/10/03 9:55, Andrew Lunn wrote:
>>> With CONFIG_BRIDGE_VLAN_FILTERING enabled, but the feature not enabled
>>> via /sys/class/net/brX/bridge/vlan_filtering, mdb offloaded to the
>>> kernel have the wrong VID.
>>>
>>> When an interface is added to the bridge, switchdev is first used to
>>> notify the hardware that a port has joined a bridge. This is
>>> immediately followed by the default_pvid, 1, being added to the
>>> interface via another switchdev call.
>>>
>>> The bridge will then perform IGMP snooping, and offload an mdb entries
>>> to the switch as needed. With vlan filtering disabled, the vid is left
>>> as 0. This causes the switch to put the static mdb into the wrong
>>> vlan, and so frames are not forwarded by the mdb entry.
>>>
>>> If vlan filtering is disable, use the default_pvid, not 0.
>>>
>>> Fixes: f1fecb1d10ec ("bridge: Reflect MDB entries to hardware")
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> ---
>>>  net/bridge/br_vlan.c | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>>> index 233a30040c91..aa3589891797 100644
>>> --- a/net/bridge/br_vlan.c
>>> +++ b/net/bridge/br_vlan.c
>>> @@ -492,6 +492,7 @@ bool br_allowed_ingress(const struct net_bridge *br,
>>>  	 */
>>>  	if (!br->vlan_enabled) {
>>>  		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
>>> +		*vid = br_get_pvid(vg);
>>>  		return true;
>>>  	}
>>>
>>
>> This does not look correct.
>> This will update fdb with vid which is not 0.
>> Pvid can be different between each port even when vlan_filtering is
>> disabled so unicast forwarding (fdb learning) will break.
>> Also, fdb is visible to userspace so this can break userspace which
>> expects fdb entries with 0 as well.
>>
>> Why does the switch driver use pvid while vlan_filtering is disabled?
>
> Hi Toshiaki
>
> We get a vlan added to the port. I think it comes from a combination
> of:
>
>
> int br_vlan_init(struct net_bridge *br)
> {
>         struct net_bridge_vlan_group *vg;
>         int ret = -ENOMEM;
>
>         vg = kzalloc(sizeof(*vg), GFP_KERNEL);
>         if (!vg)
>                 goto out;
>         ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
>         if (ret)
>                 goto err_rhtbl;
>         ret = vlan_tunnel_init(vg);
>         if (ret)
>                 goto err_tunnel_init;
>         INIT_LIST_HEAD(&vg->vlan_list);
>         br->vlan_proto = htons(ETH_P_8021Q);
>         br->default_pvid = 1;
>
> and
>
> int nbp_vlan_init(struct net_bridge_port *p)
> {
>         struct switchdev_attr attr = {
>                 .orig_dev = p->br->dev,
>                 .id = SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
>                 .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>                 .u.vlan_filtering = p->br->vlan_enabled,
>         };
>         struct net_bridge_vlan_group *vg;
>         int ret = -ENOMEM;
>
>         vg = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
>         if (!vg)
>                 goto out;
>
>         ret = switchdev_port_attr_set(p->dev, &attr);
>         if (ret && ret != -EOPNOTSUPP)
>                 goto err_vlan_enabled;
>
>         ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
>         if (ret)
>                 goto err_rhtbl;
>         ret = vlan_tunnel_init(vg);
>         if (ret)
>                 goto err_tunnel_init;
>         INIT_LIST_HEAD(&vg->vlan_list);
>         rcu_assign_pointer(p->vlgrp, vg);
>         if (p->br->default_pvid) {
>                 ret = nbp_vlan_add(p, p->br->default_pvid,
>                                    BRIDGE_VLAN_INFO_PVID |
>                                    BRIDGE_VLAN_INFO_UNTAGGED);
>
> Now, i just noticed the switchdev call above. I don't think the DSA
> layer implements SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING. It probably
> should. So what is it supposed to do with this VLAN when filtering is
> disabled?

The vlan will be effective only when vlan_filtering is enabled.
When vlan_filtering is disabled, vlan information is still kept in the 
bridge and gets effective later when vlan_filtering becomes enable.

Toshiaki Makita
