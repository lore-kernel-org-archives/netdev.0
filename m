From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [BUG PATCH RFC] Memory on tcp_prot with TPROXY and TCP early demux
Date: Tue, 21 Jan 2014 10:43:21 +0100
Message-ID: <20140121094321.GP7176@imap.eitzenberger.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vA66WO2vHvL/CRSR"
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Krisztian Kovacs <hidden@sch.bme.hu>
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55398 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbaAUJnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 04:43:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vA66WO2vHvL/CRSR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I see a memory leak when using a transparent HTTP proxy using TPROXY
together with TCP early demux and Kernel v3.8.13.15 (Ubuntu stable):

unreferenced object 0xffff88008cba4a40 (size 1696):
  comm "softirq", pid 0, jiffies 4294944115 (age 8907.520s)
  hex dump (first 32 bytes):
    0a e0 20 6a 40 04 1b 37 92 be 32 e2 e8 b4 00 00  .. j@..7..2.....
    02 00 07 01 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff810b710a>] kmem_cache_alloc+0xad/0xb9
    [<ffffffff81270185>] sk_prot_alloc+0x29/0xc5
    [<ffffffff812702cf>] sk_clone_lock+0x14/0x283
    [<ffffffff812aaf3a>] inet_csk_clone_lock+0xf/0x7b
    [<ffffffff8129a893>] netlink_broadcast+0x14/0x16
    [<ffffffff812c1573>] tcp_create_openreq_child+0x1b/0x4c3
    [<ffffffff812c033e>] tcp_v4_syn_recv_sock+0x38/0x25d
    [<ffffffff812c13e4>] tcp_check_req+0x25c/0x3d0
    [<ffffffff812bf87a>] tcp_v4_do_rcv+0x287/0x40e
    [<ffffffff812a08a7>] ip_route_input_noref+0x843/0xa55
    [<ffffffff812bfeca>] tcp_v4_rcv+0x4c9/0x725
    [<ffffffff812a26f4>] ip_local_deliver_finish+0xe9/0x154
    [<ffffffff8127a927>] __netif_receive_skb+0x4b2/0x514
    [<ffffffff8127aa77>] process_backlog+0xee/0x1c5
    [<ffffffff8127c949>] net_rx_action+0xa7/0x200
    [<ffffffff81209d86>] add_interrupt_randomness+0x39/0x157

But I see plenty of them, resulting in the machine going OOM after
some days.

>From looking at the TPROXY code, and with help from Florian, I see that
the memory leak is introduced in tcp_v4_early_demux():

  void tcp_v4_early_demux(struct sk_buff *skb)
  {
    /* ... */

  	iph = ip_hdr(skb);
  	th = tcp_hdr(skb);
  
  	if (th->doff < sizeof(struct tcphdr) / 4)
  		return;
  
  	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
  				       iph->saddr, th->source,
  				       iph->daddr, ntohs(th->dest),
  				       skb->skb_iif);
  	if (sk) {
  		skb->sk = sk;

where the socket is assigned unconditionally to skb->sk, also bumping
the refcnt on it.  This is problematic, because in our case the skb
has already a socket assigned in the TPROXY target if being proxied
traffic.  This then results in the leak I see.

The very same issue seems to be with IPv6, but haven't tested.

Because this codepath is only hit with net.ipv4.ip_early_demux enabled
(default '0') disabling Early Demux prooved to be a valid workaround
for this issue.

The patch which fixes the issue for me is attached as RFC: I simply
skip Early Demux if a local socket already has been assigned
in the target.  Both for IPv4 and IPv6.  kmemleak then reports
no more leaks.

Please have a look, there may be smarter ways of fixing that.

Same issue is present in net-next and v3.13.

Thanks,

 /Holger


--vA66WO2vHvL/CRSR
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: inline; filename="fix-memleak-if-TPROXY-plus-early-demux.diff"

net: Fix memory leak if TPROXY used with TCP early demux

I see a memory leak when using a transparent HTTP proxy using TPROXY
together with TCP early demux and Kernel v3.8.13.15 (Ubuntu stable):

unreferenced object 0xffff88008cba4a40 (size 1696):
  comm "softirq", pid 0, jiffies 4294944115 (age 8907.520s)
  hex dump (first 32 bytes):
    0a e0 20 6a 40 04 1b 37 92 be 32 e2 e8 b4 00 00  .. j@..7..2.....
    02 00 07 01 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff810b710a>] kmem_cache_alloc+0xad/0xb9
    [<ffffffff81270185>] sk_prot_alloc+0x29/0xc5
    [<ffffffff812702cf>] sk_clone_lock+0x14/0x283
    [<ffffffff812aaf3a>] inet_csk_clone_lock+0xf/0x7b
    [<ffffffff8129a893>] netlink_broadcast+0x14/0x16
    [<ffffffff812c1573>] tcp_create_openreq_child+0x1b/0x4c3
    [<ffffffff812c033e>] tcp_v4_syn_recv_sock+0x38/0x25d
    [<ffffffff812c13e4>] tcp_check_req+0x25c/0x3d0
    [<ffffffff812bf87a>] tcp_v4_do_rcv+0x287/0x40e
    [<ffffffff812a08a7>] ip_route_input_noref+0x843/0xa55
    [<ffffffff812bfeca>] tcp_v4_rcv+0x4c9/0x725
    [<ffffffff812a26f4>] ip_local_deliver_finish+0xe9/0x154
    [<ffffffff8127a927>] __netif_receive_skb+0x4b2/0x514
    [<ffffffff8127aa77>] process_backlog+0xee/0x1c5
    [<ffffffff8127c949>] net_rx_action+0xa7/0x200
    [<ffffffff81209d86>] add_interrupt_randomness+0x39/0x157

But there are many more, resulting in the machine going OOM after some
days.

>From looking at the TPROXY code, and with help from Florian, I see
that the memory leak is introduced in tcp_v4_early_demux():

  void tcp_v4_early_demux(struct sk_buff *skb)
  {
    /* ... */

    iph = ip_hdr(skb);
    th = tcp_hdr(skb);

    if (th->doff < sizeof(struct tcphdr) / 4)
        return;

    sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
                       iph->saddr, th->source,
                       iph->daddr, ntohs(th->dest),
                       skb->skb_iif);
    if (sk) {
        skb->sk = sk;

where the socket is assigned unconditionally to skb->sk, also bumping
the refcnt on it.  This is problematic, because in our case the skb
has already a socket assigned in the TPROXY target.  This then results
in the leak I see.

The very same issue seems to be with IPv6, but haven't tested.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next/net/ipv4/ip_input.c
===================================================================
--- net-next.orig/net/ipv4/ip_input.c
+++ net-next/net/ipv4/ip_input.c
@@ -314,7 +314,7 @@ static int ip_rcv_finish(struct sk_buff
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
-	if (sysctl_ip_early_demux && !skb_dst(skb)) {
+	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
Index: net-next/net/ipv6/ip6_input.c
===================================================================
--- net-next.orig/net/ipv6/ip6_input.c
+++ net-next/net/ipv6/ip6_input.c
@@ -49,7 +49,7 @@
 
 int ip6_rcv_finish(struct sk_buff *skb)
 {
-	if (sysctl_ip_early_demux && !skb_dst(skb)) {
+	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
 
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);

--vA66WO2vHvL/CRSR--
