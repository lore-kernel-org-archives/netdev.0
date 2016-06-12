From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCHi next] veth: advertise peer link relationship for both
 devices
Date: Sat, 11 Jun 2016 22:04:13 -0400 (EDT)
Message-ID: <489378018.52267492.1465697053847.JavaMail.zimbra@redhat.com>
References: <1465576339-17641-1-git-send-email-lrichard@redhat.com> <20160611.154340.1340829899277605940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:50034 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222AbcFLCES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 22:04:18 -0400
In-Reply-To: <20160611.154340.1340829899277605940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "David Miller" <davem@davemloft.net>
> To: lrichard@redhat.com
> Cc: netdev@vger.kernel.org, "nicolas dichtel" <nicolas.dichtel@6wind.com>
> Sent: Saturday, June 11, 2016 6:43:40 PM
> Subject: Re: [PATCHi next] veth: advertise peer link relationship for both devices
> 
> From: Lance Richardson <lrichard@redhat.com>
> Date: Fri, 10 Jun 2016 12:32:19 -0400
> 
> > Currently, when creating a veth pair, notfications to user
> > space only include link peer for one end of the veth pair:
> >    # ip monitor link &
> >    # ip link add dev vm1 type veth peer name vm2
> >    30: vm2@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> >        link/ether be:e3:b7:0e:14:52 brd ff:ff:ff:ff:ff:ff
> >    31: vm1@vm2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
> >        link/ether da:e6:a6:c5:42:54 brd ff:ff:ff:ff:ff:ff
> > 
> > With this change, netlink notifications are sent with complete
> > information for both interfaces of the veth pair:
> > 
> >    # 3: vm2@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> >        link/ether e2:94:54:8a:ac:f5 brd ff:ff:ff:ff:ff:ff
> >    4: vm1@vm2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
> >        link/ether b2:05:70:e0:fc:35 brd ff:ff:ff:ff:ff:ff
> >    3: vm2@vm1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN
> >        link/ether e2:94:54:8a:ac:f5 brd ff:ff:ff:ff:ff:ff
> > 
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> 
> I don't know about this.
> 
> First of all, those notifications you get above tell you everything you
> need to know in order to figure out what both ends of the veth pair are.
> 
> In fact, I would say that the vm1@vm2 notification #31 above is the _only_
> one you absolutely need.
> 
> > @@ -466,8 +466,16 @@ static int veth_newlink(struct net *src_net, struct
> > net_device *dev,
> >  
> >  	priv = netdev_priv(peer);
> >  	rcu_assign_pointer(priv->peer, dev);
> > +
> > +	err = rtnl_configure_link(dev, NULL);
> > +	if (err < 0)
> > +		goto err_configure_dev;
> > +
> > +	rtmsg_ifinfo(RTM_NEWLINK, peer, 0, GFP_KERNEL);
> >  	return 0;
> >  
> > +err_configure_dev:
> > +	/* nothing to do */
> >  err_register_dev:
> >  	/* nothing to do */
> >  err_configure_peer:
> 
> If you're registering the peer here explicitly, this means a link configure
> somewhere else is now superfluous.
> 
> I really don't like this change at all, both from a necessity perspective as
> well as from it's implementation.
> 

I'll confess to not being super-happy with it myself, which is why I've
been sitting on this patch for some time now. A hard NAK will help justify
a "will not fix" to the reporter of this issue.

Thanks,

  Lance
