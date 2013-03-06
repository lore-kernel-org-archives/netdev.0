From: David Miller <davem@davemloft.net>
Subject: Re: destroy_conntrack GPF in 3.7.9
Date: Wed, 06 Mar 2013 15:46:41 -0500 (EST)
Message-ID: <20130306.154641.1893414808816499940.davem@davemloft.net>
References: <20130306155955.GA24215@redhat.com>
	<1362588847.15793.180.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805Ab3CFUqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:46:43 -0500
In-Reply-To: <1362588847.15793.180.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Mar 2013 08:54:07 -0800

> tun driver lacks a nf_reset(skb) call
> 
> I would try :
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 2c6a22e..b7c457a 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -747,6 +747,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  		goto drop;
>  	skb_orphan(skb);
>  
> +	nf_reset(skb);
> +

We just recently fixed a similar bug in the VXLAN driver too.

Eric please submit the TUN fix formally, thanks.

commit 88c4c066c6b4db26dc4909ee94e6bf377e8e8e81
Author: Zang MingJie <zealot0630@gmail.com>
Date:   Mon Mar 4 06:07:34 2013 +0000

    reset nf before xmit vxlan encapsulated packet
    
    We should reset nf settings bond to the skb as ipip/ipgre do.
    
    If not, the conntrack/nat info bond to the origin packet may continually
    redirect the packet to vxlan interface causing a routing loop.
    
    this is the scenario:
    
         VETP     VXLAN Gateway
        /----\  /---------------\
        |    |  |               |
        |  vx+--+vx --NAT-> eth0+--> Internet
        |    |  |               |
        \----/  \---------------/
    
    when there are any packet coming from internet to the vetp, there will be lots
    of garbage packets coming out the gateway's vxlan interface, but none actually
    sent to the physical interface, because they are redirected back to the vxlan
    interface in the postrouting chain of NAT rule, and dmesg complains:
    
        Mar  1 21:52:53 debian kernel: [ 8802.997699] Dead loop on virtual device vxlan0, fix it urgently!
        Mar  1 21:52:54 debian kernel: [ 8804.004907] Dead loop on virtual device vxlan0, fix it urgently!
        Mar  1 21:52:55 debian kernel: [ 8805.012189] Dead loop on virtual device vxlan0, fix it urgently!
        Mar  1 21:52:56 debian kernel: [ 8806.020593] Dead loop on virtual device vxlan0, fix it urgently!
    
    the patch should fix the problem
    
    Signed-off-by: Zang MingJie <zealot0630@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f10e58a..c3e3d29 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -961,6 +961,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
 	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
 
+	nf_reset(skb);
+
 	vxlan_set_owner(dev, skb);
 
 	/* See iptunnel_xmit() */
