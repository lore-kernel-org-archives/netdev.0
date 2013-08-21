From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: Performance regression 3.11 with macvlan between 2 linux guests
 (bisected)
Date: Wed, 21 Aug 2013 14:12:06 -0400
Message-ID: <521502F6.5030005@redhat.com>
References: <5214B4D4.7020806@de.ibm.com> <52150145.7020801@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab3HUSMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 14:12:14 -0400
In-Reply-To: <52150145.7020801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 02:04 PM, Vlad Yasevich wrote:
> On 08/21/2013 08:38 AM, Christian Borntraeger wrote:
>> Vlad,
>>
>> the patch
>>
>> commit 3e4f8b787370978733ca6cae452720a4f0c296b8
>> Author: Vlad Yasevich <vyasevic@redhat.com>
>> Date:   Tue Jun 25 16:04:22 2013 -0400
>>
>>      macvtap: Perform GSO on forwarding path.
>>
>> causes a severe performance regression for 2 Linux guests with virtio-net
>> connected via macvlan/vtap doing iperf workload. (2GBit vs. 20Gbit)
>>
>> If I understand the patch correctly, we now check for gso depending on
>> the
>> macvlan features. If the underlying hardware does not support the
>> necessary
>> offloads then we will do segmentation, even if we keep the whole
>> traffic internal
>> between two guests and even if both guests supports LRO,GSO etc.
>> ---snip---
>> [...]
>> +       features = netif_skb_features(skb) & vlan->tap_features;
>> +       if (netif_needs_gso(skb, features)) {
>> +               struct sk_buff *segs = __skb_gso_segment(skb,
>> features, false);
>> [...]
>>
>> ---snip---
>> Shouldnt we take the features of the target device or even better do
>> the gsoing in the
>> target device driver?
>
> A corrected patch has been sent upstream.  We take into consideration
> the features on the target device that the user/vm has specified.
> If the VM has enabled the TSO flags, then nothing will happen to the
> GSO packet.  However, if the TSO flag is off, segmentation will be
> performed.

Particularly.  This commit should fix the issue:
commit a567dd6252263c8147b7269df5d03d9e31463e11
  macvtap: simplify usage of tap_features

-vlad

>
> -vlad
>
>>
>> Christian
>>
>> FYI, the underlying HW has:
>>
>> Features for eth0:
>> rx-checksumming: off [fixed]
>> tx-checksumming: off
>>     tx-checksum-ipv4: off [fixed]
>>     tx-checksum-ip-generic: off [fixed]
>>     tx-checksum-ipv6: off [fixed]
>>     tx-checksum-fcoe-crc: off [fixed]
>>     tx-checksum-sctp: off [fixed]
>> scatter-gather: off
>>     tx-scatter-gather: off [fixed]
>>     tx-scatter-gather-fraglist: off [fixed]
>> tcp-segmentation-offload: off
>>     tx-tcp-segmentation: off [fixed]
>>     tx-tcp-ecn-segmentation: off [fixed]
>>     tx-tcp6-segmentation: off [fixed]
>> udp-fragmentation-offload: off [fixed]
>> generic-segmentation-offload: off [requested on]
>> generic-receive-offload: on
>> large-receive-offload: off [fixed]
>> rx-vlan-offload: off [fixed]
>> tx-vlan-offload: off [fixed]
>> ntuple-filters: off [fixed]
>> receive-hashing: off [fixed]
>> highdma: off [fixed]
>> rx-vlan-filter: on [fixed]
>> vlan-challenged: off [fixed]
>> tx-lockless: off [fixed]
>> netns-local: off [fixed]
>> tx-gso-robust: off [fixed]
>> tx-fcoe-segmentation: off [fixed]
>> tx-gre-segmentation: off [fixed]
>> tx-udp_tnl-segmentation: off [fixed]
>> tx-mpls-segmentation: off [fixed]
>> fcoe-mtu: off [fixed]
>> tx-nocache-copy: off
>> loopback: off [fixed]
>> rx-fcs: off [fixed]
>> rx-all: off [fixed]
>> tx-vlan-stag-hw-insert: off [fixed]
>> rx-vlan-stag-hw-parse: off [fixed]
>> rx-vlan-stag-filter: off [fixed]
>>
>
