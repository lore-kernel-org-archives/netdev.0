From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next  1/2] vxlan: Notify drivers for listening UDP port
 changes
Date: Wed, 28 Aug 2013 13:41:08 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1308281338310.26333@intel.com>
References: <1377665218-6760-1-git-send-email-jeffrey.t.kirsher@intel.com> <521E50B1.4010102@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30256 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362Ab3H1U0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 16:26:16 -0400
In-Reply-To: <521E50B1.4010102@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 28 Aug 2013, John Fastabend wrote:

> On 8/27/2013 9:46 PM, Jeff Kirsher wrote:
> > From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> >
> > This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> > ndo_del_rx_vxlan_port().
> >
> > Drivers can get notifications through the above functions about changes
> > of the UDP listening port of VXLAN. Also, when physical ports come up,
> > now they can call vxlan_get_rx_port() in order to obtain the port number(s)
> > of the existing VXLAN interface in case they already up before them.
> >
> > This information about the listening UDP port would be used for VXLAN
> > related offloads.
> 
> [...]
> 
> >   /* Add new entry to forwarding table -- assumes lock held */
> >   static int vxlan_fdb_create(struct vxlan_dev *vxlan,
> >   			    const u8 *mac, __be32 ip,
> > @@ -797,13 +823,15 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
> >
> >   void vxlan_sock_release(struct vxlan_sock *vs)
> >   {
> > -	struct vxlan_net *vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
> > +	struct net *net = sock_net(vs->sock->sk);
> > +	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> >
> >   	if (!atomic_dec_and_test(&vs->refcnt))
> >   		return;
> >
> >   	spin_lock(&vn->sock_lock);
> >   	hlist_del_rcu(&vs->hlist);
> > +	vxlan_notify_del_rx_port(net, inet_sk(vs->sock->sk)->inet_sport);
> >   	spin_unlock(&vn->sock_lock);
> 
> Both the del and add port are protected by sock_lock serializing the
> operations.
> 
> >
> >   	queue_work(vxlan_wq, &vs->del_work);
> > @@ -1543,6 +1571,28 @@ static struct device_type vxlan_type = {
> >   	.name = "vxlan",
> >   };
> >
> > +/* Calls the ndo_add_vxlan_port of the caller in order to
> > + * supply the listening VXLAN udp ports.
> > + */
> > +void vxlan_get_rx_port(struct net_device *dev)
> > +{
> > +	struct vxlan_sock *vs;
> > +	struct net *net = dev_net(dev);
> > +	u16 port;
> > +	int i;
> > +
> > +	if (!dev || !dev->netdev_ops || !dev->netdev_ops->ndo_add_vxlan_port)
> > +		return;
> > +
> > +	for (i = 0; i < PORT_HASH_SIZE; ++i) {
> > +		hlist_for_each_entry_rcu(vs, vs_head(net, i), hlist) {
> > +			port = htons(inet_sk(vs->sock->sk)->inet_sport);
> > +			dev->netdev_ops->ndo_add_vxlan_port(dev, port);
> 
> However this list walk occurs without the sock_lock. Looks like you
> could delete a port and then subsequently add it here if you had really
> "good" timing.
> 
> Then it would be deleted from the vxlan list but pushed into hardware.
> Probably not a terrible scenario but it would waste hardware resources.
> 
> I suspect you want to lock this list traversal with the sock_lock as
> well.
> 

Yes, you are right. I will wait a little bit more to gather more comments 
and will push a v2 fixing this issue.

> > +		}
> > +	}
> > +}
> > +EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
