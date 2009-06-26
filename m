From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Fri, 26 Jun 2009 12:44:44 -0700
Message-ID: <20090626124444.c24d9b38.akpm@linux-foundation.org>
References: <bug-13627-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Oliver Hartkopp <olver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43474 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754832AbZFZTpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 15:45:55 -0400
In-Reply-To: <bug-13627-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 26 Jun 2009 14:45:11 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13627
> 
>            Summary: Tunnel device ignores TCP/UDP traffic
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: pm@debian.org
>         Regression: Yes
> 

It's a post-2.6.30 regression which Paul has bisected down to

  commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
  Author:     Herbert Xu <herbert@gondor.apana.org.au>
  AuthorDate: Mon Jun 22 02:25:25 2009 +0000
  Commit:     David S. Miller <davem@davemloft.net>
  CommitDate: Tue Jun 23 16:36:25 2009 -0700

      net: Move rx skb_orphan call to where needed

(thanks for doing the bisection!)

> Using OpenVPN on 2.6.29.4 and 2.6.30 works but 2.6.31-rc1 doesn't.
> 
> I can ping (ICMP) the remote end, and see the packets going back and forth
> using tcpdump, but they don't appear to be reaching the upper layers.
> 
> traceroute with -U (UDP) and -T (TCP SYN) options (ie. raw packet socket)
> works.
> 
> There are no iptables filters in place. Nothing unusual appears in dmesg or
> syslog.
> 
> root@thinkpad:~# ping 172.17.2.1
> PING 172.17.2.1 (172.17.2.1) 56(84) bytes of data.
> 64 bytes from 172.17.2.1: icmp_seq=1 ttl=64 time=97.9 ms
> 64 bytes from 172.17.2.1: icmp_seq=2 ttl=64 time=108 ms
> 64 bytes from 172.17.2.1: icmp_seq=3 ttl=64 time=184 ms
> 64 bytes from 172.17.2.1: icmp_seq=4 ttl=64 time=96.0 ms
> ^C
> --- 172.17.2.1 ping statistics ---
> 4 packets transmitted, 4 received, 0% packet loss, time 3004ms
> rtt min/avg/max/mdev = 96.022/121.776/184.465/36.510 ms
> 
> # tcptraceroute -n 192.168.1.1 1
> traceroute to 192.168.1.1 (192.168.1.1), 30 hops max, 60 byte packets
>  1  192.168.1.1  90.230 ms  105.535 ms  104.833 ms
> 
> 
> ~# telnet 172.17.2.1 1
> Trying 172.17.2.1...
> ^C
> 
> # tcpdump -n -p -i tun0
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on tun0, link-type RAW (Raw IP), capture size 96 bytes
> 15:28:44.450554 IP 172.17.2.10.46287 > 172.17.2.1.1: Flags [S], seq 434762695,
> win 5840, options [mss 1460,sackOK,TS val 169108 ecr 0,nop,wscale 6], length 0
> 15:28:44.542303 IP 172.17.2.1.1 > 172.17.2.10.46287: Flags [R.], seq 0, ack
> 434762696, win 0, length 0
> 
> 
> # ip link
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 4: wmaster0: <UP,LOWER_UP> mtu 0 qdisc pfifo_fast state UNKNOWN qlen 1000
>     link/ieee802.11 00:14:a4:04:df:09 brd 00:00:00:00:00:00
> 5: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP
> qlen 1000
>     link/ether 00:14:a4:04:df:09 brd ff:ff:ff:ff:ff:ff
> 8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UNKNOWN qlen 100
>     link/[65534]
> 
> # ip addr
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 4: wmaster0: <UP,LOWER_UP> mtu 0 qdisc pfifo_fast state UNKNOWN qlen 1000
>     link/ieee802.11 00:14:a4:04:df:09 brd 00:00:00:00:00:00
> 5: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP
> qlen 1000
>     link/ether 00:14:a4:04:df:09 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.10.118/24 brd 192.168.10.255 scope global wlan0
>     inet6 fe80::214:a4ff:fe04:df09/64 scope link
>        valid_lft forever preferred_lft forever
> 8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UNKNOWN qlen 100
>     link/[65534]
>     inet 172.17.2.10 peer 172.17.2.9/32 scope global tun0
> 
> # ip route
> 172.17.2.9 dev tun0  proto kernel  scope link  src 172.17.2.10
> 192.168.1.0/24 via 172.17.2.9 dev tun0  metric 20
> 172.17.2.0/24 via 172.17.2.9 dev tun0
> 192.168.10.0/24 dev wlan0  proto kernel  scope link  src 192.168.10.118
> default via 192.168.10.1 dev wlan0

