From: "Sebastian J. Bronner" <sebastian.bronner@d9t.de>
Subject: bridge not routing packets via source bridgeport
Date: Mon, 03 Jan 2011 18:52:59 +0100
Message-ID: <4D220CFB.5060300@d9t.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507040001030200030206"
Cc: Daniel Kraft <daniel.kraft@d9t.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj232.sb.d9t.de ([94.186.148.168]:45723 "EHLO
	zimbra.pool.b.d9tcloud.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348Ab1ACSCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 13:02:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by zimbra.pool.b.d9tcloud.de (Postfix) with ESMTP id 6FC70AEAE4
	for <netdev@vger.kernel.org>; Mon,  3 Jan 2011 18:59:14 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060507040001030200030206
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Hi all,

we recently upgraded from 2.6.32.25 to 2.6.35.24 and discovered that our
virtual machines can no longer access their own external IP addresses.
Testing revealed that 2.6.34 was the last version not to have the
problem. 2.6.36 still had it. But on to the details.

Our setup:

We use KVM to virtualise our guests. The physical machines (nodes) act
as One-to-One NAT routers to the virtual machines. The virtual machines
are connected via virtio interfaces in a bridge.

Since the virtual machines only know about their RFC-1918 addresses, any
request they make to their NATed global addresses requires a trip
through the node's netfilter to perform the needed SNAT and DNAT operations.

Take the following setup:

   {internet}
       |
     (eth0)       <- 1.1.1.254, proxy_arp=1
       |
     [node]       <- ip_forward=1, routes*, nat**
       |
    (virbr1)      <- 10.0.0.1
    /      \
(vnet0)     |
   |     (vnet1)
(veth0)     |     <- 10.0.0.2
   |     (veth0)  <- 10.0.0.3
 [vm1]      |
          [vm2]

* The static routes on the node for the vms mentioned above are as follows:
# ip r
1.1.1.2 dev virbr1 scope link
1.1.1.3 dev virbr1 scope link

** The NAT rules are set up as follows (in reality, they're a bit more
complicated - but this suffices to illustrate the problem at hand):
# iptables-save -t nat
-A PREROUTING -d 1.1.1.2 -j DNAT --to-destination 10.0.0.2
-A PREROUTING -d 1.1.1.3 -j DNAT --to-destination 10.0.0.3
-A POSTROUTING -s 10.0.0.2 -j SNAT --to-source 1.1.1.2
-A POSTROUTING -s 10.0.0.3 -j SNAT --to-source 1.1.1.3

This means that 1.1.1.2 maps to 10.0.0.2 (vm1) and
                1.1.1.3 maps to 10.0.0.3 (vm2).

Assuming ssh is running on both vms, running 'nc -v 1.1.1.3 22' from vm1
gets me ssh's introductory message.

Assuming, no service is running on port 23, running 'nc -v 1.1.1.3 23'
from vm1 gets me 'Connection refused'.

That's all fine and exactly as it should be. The vms are accessible from
the internet as well, and can access the internet.

If, however, i run 'nc -v 1.1.1.2 22' from vm1 (or any port for that
matter), I get a timeout!

Running tcpdump on all the involved interfaces showed me that the
packets successfully traverse veth0 and vnet0 and appear to get lost
upon reaching virbr1.

So, then I decided to set up a packet trace with iptables:
[on the node]
# modprobe ipt_LOG
# iptables -t raw -A PREROUTING -p tcp --dport 4577 -j TRACE
# tail -f /var/log/messages | grep TRACE
[on vm1]
# nc -v 1.1.1.2 4577

The results were very interesting, if somewhat dumbfounding. They are
attached for easier perusal. The gist of it is that the packet in
question disappears without a trace after going through the DNAT rule in
the PREROUTING chain of the NAT table. This can be seen happening three
times in vm1-to-1.1.1.2.txt in three and six second intervals (retries).

For comparison, I have also included a trace of a successful packet
traversal that ends in a 'Connection refused'. It is in vm1-to-1.1.1.3.txt.

As a last note, I should add that the problem isn't related to the IP
address. I eliminated that by putting two RFC-1918 IPs on vm1 and
mapping two IPs to it, then running nc on one IP, while the other one
was being used as the source IP.

The problem appears to be that packets can't be routed out the same
bridgeport that they arrived from.

I hope this all makes sense and that you can reproduce the problem. One
virtual machine will suffise to see the problem at work.

Feel free to contact me if you need more information or have suggestions
for me.

Cheers,
Sebastian Bronner

P.S.: The IP addresses are faked. I used vim to replace all instances of
the real IPs with the fake ones used in this e-mail consistently.
-- 
*Sebastian J. Bronner*
Administrator

D9T GmbH - Magirusstr. 39/1 - D-89077 Ulm
Tel: +49 731 1411 696-0 - Fax: +49 731 3799-220

Geschäftsführer: Daniel Kraft
Sitz und Register: Ulm, HRB 722416
Ust.IdNr: DE 260484638

http://d9t.de - D9T High Performance Hosting
info@d9t.de

--------------060507040001030200030206
Content-Type: text/plain;
 name="vm1-to-1.1.1.2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="vm1-to-1.1.1.2.txt"

Jan  3 18:29:35 s14 kernel: [15791.001685] TRACE: raw:PREROUTING:policy:2 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62671 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E78D50000000001030307) UID=0 GID=0 
Jan  3 18:29:35 s14 kernel: [15791.001730] TRACE: mangle:PREROUTING:policy:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62671 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E78D50000000001030307) UID=0 GID=0 
Jan  3 18:29:35 s14 kernel: [15791.001762] TRACE: nat:PREROUTING:rule:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62671 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E78D50000000001030307) UID=0 GID=0 
Jan  3 18:29:38 s14 kernel: [15793.995583] TRACE: raw:PREROUTING:policy:2 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62672 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7A010000000001030307) UID=0 GID=0 
Jan  3 18:29:38 s14 kernel: [15793.995624] TRACE: mangle:PREROUTING:policy:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62672 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7A010000000001030307) UID=0 GID=0 
Jan  3 18:29:38 s14 kernel: [15793.995656] TRACE: nat:PREROUTING:rule:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62672 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7A010000000001030307) UID=0 GID=0 
Jan  3 18:29:44 s14 kernel: [15799.995658] TRACE: raw:PREROUTING:policy:2 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62673 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7C590000000001030307) UID=0 GID=0 
Jan  3 18:29:44 s14 kernel: [15799.995700] TRACE: mangle:PREROUTING:policy:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62673 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7C590000000001030307) UID=0 GID=0 
Jan  3 18:29:44 s14 kernel: [15799.995732] TRACE: nat:PREROUTING:rule:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.2 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=62673 DF PROTO=TCP SPT=49068 DPT=4577 SEQ=1589611546 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000E7C590000000001030307) UID=0 GID=0 

--------------060507040001030200030206
Content-Type: text/plain;
 name="vm1-to-1.1.1.3.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="vm1-to-1.1.1.3.txt"

Jan  3 18:32:33 s14 kernel: [15968.856178] TRACE: raw:PREROUTING:policy:2 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) UID=0 GID=0 
Jan  3 18:32:33 s14 kernel: [15968.856211] TRACE: mangle:PREROUTING:policy:1 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) UID=0 GID=0 
Jan  3 18:32:33 s14 kernel: [15968.856233] TRACE: nat:PREROUTING:policy:2 IN=virbr1 OUT= PHYSIN=vnet0 MAC=02:00:00:00:00:16:52:54:00:4a:25:72:08:00 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) UID=0 GID=0 
Jan  3 18:32:33 s14 kernel: [15968.856272] TRACE: mangle:FORWARD:policy:1 IN=virbr1 OUT=eth0 PHYSIN=vnet0 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) 
Jan  3 18:32:33 s14 kernel: [15968.856288] TRACE: filter:FORWARD:policy:1 IN=virbr1 OUT=eth0 PHYSIN=vnet0 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) 
Jan  3 18:32:33 s14 kernel: [15968.856305] TRACE: mangle:POSTROUTING:policy:1 IN= OUT=eth0 PHYSIN=vnet0 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) 
Jan  3 18:32:33 s14 kernel: [15968.856321] TRACE: nat:POSTROUTING:rule:1 IN= OUT=eth0 PHYSIN=vnet0 SRC=10.0.0.2 DST=1.1.1.3 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=36414 DF PROTO=TCP SPT=37569 DPT=4577 SEQ=80883825 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0 OPT (020405B40402080A000EBE4F0000000001030307) 

--------------060507040001030200030206
Content-Type: text/plain;
 name="iptables-nat.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="iptables-nat.txt"

Chain PREROUTING (policy ACCEPT 4027 packets, 296K bytes)
 pkts bytes target     prot opt in     out     source               destination         
    8   488 DNAT       all  --  *      *       0.0.0.0/0            1.1.1.2             to:10.0.0.2 

Chain OUTPUT (policy ACCEPT 24412 packets, 1578K bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 24430 packets, 1579K bytes)
 pkts bytes target     prot opt in     out     source               destination         
    4   240 SNAT       all  --  *      *       10.0.0.2             0.0.0.0/0           to:1.1.1.2 

--------------060507040001030200030206--
