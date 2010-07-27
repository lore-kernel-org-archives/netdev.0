From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: br_forward.c - rcu dereference warning
Date: Tue, 27 Jul 2010 13:42:23 -0700
Message-ID: <20100727134223.5bb0be30@nehalam>
References: <1280227553.3755.2.camel@jlt3.sipsolutions.net>
	<20100727123859.GF3766@linux.vnet.ibm.com>
	<20100727112630.5a5ce84b@nehalam>
	<1280261679.3755.6.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56509 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031Ab0G0Um1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 16:42:27 -0400
In-Reply-To: <1280261679.3755.6.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jul 2010 22:14:39 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Tue, 2010-07-27 at 11:26 -0700, Stephen Hemminger wrote:
> 
> > -/* net device transmit always called with no BH (preempt_disabled) */
> > +/* net device transmit always called with no BH disabled */
> 
> "no BH disabled"?
> 
> > @@ -48,6 +48,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
> >  	skb_reset_mac_header(skb);
> >  	skb_pull(skb, ETH_HLEN);
> >  
> > +	rcu_read_lock();
> >  	if (is_multicast_ether_addr(dest)) {
> >  		if (unlikely(netpoll_tx_running(dev))) {
> >  			br_flood_deliver(br, skb);
> > @@ -67,6 +68,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
> >  		br_flood_deliver(br, skb);
> >  
> >  out:
> > +	rcu_read_unlock();
> >  	return NETDEV_TX_OK;
> >  }
> >  
> > --- a/net/bridge/br_fdb.c	2010-07-27 11:18:30.815320981 -0700
> > +++ b/net/bridge/br_fdb.c	2010-07-27 11:18:59.597710975 -0700
> > @@ -214,7 +214,7 @@ void br_fdb_delete_by_port(struct net_br
> >  	spin_unlock_bh(&br->hash_lock);
> >  }
> >  
> > -/* No locking or refcounting, assumes caller has no preempt (rcu_read_lock) */
> > +/* No locking or refcounting, assumes caller has rcu_read_lock */
> >  struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
> >  					  const unsigned char *addr)
> >  {
> > --- a/net/bridge/br_input.c	2010-07-27 11:19:05.266181492 -0700
> > +++ b/net/bridge/br_input.c	2010-07-27 11:19:29.148163149 -0700
> > @@ -39,7 +39,7 @@ static int br_pass_frame_up(struct sk_bu
> >  		       netif_receive_skb);
> >  }
> >  
> > -/* note: already called with rcu_read_lock (preempt_disabled) */
> > +/* note: already called with rcu_read_lock */
> >  int br_handle_frame_finish(struct sk_buff *skb)
> >  {
> >  	const unsigned char *dest = eth_hdr(skb)->h_dest;
> > @@ -110,7 +110,7 @@ drop:
> >  	goto out;
> >  }
> >  
> > -/* note: already called with rcu_read_lock (preempt_disabled) */
> > +/* note: already called with rcu_read_lock */
> >  static int br_handle_local_finish(struct sk_buff *skb)
> >  {
> >  	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
> > @@ -133,8 +133,7 @@ static inline int is_link_local(const un
> >  
> >  /*
> >   * Return NULL if skb is handled
> > - * note: already called with rcu_read_lock (preempt_disabled) from
> > - * netif_receive_skb
> > + * note: already called with rcu_read_lock from netif_receive_skb
> >   */
> >  struct sk_buff *br_handle_frame(struct sk_buff *skb)
> >  {
> > --- a/net/bridge/br_stp_bpdu.c	2010-07-27 11:19:34.092573294 -0700
> > +++ b/net/bridge/br_stp_bpdu.c	2010-07-27 11:19:40.725123403 -0700
> > @@ -131,7 +131,7 @@ void br_send_tcn_bpdu(struct net_bridge_
> >  /*
> >   * Called from llc.
> >   *
> > - * NO locks, but rcu_read_lock (preempt_disabled)
> > + * NO locks, but rcu_read_lock
> >   */
> >  void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
> >  		struct net_device *dev)
> > 
> 
> Did you want me to test the patch?

Yes please, I can make sure it works, but not that it gets rid
of your error

-- 
