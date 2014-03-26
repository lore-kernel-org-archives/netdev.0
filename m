From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 26 Mar 2014 11:47:54 +0200
Message-ID: <20140326094754.GA19337@zed>
References: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
 <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
 <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
 <20140325.205324.1845346581147557473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Stevens <dlstevens@us.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:45463 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaCZJsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 05:48:00 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so1427921eek.36
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 02:47:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140325.205324.1845346581147557473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 2:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Sun, 23 Mar 2014 16:43:52 +0200
>
>> On Sun, Mar 23, 2014 at 11:27 AM, Mike Rapoport
>> <mike.rapoport@ravellosystems.com> wrote:
>>
>>> 1) When the vxlan is configured with IPv4 group it crashes when it
>>> starts to receive IPv6 IGMP packets encapsulated into IPv4 vxlan
>>> packets. This happens because when ipv6_rcv handles the inner packet,
>>> the skb->dst still refernces outer IPv4 info. The very old vxlan code
>>> had skb_dst_drop call in vxlan_udp_encap_recv, which was removed when
>>> vxlan was refactored to use iptunnel_pull_header (commit
>>> 7ce04758279514ca1d8ebfe322508a4a430fe2c8: "vxlan: Restructure vxlan
>>> receive"). The iptunnel_pull_header called skb_dst_drop until recent
>>> commit 10ddceb22bab11dab10ba645c7df2e4a8e7a5db5 ("ip_tunnel:multicast
>>> process cause panic due to skb->_skb_refdst NULL pointer").
>>> The simplest fix, I think, would be to restore call to skb_dst_drop in
>>> vxlan_udp_encap_recv.
>>
>> Yep, following Mike's suggestion, adding the below call allows things to work,
>> where trying vxlan without OVS, e.g using
>>
>> $ ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN
>>
>> $ ifconfig vxlan42 192.168.42.54/24 up
>>
>> over the net tree with 3.14-rc6 and beyond crashes instantly on node A
>> when node B is
>> taken up and starts sending, so commit 10ddceb22b indeed introduced a
>> regression.
>
> It turns out we are going to partially revert that commit and
> iptunnel_pull_header() will start doing the skb_dst_drop() again.
>
> See:
>
>         http://patchwork.ozlabs.org/patch/332956/
>
> for details.
>
> Will that fix this bug too?

It fixes the instant crashes occurring when vxlan interface goes up, but
I have other crashes with custom vxlan configuration, e.g. in the
following scenario:

Node A:
$ ip link add vxlan1 type vxlan id 1 dev ethA
$ ip addr add dev vxlan1 10.0.0.1/24
$ ip link set up dev vxlan1
$ bridge fdb append 00:00:00:00:00:00 dev vxlan1 dst <ethB IPv4 address>

Node B:
$ ip link add vxlan1 type vxlan id 1 dev ethB
$ ip addr add dev vxlan1 10.0.0.2/24
$ ip link set up dev vxlan1
$ bridge fdb append 00:00:00:00:00:00 dev vxlan1 dst <ethA A IPv4 address>
$ ping 10.0.0.1

Node A gets NULL pointer dereference at ip6_route_output.

Setting defailt_dst family to AF_INET (see below) and making it
consistent with actual vxlan socket family solves the problem for IPv4 case. 
As for the IPv6 with custom vxlan configuration, it's not functional at
the moment because unless v6 is explicitly specified by either
IFLA_VXLAN_GROUP6 or IFLA_VXLAN_LOCAL6, the driver assumes IPv4 and will
crash when it's trying to xmit to an fdb entry with IPv6 address.
Disallowing addition of fdb entries with IPv6 destinations in this case
prevents such crashes.
If these changes are acceptable I'll resend them as proper patch.

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1236812..f389cbc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -871,6 +871,9 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (err)
 		return err;
 
+	if (vxlan->default_dst.remote_ip.sa.sa_family != ip.sa.sa_family)
+		return -EAFNOSUPPORT;
+
 	spin_lock_bh(&vxlan->hash_lock);
 	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags,
 			       port, vni, ifindex, ndm->ndm_flags);
@@ -2612,9 +2615,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 	dst->remote_vni = vni;
 
+	dst->remote_ip.sa.sa_family = AF_INET;
 	if (data[IFLA_VXLAN_GROUP]) {
 		dst->remote_ip.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
-		dst->remote_ip.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_GROUP6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;

> Thanks.

-- 
Sincerely yours,
Mike.
