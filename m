From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: HFSC classes going out of bounds, regression in recent kernels?
Date: Tue, 6 Apr 2010 18:22:21 +0300
Message-ID: <201004061822.21735.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59050 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab0DFPX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I notice on one of my QoS machines that HFSC start going out of bandwidth 
limits. The most terrible thing - it happens suddenly, and if i just relaunch 
QoS script - everything will work fine.
I'm not sure it is not my mistake, but most probably it is a bug.
I can't tell for sure when it is happened, last kernel was on this machine 
2.6.28 i guess, or maybe even older.

The only possible cause - that i must setup stab for each qdisc, not only 
root. But i see it goes wild too much on graphs (up to 25-26 Mbps for 5 min 
average).
Here is qdisc setup:

qdisc bfifo 110: parent 1:110 limit 100000b
qdisc hfsc 1: root refcnt 2
 linklayer ethernet overhead 4 mpu 64 mtu 2047 tsize 512
qdisc bfifo 120: parent 1:120 limit 100000b
qdisc bfifo 130: parent 1:130 limit 100000b
qdisc bfifo 140: parent 1:140 limit 100000b
qdisc bfifo 150: parent 1:150 limit 1000000b
qdisc bfifo 160: parent 1:160 limit 100000b
qdisc bfifo 170: parent 1:170 limit 100000b
qdisc bfifo 180: parent 1:180 limit 100000b
qdisc bfifo 190: parent 1:190 limit 100000b


All offloading (except checksumming) disabled on eth0 and eth0.33.


Here is example of stats, on this snapshot total bandwidth goes out of bounds 
20Mbit/s to 21.6 Mbit/s.

Router# tc -s -d class show dev eth0.33;sleep 10;tc -s -d class show dev 
eth0.33;                                                                                                                 
class hfsc 1:110 parent 1:100 leaf 110: sc m1 0bit d 0us m2 8000bit                                                                                                                                       
 Sent 1544928 bytes 18392 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                        
 rate 1344bit 2pps backlog 0b 0p requeues 0                                                                                                                                                               
 period 18392 work 1544928 bytes rtwork 1411368 bytes level 0                                                                                                                                             
                                                                                                                                                                                                          
class hfsc 1: root                                                                                                                                                                                        
 Sent 4180 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                              
 backlog 0b 0p requeues 0                                                                                                                                                                                 
 period 0 level 2                                                                                                                                                                                         
                                                                                                                                                                                                          
class hfsc 1:100 parent 1: sc m1 0bit d 0us m2 20000Kbit ul m1 0bit d 0us m2 
20000Kbit                                                                                                                    
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                                  
 rate 0bit 0pps backlog 0b 0p requeues 0                                                                                                                                                                  
 period 74 work 22978893888 bytes level 1                                                                                                                                                                 
                                                                                                                                                                                                          
class hfsc 1:130 parent 1:100 leaf 130: sc m1 0bit d 0us m2 7000Kbit ul m1 
0bit d 0us m2 20000Kbit                                                                                                        
 Sent 5900522796 bytes 19334198 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                  
 rate 5826Kbit 2360pps backlog 0b 0p requeues 0                                                                                                                                                           
 period 13454851 work 5900522796 bytes rtwork 3473525428 bytes level 0                                                                                                                                    
                                                                                                                                                                                                          
class hfsc 1:120 parent 1:100 leaf 120: sc m1 0bit d 0us m2 3000Kbit ul m1 
0bit d 0us m2 20000Kbit                                                                                                        
 Sent 659289392 bytes 3151731 pkt (dropped 484, overlimits 0 requeues 0)                                                                                                                                  
 rate 490560bit 329pps backlog 0b 0p requeues 0                                                                                                                                                           
 period 2902223 work 659289392 bytes rtwork 391958652 bytes level 0                                                                                                                                       
                                                                                                                                                                                                          
class hfsc 1:150 parent 1:100 leaf 150: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit                                                                                                        
 Sent 15792563632 bytes 79195890 pkt (dropped 376595, overlimits 0 requeues 0)                                                                                                                            
 rate 14354Kbit 8650pps backlog 0b 0p requeues 0                                                                                                                                                          
 period 9906952 work 15792563632 bytes rtwork 2219169504 bytes level 0                                                                                                                                    
                                                                                                                                                                                                          
class hfsc 1:140 parent 1:100 leaf 140: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit                                                                                                        
 Sent 87850052 bytes 540018 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                      
 rate 47024bit 70pps backlog 0b 0p requeues 0                                                                                                                                                             
 period 527595 work 87850052 bytes rtwork 82404272 bytes level 0                                                                                                                                          
                                                                                                                                                                                                          
class hfsc 1:170 parent 1:100 leaf 170: sc m1 0bit d 0us m2 256000bit ul m1 
0bit d 0us m2 20000Kbit                                                                                                       
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                                  
 rate 0bit 0pps backlog 0b 0p requeues 0                                                                                                                                                                  
 period 0 level 0                                                                                                                                                                                         
                                                                                                                                                                                                          
class hfsc 1:160 parent 1:100 leaf 160: sc m1 0bit d 0us m2 256000bit ul m1 
0bit d 0us m2 20000Kbit                                                                                                       
 Sent 75659416 bytes 58924 pkt (dropped 201, overlimits 0 requeues 0)                                                                                                                                     
 rate 256bit 0pps backlog 0b 0p requeues 0                                                                                                                                                                
 period 27786 work 75659416 bytes rtwork 14074548 bytes level 0                                                                                                                                           
                                                                                                                                                                                                          
class hfsc 1:190 parent 1:100 leaf 190: sc m1 0bit d 0us m2 200000bit ul m1 
0bit d 0us m2 400000bit                                                                                                       
 Sent 459905752 bytes 5083942 pkt (dropped 2305517, overlimits 0 requeues 0)                                                                                                                              
 rate 400112bit 548pps backlog 0b 1094p requeues 0                                                                                                                                                        
 period 3 work 459806144 bytes rtwork 229903112 bytes level 0                                                                                                                                             
                                                                                                                                                                                                          
class hfsc 1:180 parent 1:100 leaf 180: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit                                                                                                        
 Sent 1657528 bytes 7985 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                         
 rate 1320bit 1pps backlog 0b 0p requeues 0                                                                                                                                                               
 period 7097 work 1657528 bytes rtwork 1380512 bytes level 0                                                                                                                                              

------------------------
After 10 seconds
                                                                                                                                                                                                          
class hfsc 1:110 parent 1:100 leaf 110: sc m1 0bit d 0us m2 8000bit                                                                                                                                       
 Sent 1546608 bytes 18412 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                        
 rate 1344bit 2pps backlog 0b 0p requeues 0                                                                                                                                                               
 period 18412 work 1546608 bytes rtwork 1413048 bytes level 0                                                                                                                                             
                                                                                                                                                                                                          
class hfsc 1: root                                                                                                                                                                                        
 Sent 4180 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                              
 backlog 0b 0p requeues 0                                                                                                                                                                                 
 period 0 level 2                                                                                                                                                                                         
                                                                                                                                                                                                          
class hfsc 1:100 parent 1: sc m1 0bit d 0us m2 20000Kbit ul m1 0bit d 0us m2 
20000Kbit                                                                                                                    
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)                                                                                                                                                  
 rate 0bit 0pps backlog 0b 0p requeues 0                                                                                                                                                                  
 period 74 work 23004936640 bytes level 1                                                                                                                                                                 

class hfsc 1:130 parent 1:100 leaf 130: sc m1 0bit d 0us m2 7000Kbit ul m1 
0bit d 0us m2 20000Kbit
 Sent 5907643408 bytes 19355979 pkt (dropped 0, overlimits 0 requeues 0)
 rate 5663Kbit 2226pps backlog 0b 6p requeues 0
 period 13471026 work 5907643020 bytes rtwork 3477346092 bytes level 0

class hfsc 1:120 parent 1:100 leaf 120: sc m1 0bit d 0us m2 3000Kbit ul m1 
0bit d 0us m2 20000Kbit
 Sent 659705168 bytes 3154632 pkt (dropped 484, overlimits 0 requeues 0)
 rate 380008bit 303pps backlog 0b 0p requeues 0
 period 2905063 work 659705168 bytes rtwork 392246028 bytes level 0

class hfsc 1:150 parent 1:100 leaf 150: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit
 Sent 15810495520 bytes 79281120 pkt (dropped 376595, overlimits 0 requeues 0)
 rate 14362Kbit 8547pps backlog 0b 0p requeues 0
 period 9928987 work 15810495520 bytes rtwork 2221499996 bytes level 0

class hfsc 1:140 parent 1:100 leaf 140: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit
 Sent 87918300 bytes 540801 pkt (dropped 0, overlimits 0 requeues 0)
 rate 50528bit 74pps backlog 0b 0p requeues 0
 period 528353 work 87918300 bytes rtwork 82463492 bytes level 0

class hfsc 1:170 parent 1:100 leaf 170: sc m1 0bit d 0us m2 256000bit ul m1 
0bit d 0us m2 20000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 1:160 parent 1:100 leaf 160: sc m1 0bit d 0us m2 256000bit ul m1 
0bit d 0us m2 20000Kbit
 Sent 75659480 bytes 58925 pkt (dropped 201, overlimits 0 requeues 0)
 rate 96bit 0pps backlog 0b 0p requeues 0
 period 27787 work 75659480 bytes rtwork 14074612 bytes level 0

class hfsc 1:190 parent 1:100 leaf 190: sc m1 0bit d 0us m2 200000bit ul m1 
0bit d 0us m2 400000bit
 Sent 460405988 bytes 5089449 pkt (dropped 2307857, overlimits 0 requeues 0)
 rate 399960bit 548pps backlog 0b 1109p requeues 0
 period 3 work 460306304 bytes rtwork 230153172 bytes level 0

class hfsc 1:180 parent 1:100 leaf 180: sc m1 0bit d 0us m2 2000Kbit ul m1 
0bit d 0us m2 20000Kbit
 Sent 1662240 bytes 8007 pkt (dropped 0, overlimits 0 requeues 0)
 rate 2088bit 1pps backlog 0b 0p requeues 0
 period 7118 work 1662240 bytes rtwork 1384776 bytes level 0

qdisc setup
