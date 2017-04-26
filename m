From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>
Subject: Re: Bug and configuration MPLS error?
Date: Wed, 26 Apr 2017 15:40:32 +0300
Message-ID: <1728581493210432@web45j.yandex.ru>
References: <184081493141314@web16g.yandex.ru> <a104e7e4-9ebc-329a-1bf0-7e860ea0d61a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: David Ahern <dsahern@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward4o.cmail.yandex.net ([37.9.109.248]:37937 "EHLO
        forward4o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2993770AbdDZMu2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 08:50:28 -0400
In-Reply-To: <a104e7e4-9ebc-329a-1bf0-7e860ea0d61a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



26.04.2017, 05:23, "David Ahern" <dsahern@gmail.com>:
> On 4/25/17 11:28 AM, Алексей Болдырев wrote:
>>  226 sysctl -w net.mpls.conf.lo.input=1
>>  227 sysctl -w net.mpls.platform_labels=1048575
>>  228 ip link add veth0 type veth peer name veth1
>>  229 ip link add veth2 type veth peer name veth3
>>  230 sysctl -w net.mpls.conf.veth0.input=1
>>  231 sysctl -w net.mpls.conf.veth2.input=1
>>  232 ifconfig veth0 10.3.3.1 netmask 255.255.255.0
>>  233 ifconfig veth2 10.4.4.1 netmask 255.255.255.0
>>  234 ip netns add host1
>>  235 ip netns add host2
>>  236 ip link set veth1 netns host1
>>  237 ip link set veth3 netns host2
>>  238 ip netns exec host1 ifconfig veth1 10.3.3.2 netmask 255.255.255.0 up
>>  239 ip netns exec host2 ifconfig veth3 10.4.4.2 netmask 255.255.255.0 up
>>  240 ip netns exec host1 ip route add 10.10.10.2/32 encap mpls 112 via inet 10.3.3.1
>>  241 ip netns exec host2 ip route add 10.10.10.1/32 encap mpls 111 via inet 10.4.4.1
>>  242 ip -f mpls route add 111 via inet 10.3.3.2
>>  243 ip -f mpls route add 112 via inet 10.4.4.2
>
> your setup is incomplete.
>
> # ip netns exec host2 ping 10.10.10.1
> PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
> ^C
> --- 10.10.10.1 ping statistics ---
> 2 packets transmitted, 0 received, 100% packet loss, time 1038ms
>
> If you run tcpdump on veth1 in host1 you see the packets come in but no
> response:
>
> # ip netns exec host1 tcpdump -n -i veth1
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on veth1, link-type EN10MB (Ethernet), capture size 262144 bytes
> 19:20:24.599529 IP6 fe80::347d:e3ff:fe93:944b > ff02::2: ICMP6, router
> solicitation, length 16
> 19:20:27.413901 IP 10.4.4.2 > 10.10.10.1: ICMP echo request, id 978, seq
> 1, length 64
> 19:20:28.439574 IP 10.4.4.2 > 10.10.10.1: ICMP echo request, id 978, seq
> 2, length 64
>
> and the lack of response is b/c:
> 1. host1 has no address for 10.10.10.1 and
> 2. even if it did, there is no return route to 10.4.4.2:
>
> # ip -netns host1 ro ls
> 10.3.3.0/24 dev veth1 proto kernel scope link src 10.3.3.2
> 10.10.10.2 encap mpls 112 via 10.3.3.1 dev veth1

As for ping, you need to enter this:
Ip netns exec host2 ping 10.10.10.1 -A 10.10.10.2
Here I published the results of testing on new (>4.9) cores. (in Russian):
http://forum.nag.ru/forum/index.php?s=d09f0e5186fda59b3099eb81ad07ee63&showtopic=128927
But on the old kernels:
http://forum.nag.ru/forum/index.php?showtopic=128927&view=findpost&p=1396067
