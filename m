From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Thu, 27 Dec 2012 08:54:01 -0800
Message-ID: <1356627241.30414.1079.camel@edumazet-glaptop>
References: <20121114231411.4328fc47@lola.kot>
	 <20121114.162956.610530798200803185.davem@davemloft.net>
	 <20121115010324.2707950c@lola.kot>
	 <20121114.180824.1930899985436392426.davem@davemloft.net>
	 <20121227175735.26c70cbb@lola.kot>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: George Kargiotakis <kargig@void.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:51328 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab2L0QyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 11:54:05 -0500
Received: by mail-pb0-f43.google.com with SMTP id um15so5483635pbc.30
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 08:54:05 -0800 (PST)
In-Reply-To: <20121227175735.26c70cbb@lola.kot>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-27 at 17:57 +0200, George Kargiotakis wrote:
> Hello all,
> 
> I had previously informed this list about the issue of the linux kernel 
> losing IPv6 privacy extensions by a local LAN attacker.
> Recently I've found that there's actually another, more serious in my
> opinion, issue that follows the previous one. If the user tries to
> disconnect/reconnect the network device/connection for whatever reason
> (e.g. thinking he might gain back privacy extensions), then the device
> gets IPs from SLAAC that have the "tentative" flag and never loses
> that. That means that IPv6 functionality for that device is from then
> on completely lost.  I haven't been able to bring back the kernel to a
> working IPv6 state without a reboot.
> 
> This is definitely a DoS situation and it needs fixing.
> 
> Here are the steps to reproduce:
> 
> == Step 1. Boot Ubuntu 12.10 (kernel 3.5.0-17-generic) ==
> ubuntu@ubuntu:~$ ip a ls dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
>     link/ether 52:54:00:8b:99:5d brd ff:ff:ff:ff:ff:ff
>     inet 192.168.1.96/24 brd 192.168.1.255 scope global eth0
>     inet6 2001:db8:f00:f00:ad1f:9166:93d4:fd6d/64 scope global temporary dynamic 
>        valid_lft 86379sec preferred_lft 3579sec
>     inet6 2001:db8:f00:f00:5054:ff:fe8b:995d/64 scope global dynamic 
>        valid_lft 86379sec preferred_lft 3579sec
>     inet6 fdbb:aaaa:bbbb:cccc:ad1f:9166:93d4:fd6d/64 scope global temporary dynamic 
>        valid_lft 86379sec preferred_lft 3579sec
>     inet6 fdbb:aaaa:bbbb:cccc:5054:ff:fe8b:995d/64 scope global dynamic 
>        valid_lft 86379sec preferred_lft 3579sec
>     inet6 fe80::5054:ff:fe8b:995d/64 scope link 
>        valid_lft forever preferred_lft forever
> 
> ubuntu@ubuntu:~$ sysctl -a | grep use_tempaddr
> net.ipv6.conf.all.use_tempaddr = 2
> net.ipv6.conf.default.use_tempaddr = 2
> net.ipv6.conf.eth0.use_tempaddr = 2
> net.ipv6.conf.lo.use_tempaddr = 2
> 
> ubuntu@ubuntu:~$ nmcli con status
> NAME                      UUID                                   DEVICES    DEFAULT  VPN   MASTER-PATH
> Wired connection 1        923e6729-74a7-4389-9dbd-43ed7db3d1b8   eth0       yes      no    --
> ubuntu@ubuntu:~$ nmcli dev status
> DEVICE     TYPE              STATE
> eth0       802-3-ethernet    connected
> 
> //ping6 2a00:1450:4002:800::100e  while in another terminal: tcpdump -ni eth0 ip6
> 
> ubuntu@ubuntu:~$ ping6 2a00:1450:4002:800::100e -c1
> PING 2a00:1450:4002:800::100e(2a00:1450:4002:800::100e) 56 data bytes
> 64 bytes from 2a00:1450:4002:800::100e: icmp_seq=1 ttl=53 time=70.9 ms
> 
> --- 2a00:1450:4002:800::100e ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 70.994/70.994/70.994/0.000 ms
> 
> # tcpdump -ni eth0 host 2a00:1450:4002:800::100e
> 17:57:37.784658 IP6 2001:db8:f00:f00:ad1f:9166:93d4:fd6d > 2a00:1450:4002:800::100e: ICMP6, echo request, seq 1, length 64
> 17:57:37.855257 IP6 2a00:1450:4002:800::100e > 2001:db8:f00:f00:ad1f:9166:93d4:fd6d: ICMP6, echo reply, seq 1, length 64
> 
> == Step 2. flood RAs on the LAN ==
> 
> $ dmesg | tail
> [ 1093.642053] IPv6: ipv6_create_tempaddr: retry temporary address regeneration
> [ 1093.642062] IPv6: ipv6_create_tempaddr: retry temporary address regeneration
> [ 1093.642065] IPv6: ipv6_create_tempaddr: retry temporary address regeneration
> [ 1093.642067] IPv6: ipv6_create_tempaddr: regeneration time exceeded - disabled temporary address support
> 
> ubuntu@ubuntu:~$ sysctl -a | grep use_tempaddr
> net.ipv6.conf.all.use_tempaddr = 2
> net.ipv6.conf.default.use_tempaddr = 2
> net.ipv6.conf.eth0.use_tempaddr = -1
> net.ipv6.conf.lo.use_tempaddr = 2
> 
> //ping6 2a00:1450:4002:800::100e  while in another terminal: tcpdump -ni eth0 ip6
> 
> ubuntu@ubuntu:~$ ping6 2a00:1450:4002:800::100e -c1
> PING 2a00:1450:4002:800::100e(2a00:1450:4002:800::100e) 56 data bytes
> 64 bytes from 2a00:1450:4002:800::100e: icmp_seq=1 ttl=53 time=77.5 ms
> 
> --- 2a00:1450:4002:800::100e ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 77.568/77.568/77.568/0.000 ms
> 
> # tcpdump -ni eth0 host 2a00:1450:4002:800::100e
> 17:59:38.204173 IP6 2001:db8:f00:f00:5054:ff:fe8b:995d > 2a00:1450:4002:800::100e: ICMP6, echo request, seq 1, length 64
> 17:59:38.281437 IP6 2a00:1450:4002:800::100e > 2001:db8:f00:f00:5054:ff:fe8b:995d: ICMP6, echo reply, seq 1, length 64
> 
> //notice the change of IPv6 address to the one not using privacy extensions even after the flooding has finished long ago.
> 
> == Step 3. Disconnect/Reconnect connection  ==
> // restoring net.ipv6.conf.eth0.use_tempaddr to value '2' makes no difference at all for the rest of the process
> 
> # nmcli dev disconnect iface eth0
> # nmcli con up uuid 923e6729-74a7-4389-9dbd-43ed7db3d1b8
> 
> ubuntu@ubuntu:~$ ip a ls dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
>     link/ether 52:54:00:8b:99:5d brd ff:ff:ff:ff:ff:ff
>     inet 192.168.1.96/24 brd 192.168.1.255 scope global eth0
>     inet6 2001:db8:f00:f00:5054:ff:fe8b:995d/64 scope global tentative dynamic 
>        valid_lft 86400sec preferred_lft 3600sec
>     inet6 fdbb:aaaa:bbbb:cccc:5054:ff:fe8b:995d/64 scope global tentative dynamic 
>        valid_lft 86400sec preferred_lft 3600sec
>     inet6 fe80::5054:ff:fe8b:995d/64 scope link tentative 
>        valid_lft forever preferred_lft forever
> 
> //Notice the "tentative" flag of the IPs on the device
> 
> //ping6 2a00:1450:4002:800::100e  while in another terminal: tcpdump -ni eth0 ip6
> 
> ubuntu@ubuntu:~$ ping6 2a00:1450:4002:800::100e -c1
> PING 2a00:1450:4002:800::100e(2a00:1450:4002:800::100e) 56 data bytes
> ^C
> --- 2a00:1450:4002:800::100e ping statistics ---
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> 
> # tcpdump -ni eth0 host 2a00:1450:4002:800::100e
> 18:01:45.264194 IP6 ::1 > 2a00:1450:4002:800::100e: ICMP6, echo request, seq 1, length 64
> 
> Summary:
> Before flooding it uses IP:  2001:db8:f00:f00:ad1f:9166:93d4:fd6d
> After  flooding it uses IP:  2001:db8:f00:f00:5054:ff:fe8b:995d --> it has lost privacy extensions
> After  disconnect/reconnect it tries to use IP:  ::1 --> it has lost IPv6 connectivity
> 
> Best regards,

We should only rate limit, and not disable forever.

If I cook a patch, are you willing to compile a kernel and test it ?

Thanks
