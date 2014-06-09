From: Cong Wang <cwang@twopensource.com>
Subject: Re: Bug 75571
Date: Mon, 9 Jun 2014 16:49:02 -0700
Message-ID: <CAHA+R7Nnm0ueWPKYYT0M1Nn8DOcKcRiDG6-Py+OcNgvvnqO2Ng@mail.gmail.com>
References: <1401085231.1775.9.camel@anpws>
	<CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	<1401870692.29664.1.camel@anpws>
	<CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
	<1401945732.29664.6.camel@anpws>
	<CAHA+R7Mi-mBXWSytEtJhqEfjYQyrd9zae5GndYy3qmK=+_mk_g@mail.gmail.com>
	<1402027981.29664.16.camel@anpws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:60050 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933234AbaFIXtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 19:49:03 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1485155qcy.29
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 16:49:02 -0700 (PDT)
In-Reply-To: <1402027981.29664.16.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 5, 2014 at 9:13 PM, Alex <d77190@mail.ru> wrote:
>> Hmm, e1000e should init dev->hard_header_len to ETH_LEN, which is 14.
>> Plus IPv4 header len (20), it should be about 34. I don't understand why
>> the ipip tunnel's hard_header_len is 148 in your case. It is only possible when
>> there is no underlying interface, that is, LL_MAX_HEADER + sizeof(struct iphdr).
>>
>> What do `ip -d link show` and `ip route show` say?
>
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP mode DEFAULT group default qlen 1000
>     link/ether 00:15:17:28:a7:02 brd ff:ff:ff:ff:ff:ff
>
> 7: eth0.99@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue state UP mode DEFAULT group default
>     link/ether 00:15:17:28:a7:02 brd ff:ff:ff:ff:ff:ff
>     vlan protocol 802.1q id 99 <REORDER_HDR>
>
> 84: tun4177: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc htb state
> UNKNOWN mode DEFAULT group default
>     link/ipip 192.168.18.199 peer 192.168.18.17
>
>
> 192.168.18.199 is loopback address.
>
> ip route show dev eth0.99
> 172.16.254.132/30  proto kernel  scope link  src 172.16.254.134
> 192.168.18.0/26 via 172.16.254.133  proto zebra
> .... and about 200 networks received via BGP
>
> ip route show dev tun4177
> 198.18.0.177  proto kernel  scope link  src 198.18.0.1
> 198.18.100.3 via 198.18.0.177  proto zebra  metric 17
> .... and about 500 routes to hosts recieved via OSPF


Hmm, looks correct so I still have no idea why dev->hard_header_len
is not correct for your ipip tunnel, looks like the only possible reason
is ip_route_output_ports() returns error for some reason.

The best thing we can try is to fix it dynamically on rx, something
like below (if you want to try this patch, please revert the previous one):

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 5dc5137..5eff109 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -407,6 +407,7 @@ static int ipip_rcv(struct sk_buff *skb)
                tstats->rx_packets++;
                tstats->rx_bytes += skb->len;

+               tunnel->dev->hard_header_len = skb->data - skb_mac_header(skb);
                __skb_tunnel_rx(skb, tunnel->dev);

                ipip_ecn_decapsulate(iph, skb);
