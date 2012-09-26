From: Stephen Clark <sclark46@earthlink.net>
Subject: Routing issue
Date: Wed, 26 Sep 2012 07:01:32 -0400
Message-ID: <5062E08C.1010008@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:56321 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753887Ab2IZLBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 07:01:35 -0400
Received: from [69.22.83.100] (helo=joker.seclark.com)
	by elasmtp-banded.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1TGpN0-0002WL-B3
	for netdev@vger.kernel.org; Wed, 26 Sep 2012 07:01:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Because Linux makes routing decisions before SNAT it is causing
problems when trying to use FTP with two upstream providers in
a load balanced setup.

Other than ftp things seem to work OK. Below is my setup and tcpdump
output that shows ftp packets trying to go out the wrong interface.

ip ru sh
0:      from all lookup local
200:    from y.y.y.174 lookup t1
201:    from x.x.x.217 lookup t2
32766:  from all lookup main
32767:  from all lookup default

ip r s
y.y.y.129 dev eth1  scope link
172.16.0.0/29 dev gre1  proto kernel  scope link  src 172.16.0.1
y.y.y.128/25 dev eth1  proto kernel  scope link  src y.y.y.174
10.0.1.0/24 dev eth0  proto kernel  scope link  src 10.0.1.90
192.168.198.0/24 dev eth0  proto kernel  scope link  src 192.168.198.92
x.x.x.0/24 dev eth2  proto kernel  scope link  src x.x.x.217
10.0.128.0/17 dev eth0  proto kernel  scope link  src 10.0.129.88
default
         nexthop via y.y.y.129  dev eth1 weight 1
         nexthop via x.x.x.1  dev eth2 weight 1

ip r s tab t1
default via y.y.y.129 dev eth1  src y.y.y.174

ip r s tab t2
default via x.x.x.1 dev eth2  src x.x.x.217

Chain PREROUTING (policy ACCEPT 1050K packets, 128M bytes)
  pkts bytes target     prot opt in     out     source               
destination

Chain POSTROUTING (policy ACCEPT 423K packets, 35M bytes)
  pkts bytes target     prot opt in     out     source               
destination
     0     0 ACCEPT     all  --  *      eth1    10.0.1.0/24          
10.0.0.0/8
     0     0 ACCEPT     all  --  *      eth1    10.0.1.0/24          
172.16.0.0/12
     0     0 ACCEPT     all  --  *      eth1    10.0.1.0/24          
192.168.0.0/16
    58  3480 SNAT       all  --  *      eth1    10.0.1.0/24          
0.0.0.0/0           to:y.y.y.174
     4   240 SNAT       all  --  *      eth2    10.0.1.0/24          
0.0.0.0/0           to:x.x.x.217

lsmod | grep nf_
nf_conntrack_ipv6       7207  3
nf_defrag_ipv6          9873  1 nf_conntrack_ipv6
nf_nat_ftp              2602  0
nf_nat                 18580  2 iptable_nat,nf_nat_ftp
nf_conntrack_ipv4       7694  6 iptable_nat,nf_nat
nf_defrag_ipv4          1039  1 nf_conntrack_ipv4
nf_conntrack_ftp       10475  1 nf_nat_ftp
nf_conntrack           65524  7 
iptable_nat,nf_conntrack_ipv6,xt_state,nf_nat_ftp,nf_nat,nf_conntrack_ipv4,nf_conntrack_ftp
ipv6                  264769  41 
nf_conntrack_ipv6,nf_defrag_ipv6,ip6table_mangle,ip6_tunnel,tunnel6

connection starts out eth2 - but then subsequent packets that should be
routed out eth2 are being sent out eth1 see below.
eth2 x.x.x.217
tcpdump -nli eth2 host 131.247.254.5

16:23:06.062451 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [S], seq 
1482565198, win 5840, options [mss 1460,sackOK,TS val 423546705 ecr 
0,nop,wscale 6], length 0
16:23:06.076788 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [S.], seq 
740341460, ack 1482565199, win 5792, options [mss 1460,sackOK,TS val 
2565444838 ecr 423546705,nop,wscale 7], length 0
16:23:06.077224 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423546720 ecr 2565444838], length 0
16:23:06.096900 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565444858 ecr 423546720], 
length 96
16:23:06.316866 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565445077 ecr 423546720], 
length 96
16:23:06.764410 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565445515 ecr 423546720], 
length 96
16:23:07.634411 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565446391 ecr 423546720], 
length 96
16:23:09.394482 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565448143 ecr 423546720], 
length 96
16:23:12.886997 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565451647 ecr 423546720], 
length 96
16:23:19.892082 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565458655 ecr 423546720], 
length 96
16:23:33.907303 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565472671 ecr 423546720], 
length 96
16:24:01.935273 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565500703 ecr 423546720], 
length 96
16:24:57.993631 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565556767 ecr 423546720], 
length 96
16:26:50.107951 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [P.], seq 
1:97, ack 1, win 46, options [nop,nop,TS val 2565668895 ecr 423546720], 
length 96
16:28:06.104031 IP 131.247.254.5.ftp > x.x.x.217.53651: Flags [FP.], seq 
97:111, ack 1, win 46, options [nop,nop,TS val 2565744900 ecr 
423546720], length 14


These packets should be going out eth2 not eth1
eth1 y.y.y.174
tcpdump -pnli eth1 host 131.247.254.5

16:23:06.097415 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
740341557, win 92, options [nop,nop,TS val 423546741 ecr 2565444858], 
length 0
16:23:06.317381 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423546961 ecr 2565445077,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:06.764908 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423547408 ecr 2565445515,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:07.634894 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423548278 ecr 2565446391,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:09.394972 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423550038 ecr 2565448143,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:12.887529 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423553531 ecr 2565451647,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:19.892616 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423560536 ecr 2565458655,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:33.907736 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423574551 ecr 2565472671,nop,nop,sack 
1 {4294967201:1}], length 0
16:23:40.173991 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423580817 ecr 2565472671], 
length 13
16:23:40.388692 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423581032 ecr 2565472671], 
length 13
16:23:40.819714 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423581463 ecr 2565472671], 
length 13
16:23:41.680729 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423582324 ecr 2565472671], 
length 13
16:23:43.404732 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423584048 ecr 2565472671], 
length 13
16:23:46.852787 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423587496 ecr 2565472671], 
length 13
16:23:53.756879 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423594400 ecr 2565472671], 
length 13
16:24:01.935822 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423602578 ecr 2565500703,nop,nop,sack 
1 {4294967201:1}], length 0
16:24:07.549037 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423608192 ecr 2565500703], 
length 13
16:24:35.133346 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423635776 ecr 2565500703], 
length 13
16:24:57.994150 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423658636 ecr 2565556767,nop,nop,sack 
1 {4294967201:1}], length 0
16:25:30.365963 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423691008 ecr 2565556767], 
length 13
16:26:50.108488 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [.], ack 
1, win 92, options [nop,nop,TS val 423770749 ecr 2565668895,nop,nop,sack 
1 {4294967201:1}], length 0
16:27:20.703243 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [P.], seq 
0:13, ack 1, win 92, options [nop,nop,TS val 423801344 ecr 2565668895], 
length 13
16:28:06.104578 IP x.x.x.217.53651 > 131.247.254.5.ftp: Flags [F.], seq 
13, ack 16, win 92, options [nop,nop,TS val 423846744 ecr 2565744900], 
length 0

Is there a way to make this work correctly?

Thanks,
Steve
