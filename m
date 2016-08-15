From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 09:35:50 -0700
Message-ID: <57B1EF66.9060100@gmail.com>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
 <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
 <20160815132436.0d1e34b6@pixies>
 <a27a76e8-d7c3-457d-be98-00cf2d942cf8@mojatatu.com>
 <20160815113653.GD19058@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33904 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHOQg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 12:36:26 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so3845680pac.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 09:36:26 -0700 (PDT)
In-Reply-To: <20160815113653.GD19058@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-15 04:36 AM, Amir Vadai wrote:
> On Mon, Aug 15, 2016 at 06:41:14AM -0400, Jamal Hadi Salim wrote:
>> On 16-08-15 06:24 AM, Shmulik Ladkani wrote:
>>> On Mon, 15 Aug 2016 06:08:10 -0400, jhs@mojatatu.com wrote:
>>
>>>> Assuming $VXLAN is actually not a linux netdev of type vxlan?
>>>> then the action does vxlan encap redirect sends it to the $VXLAN
>>>> dev with encapsulation in place.
>>>
>>> I assume Amir refers to vxlan netdev in VXLAN_F_COLLECT_METADATA mode,
>>> using the tun_info metadata found in skb_metadata_dst.
>>> The action is supposed to assign the tun metadata.
>>>
>>
>> I see - so you let the vxlan netdev do the encap?
>> Would it still scale to a _very large_ number of tunnels?
>> How many netdevs are you going to use? I am assuming you will hit
>> a nasty lock somewhere(qdisc?) if you use only one.
> Having a netdev per tunnel is problematic in its memory use [1].
> User can take each of the approaches. Can have a shared netdev, but will
> have some contention on the qdisc lock, or create a vxlan dev per VNI
> and increase memory use.
> When offloading will be added, shared netdev will enjoy all worlds - low
> memory use and no lock contention.
> 

vxlan devices are lockless if your worried about many netdevs using
shared netdev with metadata is a good approach.


static void vxlan_setup(struct net_device *dev)
{
        struct vxlan_dev *vxlan = netdev_priv(dev);
        unsigned int h;

        eth_hw_addr_random(dev);
        ether_setup(dev);

        dev->destructor = free_netdev;
        SET_NETDEV_DEVTYPE(dev, &vxlan_type);

        dev->features   |= NETIF_F_LLTX;		<--- ;) here
        dev->features   |= NETIF_F_SG | NETIF_F_HW_CSUM;
        dev->features   |= NETIF_F_RXCSUM;
        dev->features   |= NETIF_F_GSO_SOFTWARE;


> 
> [1] - http://www.netdevconf.org/1.1/proceedings/slides/ahern-aleksandrov-prabhu-scaling-network-cumulus.pdf
> 
>>
>> cheers,
>> jamal
