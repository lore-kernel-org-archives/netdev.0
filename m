From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and
 Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Wed, 16 Oct 2013 10:03:16 -0700
Message-ID: <1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Peter Schmitt <peter.schmitt82@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:55375 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761211Ab3JPRDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 13:03:17 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so1077983pbb.13
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 10:03:17 -0700 (PDT)
In-Reply-To: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 09:35 +0100, Peter Schmitt wrote:
> Hi,
> 
> I have a setup with the current kernel (3.10.16) and can't get WCCPv2 to work using GRE since kernel 3.10.x. With 3.9.x everything was working fine.
> 
> My setup is simple with three boxes included:
> 
> Client (10.111.111.222/24) -- (10.111.111.1/24) Cisco 7200 (192.168.180.113/24) -- Internet Gateway
>                                             (192.168.234.1/30)
>                                                     |
>                                                 WCCPv2
>                                                     |
>                                             (192.168.234.2/30)
>                                    Caching Box with Squid 2.7STABLE9 WCCPv2
> 
> 
> On the caching box, I have the interfaces:
> 6: eth3 inet 192.168.234.2/30 scope global eth3\ valid_lft forever preferred_lft forever
> 22: wccp104102 inet 192.168.234.2/32 scope global wccp104102\ valid_lft forever preferred_lft forever 
> 
> The WCCP handshake is established and I can see messages on the Cisco Router:
> *Oct 14 10:44:09.487: %WCCP-5-SERVICEFOUND: Service 80 acquired on WCCP client 192.168.234.2
> *Oct 14 10:44:09.495: %WCCP-5-SERVICEFOUND: Service 90 acquired on WCCP client 192.168.234.2
> 
> When the client now starts a request, it gets connection timeouts:
> >wget google.com
> --2013-10-14 13:53:30--  http://google.com/
> Resolving google.com (google.com)... 173.194.70.113, 173.194.70.100, 173.194.70.138, ...
> Connecting to google.com (google.com)|173.194.70.113|:80... failed: Connection timed out.
> Connecting to google.com (google.com)|173.194.70.100|:80... failed: Connection timed out.
> ...
> 
> A tcpdump on the Caching Box reveals the following:
> > tcpdump -i eth3 -n proto gre                                                                                                                                                                
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth3, link-type EN10MB (Ethernet), capture size 96 bytes
> 13:53:35.686377 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:53:36.678849 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:53:38.682782 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:53:42.690670 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:53:50.714444 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:54:06.745979 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:54:38.813539 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:54:39.808525 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:54:41.812964 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e
> 13:54:45.816337 IP 192.168.234.1 > 192.168.234.2: GREv0, length 68: gre-proto-0x883e 
> 
> > tcpdump -i wccp104102 -n                                                                                                                                                                    
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on wccp104102, link-type LINUX_SLL (Linux cooked), capture size 96 bytes
> 13:53:35.686377 IP0 bad-hlen 4
> 13:53:36.678849 IP0 bad-hlen 4
> 13:53:38.682782 IP0 bad-hlen 4
> 13:53:42.690670 IP0 bad-hlen 4
> 13:53:50.714444 IP0 bad-hlen 4
> 13:54:06.745979 IP0 bad-hlen 4
> 13:54:38.813539 IP0 bad-hlen 4
> 13:54:39.808525 IP0 bad-hlen 4
> 13:54:41.812964 IP0 bad-hlen 4
> 13:54:45.816337 IP0 bad-hlen 4 
> So I get correct GRE packets on the eth3 interface, but only bad-hlen messages from the GRE interface.
> 
> 
> ver_linux from the Caching box:
> 
> Linux cache 3.10.16-x86 #1 SMP Mon Oct 14 06:33:21 CEST 2013 i686 GNU/Linux
> Gnu C                       4.4.3
> Gnu make                 3.81
> binutils                      2.20.1
> util-linux                    2.17.2
> mount                       2.15.1-rc1
> module-init-tools        3.11.1
> e2fsprogs                  1.42.7
> PPP                         2.4.5
> Linux C Library          2.11.1
> Dynamic linker (ldd)   2.11.1
> Procps                     3.2.8
> Net-tools                  1.60
> Kbd                         1.15
> Sh-utils                    7.4
> Modules Loaded       xt_TPROXY nf_tproxy_core xt_set xt_socket nf_defrag_ipv6 xt_REDIRECT ip_set_hash_ip hwmon_vid hwmon bridge ip_set iptable_nat nf_nat_ipv4 ipt_REJECT nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ftp ip_gre gre bonding pcspkr uhci_hcd ehci_pci ehci_hcd lpc_ich mfd_core pata_acpi ata_generic
> 
> 
> Has anybody an idea of what's going wrong here? If you need any further information or some pcap files, I will surely provide them.
> 
> Thanks a lot for your attention!


3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the probable
fix :

commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
("ip_tunnel: push generic protocol handling to ip_tunnel module.")

The problem is 3.10 do not pull the extra 4 bytes of WCCP

This is now properly done in iptunnel_pull_header()
