From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Thu, 1 May 2008 14:59:42 +0200
Message-ID: <BAY103-DAV8F11938C76B8B9245D864B2DB0@phx.gbl>
References: <E1JrXMB-00028Q-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s5.bay0.hotmail.com ([65.54.246.205]:3855 "EHLO
	bay0-omc3-s5.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755508AbYEAM6q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 08:58:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
 
> So it would appear that some netfilter rule has freed skb->dst.
> Do you have relevant netfilter rules, e.g., NAT entries

nat table is empty

> or any
> rules that might reroute the packet?

Yes indeed, this box is in the middle of a very poorly designed
network: it is the default gateway for lan clients, but it is
routing back all traffic to another lan box except for ipsec
traffic.

eth2 is internal lan and eth0 is the interface connected to
the isp router.

root@Halley:/# ip ru sh
0:      from all lookup local
601:    from 172.23.0.0/23 iif eth2 lookup isa
32766:  from all lookup main
32767:  from all lookup default

root@Halley:/# ip r s table isa
default via 172.23.1.254 dev eth2  metric 1

root@Halley:/# ip r s
88.51.228.225 dev eth0  scope link
88.51.228.224/28 dev eth1  proto kernel  scope link  src 88.51.228.238
172.22.1.0/24 via 88.51.228.225 dev eth0  src 172.23.2.254
172.18.1.0/24 via 88.51.228.225 dev eth0
172.25.5.0/24 via 88.51.228.225 dev eth0
172.25.1.0/24 via 88.51.228.225 dev eth0
172.21.1.0/24 via 88.51.228.225 dev eth0
172.17.1.0/24 via 88.51.228.225 dev eth0
172.23.2.0/23 via 88.51.228.225 dev eth0
172.23.0.0/23 dev eth2  proto kernel  scope link  src 172.23.1.8
172.16.0.0/23 via 88.51.228.225 dev eth0
127.0.0.0/8 dev lo  scope link
default via 88.51.228.225 dev eth0  metric 1

root@Halley:/# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:90:27:74:66:4c brd ff:ff:ff:ff:ff:ff
    inet 88.51.228.238/28 brd 88.51.228.239 scope global eth0
    inet 172.23.2.254/32 scope global eth0
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 00:d0:b7:18:14:bc brd ff:ff:ff:ff:ff:ff
    inet 88.51.228.238/28 brd 88.51.228.239 scope global eth1
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 00:60:08:6d:3a:84 brd ff:ff:ff:ff:ff:ff
    inet 172.23.1.8/23 brd 172.23.1.255 scope global eth2

Here is the info you asked:

root@Halley:~# iptables -nvxL -t nat
Chain PREROUTING (policy ACCEPT 72557 packets, 6148591 bytes)
    pkts      bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 46575 packets, 3596771 bytes)
    pkts      bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 191 packets, 26422 bytes)
    pkts      bytes target     prot opt in     out     source               destination

root@Halley:~# iptables -nvxL -t mangle
Chain PREROUTING (policy ACCEPT 13646213 packets, 12635102939 bytes)
    pkts      bytes target     prot opt in     out     source               destination
    2752  2713288 MARK       tcp  --  eth2   *       0.0.0.0/0            172.16.0.0/12       multiport dports 20,25 MARK set 0x6e
       0        0 MARK       all  --  *      *       0.0.0.0/0            172.16.0.0/12       helper match "ftp" MARK set 0x6e
  209912 10965262 MARK       tcp  --  eth2   *       0.0.0.0/0            172.16.0.0/12       multiport dports 1494,2598 MARK set 0x70

Chain INPUT (policy ACCEPT 7226005 packets, 8188427260 bytes)
    pkts      bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 6413301 packets, 4441928803 bytes)
    pkts      bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 2626545 packets, 513891469 bytes)
    pkts      bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 8985576 packets, 4948767535 bytes)
    pkts      bytes target     prot opt in     out     source               destination

root@Halley:~# iptables -nvxL -t filter
Chain INPUT (policy DROP 18528 packets, 1978955 bytes)
    pkts      bytes target     prot opt in     out     source               destination         
    9788   662676 ACCEPT     all  --  *      *       172.16.1.247         0.0.0.0/0           
  107544 30848205 ACCEPT     all  --  *      *       80.204.235.254       0.0.0.0/0           
       0        0 ACCEPT     all  --  *      *       127.0.0.1            127.0.0.1           
 3721271 4246951537 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
   18232  1950857 green-me   all  --  eth2   *       172.23.0.0/23        0.0.0.0/0           
       0        0 dmz-me     all  --  eth1   *       88.51.228.224/28     0.0.0.0/0           
 3361526 3907062198 red-me     all  --  eth0   *       0.0.0.0/0            0.0.0.0/0           

Chain FORWARD (policy DROP 3093 packets, 230687 bytes)
    pkts      bytes target     prot opt in     out     source               destination         
 6211800 4421683285 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
  147228 15568498 ACCEPT     all  --  eth2   eth2    172.23.0.0/23        0.0.0.0/0           
    2366   220478 ACCEPT     all  --  *      *       172.23.0.0/23        172.16.0.0/23       
    5774   531670 ACCEPT     all  --  *      *       172.16.0.0/23        172.23.0.0/23       
    1201    90893 ACCEPT     all  --  *      *       172.23.0.0/23        172.23.2.0/23       
    3114   275588 ACCEPT     all  --  *      *       172.23.2.0/23        172.23.0.0/23       
    6141   505776 ACCEPT     all  --  *      *       172.23.0.0/23        172.18.1.0/24       
   10018   684510 ACCEPT     all  --  *      *       172.18.1.0/24        172.23.0.0/23       
    8620   755691 ACCEPT     all  --  *      *       172.23.0.0/23        172.25.1.0/24       
     572    86585 ACCEPT     all  --  *      *       172.25.1.0/24        172.23.0.0/23       
    2554   124898 ACCEPT     all  --  *      *       172.23.0.0/23        172.25.5.0/24       
    3713   286355 ACCEPT     all  --  *      *       172.25.5.0/24        172.23.0.0/23       
      66     3168 ACCEPT     all  --  *      *       172.23.0.0/23        172.17.1.0/24       
     298    30003 ACCEPT     all  --  *      *       172.17.1.0/24        172.23.0.0/23       
       0        0 ACCEPT     all  --  *      *       172.23.0.0/23        172.22.1.0/24       
      10     2674 ACCEPT     all  --  *      *       172.22.1.0/24        172.23.0.0/23       
       0        0 ACCEPT     all  --  *      *       172.23.0.0/23        172.21.1.0/24       
     108    26588 ACCEPT     all  --  *      *       172.21.1.0/24        172.23.0.0/23       
       0        0 ACCEPT     all  --  *      *       172.23.0.0/23        81.113.185.96/27    
       0        0 ACCEPT     all  --  *      *       81.113.185.96/27     172.23.0.0/23       
      30     1472 green-red  all  --  eth2   eth0    172.23.0.0/23        0.0.0.0/0           
       0        0 green-dmz  all  --  eth2   eth1    172.23.0.0/23        88.51.228.224/28    
       0        0 dmz-red    all  --  eth1   eth0    88.51.228.224/28     0.0.0.0/0           
       0        0 dmz-green  all  --  eth1   eth2    88.51.228.224/28     172.23.0.0/23       
    3063   229215 syn-flood-dmz  all  --  eth0   eth1    0.0.0.0/0            88.51.228.224/28    
       0        0 syn-flood-green  all  --  eth0   eth2    0.0.0.0/0            172.23.0.0/23       

Chain OUTPUT (policy DROP 4866 packets, 722169 bytes)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     all  --  *      *       127.0.0.1            127.0.0.1           
 2570465 506300871 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
   36483  5204284 me-green   all  --  *      eth2    0.0.0.0/0            172.23.0.0/23       
       0        0 me-dmz     all  --  *      eth1    0.0.0.0/0            88.51.228.224/28    
     191    26666 me-red     all  --  *      eth0    0.0.0.0/0            0.0.0.0/0           

Chain dmz-green (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            0.0.0.0/0           
       0        0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-unreachable 

Chain dmz-me (1 references)
    pkts      bytes target     prot opt in     out     source               destination         

Chain dmz-red (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            0.0.0.0/0           
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     85.32.35.0/27       
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     82.189.143.32/28    
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     88.45.249.192/27    
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     88.35.239.32/28     
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     81.113.185.96/27    
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     88.57.240.144/28    
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     88.40.176.96/28     
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     85.41.109.160/27    
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     80.204.235.224/27   
       0        0 ACCEPT     all  --  *      *       88.51.228.224/28     88.52.180.96/28     

Chain green-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           

Chain green-me (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     icmp --  *      *       172.23.1.4           0.0.0.0/0           icmp type 8 

Chain green-red (1 references)
    pkts      bytes target     prot opt in     out     source               destination         

Chain icmp-me (3 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0           icmp type 0 
       0        0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0           icmp type 8 
       0        0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0           icmp type 3 

Chain me-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               destination         

Chain me-green (1 references)
    pkts      bytes target     prot opt in     out     source               destination         

Chain me-red (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            0.0.0.0/0           
       4      576 ACCEPT     esp  --  *      *       0.0.0.0/0            0.0.0.0/0           
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           multiport dports 53,123 
     183    25850 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0           multiport dports 53,123,500,4500,6666 

Chain red-dmz (3 references)
    pkts      bytes target     prot opt in     out     source               destination         

Chain red-green (3 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            172.23.1.2          multiport dports 80 

Chain red-me (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0           icmp type 3 
     179    36984 ACCEPT     esp  --  *      *       0.0.0.0/0            0.0.0.0/0           
 3360694 3906910252 ACCEPT     4    --  *      *       0.0.0.0/0            0.0.0.0/0           
     376    93408 ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0           multiport dports 500,4500 

Chain syn-flood-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
    1767   101324 red-dmz    tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x02 limit: avg 1/sec burst 5 
       7      280 red-dmz    tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x04 limit: avg 1/sec burst 5 
     214    66554 red-dmz    udp  --  *      *       0.0.0.0/0            0.0.0.0/0           
       0        0 ACCEPT     all  --  *      *       85.32.35.0/27        88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       82.189.143.32/28     88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       88.45.249.192/27     88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       88.35.239.32/28      88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       81.113.185.96/27     88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       88.57.240.144/28     88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       88.40.176.96/28      88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       85.41.109.160/27     88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       80.204.235.224/27    88.51.228.224/28    
       0        0 ACCEPT     all  --  *      *       88.52.180.96/28      88.51.228.224/28    

Chain syn-flood-green (1 references)
    pkts      bytes target     prot opt in     out     source               destination         
       0        0 red-green  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x02 limit: avg 20/min burst 5 
       0        0 red-green  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x04 limit: avg 20/min burst 5 
       0        0 red-green  udp  --  *      *       0.0.0.0/0            0.0.0.0/0           

root@Halley:/# ip x p
src 172.25.1.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 85.41.109.190 dst 88.51.228.238
                proto comp reqid 16386 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16385 mode transport
src 172.18.1.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 85.32.35.30 dst 88.51.228.238
                proto comp reqid 16394 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16393 mode transport
src 172.21.1.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 88.35.239.46 dst 88.51.228.238
                proto comp reqid 16390 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport
src 172.22.1.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 88.45.249.222 dst 88.51.228.238
                proto comp reqid 16398 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16397 mode transport
src 172.25.5.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 88.57.240.158 dst 88.51.228.238
                proto comp reqid 16402 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16401 mode transport
src 172.17.1.0/24 dst 172.23.0.0/23
        dir in priority 2376
        tmpl src 82.189.143.46 dst 88.51.228.238
                proto comp reqid 16410 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16409 mode transport
src 172.16.0.0/23 dst 172.23.0.0/23
        dir in priority 2377
        tmpl src 80.204.235.254 dst 88.51.228.238
                proto comp reqid 16414 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16413 mode transport
src 172.23.2.0/23 dst 172.23.0.0/23
        dir in priority 2377
        tmpl src 88.52.180.110 dst 88.51.228.238
                proto comp reqid 16406 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16405 mode transport
src 172.23.0.0/23 dst 172.25.1.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 85.41.109.190
                proto comp reqid 16386 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16385 mode transport
src 172.23.0.0/23 dst 172.21.1.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 88.35.239.46
                proto comp reqid 16390 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport
src 172.23.0.0/23 dst 172.18.1.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 85.32.35.30
                proto comp reqid 16394 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16393 mode transport
src 172.23.0.0/23 dst 172.22.1.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 88.45.249.222
                proto comp reqid 16398 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16397 mode transport
src 172.23.0.0/23 dst 172.25.5.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 88.57.240.158
                proto comp reqid 16402 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16401 mode transport
src 172.23.0.0/23 dst 172.17.1.0/24
        dir out priority 2376
        tmpl src 88.51.228.238 dst 82.189.143.46
                proto comp reqid 16410 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16409 mode transport
src 172.23.0.0/23 dst 172.23.2.0/23
        dir out priority 2377
        tmpl src 88.51.228.238 dst 88.52.180.110
                proto comp reqid 16406 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16405 mode transport
src 172.23.0.0/23 dst 172.16.0.0/23
        dir out priority 2377
        tmpl src 88.51.228.238 dst 80.204.235.254
                proto comp reqid 16414 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16413 mode transport
src 172.25.1.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 85.41.109.190 dst 88.51.228.238
                proto comp reqid 16386 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16385 mode transport
src 172.18.1.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 85.32.35.30 dst 88.51.228.238
                proto comp reqid 16394 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16393 mode transport
src 172.21.1.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 88.35.239.46 dst 88.51.228.238
                proto comp reqid 16390 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport
src 172.22.1.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 88.45.249.222 dst 88.51.228.238
                proto comp reqid 16398 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16397 mode transport
src 172.25.5.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 88.57.240.158 dst 88.51.228.238
                proto comp reqid 16402 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16401 mode transport
src 172.17.1.0/24 dst 172.23.0.0/23
        dir fwd priority 2376
        tmpl src 82.189.143.46 dst 88.51.228.238
                proto comp reqid 16410 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16409 mode transport
src 172.16.0.0/23 dst 172.23.0.0/23
        dir fwd priority 2377
        tmpl src 80.204.235.254 dst 88.51.228.238
                proto comp reqid 16414 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16413 mode transport
src 172.23.2.0/23 dst 172.23.0.0/23
        dir fwd priority 2377
        tmpl src 88.52.180.110 dst 88.51.228.238
                proto comp reqid 16406 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16405 mode transport

and this my rc.qos script for setting up qdisc:

root@Halley:/etc/rc.d# cat rc.qos
#!/bin/sh
#set -x

# cleaning environment
tc qdisc del dev eth0 root
# done

# 1600kbit -->> 200kbps
# 200kbit -->> 25kbps
# 400kbit -->> 50kbps
# 600kbit -->> 75kbps
# 1200kbit -->> 150kbps
# 800kbit -->> 100kbps

tc qdisc add dev eth0 root handle 1:0 htb default 11

tc class add dev eth0 parent 1:0 classid 1:1 htb rate 1700kbit ceil 1700kbit burst 15k

tc class add dev eth0 parent 1:1 classid 1:10 htb rate 200kbit ceil 400kbit burst 5k
tc class add dev eth0 parent 1:1 classid 1:11 htb rate 600kbit ceil 1600kbit burst 5k
tc class add dev eth0 parent 1:1 classid 1:12 htb rate 800kbit ceil 1700kbit burst 15k

tc qdisc add dev eth0 parent 1:10 handle 10:0 sfq perturb 10
tc qdisc add dev eth0 parent 1:11 handle 20:0 sfq perturb 5
tc qdisc add dev eth0 parent 1:12 handle 30:0 sfq perturb 10

FW="tc filter add dev eth0 protocol ip parent 1:0 prio 1"
$FW handle 110 fw flowid 1:10
$FW handle 111 fw flowid 1:11
$FW handle 112 fw flowid 1:12


