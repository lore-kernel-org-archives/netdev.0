From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Mon, 27 Dec 2004 13:17:34 +0900 (JST)
Message-ID: <200412270417.iBR4HZRG021429@toshiba.co.jp>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, kaber@trash.net, laforge@gnumonks.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: pb@bieringer.de
In-Reply-To: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


From: Peter Bieringer <pb@bieringer.de>
Date: Sat, 25 Dec 2004 18:47:52 +0100

> I tried several rules (don't wonder about the wrong order, it was a try and 
> error -I insert, uppest rule was inserted last):
> 
> # ip6tables -vn -L OUTPUT
> Chain OUTPUT (policy DROP 4 packets, 4872 bytes)
>  pkts bytes target     prot opt in     out     source 
> destination
>     2   192 ACCEPT     all      *      eth0    ::/0                 ::/0
>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0 
> ipv6-icmp type 143
>     0     0 ACCEPT     icmpv6    *      *       ::/0 
> ff02::/16          ipv6-icmp type 143
>     0     0 ACCEPT     icmpv6    *      *       ::/0 
> ff02::/16          ipv6-icmp type 143
>     0     0 ACCEPT     icmpv6    *      *       ::/0 
> ff02::16/128       ipv6-icmp type 143
> 
> Packet dump:
> 
> 18:46:07.984044 :: > ff02::16: HBH (rtalert: 0x0000) (padn)[icmp6 sum ok] 
> icmp6: type-#143 [hlim 1] (len 56)
>         0x0000:  6000 0000 0038 0001 0000 0000 0000 0000  `....8..........
>         0x0010:  0000 0000 0000 0000 ff02 0000 0000 0000  ................
>         0x0020:  0000 0000 0000 0016 3a00 0502 0000 0100  ........:.......
>         0x0030:  8f00 6b6a 0000 0002 0400 0000 ff05 0000  ..kj............
>         0x0040:  0000 0000 0000 0000 0001 0003 0400 0000  ................
>         0x0050:  ff02 0000 0000 0000 0000 0000 0001 0002  ................
> 
> I wonder that only the proto "all" rule matches such packet.

Well, the Multicast Listener Report seems that skb->data != skb->nh.ipv6h
when interface is up. But IPv6 netfilter modules assumes that
skb->data == skb->nh.ipv6h like IPv4 netfilter modules.

folks, is this wrong or bad asumption ? If so, I'll fix this problem in
many modules as follows.

--- linux-2.6.10/net/ipv6/netfilter/ip6_tables.c	2004-12-27 11:26:57.000000000 +0900
+++ linux-2.6.10-fixed/net/ipv6/netfilter/ip6_tables.c	2004-12-27 11:28:23.000000000 +0900
@@ -222,7 +222,7 @@
 		u_int16_t hdrlen;	/* Header */
 		u_int16_t _fragoff = 0, *fp = NULL;
 
-		ptr = IPV6_HDR_LEN;
+		ptr = ((u8*)skb->nh.ipv6h - skb->data) + IPV6_HDR_LEN;
 
 		while (ip6t_ext_hdr(currenthdr)) {
 	                /* Is there enough space for the next ext header? */


Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>
