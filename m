From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH 7/8] net: support tx_ring per UP in HW based QoS mechanism
Date: Thu, 15 Mar 2012 12:05:29 +0200
Message-ID: <4F61BEE9.9040106@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com> <1331659323-12904-8-git-send-email-amirv@mellanox.com> <4F5F9087.7090607@intel.com> <4F606E5A.6080407@mellanox.com> <4F610F77.7010200@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Liran Liss <liranl@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:48455 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754285Ab2COKFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 06:05:42 -0400
In-Reply-To: <4F610F77.7010200@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2012 11:36 PM, John Fastabend wrote:
> On 3/14/2012 3:09 AM, Amir Vadai wrote:
>> On 03/13/2012 08:23 PM, John Fastabend wrote:
>>> On 3/13/2012 10:22 AM, Amir Vadai wrote:
>>>> From: Amir Vadai<amirv@mellanox.co.il>
>>>>
>>>> The Current HW based QoS mechanism which was introduced in commit 4f57c087de9
>>>> "net: implement mechanism for HW based QOS" is in orientation to ETS traffic
>>>> class. This patch introduces an approach which allow to use this mechanism also
>>>> with hardware who has queues per user priority (UP). After the change,
>>>> __skb_tx_hash() will direct a flow to a tx ring from a range of tx rings. This
>>>> range is defined by the caller function by the specific HW. If TC based queues,
>>>> the range is by TC number and for UP based queues, the range is by UP.
>>>>
>>> ETS is one specific use case for mqprio it can easily be used with other
>>> hardware transmission selection algorithms 802.1Q std based or otherwise.
>>>
>>> The mapping is really just an skb->priority to group of queues (qoffset and
>>> qcount). I happened to call the queue grouping a traffic class because that
>>> aligns with 802.1Q but it _really_ is just a queue grouping.
>
>> This is good for untagged traffic, but for tagged traffic I can see 2 problems with this approach:
>> 1. mqprio mapping could contradict egress map or 8021Qaz mapping (UP
>> <=>  TC). This could be solved (not very elegantly) by forcing the
>> mappings to be synced.
>
> OK. We've just been keeping them in-sync.
>
>> 2. egress map is per vlan, and mqprio mapping
>> is one global mapping.
>
> So it only matters when you want the egress map per vlan? The problem
> I see with this now is the mellanox driver does DCB differently then
> the existing drivers.
>
> For example if I put a task in a net_prio cgroup and assign the vlan
> a priority this won't actually steer the packet correctly on mlx. I
> also have to create an egress map existing drivers will ignore the
> egress_map and steer the skb as they always have.
But if you don't create an egress map for tagged traffic. What will be 
in the PCP field of the vlan tag (= User Priority)?
>
> At minimum skbs need to be steered the same on all drivers. We can't
> expect user space to "know" what hardware is underneath.
>
>>>
>>> In your case what would it mean to change the map and num_tc see 'tc':
>>>
>>> [root@jf-dev1-dcblab netperf]# tc qdisc add dev eth3 root mqprio help
>>> Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
>>>                     [queues count1@offset1 count2@offset2 ...] [hw 1|0]
>>>
>>> For example setting 'num_tc 8 map 0 1 2 3 0 1 2 3' looks like it might
>>> not work correctly. Would you end up with an skb tagged with priority
>>> 4,5,6,7 being sent out UP queues 0,1,2,3? My quess is that won't work
>>> with PFC or your ETS correctly.
>> I don't see a problem here. For example, skb tagged with priority 5
>> is mapped to UP 1. And sent through one of the tx rings of UP 1. All
>> the rings of UP 1 share the same transmission queue (schedule queue)
>> which is controlled by PFC and ETS by the HW. What is the problem
>> here?
>
> I was concerned about the actual tag that gets added. In ixgbe we've been
> adding a tag based on skb->priority in the untagged pkt case. In your
> driver after looking at the code either your not adding a tag or the
> hardware is adding the correct user priority to the priority tagged pkts.
It is added by the HW according to the tx_ring.
>
> We use the skb->priority in ixgbe because we can have multiple user
> priorities (PCPs) on a single tx_ring with the above map. We have
> no other way to know what the priority should be in the untagged
> case.
Instead of attaching a tx_ring to ETS TC like your driver does, in our 
driver a tx_ring is attached to a single user priority (UP).
With this UP and the mapping UP <=> TC configured by DCB netlink to the 
HW, the HW can enforce the 8021Qaz attributes by the mapped TC.
For tagged traffic this UP is also used in the PCP field in the vlan tag.
>
>>>
>>> In the canonical iSCSI case we put iscsid in a net_prio cgroup to get the
>>> priority set then use the priority to steer the skb to the correct queue
>>> groupings. In your case I think you can just fail any num_tc != 8 and keep
>>> the dflt map 1:1 then this should work. What did I miss? It looks like you
>>> already fail the num_tc != 8 case so why do we need this change?
>>>
>>> At most maybe we need a flag to indicate the mqprio map can't be changed in
>>> some cases.
>> What you suggest is that the priority in net_prio cgroup will be the User Priority, and not just the skb priority?
>
> That is how we are using it today yes. Which creates the some what
> unfortunate case (I guess) that the egress map has to be aligned
> with the qdisc map. This hasn't caused any problems in practice for us.
>
>> And also, for tagged traffic, how could it be forced to be synced with egress map?
>
> there is a priority in net_prio.ifpriomap group for each vlan as well as
> real device so we just setup the mapping for the vlan.
>
> This is how we do things like assign a vlan a default priority.
>
>
>>> [...]
>>>
>>>>
>>>>    void bnx2x_set_num_queues(struct bnx2x *bp)
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>>> index 7a49830..d0d96e3 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>>> @@ -570,18 +570,15 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
>>>>
>>>>    u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
>>>>    {
>>>> -    struct mlx4_en_priv *priv = netdev_priv(dev);
>>>> -    int up = -1;
>>>> +    int up = 0;
>>>>
>>>>        if (vlan_tx_tag_present(skb))
>>>>            up = (vlan_tx_tag_get(skb)>>   13);
>>> I was trying to avoid logic like this in select_queue().
>> Why?
>
> Because this makes your driver potentially behave differently then
> other drivers. DCB should look the same from the user side
> regardless of the driver.
I agree - it should look the same.
>
>>>
>>> Can we get the same behavior by keeping the egress map and mqprio
>>> map in sync?
>> As I said above, if we force egress map to be synced to mqprio mapping, we loose it's power - mqprio is global, and egress map is per vlan.
>
> using net_prio cgroups per vlan allows per vlan priority mappings.
> I agree this is a bit awkward right now and it seems reasonable
> to expect setting the egress_map causes the skb steering to work
> correctly.
>
> The crux of the issue here is that ixgbe and bnx2x are modeling
> the qdisc tc as a traffic class but your hardware is based on
> a model that exposes user priorities. We need these to look the
> same from the user perspective. We need to figure out how to
> make this correct for both models. Any suggestions?
Before suggesting, I need to make sure I understand the current model:

Assumptions
-----------
a. If tagged traffic is involved, egress map is configured 1:1 and
    therefore, skb priority = User Priority (UP)
b. mqprio traffic class is ETS TC

Mappings in use
---------------
1. net_prio cgroup: netdev + task <=> skb priority
2. SO_PRIORITY/SO_IP_TOS: skb_priority
3. mqprio: skb priority <=> traffic class
4. DCB netlink: UP <=> ETS TC

Untagged traffic
----------------
User is using [1] or [2] to tag a flow with priority.
Driver is using [3] to steer traffic according to 8021Qaz ETS attributes.

Tagged traffic
--------------
User is using [1] or [2] to tag a flow with priority
Driver is setting PCP bits in vlan header using skb priority (1:1 in 
egress map).
Traffic is steered using [3].

Mapping [4] must be synced with [3].

>
> .John


- Amir
