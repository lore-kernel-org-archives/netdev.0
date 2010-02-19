From: Stephen Hemminger <shemminger@vyatta.com>
Subject: NAT regression in next tree
Date: Thu, 18 Feb 2010 17:36:33 -0800
Message-ID: <20100218173633.30bb8c41@nehalam>
References: <20100216173658.519b6245@nehalam>
	<201002171526.02493.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201002171526.02493.arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Something in net-next tree broke bridging of virtual nets.
My local VM's can no longer access external networks.

It is a NAT problem. One of the recent netfilter changes is causing
the packets to not have there source address rewritten.

I see:
    VM1  -- 192.168.100.0/24 -- HOST -- 192.168.1.0/24 -- ROUTER
                           virbr0    eth0

Even a simple ping from VM1 doesn't get responded to because
the 192.168.100.X source address is not getting rewritten.

iptables -n -v -v -L (on host) after several attempted packets
-----------------
Chain INPUT (policy ACCEPT 2767 packets, 1347K bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     udp  --  virbr1 *       0.0.0.0/0            0.0.0.0/0           udp dpt:53 
    0     0 ACCEPT     tcp  --  virbr1 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:53 
    0     0 ACCEPT     udp  --  virbr1 *       0.0.0.0/0            0.0.0.0/0           udp dpt:67 
    0     0 ACCEPT     tcp  --  virbr1 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:67 
    0     0 ACCEPT     udp  --  virbr2 *       0.0.0.0/0            0.0.0.0/0           udp dpt:53 
    0     0 ACCEPT     tcp  --  virbr2 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:53 
    0     0 ACCEPT     udp  --  virbr2 *       0.0.0.0/0            0.0.0.0/0           udp dpt:67 
    0     0 ACCEPT     tcp  --  virbr2 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:67 
    5   295 ACCEPT     udp  --  virbr0 *       0.0.0.0/0            0.0.0.0/0           udp dpt:53 
    0     0 ACCEPT     tcp  --  virbr0 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:53 
    2   656 ACCEPT     udp  --  virbr0 *       0.0.0.0/0            0.0.0.0/0           udp dpt:67 
    0     0 ACCEPT     tcp  --  virbr0 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:67 
    0     0 ACCEPT     udp  --  virbr4 *       0.0.0.0/0            0.0.0.0/0           udp dpt:53 
    0     0 ACCEPT     tcp  --  virbr4 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:53 
    0     0 ACCEPT     udp  --  virbr4 *       0.0.0.0/0            0.0.0.0/0           udp dpt:67 
    0     0 ACCEPT     tcp  --  virbr4 *       0.0.0.0/0            0.0.0.0/0           tcp dpt:67 

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 ACCEPT     all  --  virbr1 virbr1  0.0.0.0/0            0.0.0.0/0           
    0     0 REJECT     all  --  *      virbr1  0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 REJECT     all  --  virbr1 *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 ACCEPT     all  --  virbr2 virbr2  0.0.0.0/0            0.0.0.0/0           
    0     0 REJECT     all  --  *      virbr2  0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 REJECT     all  --  virbr2 *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 ACCEPT     all  --  *      virbr0  0.0.0.0/0            192.168.100.0/24    state RELATED,ESTABLISHED 
   15  1188 ACCEPT     all  --  virbr0 *       192.168.100.0/24     0.0.0.0/0           
    0     0 ACCEPT     all  --  virbr0 virbr0  0.0.0.0/0            0.0.0.0/0           
    0     0 REJECT     all  --  *      virbr0  0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 REJECT     all  --  virbr0 *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 ACCEPT     all  --  virbr4 virbr4  0.0.0.0/0            0.0.0.0/0           
    0     0 REJECT     all  --  *      virbr4  0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 
    0     0 REJECT     all  --  virbr4 *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-port-unreachable 

Chain OUTPUT (policy ACCEPT 2720 packets, 1311K bytes)
 pkts bytes target     prot opt in     out     source               destination         
libiptc vlibxtables.so.2. 6000 bytes.
Table `filter'
Hooks: pre/in/fwd/out/post = ffffffff/0/d18/1628/ffffffff
Underflows: pre/in/fwd/out/post = ffffffff/c80/1590/1628/ffffffff
Entry 0 (0):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 1 (200):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 2 (400):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 3 (600):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 4 (800):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 5 (1000):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 6 (1200):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 7 (1400):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 8 (1600):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 5 packets, 295 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 9 (1800):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 10 (2000):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 2 packets, 656 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 11 (2200):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 12 (2400):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 13 (2600):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 14 (2800):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `'/................
Protocol: 17
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `udp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 15 (3000):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `'/................
Protocol: 6
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `tcp'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 16 (3200):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 2767 packets, 1347401 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 17 (3352):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `virbr1'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 18 (3504):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `virbr1'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 19 (3656):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr1'/XXXXXXX.........to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 20 (3808):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `virbr2'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 21 (3960):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `virbr2'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 22 (4112):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr2'/XXXXXXX.........to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 23 (4264):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 192.168.100.0/255.255.255.0
Interface: `'/................to `virbr0'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Match name: `state'
Target name: `' [40]
verdict=NF_ACCEPT

Entry 24 (4456):
SRC IP: 192.168.100.0/255.255.255.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 15 packets, 1188 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 25 (4608):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `virbr0'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 26 (4760):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `virbr0'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 27 (4912):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr0'/XXXXXXX.........to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 28 (5064):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `virbr4'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 29 (5216):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `virbr4'/XXXXXXX.........
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 30 (5368):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `virbr4'/XXXXXXX.........to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `REJECT' [40]

Entry 31 (5520):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 32 (5672):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 2720 packets, 1310915 bytes
Cache: 00000000
Target name: `' [40]
verdict=NF_ACCEPT

Entry 33 (5824):
SRC IP: 0.0.0.0/0.0.0.0
DST IP: 0.0.0.0/0.0.0.0
Interface: `'/................to `'/................
Protocol: 0
Flags: 00
Invflags: 00
Counters: 0 packets, 0 bytes
Cache: 00000000
Target name: `ERROR' [64]
error=`ERROR'

