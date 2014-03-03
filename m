From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: macvtap performance regression (bisected) between 3.13 and 3.14-rc1
Date: Mon, 03 Mar 2014 10:11:35 +0100
Message-ID: <53144747.2070605@de.ibm.com>
References: <530FA586.3010400@de.ibm.com> <53110A62.7070109@redhat.com> <5311C142.6040509@de.ibm.com> <53123495.7030902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	KVM list <kvm@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:59419 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbaCCJLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 04:11:43 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
	Mon, 3 Mar 2014 09:11:41 -0000
In-Reply-To: <53123495.7030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/14 20:27, Vlad Yasevich wrote:
> On 03/01/2014 06:15 AM, Christian Borntraeger wrote:
>> On 28/02/14 23:14, Vlad Yasevich wrote:
>>> On 02/27/2014 03:52 PM, Christian Borntraeger wrote:
>>>> Vlad,
>>>>
>>>> commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
>>>>     macvtap: Add support of packet capture on macvtap device.
>>>>
>>>> causes a performance regression for iperf traffic between two KVM guests
>>>> on my s390 system. Both guests are connected via two macvtaps on the same OSA
>>>> network card.
>>>> Before that patch I get ~20 Gbit/sec between two guests, afterwards I get
>>>> ~4Gbit/sec
>>>>
>>>> Latency seems to be unchanges (uperf 1byte ping pong).
>>>>
>>>> According to ifconfig in the guest, I have ~ 1500 bytes per packet with this
>>>> patch and ~  40000 bytes without. So for some reason this patch causes the
>>>> network stack to do segmentation. (the guest kernel stays the same, only host 
>>>> kernel is changed).
>>>>
>>>> Any ideas?
>>>
>>> I am looking.  It shouldn't cause addition segmentations and when I ran
>>> netperf on the code I didn't see any difference in the throughput.
>>
>> Dont know if the different bytes/packets ratio is really the reason or
>> just a side effect. As a hint: the underlying network device does not support
>> segmentation, but this should not matter for traffic between to guests.
> 
> Could you post 'ethtool -k' output for both lower-level device and the
> macvtap device?




Features for eth0:
rx-checksumming: off [fixed]
tx-checksumming: off
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: off
	tx-scatter-gather: off [fixed]
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [fixed]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]


Features for macvtap1:
rx-checksumming: off [fixed]
tx-checksumming: off
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: off
	tx-scatter-gather: off [fixed]
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [fixed]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
