From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Wed, 27 Jul 2016 21:01:21 +0200
Message-ID: <1469646081.17736.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Brandon Cazander <brandon.cazander@multapplied.net>,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36693 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757190AbcG0TBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 15:01:40 -0400
In-Reply-To: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-07-27 at 18:19 +0000, Brandon Cazander wrote:
> [1.] One line summary of the problem:
> Using TPROXY together with a DNAT rule (working on older kernels) fails to work on newer kernels as of commit 079096f103fa
> 
> [2.] Full description of the problem/report:
> I performed a git bisect using a qemu image to test my example below, and the bisect ended at this commit:
> 
> > commit 079096f103faca2dd87342cca6f23d4b34da8871
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Fri Oct 2 11:43:32 2015 -0700
> > 
> >     tcp/dccp: install syn_recv requests into ehash table
> 
> [3.] Keywords: networking
> 
> [4.] Kernel information
> [4.1.] Kernel version (from /proc/version):
> Everything as of commit 079096f103fa (tested up to 4.5.0)
> 
> [4.2.] Kernel .config file:
> When performing the bisect, I built with make oldconfig. Let me know if you want the whole .config file.
> 
> [5.] Most recent kernel version which did not have the bug:
> Any kernel that I built prior to commit 079096f103faca2dd87342cca6f23d4b34da8871 did not have this issue.
> 
> [6.] no Oops
> 
> [7.] A small shell script or example program which triggers the
>      problem (if possible)
> 
> I have produced what I hope is a minimal example, using the instructions for TPROXY from http://lxr.linux.no/#linux+v3.10/Documentation/networking/tproxy.txt and an example transparent TCP proxy written in C that I found at https://github.com/kristrev/tproxy-example.
> 
> * I have a machine ("ROUTER") with 10.100.0.164/24 on eth0, and 192.168.30.2/24 on eth1. This is running the tproxy-example program, with the following rules:
>     iptables -t mangle -N DIVERT
>     iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
>     iptables -t mangle -A DIVERT -j MARK --set-mark 1
>     iptables -t mangle -A DIVERT -j ACCEPT
>     iptables -t mangle -A PREROUTING -p tcp --dport 8080 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 9876
>     iptables -t nat -I PREROUTING -i eth0 -d 42.0.1.1 -j DNAT --to-dest 192.168.30.1
>     ip rule add fwmark 1 lookup 100
>     ip route add local 0.0.0.0/0 dev lo table 100
> 
> * There is a machine ("WEBSERVER") at 192.168.30.1/24 hosting a webserver on port 8080.
> 
> * My workstation is at 10.100.0.206, and I have a static route for both 192.168.30.2 and 42.0.1.1 via 10.100.0.164.
> 
> * Making a curl request to 192.168.30.2:8080 hits the transparent proxy and works in both GOOD (before the aforementioned commit) kernel, and BAD (at the commit or later) kernel.
> 
> * Making a curl request to 42.0.1.1:8080 hits the transparent proxy and works in GOOD kernel but in BAD kernel I get:
>     "curl: (56) Recv failure: Connection reset by peer"
> 
> * When it fails, no traffic hits the WEBSERVER. A tcpdump on the bad kernel shows:
>     root@dons-qemu-new-kernel:~# tcpdump -niany tcp and port 8080
>     tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>     listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
>     16:42:31.551952 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [S], seq 3793582216, win 29200, options [mss 1460,sackOK,TS val 632068656 ecr 0,nop,wscale 7], length 0
>     16:42:31.551988 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 745382 ecr 632068656,nop,wscale 7], length 0
>     16:42:31.552222 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [.], ack 1, win 229, options [nop,nop,TS val 632068657 ecr 745382], length 0
>     16:42:31.552238 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [R], seq 4042636217, win 0, length 0
>     16:42:31.552246 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [P.], seq 1:78, ack 1, win 229, options [nop,nop,TS val 632068657 ecr 745382], length 77
>     16:42:31.552251 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [R], seq 4042636217, win 0, length 0
>     16:42:32.551668 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 745632 ecr 632068656,nop,wscale 7], length 0
>     16:42:32.551925 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [R], seq 3793582217, win 0, length 0
>     16:42:34.551668 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 746132 ecr 632068656,nop,wscale 7], length 0
>     16:42:34.551995 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [R], seq 3793582217, win 0, length 0
> 
> * A tcpdump on a GOOD kernel shows:
> root@dons-qemu-old-kernel:~# tcpdump -niany tcp and port 8080
>     tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>     listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
>     16:44:18.364537 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [S], seq 3963646692, win 29200, options [mss 1460,sackOK,TS val 632175966 ecr 0,nop,wscale 7], length 0
>     16:44:18.364571 IP 42.0.1.1.8080 > 10.100.0.206.35996: Flags [S.], seq 4117262662, ack 3963646693, win 14480, options [mss 1460,sackOK,TS val 4294903654 ecr 632175966,nop,wscale 7], length 0
>     16:44:18.364819 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [.], ack 1, win 229, options [nop,nop,TS val 632175966 ecr 4294903654], length 0
>     16:44:18.364846 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [P.], seq 1:78, ack 1, win 229, options [nop,nop,TS val 632175966 ecr 4294903654], length 77
>     16:44:18.364851 IP 42.0.1.1.8080 > 10.100.0.206.35996: Flags [.], ack 78, win 114, options [nop,nop,TS val 4294903655 ecr 632175966], length 0
>     16:44:18.364931 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [S], seq 2684311354, win 14600, options [mss 1460,sackOK,TS val 4294903655 ecr 0,nop,wscale 7], length 0
>     16:44:18.365148 IP 192.168.30.1.8080 > 192.168.30.2.38777: Flags [S.], seq 3410019333, ack 2684311355, win 14000, options [mss 1412,sackOK,TS val 131740369 ecr 4294903655,nop,wscale 7], length 0
>     16:44:18.365186 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [.], ack 1, win 115, options [nop,nop,TS val 4294903655 ecr 131740369], length 0
>     16:44:18.365339 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [P.], seq 1:78, ack 1, win 115, options [nop,nop,TS val 4294903655 ecr 131740369], length 77
>     16:44:18.365444 IP 192.168.30.1.8080 > 192.168.30.2.38777: Flags [.], ack 78, win 110, options [nop,nop,TS val 131740369 ecr 4294903655], length 0
>     16:44:18.365564 IP 192.168.30.1.8080 > 192.168.30.2.38777: Flags [P.], seq 1:367, ack 78, win 110, options [nop,nop,TS val 131740369 ecr 4294903655], length 366
>     16:44:18.365573 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [.], ack 367, win 123, options [nop,nop,TS val 4294903655 ecr 131740369], length 0
>     16:44:18.365616 IP 42.0.1.1.8080 > 10.100.0.206.35996: Flags [P.], seq 1:367, ack 78, win 114, options [nop,nop,TS val 4294903655 ecr 632175966], length 366
>     16:44:18.365819 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [.], ack 367, win 237, options [nop,nop,TS val 632175967 ecr 4294903655], length 0
>     16:44:18.365893 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [F.], seq 78, ack 367, win 237, options [nop,nop,TS val 632175967 ecr 4294903655], length 0
>     16:44:18.365953 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [F.], seq 78, ack 367, win 123, options [nop,nop,TS val 4294903655 ecr 131740369], length 0
>     16:44:18.365973 IP 42.0.1.1.8080 > 10.100.0.206.35996: Flags [F.], seq 367, ack 79, win 114, options [nop,nop,TS val 4294903655 ecr 632175967], length 0
>     16:44:18.366054 IP 192.168.30.1.8080 > 192.168.30.2.38777: Flags [F.], seq 367, ack 79, win 110, options [nop,nop,TS val 131740369 ecr 4294903655], length 0
>     16:44:18.366066 IP 192.168.30.2.38777 > 192.168.30.1.8080: Flags [.], ack 368, win 123, options [nop,nop,TS val 4294903655 ecr 131740369], length 0
>     16:44:18.366103 IP 10.100.0.206.35996 > 42.0.1.1.8080: Flags [.], ack 368, win 237, options [nop,nop,TS val 632175968 ecr 4294903655], length 0
> 
> Hopefully that's enough detail to replicate this issue. I have the full environment set up for both working and non-working kernel versions, so please let me know if there's anything else I can provide.
> 
> Regards,
> Brandon Cazander

Thanks for the report

CC netfilter guys, because I am traveling (vacation time) and wont be
able to look at this before at least next week.
