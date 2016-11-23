From: yuehaibing <yuehaibing@huawei.com>
Subject: net/arp: ARP cache aging failed.
Date: Wed, 23 Nov 2016 09:16:08 +0800
Message-ID: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:47750 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756034AbcKWBQ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 20:16:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 Hi,

	I've encountered a arp cache aging failed bug in 4.9 kernel.The topo is as follow:


		HOST1			   --------		  -----
	  --------------------IP1 --------| Switch |--------IP2-| HOST2 |
		 |			   --------		  -----
 	  ------Bonging----                  |
	   |		   |		     IP3
 	 MAC1            MAC2		   | HOST3 |


	HOST1 have a bonding interface which including two NICs

	IP1:192.168.1.100/24
	IP2:192.168.1.200/24
	IP2:192.168.1.300/24

	There are large numbers of TCP transaction between HOST2 and HOST3.


	The Host2 can ping HOST1 normally.However,It cannot ping after HOST1 bonding interface deactived a working NIC.
	

	on HOST2 ,use fowllow command:

		watch "ip -s neigh show|grep 192.168.1.100"
	
	I noticed the old HOST1 arp cache aging counter is gradually  increased ,then reset before it reached 30.This process is repeated,
thus the arp cache holding REACHABLE status.The new HOST1 MAC arp cache cannot been renewed ,and thus ping cannot sendto the correct HOST1 MAC.

	Then I found n->confirmed is freshed  in dst_neigh_output while dst->pending_confirm is set to 1.

include/net/dst.h

static inline void dst_confirm(struct dst_entry *dst)
{
	dst->pending_confirm = 1;
}

static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
                                   struct sk_buff *skb)
{
        const struct hh_cache *hh;

        if (dst->pending_confirm) {
                unsigned long now = jiffies;

                dst->pending_confirm = 0;
                /* avoid dirtying neighbour */
                if (n->confirmed != now)
                        n->confirmed = now;
        }
	.......
}

	dst_confirm can be called by tcp_ack in net/ipv4/tcp_input.c.

/* This routine deals with incoming acks, but not outgoing ones. */
static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
{
	.....
	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
		struct dst_entry *dst = __sk_dst_get(sk);
		if (dst)
			dst_confirm(dst);
	}
	.....
}
	
	As to my topo,HOST1 and HOST3 share one route on HOST2, tcp connection between HOST2 and HOST3 may call tcp_ack to set dst->pending_confirm.
	
So dst_neigh_output may wrongly freshed  n->confirmed which stands for HOST1,however HOST1'MAC had been changed.

	The possibility of this occurred Significantly increases ,when ping and TCP transaction are set the same processor affinity on the HOST2.

	It seems that the issue is brought in commit 5110effee8fde2edfacac9cd12a9960ab2dc39ea ("net: Do delayed neigh confirmation.").
