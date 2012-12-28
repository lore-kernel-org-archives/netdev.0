From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Fri, 28 Dec 2012 10:11:03 -0800
Message-ID: <1356718263.21409.430.camel@edumazet-glaptop>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	 <20121013163639.87abca00.bircoph@gmail.com>
	 <1350135860.21172.14606.camel@edumazet-glaptop>
	 <20121014031119.a60263d6.bircoph@gmail.com>
	 <20121021032543.09d1844f.bircoph@gmail.com>
	 <1350823941.13333.2167.camel@edumazet-glaptop>
	 <20121022073636.98462bc6.bircoph@gmail.com>
	 <1350888489.8609.322.camel@edumazet-glaptop>
	 <20121023012759.ca7f91d6.bircoph@gmail.com>
	 <20121212122716.1e71f644.bircoph@gmail.com>
	 <20121223150627.d7ebcf6a.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:47498 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782Ab2L1SLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 13:11:08 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so6193548pad.30
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2012 10:11:07 -0800 (PST)
In-Reply-To: <20121223150627.d7ebcf6a.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-23 at 15:06 +0400, Andrew Savchenko wrote:
> Hello,
> 
> the bug has struck again on 3.7.0, see details below.
> 
> On Wed, 12 Dec 2012 12:27:16 +0400 Andrew Savchenko wrote:
> > [...]
> > > > Some driver or protocol stack is messing with skb->truesize, as
> > > > your /proc/net/udp file contains anomalies :
> > > > 
> > > > $ cat /proc/net/udp
> > > >   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops
> > > > ...
> > > >   323: 074A070A:007B 00000000:0000 07 FFFDF700:00000000 00:00000000 00000000   123        0 254469 2 ffff88003d581880 0
> > > > ...
> > > >   323: 00FCA8C0:007B 00000000:0000 07 FFFFF900:00000000 00:00000000 00000000     0        0 5187 2 ffff880039993880 0
> > > > 
> > > > Its clearly not possible to get tx_queue = 0xFFFDF700 or 0xFFFFF900
> > > > 
> > > > So what drivers handle following IP addresses : 192.168.252.0 , 10.7.74.7  ?
> > > 
> > > 192.168.252.0 is handled by eth0 interface running on Realtek
> > > Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (10ec:8139) NIC.
> > > Kernel driver 8139too. This interface handles multiple subnetworks:
> > > 
> > > # ip addr show eth0
> > > 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000 
> > > link/ether 00:80:48:30:ca:f3 brd ff:ff:ff:ff:ff:ff
> > > inet 10.51.15.126/25 brd 10.51.15.127 scope global eth0
> > > inet 192.168.252.0/31 scope global eth0
> > > 
> > > 10.7.74.7 is an l2tp connection handled by ppp over l2tp:
> > > CONFIG_PPPOL2TP=y
> > > It is running on top of eth0 described above.
> > > 
> > > # ip addr show ppp0
> > > 65: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UNKNOWN qlen 3
> > > link/ppp 
> > > inet 10.7.74.7 peer 10.7.2.18/32 scope global ppp0
> > 
> > I updated kernel on this system to 3.7.0 and udp anomaly is still
> > present:
> > 
> > $ cat /proc/net/udp
> >   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops             
> >     0: 00000000:06A5 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5326 2 ffff88003dbf0a80 0          
> >     8: 00000000:7EAD 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5157 2 ffff8800398c2000 0          
> >    89: 00000000:90FE 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5101 2 ffff88003dbd3500 0          
> >   160: 0100007F:2745 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4598 2 ffff88003d612700 0          
> >   184: 0100007F:035D 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4774 2 ffff88003d612a80 0          
> >   217: 00000000:857E 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5195 2 ffff8800398c2700 0          
> >   318: 00000000:A9E3 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4782 2 ffff88003d612e00 0          
> >   335: 7E0F330A:01F4 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5303 2 ffff8800398c2e00 0          
> >   348: 00000000:0801 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5186 2 ffff8800398c2380 0          
> >   387: 7E0F330A:DE28 1400320A:06A5 01 00000000:00000000 00:00000000 00000000     0        0 5332 4 ffff88003dbf0e00 0          
> >   400: 010013AC:0035 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4842 2 ffff88003d613880 0          
> >   400: 0100007F:0035 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4841 2 ffff88003d613500 0          
> >   414: 00000000:0043 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5273 2 ffff8800398c2a80 0          
> >   458: 00000000:006F 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4483 2 ffff88003d612000 0          
> >   459: 00000000:0270 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4507 2 ffff88003d612380 0          
> >   466: 00000000:0277 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4802 2 ffff88003d613180 0          
> >   470: 076A070A:007B 00000000:0000 07 FFFF4600:00000000 00:00000000 00000000   123        0 5552 2 ffff880039974380 0          
> >   470: 010213AC:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4986 2 ffff88003dbd3180 0          
> >   470: 010013AC:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4985 2 ffff88003dbd2e00 0          
> >   470: 00FCA8C0:007B 00000000:0000 07 FFFFFB00:00000000 00:00000000 00000000     0        0 4984 2 ffff88003dbd2a80 0          
> >   470: 7E0F330A:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4983 2 ffff88003dbd2700 0          
> >   470: 0100007F:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4982 2 ffff88003dbd2380 0          
> >   470: 00000000:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4975 2 ffff88003d613c00 0          
> >   484: FF0013AC:0089 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5316 2 ffff88003dbf0000 0          
> >   484: 010013AC:0089 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5315 2 ffff88003dbd3880 0          
> >   484: FF0213AC:0089 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5312 2 ffff8800398c3c00 0          
> >   484: 010213AC:0089 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5311 2 ffff8800398c3880 0          
> >   484: 00000000:0089 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5308 2 ffff8800398c3180 0          
> >   485: FF0013AC:008A 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5318 2 ffff88003dbf0700 0          
> >   485: 010013AC:008A 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5317 2 ffff88003dbf0380 0          
> >   485: FF0213AC:008A 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5314 2 ffff88003dbd3c00 0          
> >   485: 010213AC:008A 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5313 2 ffff88003dbd2000 0          
> >   485: 00000000:008A 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 5309 2 ffff8800398c3500 0
> > 
> > The bug hasn't shown up yet, I'll need to wait for about a week to see
> > if it is reproducible.
> 
> I hit this bug again on uptime 11 days on 3.7.0 vanilla kernel.
> See kernel config, /prot/net/upd, netstat -s and dropwatch logs
> attached to this mail. This bug happens on UDP DNS requests only,
> TCP requests work fine, see dig.log attached.
> 
> Increasing of net.ipv4.udp_mem from
> 24150        32201   48300
> to
> 100000       150000  200000
> helps, but I'm afraid only temporary again.
> 
> Dropwatch data was collected in the following way:
> - dropwatch.bug.* files contain data obtained after bug occurred;
> - dropwatch.*.background files contain background data when no
>   host or dig test was running; this system has active firewall
>   and complicated routing, ipv6 disabled via sysctl, etc, so some
>   drops are normal;
> - dropwatch.*.host.request shows dropped packets recorded during
>   host ya.ru request; of course, during this time some background
>   packets were recorded as well (dropwatch doesn't support filtering
>   at this moment);
> - dropwatch.nobug.* data was collected after the bug was
>   workarounded via net.ipv4.upd_mem as described above.
> 
> As can be seen from dropwatch logs, drop in __udp_queue_rcv_skb+61
> happens only on host request on bug conditions, thus something is
> wrong there.
> 
> Best regards,
> Andrew Savchenko

Thanks a lot !

I see strange drops in dev_hard_start_xmit()

l2tp needs some care.

Please try the following patch, as skb_cow_head() API
doesnt really ease skb->truesize exact tracking anyway, better not mess
with it. 

 net/l2tp/l2tp_core.c |    6 ------
 net/l2tp/l2tp_ppp.c  |    6 ------
 2 files changed, 12 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1a9f372..d77e655 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1123,8 +1123,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	struct udphdr *uh;
 	struct inet_sock *inet;
 	__wsum csum;
-	int old_headroom;
-	int new_headroom;
 	int headroom;
 	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	int udp_len;
@@ -1136,16 +1134,12 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	 */
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
 		uhlen + hdr_len;
-	old_headroom = skb_headroom(skb);
 	if (skb_cow_head(skb, headroom)) {
 		kfree_skb(skb);
 		return NET_XMIT_DROP;
 	}
 
-	new_headroom = skb_headroom(skb);
 	skb_orphan(skb);
-	skb->truesize += new_headroom - old_headroom;
-
 	/* Setup L2TP header */
 	session->build_header(session, __skb_push(skb, hdr_len));
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 286366e..716605c 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -388,8 +388,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel;
 	struct pppol2tp_session *ps;
-	int old_headroom;
-	int new_headroom;
 	int uhlen, headroom;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
@@ -408,7 +406,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (tunnel == NULL)
 		goto abort_put_sess;
 
-	old_headroom = skb_headroom(skb);
 	uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	headroom = NET_SKB_PAD +
 		   sizeof(struct iphdr) + /* IP header */
@@ -418,9 +415,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (skb_cow_head(skb, headroom))
 		goto abort_put_sess_tun;
 
-	new_headroom = skb_headroom(skb);
-	skb->truesize += new_headroom - old_headroom;
-
 	/* Setup PPP header */
 	__skb_push(skb, sizeof(ppph));
 	skb->data[0] = ppph[0];
