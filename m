From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: [RFC PATCH] Change "local" route table preference from 0 to 3fff,
 to permit send-to-self policy routing
Date: Fri, 18 Jun 2004 18:25:05 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618182505.195d76ba.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Firstly, please accept my apologies for the size of this email. 

I've come up with a way of performing send-to-self routing, via two ethernet
interfaces and a loopback (actually via a switch), using the policy routing
engine. 

It is a bit fiddly to set up. I needed to be able to insert the policy routing
rules before the "local" route table match. I've attached a (very) small patch
to change the preference of the "local" route table from 0 to 3fff (16383),
which is half of the value of the "default" route table preference. The 3fff
value is mostly arbitrary, the assigned value isn't all that important as
long as it is greater than zero, and leaves enough room for a number of
preceeding policies.

Here is how it is set up :

(a) Assign IP addresses to the ethernet interfaces that are going to be used
for the send-to-self traffic. In my example, I'm using 10.0.0.1 and 10.0.0.2 :

[root@monte] # ip addr add 10.0.0.1/24 dev eth1
[root@monte] # ip addr add 10.0.0.2/24 dev eth2

[root@monte] # ip addr show dev eth1
9: eth1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:40:33:23:c6:d2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.2/24 brd 192.168.1.255 scope global eth1
    inet 10.0.0.1/24 scope global eth1
    inet6 fe80::240:33ff:fe23:c6d2/64 scope link 
       valid_lft forever preferred_lft forever
[root@monte] # ip addr show dev eth2
10: eth2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:40:33:23:c2:1c brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.2/24 brd 192.168.2.255 scope global eth2
    inet 10.0.0.2/24 scope global eth2
    inet6 fe80::240:33ff:fe23:c21c/64 scope link 
       valid_lft forever preferred_lft forever
[root@monte] #


(b) Create two policies that match these IP addresses, and forward traffic
towards them using custom route tables. These policies need to appear
before the"local" route table match, hence the patch to change the "local"
route table preference from 0 to 3fff. (partial output of"ip rule show"
command to minimise confusion at this point - this stuff screwed with my
head for a while when I was working it out):

[root@monte] # ip rule add to 10.0.0.2 table 200 pref 200
[root@monte] # ip rule add to 10.0.0.1 table 201 pref 201

--
200:    from all to 10.0.0.2 lookup 200 
201:    from all to 10.0.0.1 lookup 201
--

(c) Create corresponding route tables, which specify which interface to use to
get to the above IP addresses, and the source address to use when doing so :

[root@monte] # ip route add 10.0.0.2 dev eth1 src 10.0.0.1 table 200
[root@monte] # ip route add 10.0.0.1 dev eth2 src 10.0.0.2 table 201

[root@monte] # ip route show table 200
10.0.0.2 dev eth1  scope link  src 10.0.0.1 
[root@monte] # ip route show table 201
10.0.0.1 dev eth2  scope link  src 10.0.0.2 
[root@monte] #

At this point, any traffic sent towards 10.0.0.2 will leave the host via eth1,
and any traffic towards 10.0.0.1 will leave the host via eth2, even though
those addresses are assigned to local interfaces. The next step is to process
this traffic when it comes into the host via eth2 for 10.0.0.2 and via eth1
for 10.0.0.1.

(d) Create policies that match these IP addresses, on the specified incoming
interface (which is the interface the address is assigned to), and use
the "local" table for routing. Traffic processed by the "local" table will be
processed by the host itself ie. passed up the network stack for local
processing. These policies have to appear before both the "local" table
policy and the previous policies that send the traffic out the ethernet
interfaces. This ensures that traffic that enters the physical interfaces
"jumps" over the policies that sent it out the physical interfaces in the
first place.

[root@monte] # ip rule add to 10.0.0.2 dev eth2 table local pref 100
[root@monte] # ip rule add to 10.0.0.1 dev eth1 table local pref 101

After this step, the policy ruleset will look as follows :

[root@monte] # ip rule show
100:    from all to 10.0.0.2 iif eth2 lookup local 
101:    from all to 10.0.0.1 iif eth1 lookup local 
200:    from all to 10.0.0.2 lookup 200 
201:    from all to 10.0.0.1 lookup 201 
16383:  from all lookup local 
32766:  from all lookup main 
32767:  from all lookup default

(e) Finally, create static ARP entries for the IP addresses, specifying the
MAC address of the interface the address is assigned to, and the interface
that is going to be used to reach the address ie. the _other_ interface of the
pair.

[root@monte] # ip neigh add 10.0.0.2 dev eth1 lladdr 00:40:33:23:c2:1c
[root@monte] # ip neigh add 10.0.0.1 dev eth2 lladdr 00:40:33:23:c6:d2

[root@monte] # ip neigh show
10.0.0.1 dev eth2 lladdr 00:40:33:23:c6:d2 nud permanent
10.0.0.2 dev eth1 lladdr 00:40:33:23:c2:1c nud permanent
192.168.0.1 dev eth0 lladdr 00:a0:cc:a2:6e:4d nud reachable
[root@monte] #

I don't know if this is completely necessary, I haven't played with the
various ARP reply options available. By default, I didn't think I was seeing
ARP replies from addresses assigned to the host itself, although I could have
been a bit confused at this point. Creating static ARP entries seemed to fix
that problem. Something I'll look into further, unless somebody can tell me
that having a host reply its own ARP requests, even when received over a real
interface, isn't possible at all.

After all this configuration, here is a ping between the addresses, and the
interface packet count statistics after the ping (edited very slightly,
cutting-and-pasting from minicom screws up the formatting a bit, I used a
serial console to avoid any network traffic influencing the counters):

[root@monte] /root # ping -f 10.0.0.2                                         
PING 10.0.0.2 (10.0.0.2): 56 data bytes                                      
.                                                                           
--- 10.0.0.2 ping statistics ---                                           
796 packets transmitted, 795 packets received, 0% packet loss             
round-trip min/avg/max = 3.7/3.8/12.6 ms

[root@monte] /root # ip -s link show dev eth1                                 
 9: eth1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000        
 link/ether 00:40:33:23:c6:d2 brd ff:ff:ff:ff:ff:ff                      
 RX: bytes  packets  errors  dropped overrun mcast                      
   78068      797      0       0       0       1                         
 TX: bytes  packets  errors  dropped carrier collsns                  
   78386      801      0       0       0       0  
[root@monte] /root # ip -s link show dev eth2                                 
 10: eth2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000       
 link/ether 00:40:33:23:c2:1c brd ff:ff:ff:ff:ff:ff                      
 RX: bytes  packets  errors  dropped overrun mcast                      
   78068      797      0       0       0       1                         
 TX: bytes  packets  errors  dropped carrier collsns                  
   78386      801      0       0       0       0                       
[root@monte] /root #

The lights on the switch ports corresponding to eth1 and eth2 also blinked
alot while running the above flood ping :-)

The patch is as follows 

--- fib_rules.c.orig	Thu Jun 17 21:31:46 2004
+++ fib_rules.c	Thu Jun 17 21:32:43 2004
@@ -94,6 +94,7 @@
 static struct fib_rule local_rule = {
 	.r_next =	&main_rule,
 	.r_clntref =	ATOMIC_INIT(2),
+	.r_preference = 0x3FFF,
 	.r_table =	RT_TABLE_LOCAL,
 	.r_action =	RTN_UNICAST,
 };


I'm hoping this patch could be applied. I don't think it effects the standard
operation of the network stack, yet allows the above policy routing
configuration to be implemented. Please note that I don't know much about
kernel hacking, if there is a better way to change the "local" route table
preference, I'm all ears.

I'm interested in any comments, questions or constructive criticisms. For any
follow up emails, please CC me as I'm not subscribed to the list.

Thanks for reading this far :-)

Regards,
Mark.
