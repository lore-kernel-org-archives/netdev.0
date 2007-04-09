From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Mon, 9 Apr 2007 13:23:43 -0400
Message-ID: <20070409172343.GD2299@csclub.uwaterloo.ca>
References: <20070408150123.GA3511@csclub.uwaterloo.ca> <1176048615.686.78.camel@owl.home.ie> <20070408182210.GJ3508@csclub.uwaterloo.ca> <1176060547.686.95.camel@owl.home.ie> <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie> <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net> <20070409161932.GA2302@csclub.uwaterloo.ca> <1176138144.686.115.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:54532 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752277AbXDIRXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 13:23:44 -0400
Content-Disposition: inline
In-Reply-To: <1176138144.686.115.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 06:02:23PM +0100, W Agtail wrote:
> Thanks Patrick for your comments too.
> It seems that you can't mix PREROUTING with --sport or -o.
> I've also changed the ip rule tables to higher numbers, so I now have:

I thought you could have --sport, but NOT -o.  No need for -o of course.

> iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j LOG
> --log-prefix "fwmark 1: "
> iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j LOG
> --log-prefix "fwmark 2: "
> 
> iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
> --set-mark 1
> iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
> --set-mark 2
> iptables -t mangle -A PREROUTING -m mark --mark 1 -j LOG --log-prefix
> "marked 1: "
> iptables -t mangle -A PREROUTING -m mark --mark 2 -j LOG --log-prefix
> "marked 2: "

The thing is that the destination port will NEVER be 8088 for the
outgoing packets from apache.  The source port will be.

Try this:

iptables -t mangle -A PREROUTING -p tcp --sport 8088 -j LOG --log-prefix "fwmark 1: "
iptables -t mangle -A PREROUTING -p tcp --sport 8089 -j LOG --log-prefix "fwmark 2: "
iptables -t mangle -A PREROUTING -p tcp --sport 8088 -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -p tcp --sport 8089 -j MARK --set-mark 2
iptables -t mangle -A PREROUTING -m mark --mark 1 -j LOG --log-prefix "marked 1: "
iptables -t mangle -A PREROUTING -m mark --mark 2 -j LOG --log-prefix "marked 2: "

> ip route add table 8088 default via 10.18.35.11 dev eth0
> ip route add table 8089 default via 10.18.35.21 dev eth0
> 
> ip rule add fwmark 1 table 8088
> ip rule add fwmark 2 table 8089
> 
> 
> # Confirmation of syntax:
> iptables -t mangle --list -v -n
> Chain PREROUTING (policy ACCEPT 5921 packets, 403K bytes)
>  pkts bytes target     prot opt in     out     source
> destination
>    18   984 LOG        tcp  --  eth0   *       0.0.0.0/0
> 0.0.0.0/0           tcp dpt:8088 LOG flags 0 level 4 prefix `fwmark 1: '
>     0     0 LOG        tcp  --  eth0   *       0.0.0.0/0
> 0.0.0.0/0           tcp dpt:8089 LOG flags 0 level 4 prefix `fwmark 2: '
>    18   984 MARK       tcp  --  eth0   *       0.0.0.0/0
> 0.0.0.0/0           tcp dpt:8088 MARK set 0x1
>     0     0 MARK       tcp  --  eth0   *       0.0.0.0/0
> 0.0.0.0/0           tcp dpt:8089 MARK set 0x2
>    18   984 LOG        all  --  *      *       0.0.0.0/0
> 0.0.0.0/0           MARK match 0x1 LOG flags 0 level 4 prefix `marked 1:
> '
>     0     0 LOG        all  --  *      *       0.0.0.0/0
> 0.0.0.0/0           MARK match 0x2 LOG flags 0 level 4 prefix `marked 2:
> '
> 
> 
> ip rule list
> 0:      from all lookup local
> 32764:  from all fwmark 0x2 lookup 8089
> 32765:  from all fwmark 0x1 lookup 8088
> 32766:  from all lookup main
> 32767:  from all lookup default
> 
> ip route list table 8088; ip route list table 8089
> default via 10.18.35.11 dev eth0
> default via 10.18.35.21 dev eth0
> 
> This is what I see in web2's /var/log/messages:
> Apr  9 06:46:58 web2-fc6 kernel: fwmark 1: IN=eth0 OUT=
> MAC=00:0c:29:d1:08:48:00:0c:29:49:04:9f:08:00 SRC=192.168.0.241
> DST=10.18.35.52 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=42359 DF PROTO=TCP
> SPT=33321 DPT=8088 WINDOW=5840 RES=0x00 SYN URGP=0
> 
> Apr  9 06:46:58 web2-fc6 kernel: marked 1: IN=eth0 OUT=
> MAC=00:0c:29:d1:08:48:00:0c:29:49:04:9f:08:00 SRC=192.168.0.241
> DST=10.18.35.52 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=42359 DF PROTO=TCP
> SPT=33321 DPT=8088 WINDOW=5840 RES=0x00 SYN URGP=0
> 
> As you can see, packets appear to be marked.
> But here's a tcpdump on gw2's eth1:
> 
> 07:20:35.004205 192.168.0.241.59438 > 10.18.35.52.8088: S
> 221760494:221760494(0) win 5840 <mss 1460,sackOK,timestamp 1320423
> 0,nop,wscale 6> (DF)
> 07:20:35.013144 10.18.35.52.8088 > 192.168.0.241.59438: S
> 2705868365:2705868365(0) ack 221760495 win 5792 <mss
> 1460,sackOK,timestamp 2191014 1320423,nop,wscale 1> (DF)
> 07:20:35.021857 192.168.0.241.59438 > 10.18.35.52.8088: R
> 221760495:221760495(0) win 0 (DF)
> 07:20:38.069688 192.168.0.241.59438 > 10.18.35.52.8088: S
> 221760494:221760494(0) win 5840 <mss 1460,sackOK,timestamp 1321173
> 0,nop,wscale 6> (DF)
> 07:20:38.069695 10.18.35.52.8088 > 192.168.0.241.59438: S
> 2706988830:2706988830(0) ack 221760495 win 5792 <mss
> 1460,sackOK,timestamp 2192135 1321173,nop,wscale 1> (DF)
> 07:20:38.071232 192.168.0.241.59438 > 10.18.35.52.8088: R
> 221760495:221760495(0) win 0 (DF)
> 
> So, traffic is being returned via gw2, rather than gw1 :(

They are marked I guess, but much too late.

--
Len Sorensen
