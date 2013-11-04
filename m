From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH RESEND] packet: Deliver VLAN TPID to userspace
Date: Mon, 04 Nov 2013 19:33:52 +0100
Message-ID: <5277E890.20308@redhat.com>
References: <87r4bdk8c3.wl%atzm@stratosphere.co.jp>  <20131025.185920.1893524127229371162.davem@davemloft.net>  <1382991074.3779.22.camel@bwh-desktop.uk.level5networks.com>  <878uxbjl4n.wl%atzm@stratosphere.co.jp> <1383585391.1553.7.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Atzm Watanabe <atzm@stratosphere.co.jp>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab3KDSeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 13:34:03 -0500
In-Reply-To: <1383585391.1553.7.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2013 06:16 PM, Ben Hutchings wrote:
> On Wed, 2013-10-30 at 16:03 +0900, Atzm Watanabe wrote:
> [...]
>> Should it be structures as below?
>>
>> struct tpacket_hdr_variant1 {
>>          __u32   tp_rxhash;
>>          __u32   tp_vlan_tci;
>> };
>>
>> struct tpacket_hdr_variant2 {
>>          __u32   tp_rxhash;
>>          __u32   tp_vlan_tci;
>>          __u32   tp_vlan_tpid;
>> };
>>
>> struct tpacket3_hdr {
>>          __u32           tp_next_offset;
>>          __u32           tp_sec;
>>          __u32           tp_nsec;
>>          __u32           tp_snaplen;
>>          __u32           tp_len;
>>          __u32           tp_status;
>>          __u16           tp_mac;
>>          __u16           tp_net;
>>          /* pkt_hdr variants */
>>          union {
>>                  struct tpacket_hdr_variant1 hv1;
>>                  struct tpacket_hdr_variant2 hv2;
>>          };
>> };
>>
>> If it's ok, I'd like to send the patch v2.
> [...]
>
> I think this makes sense.
>
> Also add a BUILD_BUG_ON(TPACKET3_HDRLEN != 48) somewhere.

Sorry for coming late into this discussion.

I think the packet_mmap API with its 3 different API versions
already is a "bit" terrible, and should only be further extended
for user space if there is a _*huge*_ (!) improvement somewhere
(e.g. in terms of packet capturing/transmission performance) that
would justify it. I'm thinking that this could e.g. be in terms
of packet capturing and transmission performance.

Otherwise, each time we want to add a new member, we add yet
another subheader for userspace into tpacket, making it even
more complicated to use, and adding more "legacy" API fragments?

To solve your problem, why don't you add a socket option that,
if _enabled_, would reconstruct the vlan header as it was seen
on the "wire" and push that up to userspace, just like libpcap
does internally. It's not perfect either, but perhaps a better
way to go. What do you think?
