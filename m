From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Tue, 25 Mar 2014 20:53:24 -0400 (EDT)
Message-ID: <20140325.205324.1845346581147557473.davem@davemloft.net>
References: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
	<CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
	<CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike.rapoport@ravellosystems.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbaCZAxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 20:53:25 -0400
In-Reply-To: <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Sun, 23 Mar 2014 16:43:52 +0200

> On Sun, Mar 23, 2014 at 11:27 AM, Mike Rapoport
> <mike.rapoport@ravellosystems.com> wrote:
> 
>> I believe I've groked what's going on in vxlan_udp_encap_recv and
>> vxlan_rcv. There are actually two unrelated problems:
>>
>> 1) When the vxlan is configured with IPv4 group it crashes when it
>> starts to receive IPv6 IGMP packets encapsulated into IPv4 vxlan
>> packets. This happens because when ipv6_rcv handles the inner packet,
>> the skb->dst still refernces outer IPv4 info. The very old vxlan code
>> had skb_dst_drop call in vxlan_udp_encap_recv, which was removed when
>> vxlan was refactored to use iptunnel_pull_header (commit
>> 7ce04758279514ca1d8ebfe322508a4a430fe2c8: "vxlan: Restructure vxlan
>> receive"). The iptunnel_pull_header called skb_dst_drop until recent
>> commit 10ddceb22bab11dab10ba645c7df2e4a8e7a5db5 ("ip_tunnel:multicast
>> process cause panic due to skb->_skb_refdst NULL pointer").
>> The simplest fix, I think, would be to restore call to skb_dst_drop in
>> vxlan_udp_encap_recv.
> 
> Yep, following Mike's suggestion, adding the below call allows things to work,
> where trying vxlan without OVS, e.g using
> 
> $ ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
> 
> $ ifconfig vxlan42 192.168.42.54/24 up
> 
> over the net tree with 3.14-rc6 and beyond crashes instantly on node A
> when node B is
> taken up and starts sending, so commit 10ddceb22b indeed introduced a
> regression.

It turns out we are going to partially revert that commit and
iptunnel_pull_header() will start doing the skb_dst_drop() again.

See:

	http://patchwork.ozlabs.org/patch/332956/

for details.

Will that fix this bug too?

Thanks.
