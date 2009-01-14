From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 3/4] virtio_net: Add a set_rx_mode interface
Date: Wed, 14 Jan 2009 09:48:29 -0700
Message-ID: <1231951709.7109.335.camel@lappy>
References: <1231881799.9095.188.camel@bling>
	 <1231928111.4944.291.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231928111.4944.291.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-14 at 10:15 +0000, Mark McLoughlin wrote:
> On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> 
> Just to be sure - this patch (i.e. without the MAC table) keeps think
> working as before? i.e. the dev->uc_count check means that you don't
> need to put the device into promiscuous mode to receive any packets?

Not quite as before, but it should be functionally correct.  Promiscuous
mode will be enabled if either explicitly set or if there are additional
unicast MAC address in the uc_list.  This is what drivers typically do
if they overflow the number of available entries in the MAC filter
table.  Likewise, allmulti will be enabled if explicitly set or if there
are any additional multicast addresses in the mc_list.  Without bonding
or macvlans, there will typically be no uc_list entries and 3 mc_list
entries, so the backend will run with promisc off and allmulti on.

> > +static void virtnet_set_rx_mode(struct net_device *dev)
> > +{
> > +	struct virtnet_info *vi = netdev_priv(dev);
> > +	u8 promisc, allmulti;
> > +
> > +	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
> > +	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
> > +
> > +	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
> > +			     VIRTIO_NET_CTRL_RX_MODE_PROMISC,
> > +			     &promisc, sizeof(promisc));
> > +
> > +	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
> > +			     VIRTIO_NET_CTRL_RX_MODE_ALLMULTI,
> > +			     &allmulti, sizeof(allmulti));
> 
> Why two commands? Why not e.g.
> 
>         virtnet_send_command(vi, VIRTIO_NET_SET_RX_MODE,
>                              &rx_mode, sizeof(rx_mode));

It seemed like a good idea to keep the command set very basic.  One
command to do both means we need to define which bit is what and raises
questions about how do we expand that if we decide we want to set a
third bit.  This is also where the class/cmd comes into play by making
it easy to add another command to a class without creating a sparse
mapping of commands to functional areas.

> Also, print warning on failure?

I was tempted to, but then came back to the new guest driver, old qemu
issues.  Maybe I should return a different error if the command vq isn't
present so the caller can suppress errors, -EIO maybe.

> >  static struct ethtool_ops virtnet_ethtool_ops = {
> >  	.set_tx_csum = virtnet_set_tx_csum,
> >  	.set_sg = ethtool_op_set_sg,
> > @@ -687,6 +704,7 @@ static const struct net_device_ops virtnet_netdev = {
> >  	.ndo_start_xmit      = start_xmit,
> >  	.ndo_validate_addr   = eth_validate_addr,
> >  	.ndo_set_mac_address = virtnet_set_mac_address,
> > +	.ndo_set_rx_mode     = virtnet_set_rx_mode,
> 
> Don't think we want to hook this unless we know the host supports it -
> i.e. unless the command queue is available.

That may be any easy way to solve the problem, I'll try it.

> >  	.ndo_change_mtu	     = virtnet_change_mtu,
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  	.ndo_poll_controller = virtnet_netpoll,
> > diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> > index 1de7c86..80cd7d3 100644
> > --- a/include/linux/virtio_net.h
> > +++ b/include/linux/virtio_net.h
> > @@ -56,4 +56,8 @@ struct virtio_net_hdr_mrg_rxbuf {
> >  #define VIRTIO_NET_OK     0
> >  #define VIRTIO_NET_ERR    1
> >  
> > +#define VIRTIO_NET_CTRL_RX_MODE    0
> 
> I'd probably call the command VIRTIO_NET_CMD_SET_RX_MODE
> 
> > + #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
> > + #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
> 
> and these VIRTIO_NET_RX_MODE_PROMISC/ALLMULTI
> 
> Also, kill the leading whitespace - I didn't even think that would
> build :)

Yup, they do.  I can kill them, but I think they help delineate the
command as being valid for that class.  Thanks for the comments.

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

