From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] ifb and ppp
Date: Wed, 19 Sep 2007 15:04:54 +0200
Message-ID: <46F11E76.8030202@trash.net>
References: <200709191417.43768.mail@frithjof-hammer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040600060505090908040406"
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>
To: Frithjof Hammer <mail@frithjof-hammer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63781 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbXISNLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:11:54 -0400
In-Reply-To: <200709191417.43768.mail@frithjof-hammer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040600060505090908040406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Frithjof Hammer wrote:
> My goal is to setup an ingress traffic shaping on my PPPOE DSL line with ifb. 
> 
> My old imq stuff used iptables marks (like 'iptables -t mangle -A 
> PREROUTING -p tcp --sport 22 -m length --length :500 -j MARK --set-mark 31') 
> to classify the traffic and since i am lazy, i tried to to reuse them with 
> ifb. But no luck: iptables marks the packets well, but tc doesn't see the 
> marks on ifb0.
> 
> May be my problem is somewhere between ppp0 and ifb0, so for a basic test, I 
> tried this:
> 
> tc qdisc add dev ppp0 ingress
> modprobe ifb
> ip link set up dev ifb0
> tc filter add dev ppp0 parent ffff: protocol ip prio 10 u32 \
>    match u32 0 0 flowid 1:1 \
>    action mirred egress redirect dev ifb0
> 
> and run:
> 
> root@router:/# tcpdump -i ifb0 -n
> tcpdump: WARNING: ifb0: no IPv4 address assigned
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on ifb0, link-type EN10MB (Ethernet), capture size 96 bytes
> 12:38:29.584451 PPPoE  [ses 0x7dc] IP 217.10.79.2.10000 > 84.189.95.184.1024: 
> UDP, length 84
> 12:38:29.585924 PPPoE  [ses 0x7dc] IP 84.189.5.17 > 84.189.95.184: GREv1, call 
> 24388, seq 1868, ack 3210, length 205: compressed PPP data
> 12:38:29.600506 PPPoE  [ses 0x7dc] IP truncated-ip - 256 bytes missing! 
> 24.163.113.160.34247 > 84.189.95.184.9025: UDP, length 359
> [...]
> 
> Looks like the packetes are still pppoe en-capsuled. Is this the correct 
> behavior? This only occurs on ppp0, on other devices (like eth0) my iptables 
> marks are matched by tc. What can I do to get my iptables marks working on 
> ppp0 again?


Does this patch help?



--------------040600060505090908040406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5795789..7c80f16 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -83,6 +83,7 @@ static int tcf_mirred_init(struct rtattr *rta, struct rtattr *est,
 			case ARPHRD_IPGRE:
 			case ARPHRD_VOID:
 			case ARPHRD_NONE:
+			case ARPHRD_PPP:
 				ok_push = 0;
 				break;
 			default:

--------------040600060505090908040406--
