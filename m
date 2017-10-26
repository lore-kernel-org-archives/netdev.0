From: Jeff Barnhill <0xeffeff@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Wed, 25 Oct 2017 23:28:38 -0400
Message-ID: <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:51758 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdJZD2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 23:28:39 -0400
Received: by mail-oi0-f48.google.com with SMTP id j126so3439258oib.8
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 20:28:39 -0700 (PDT)
In-Reply-To: <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, David.

VM1:
sudo ip addr add 192.168.200.1/24 dev enp0s8 broadcast 192.168.200.255
sudo ip link set enp0s8 up
sudo ip route add 192.168.210.0/24 nexthop via 192.168.200.3 dev enp0s8
sudo ip tunnel add jtun mode sit remote 192.168.210.2 local 192.168.200.1
sudo ip -6 addr add 2001::1/64 dev jtun
sudo ip link set jtun up

VM2:
sudo ip addr add 192.168.210.2/24 dev enp0s8 broadcast 192.168.210.255
sudo ip link set enp0s8 up
sudo ip route add 192.168.200.0/24 nexthop via 192.168.210.3 dev enp0s8
sudo ip link add dev myvrf type vrf table 256
sudo ip link set myvrf up
sudo ip link set enp0s8 vrf myvrf
sudo ip tunnel add jtun mode sit remote 192.168.200.1 local 192.168.210.2
sudo ip link set jtun vrf myvrf
sudo ip -6 addr add 2001::2/64 dev jtun
sudo ip link set jtun up

VM3:
sudo ip addr add 192.168.200.3/24 dev enp0s8 broadcast 192.168.200.255
sudo ip addr add 192.168.210.3/24 dev enp0s9 broadcast 192.168.210.255
sudo ip link set enp0s8 up
sudo ip link set enp0s9 up
sudo sysctl net.ipv4.conf.enp0s8.forwarding=1
sudo sysctl net.ipv4.conf.enp0s9.forwarding=1

jeff@VM2:~$ ping -c 3 -I jtun 2001::1
PING 2001::1(2001::1) from 2001::2 jtun: 56 data bytes
>From 2001::2 icmp_seq=1 Destination unreachable: Address unreachable
>From 2001::2 icmp_seq=2 Destination unreachable: Address unreachable
>From 2001::2 icmp_seq=3 Destination unreachable: Address unreachable

--- 2001::1 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2039ms

jeff@VM2:~$ ping -c 3 -I myvrf 2001::1
ping6: Warning: source address might be selected on device other than myvrf.
PING 2001::1(2001::1) from 2001::2 myvrf: 56 data bytes
>From 2001::2 icmp_seq=1 Destination unreachable: Address unreachable
>From 2001::2 icmp_seq=2 Destination unreachable: Address unreachable
>From 2001::2 icmp_seq=3 Destination unreachable: Address unreachable

--- 2001::1 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2045ms

Let me know if you have any questions or if you think I've done something wrong.

Thanks,
Jeff


On Wed, Oct 25, 2017 at 5:31 PM, David Ahern <dsahern@gmail.com> wrote:
> On 10/25/17 2:45 PM, Jeff Barnhill wrote:
>> Are v6/sit tunnels working with VRFs?
>>
>> For instance, I have a very simple configuration with three VMs
>> running 4.13.0-16 (Ubuntu Server 17.10) kernels.  VM3 is setup as a
>> router for separation.  VM1 and VM2 have static routes to each other
>> via VM3.  All VMs have v4 interfaces configured.  If I setup a sit
>> tunnel with v6 addrs from V1 to V2, tunneled data flows as expected
>> (verified with ping) and can be seen via tcpdump on VM3.  However, if
>> I create a VRF on VM2 and enslave the v4 interface and tunnel to that
>> VRF, data does not leave VM2 and ping displays "Destination Host
>> Unreachable".  I did verify that basic v4 ping works between VM1 and
>> VM2 with the v4 interface on VM2 enslaved to VRF device.
>>
>> If this should work, I can provide more details with configuration commands.
>
> Please provide configuration details and I'll take a look
