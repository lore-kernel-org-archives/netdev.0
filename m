From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: [PATCH] openvswitch: orphan frags on local receive
Date: Tue, 25 Feb 2014 10:07:55 +0800
Message-ID: <530BFAFB.4080904@huawei.com>
References: <530B45E0.20009@huawei.com> <530B5AEC.5020509@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>, <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:50040 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbaBYCIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 21:08:25 -0500
In-Reply-To: <530B5AEC.5020509@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/24 22:45, Zoltan Kiss wrote:
> Hi,
>
> I'm also planning a similar patch, but it will call skb_orphan_frags on
> the skb in datapath.c::queue_userspace_packet, right before
> skb_zerocopy, so packets sent up to userspace via Netlink doesn't harm
> guests. I haven't checked your patch thoroughly, does it handle a
> different scenario?
>
yes, it handle another scenario, and Michael had noted that 
__netif_receive_skb_core could solve it.

I think your patch is still needed, because netif_receive_skb didn't
handle the netlink receive patch. and any skb reserved by host socket
queue might cause guest nic hang.

> Regards,
>
> Zoltan Kiss
>
> On 24/02/14 13:15, Qin Chuanyu wrote:
>> with vhost tx zero_copy, guest nic might get hang when host reserving
>> skb in socket queue delivered by guest, the case has been solved in
>> tun, it also been needed by openvswitch. This could easily happened
>> when a LAST_ACK state tcp occuring between guest and host.
>>
>> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
>> ---
>>  net/openvswitch/vport-internal_dev.c |    3 +++
>>  net/openvswitch/vport.c              |    1 +
>>  2 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/openvswitch/vport-internal_dev.c
>> b/net/openvswitch/vport-internal_dev.c
>> index 729c687..adb25e2 100644
>> --- a/net/openvswitch/vport-internal_dev.c
>> +++ b/net/openvswitch/vport-internal_dev.c
>> @@ -212,6 +212,9 @@ static int internal_dev_recv(struct vport *vport,
>> struct sk_buff *skb)
>>      struct net_device *netdev = netdev_vport_priv(vport)->dev;
>>      int len;
>>
>> +    if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>> +        return -NET_RX_DROP;
>> +
>>      len = skb->len;
>>
>>      skb_dst_drop(skb);
>> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
>> index 208dd9a..04172d6 100644
>> --- a/net/openvswitch/vport.c
>> +++ b/net/openvswitch/vport.c
>> @@ -383,6 +383,7 @@ int ovs_vport_send(struct vport *vport, struct
>> sk_buff *skb)
>>          u64_stats_update_end(&stats->syncp);
>>      } else if (sent < 0) {
>>          ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
>> +        skb_tx_error(skb);
>>          kfree_skb(skb);
>>      } else
>>          ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
>
>
> .
>
