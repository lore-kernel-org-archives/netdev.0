From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: VXLAN RCU error
Date: Thu, 23 Feb 2017 00:20:25 -0800
Message-ID: <20170223002025.2d2d3c4e@laptop>
References: <20170222142745.31c5f75e@cakuba.netronome.com>
        <20170222203031.45513e4c@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>, netdev@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:22371 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750944AbdBWI1O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 03:27:14 -0500
In-Reply-To: <20170222203031.45513e4c@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2017 20:30:31 -0800, Jakub Kicinski wrote:
> On Wed, 22 Feb 2017 14:27:45 -0800, Jakub Kicinski wrote:
> > [ 1571.067134] ===============================
> > [ 1571.071842] [ ERR: suspicious RCU usage.  ]
> > [ 1571.076546] 4.10.0-debug-03232-g12d656af4e3d #1 Tainted: G        W  O   
> > [ 1571.084166] -------------------------------
> > [ 1571.088867] ../drivers/net/vxlan.c:2111 suspicious rcu_dereference_check() usage!
> > [ 1571.097286] 
> > [ 1571.097286] other info that might help us debug this:
> > [ 1571.097286] 
> > [ 1571.106305] 
> > [ 1571.106305] rcu_scheduler_active = 2, debug_locks = 1
> > [ 1571.113654] 3 locks held by ping/13826:
> > [ 1571.117968]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffffa1cd4972>] raw_sendmsg+0x14e2/0x2e40
> > [ 1571.127758]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffffa1be9594>] ip_finish_output2+0x274/0x1390
> > [ 1571.138135]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffffa1a9b63c>] __dev_queue_xmit+0x1ec/0x2750
> ....
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 4e27c5b09600..8aa3e837cd6c 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2109,7 +2109,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>                                      vxlan->cfg.port_max, true);
>  
>         if (dst->sa.sa_family == AF_INET) {
> -               struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
> +               struct vxlan_sock *sock4 = rcu_dereference_bh(vxlan->vn4_sock);
>                 struct rtable *rt;
>                 __be16 df = 0;
>  
> @@ -2148,7 +2148,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>                                     src_port, dst_port, xnet, !udp_sum);
>  #if IS_ENABLED(CONFIG_IPV6)
>         } else {
> -               struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
> +               struct vxlan_sock *sock6 = rcu_dereference_bh(vxlan->vn6_sock);
>  
>                 ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
>                                         rdst ? rdst->remote_ifindex : 0, tos,
> 

Ugh.  Looks like this may not work even if it makes the splat go away.
synchronize_net() doesn't seem to wait for the _bh() flavor of RCU, so
we need to add syncronize_rcu_bh() call before freeing the socket or do
a normal rcu_read_lock()/unlock() on the fast path.  Any RCU experts
want to comment? :)

FWIW geneve will need similar fix, I presume.
