From: "watson" <watsonlll@gmail.com>
Subject: [problem] Duplicate IP and MAC address ARP issue
Date: Mon, 15 Dec 2008 16:05:56 +0800
Message-ID: <200812151605286405450@gmail.com>
Reply-To: watsonlll@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:27885 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbYLOIEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 03:04:45 -0500
Received: by ag-out-0708.google.com with SMTP id 31so2271001agc.10
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 00:04:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear guys,

I am building a linux box base on linux kernel 2.4.31 and I can modify the source code but can not change to other version.
eveything is ok until I connect my box to Netgear POE switch, this switch will send ARP request packet back to box, 
then box's network will "down", and can not send out any IP packet except ARP. 

test environment:
----------------------------------------------
|                10Mbps HUB                              |
|                                                              |
----------------------------------------------
          |                     |                 |
          |                     |                 |
---------------------   |    ----------------------
| Linux 2.4.31          |   |   | Netgear POE switch |
| 192.168.0.155       |   |   |       FS108P            |
| 00:0e:e9:80:22:60 |   |   |                            |
---------------------   |    ----------------------
                                |
---------------------  |  
| my laptop             |  |   
| 192.168.0.8          |--|
| 00:15:58:7c:b9:1d |     
---------------------  
 
I found that linux box works fine before I connect netgear POE switch to the same HUB.
I discovered netgear switch will forward ARP request which receive from HUB back to HUB, linux box will be sick after he receive this same package. 
 
What I have tried: (arp.c, route.c, ip_input.c locate in \linux-2.4.31\net\ipv4\)
1. add some code in front of arp_rcv()/arp.c to detect/drop the ARP request packet which send back by switch, but not work.
since arp_rcv() is called by device layer and it will drop the wrong ARP packet, I thought this packet should not affect the box, but the fact is there.
2. discovered skb->dst will be NULL in ip_rcv_finish()/ip_input.c when box didn't receive wrong packet, but after box receive wrong packet, skb->dst will hold something, 
so ip_rcv_finish() will not call ip_route_input(), even  I get rid of the judgement of "if (skb->dst == NULL)", ip_route_input() will return failed.
 
static inline int ip_rcv_finish(struct sk_buff *skb)
{
struct net_device *dev = skb->dev;
struct iphdr *iph = skb->nh.iph;
/*
 * Initialise the virtual path cache for the packet. It describes
 * how the packet travels inside Linux networking.
 */ 
if (skb->dst == NULL) {
if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
goto drop; 
}
...

some other informaion:
# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0E:E9:80:22:60  
          inet addr:192.168.0.155  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:216 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:676 (676.0 B)  TX bytes:9072 (8.8 KiB)
          Interrupt:39 
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:78 errors:0 dropped:0 overruns:0 frame:0
          TX packets:78 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:6708 (6.5 KiB)  TX bytes:6708 (6.5 KiB)
# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
127.0.0.0       0.0.0.0          255.0.0.0          U     0      0        0 eth0
0.0.0.0         192.168.0.2     0.0.0.0            UG    0      0        0 eth0
(note: when I connect switch to HUB, route -n will output the same message)

Another clue which I found is when box occur this problem, several "ifconfig eth0 up" can make the network of box work again, but it will still fail after receive wrong ARP packet.
 
I have no idea how to fix this problem, it has spent me more than two weeks and beyond my ability, so it is very appreciated if anyone can help me, thank you!

Best regards, 				
Watson

2008-12-15
---------------------------------
Email: watsonlll@gmail.com



