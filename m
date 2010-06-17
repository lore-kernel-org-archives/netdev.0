From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][BUG-FIX] the problem of checksum checking in UDP protocol
Date: Thu, 17 Jun 2010 17:09:08 +0800
Message-ID: <4C19E634.3030703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62345 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751065Ab0FQJJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 05:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


*Description of Problem*
When received an UDP packet, if the length parameter in UDP header is less than
the actual length of payload(including 8 bytes UDP header), and checksum parameter
is calculated including all payload, some NIC devices that supports hardware checksum
success to check checksum, and set ip_summed with CHECKSUM_UNNECESSARY flag. 
But If we turn off rx-checksumming offload, UDP protocol failed to check the checksum.

*Step to Reproduce*
We need to download netwib&netwox tools and then install them only on M1 node.
On M1 node, execute the below steps.

                  M1                                               M2
	+---------------------------+			+---------------------------+
	|                     eth1  |<---------------> 	|eth0                       |            
	|fe80::225:86ff:fe9d:3efa   |			|fe80::215:17ff:fe71:51f4   |
	+---------------------------+			+---------------------------+
       
  1.  netwox 149 -i fe80::215:17ff:fe71:51f4 -d eth1 -E 0:0:0:0:1:0 -e 0:15:17:71:51:f4 -I fe80::200:ff:fe00:100 -c 1
      This step is to create neighbor cache for spurious source address of fe80::200:ff:fe00:100.

  2.  netwox 141 -d eth1 -a 0:0:0:0:1:0 -b 0:15:17:71:51:f4 -f 17 -g 64 -h fe80::200:ff:fe00:100 -i fe80::215:17ff:fe71:51f4 \
       -o 3333 -p 7 -q 000000000000000000000000000000000000000000000000 -r 34525 -e 32 -s 16 -t 35126
       This step is to construct an UDPv6 packet that length field(16 bytes) less than total payload length(32 bytes).

The readable format of this packet that netwox shows.
Ethernet________________________________________________________.
| 00:00:00:00:01:00->00:15:17:71:51:F4 type:0x86DD              |
|_______________________________________________________________|
IP______________________________________________________________.
|version| traffic class |              flow label               |
|___6___|_______0_______|___________________0___________________|
|        payload length         |  next header  |   hop limit   |
|___________0x0020=32___________|____0x11=17____|______64_______|
|                            source                             |
|_____________________fe80::200:ff:fe00:100_____________________|
|                          destination                          |
|___________________fe80::215:17ff:fe71:51f4____________________|
UDP_____________________________________________________________.
|          source port          |       destination port        |
|__________0x0D05=3333__________|___________0x0007=7____________|
|            length             |           checksum            |
|___________0x0010=16___________|_________0x8936=35126__________|
00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  # ................
00 00 00 00  00 00 00 00                            # ........


*Actual Results*
  On M2 note, using ethtool to see the counter about rx_csum_offload.
  #ethtool -S eth0 | grep csum
  rx_csum_offload_good: 1
  rx_csum_offload_errors: 0

 #cat /proc/net/snmp6 | grep Udp6 
 Udp6InDatagrams                 	1
 Udp6InErrors                    	0

*Expected Results*
 #ethtool -S eth0 | grep csum
 rx_csum_offload_good: 0
 rx_csum_offload_errors: 1

 #cat /proc/net/snmp6 | grep Udp6 
 Udp6InDatagrams                 	0
 Udp6InErrors                    	1
  
*The Reason*
UDPv6 handles a received packet like this:
1. Confirm length of data
   If length parameter in UDPv6 header is greater than skb->len(actual data length added UDP header),
   the packet will be dropped. If length parameter in UDPv6 header is lower than skb->len, the data
   will be trimmed to be equal to length parameter.

2. Then UDPv6 calculates checksum with 40 bytes IPv6 pseudo-header,8 bytes UDPv6 header, 8 bytes 
   Payload Data. Note that checksum(35126) in UDPv6 header includes 16 bytes redundant data.

NIC checks checksum with total data includes redundant data, So the checksum that hardware calculated
is different from that UDP did. 

 
*The Solution*
We have reported the problem to Intel E1000e developer, the reply from Ronciak John is that
the driver code of e1000e is ok. 
About the discuss, see http://comments.gmane.org/gmane.linux.drivers.e1000.devel/7077

For this case, UDP protocol should not trust the CHECKSUM_UNNECESSARY flag set by driver.
When UDP protocol received this kind of packet, if NIC hardware checked successfully,
we reset ip_summed with CHECKSUM_NONE, and UDP protocol checked checksum again.
 
(This patch is not complete, it's just for my idea.)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1dd1aff..47f7e86 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -723,6 +723,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
                if (ulen < skb->len) {
                        if (pskb_trim_rcsum(skb, ulen))
                                goto short_packet;
+
+                       if (skb_csum_unnecessary(skb))
+                               skb->ip_summed = CHECKSUM_NONE;
+
                        saddr = &ipv6_hdr(skb)->saddr;
                        daddr = &ipv6_hdr(skb)->daddr;
                        uh = udp_hdr(skb);

