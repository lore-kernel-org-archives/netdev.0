From: Jeff Barnhill <0xeffeff@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Fri, 27 Oct 2017 01:19:06 -0400
Message-ID: <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com> <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:43583 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdJ0FTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:19:07 -0400
Received: by mail-oi0-f67.google.com with SMTP id c77so9281907oig.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 22:19:07 -0700 (PDT)
In-Reply-To: <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, David.

I corrected the static route, applied the patch, and set the
link/output dev on the tunnel and it works now.  Is it required to set
the link/output dev?  I was thinking that this should not be required
for cases where the outgoing device is not known, for instance on a
router or device with multiple interfaces.

Also, what is the expected behavior of loopback addresses in a VRF
context?  For instance, if an application were being run under "ip vrf
exec" and it tried to use these addresses.

jeff@VM2:~$ ping -I myvrf 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
^C
--- 127.0.0.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2033ms

jeff@VM2:~$ ping -I myvrf ::1
connect: Network is unreachable

Thanks,
Jeff


On Thu, Oct 26, 2017 at 1:24 PM, David Ahern <dsahern@gmail.com> wrote:
> On 10/25/17 9:28 PM, Jeff Barnhill wrote:
>> Thanks, David.
>>
>> VM1:
>> sudo ip addr add 192.168.200.1/24 dev enp0s8 broadcast 192.168.200.255
>> sudo ip link set enp0s8 up
>> sudo ip route add 192.168.210.0/24 nexthop via 192.168.200.3 dev enp0s8
>> sudo ip tunnel add jtun mode sit remote 192.168.210.2 local 192.168.200.1
>> sudo ip -6 addr add 2001::1/64 dev jtun
>> sudo ip link set jtun up
>>
>> VM2:
>> sudo ip addr add 192.168.210.2/24 dev enp0s8 broadcast 192.168.210.255
>> sudo ip link set enp0s8 up
>> sudo ip route add 192.168.200.0/24 nexthop via 192.168.210.3 dev enp0s8
>> sudo ip link add dev myvrf type vrf table 256
>> sudo ip link set myvrf up
>> sudo ip link set enp0s8 vrf myvrf
>
> You lost the static route by doing the enslaving here. When the device
> is added to or removed from a VRF it is cycled specifically to dump
> routes and neighbor entries associated with the prior vrf. Always create
> the vrf and enslave first, then add routes:
>
> sudo ip link add dev myvrf type vrf table 256
> sudo ip link set myvrf up
> sudo ip link set enp0s8 vrf myvrf
>
> sudo ip addr add 192.168.210.2/24 dev enp0s8 broadcast 192.168.210.255
> sudo ip link set enp0s8 up
> sudo ip route add 192.168.200.0/24 nexthop via 192.168.210.3 dev enp0s8
>
> That said, the above works for the wrong reason -- it is not really
> doing VRF based routing. For that to happen, the static route should be
> added to the vrf table:
>
> sudo ip route add vrf myvrf 192.168.200.0/24 nexthop via 192.168.210.3
> dev enp0s8
>
> And ...
>
>> sudo ip tunnel add jtun mode sit remote 192.168.200.1 local 192.168.210.2
>
> you need to specify the link on the tunnel create:
>
> sudo ip tunnel add jtun mode sit remote 192.168.200.1 local
> 192.168.210.2 dev enp0s8.
>
> And ...
>
> The tunnel lookup needs to account for the VRF device switch:
>
> (whitespace damaged on paste)
>
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index a799f5258614..cf0512054fa7 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -632,11 +632,18 @@ static bool packet_is_spoofed(struct sk_buff *skb,
>  static int ipip6_rcv(struct sk_buff *skb)
>  {
>         const struct iphdr *iph = ip_hdr(skb);
> +       struct net_device *dev = skb->dev;
> +       struct net *net = dev_net(dev);
>         struct ip_tunnel *tunnel;
>         int err;
>
> -       tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
> -                                    iph->saddr, iph->daddr);
> +       if (netif_is_l3_master(dev)) {
> +               dev = dev_get_by_index_rcu(net, IPCB(skb)->iif);
> +               if (!dev)
> +                       goto out;
> +       }
> +
> +       tunnel = ipip6_tunnel_lookup(net, dev, iph->saddr, iph->daddr);
>         if (tunnel) {
>                 struct pcpu_sw_netstats *tstats;
>
