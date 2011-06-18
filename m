From: Julian Anastasov <ja@ssi.bg>
Subject: Re: what's causing "ip_rt_bug"?
Date: Sat, 18 Jun 2011 20:53:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg>
References: <4DFBB270.8000003@wpkg.org> <1308342993.3539.30.camel@edumazet-laptop> <4DFBC92A.2030901@wpkg.org> <alpine.LFD.2.00.1106180227400.1583@ja.ssi.bg> <4DFC627F.7040007@wpkg.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41487 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab1FRRv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jun 2011 13:51:29 -0400
In-Reply-To: <4DFC627F.7040007@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	CC-ing tproxy developers for more ideas...

On Sat, 18 Jun 2011, Tomasz Chmielewski wrote:

> >> It's just a proxy, no special routing set:
> > 
> > 	Is transparent proxy used?
> 
> Yes, it is.
> 
> 
> >> # ip ro
> >> 58.185.117.18 via 119.46.110.193 dev eth0
> >> 119.46.240.13 via 119.46.110.193 dev eth0
> >> 58.185.117.29 via 119.46.110.193 dev eth0
> >> 119.46.241.13 via 119.46.110.193 dev eth0
> > 
> > 	Same route for 58.185.117.28 2nd time? Is that possible?:
> 
> Not second time, the addresses are similar, but different: 58.185.117.18, 58.185.117.29, 58.185.117.28. Unless there's something I don't see! ;)

	Ops, my fault :)

> >> 58.185.117.28 via 119.46.110.193 dev eth0
> >> 119.46.110.192/26 dev eth0  proto kernel  scope link  src 119.46.110.197
> >> 169.254.0.0/16 dev eth0  scope link
> >> default via 119.46.110.195 dev eth0
> >>
> >>
> >> The box is also crashing every few days; and I really had no clue why (just connected a serial console to catch any new oops/panic).
> >>
> >>
> >> The last time it crashed, I have this entry in syslog:
> >>
> >> Jun 17 16:16:17 TRUE-SC02 kernel: [172488.602629] ip_rt_bug: 124.121.155.197 ->  119.46.110.197, ?
> > 
> > 	The ip_rt_bug messages show that skb->dev is
> > NULL (OUTPUT hook), daddr in IP header is local address,
> > may be some original received packet. If such packet is
> > provided to ip_route_me_harder(skb, RTN_UNSPEC) an
> > ip_route_input call can happen. Calling later dst_output
> > should lead to this warning. The question is what can
> > cause received packet to appear in OUTPUT hook where
> > a change in mark or TOS can can trigger such ip_route_input
> > call. What kind of netfilter modules are used? nf_queue,
> > -j REJECT, NAT? Is 124.121.155.197 a local address?
> 
> No, it's not local.
> With "ip_rt_bug: 124.121.184.77 -> 119.46.110.197, ?" lines, only the address on the right side is local.

	Hm, if it happens "sometimes", can it be some
problem with tproxy and TIME_WAIT sockets? I see that
tproxy_sk_is_transparent has special treatment for TW
sockets while ip_route_me_harder is different. As result,
may be input route is assigned for TW packets.

	May be inet_sk_flowi_flags() needs fixing, not
sure. But following patch is first step to fix this
problem. I don't have setup to test this patch.

===========================================================

	Avoid creating input routes with ip_route_me_harder.
It does not work for locally generated packets. Instead,
restrict sockets to provide valid saddr for output route (or
unicast saddr for transparent proxy). For other traffic
allow saddr to be unicast or local but if callers forget
to check saddr type use 0 for the output route.

	The resulting handling should be:

- REJECT TCP:
	- in INPUT we can provide addr_type = RTN_LOCAL but
	better allow rejecting traffic delivered with
	local route (no IP address => use RTN_UNSPEC to
	allow also RTN_UNICAST).
	- FORWARD: RTN_UNSPEC => allow RTN_LOCAL/RTN_UNICAST
	saddr, add fix to ignore RTN_BROADCAST and RTN_MULTICAST
	- OUTPUT: RTN_UNSPEC

- NAT, mangle, ip_queue, nf_ip_reroute: RTN_UNSPEC in LOCAL_OUT

- IPVS:
	- use RTN_LOCAL in LOCAL_OUT and FORWARD after SNAT
	to restrict saddr to be local

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.39/linux/net/ipv4/netfilter/ipt_REJECT.c linux/net/ipv4/netfilter/ipt_REJECT.c
--- v2.6.39/linux/net/ipv4/netfilter/ipt_REJECT.c	2011-03-20 10:55:56.000000000 +0200
+++ linux/net/ipv4/netfilter/ipt_REJECT.c	2011-06-18 18:22:40.713189957 +0300
@@ -40,7 +40,6 @@ static void send_reset(struct sk_buff *o
 	struct iphdr *niph;
 	const struct tcphdr *oth;
 	struct tcphdr _otcph, *tcph;
-	unsigned int addr_type;
 
 	/* IP header checks: fragment. */
 	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
@@ -55,6 +54,9 @@ static void send_reset(struct sk_buff *o
 	if (oth->rst)
 		return;
 
+	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return;
+
 	/* Check checksum */
 	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
 		return;
@@ -101,19 +103,11 @@ static void send_reset(struct sk_buff *o
 	nskb->csum_start = (unsigned char *)tcph - nskb->head;
 	nskb->csum_offset = offsetof(struct tcphdr, check);
 
-	addr_type = RTN_UNSPEC;
-	if (hook != NF_INET_FORWARD
-#ifdef CONFIG_BRIDGE_NETFILTER
-	    || (nskb->nf_bridge && nskb->nf_bridge->mask & BRNF_BRIDGED)
-#endif
-	   )
-		addr_type = RTN_LOCAL;
-
 	/* ip_route_me_harder expects skb->dst to be set */
 	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
 	nskb->protocol = htons(ETH_P_IP);
-	if (ip_route_me_harder(nskb, addr_type))
+	if (ip_route_me_harder(nskb, RTN_UNSPEC))
 		goto free_nskb;
 
 	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
diff -urp v2.6.39/linux/net/ipv4/netfilter.c linux/net/ipv4/netfilter.c
--- v2.6.39/linux/net/ipv4/netfilter.c	2011-05-20 10:38:08.000000000 +0300
+++ linux/net/ipv4/netfilter.c	2011-06-18 19:13:39.299189310 +0300
@@ -17,51 +17,35 @@ int ip_route_me_harder(struct sk_buff *s
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
-	unsigned long orefdst;
+	__be32 saddr = iph->saddr;
+	__u8 flags = 0;
 	unsigned int hh_len;
-	unsigned int type;
 
-	type = inet_addr_type(net, iph->saddr);
-	if (skb->sk && inet_sk(skb->sk)->transparent)
-		type = RTN_LOCAL;
-	if (addr_type == RTN_UNSPEC)
-		addr_type = type;
+	if (!skb->sk && addr_type != RTN_LOCAL) {
+		if (addr_type == RTN_UNSPEC)
+			addr_type = inet_addr_type(net, saddr);
+		if (addr_type == RTN_LOCAL || addr_type == RTN_UNICAST)
+			flags |= FLOWI_FLAG_ANYSRC;
+		else
+			saddr = 0;
+	}
 
 	/* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
 	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
 	 */
-	if (addr_type == RTN_LOCAL) {
-		fl4.daddr = iph->daddr;
-		if (type == RTN_LOCAL)
-			fl4.saddr = iph->saddr;
-		fl4.flowi4_tos = RT_TOS(iph->tos);
-		fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
-		fl4.flowi4_mark = skb->mark;
-		fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			return -1;
-
-		/* Drop old route. */
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else {
-		/* non-local src, find valid iif to satisfy
-		 * rp-filter when calling ip_route_input. */
-		fl4.daddr = iph->saddr;
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			return -1;
+	fl4.daddr = iph->daddr;
+	fl4.saddr = saddr;
+	fl4.flowi4_tos = RT_TOS(iph->tos);
+	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : flags;
+	rt = ip_route_output_key(net, &fl4);
+	if (IS_ERR(rt))
+		return -1;
 
-		orefdst = skb->_skb_refdst;
-		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->dst.dev) != 0) {
-			dst_release(&rt->dst);
-			return -1;
-		}
-		dst_release(&rt->dst);
-		refdst_drop(orefdst);
-	}
+	/* Drop old route. */
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
 
 	if (skb_dst(skb)->error)
 		return -1;


=================================================================

> # iptables -L -t nat -n
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination         
> REDIRECT   tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:80 redir ports 8080 
> 
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination         
> 
> Chain POSTROUTING (policy ACCEPT)
> target     prot opt source               destination         
> 
> 
> # iptables -L -t mangle -n
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination         
> DIVERT     tcp  --  0.0.0.0/0            0.0.0.0/0           socket 
> 
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination         
> 
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination         
> 
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination         
> 
> Chain POSTROUTING (policy ACCEPT)
> target     prot opt source               destination         
> 
> Chain DIVERT (1 references)
> target     prot opt source               destination         
> MARK       all  --  0.0.0.0/0            0.0.0.0/0           MARK xset 0x1/0xffffffff 
> ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0     
> 
> 
> # lsmod
> Module                  Size  Used by
> xt_mark                 1171  1 
> xt_socket               1922  1 
> nf_tproxy_core          1752  1 xt_socket,[permanent]
> ipt_REDIRECT            1093  1 
> xt_tcpudp               2331  1 
> ebt_redirect            1234  1 
> ebt_ip                  1562  1 
> ebtable_broute          1395  1 
> bridge                 64647  1 ebtable_broute
> stp                     1931  1 bridge
> llc                     5071  2 bridge,stp
> ebtables               20458  1 ebtable_broute
> iptable_mangle          1351  1 
> iptable_nat             3644  1 
> nf_nat                 16977  2 ipt_REDIRECT,iptable_nat
> nf_conntrack_ipv4      11077  3 iptable_nat,nf_nat
> nf_defrag_ipv4          1337  2 xt_socket,nf_conntrack_ipv4
> i2c_dev                 4561  0 
> i2c_core               21774  1 i2c_dev
> nf_conntrack_netbios_ns     1486  0 
> nf_conntrack           65085  5 xt_socket,iptable_nat,nf_nat,nf_conntrack_ipv4,nf_conntrack_netbios_ns
> iptable_filter          1402  0 
> ip_tables              14931  3 iptable_mangle,iptable_nat,iptable_filter
> x_tables               20316  11 xt_mark,xt_socket,ipt_REDIRECT,xt_tcpudp,ebt_redirect,ebt_ip,ebtables,iptable_mangle,iptable_nat,iptable_filter,ip_tables
> dm_mirror              11724  0 
> dm_multipath           14772  0 
> scsi_dh                 5994  1 dm_multipath
> video                  21310  0 
> output                  2103  1 video
> sbs                    11378  0 
> sbshc                   4115  1 sbs
> battery                10902  0 
> acpi_memhotplug         4135  0 
> ac                      3274  0 
> parport_pc             21355  0 
> lp                      9491  0 
> parport                33290  2 parport_pc,lp
> option                 16045  0 
> usb_wwan               10222  1 option
> usbserial              34477  2 option,usb_wwan
> serio_raw               4064  0 
> tpm_tis                 9203  0 
> tpm                    14317  1 tpm_tis
> tpm_bios                5252  1 tpm
> rtc_cmos                8731  0 
> rtc_core               14080  1 rtc_cmos
> rtc_lib                 2497  1 rtc_core
> button                  5662  0 
> igb                   131680  0 
> shpchp                 29302  0 
> pcspkr                  1822  0 
> dm_region_hash          9574  1 dm_mirror
> dm_log                  8359  2 dm_mirror,dm_region_hash
> usb_storage            45133  0 
> ata_piix               22147  0 
> libata                169650  1 ata_piix
> cciss                  88474  24 
> sd_mod                 28117  0 
> scsi_mod              156163  5 scsi_dh,usb_storage,libata,cciss,sd_mod
> ext3                  114308  12 
> jbd                    43368  1 ext3
> uhci_hcd               18941  0 
> ohci_hcd               20027  0 
> ehci_hcd               33605  0 
> 
> 
> # ifconfig -a
> eth0      Link encap:Ethernet  HWaddr 18:A9:05:41:CC:CE  
>           inet addr:119.46.110.197  Bcast:119.46.110.255  Mask:255.255.255.192
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:4872707550 errors:0 dropped:1177767 overruns:1177767 frame:0
>           TX packets:5066061004 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:3719046973104 (3.3 TiB)  TX bytes:4237588228875 (3.8 TiB)
> 
> eth0:1    Link encap:Ethernet  HWaddr 18:A9:05:41:CC:CE  
>           inet addr:119.46.110.249  Bcast:119.46.110.255  Mask:255.255.255.192
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> 
> 
> 
> -- 
> Tomasz Chmielewski
> http://wpkg.org

Regards

--
Julian Anastasov <ja@ssi.bg>
