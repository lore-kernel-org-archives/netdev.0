From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] net: macvtap driver
Date: Fri, 29 Jan 2010 13:21:41 +0200
Message-ID: <20100129112141.GA6548@redhat.com>
References: <201001271104.20607.arnd@arndb.de> <201001272209.27361.arnd@arndb.de> <20100128173438.GA3476@redhat.com> <201001282118.09164.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16184 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab0A2LZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 06:25:15 -0500
Content-Disposition: inline
In-Reply-To: <201001282118.09164.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 09:18:08PM +0100, Arnd Bergmann wrote:
> On Thursday 28 January 2010, Michael S. Tsirkin wrote:
> > On Wed, Jan 27, 2010 at 10:09:27PM +0100, Arnd Bergmann wrote:
> > > +static inline struct macvtap_queue *macvtap_file_get_queue(struct file *file)
> > > +{
> > > +	rcu_read_lock_bh();
> > > +	return rcu_dereference(file->private_data);
> > > +}
> > > +
> > > +static inline void macvtap_file_put_queue(void)
> > > +{
> > > +	rcu_read_unlock_bh();
> > > +}
> > > +
> > 
> > I find such wrappers around rcu obscure this,
> > already sufficiently complex, pattern.
> > Might be just me.
> 
> Obviously I find them useful here, but if more people feel the
> same as you, I'll just open-code them.
> 
> > > +static int macvtap_open(struct inode *inode, struct file *file)
> > > +{
> > > +	struct net *net = current->nsproxy->net_ns;
> > > +	struct net_device *dev = dev_get_by_index(net, iminor(inode));
> > > +	struct macvtap_queue *q;
> > > +	int err;
> > > +
> > 
> > This seems to keep reference to device as long as character device is
> > open, which, if I understand correctly, will start printing error
> > messages to kernel log about once a second if you try to remove the
> > device.
> > 
> > I suspect the best way to fix this issue would be to use some kind
> > of notifier so that macvtap can disconnect on device removal.
> 
> I think I'm just missing the put in the open function, the code
> already handles the netif and the file disappearing independently.
> 
> Thanks for spotting this one, I'll fix that in the next post.
> 
> > > +	skb_reserve(skb, NET_IP_ALIGN);
> > > +	skb_put(skb, count);
> > > +
> > > +	if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
> > > +		macvlan_count_rx(q->vlan, 0, false, false);
> > > +		kfree_skb(skb);
> > > +		return -EFAULT;
> > > +	}
> > > +
> > > +	skb_set_network_header(skb, ETH_HLEN);
> > > +
> > > +	macvlan_start_xmit(skb, q->vlan->dev);
> > > +
> > > +	return count;
> > > +}
> > > +
> > 
> > I am surprised there's no GSO support.  Would it be a good idea to share
> > code with tun driver? That already has GSO ...
> 
> The driver still only does the minimum feature set to get things going.
> GSO is an obvious extension, but I wanted the code to be as simple
> as possible to find all the basic bugs before we do anything fancy.
> 
> > Also, network header pointer seems off for vlan packets?
> 
> That may well be, I haven't tried vlan. What do you think it should do
> then?

Look at eth_type for a more complete packet parsing.

> > > +/*
> > > + * provide compatibility with generic tun/tap interface
> > > + */
> > > +static long macvtap_ioctl(struct file *file, unsigned int cmd,
> > > +			  unsigned long arg)
> > > +{
> > 
> > All of these seem to be stubs, and tun has many more that you didn't
> > stub out. So, why do you bother to support any ioctls at all?
> 
> Again, minimum features to get things going. qemu fails to open
> the device if these ioctls are not implemented, but any of the
> more advanced features are left out.

This is strange, could be application bug.  E.g. send buf size is
relatively new and apps should handle failure gracefully.  IMO,
returning success and ignoring the value is not a good idea.  How about
we just fix qemu?  What about other apps?

> Thansk for the review,
> 
> 	Arnd
