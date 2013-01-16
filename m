From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: introduce a new control to set macaddr
Date: Wed, 16 Jan 2013 10:36:58 +0200
Message-ID: <20130116083658.GE11465@redhat.com>
References: <1358315821-29519-1-git-send-email-akong@redhat.com>
	<1358315821-29519-3-git-send-email-akong@redhat.com>
	<8243136.frWZnRkUJV@jason-thinkpad-t430s>
	<20130116082447.GA31074@t430s.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Amos Kong <akong@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130116082447.GA31074@t430s.nay.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 16, 2013 at 04:24:47PM +0800, Amos Kong wrote:
> On Wed, Jan 16, 2013 at 02:20:39PM +0800, Jason Wang wrote:
> > On Wednesday, January 16, 2013 01:57:01 PM akong@redhat.com wrote:
> > > From: Amos Kong <akong@redhat.com>
> > > 
> > > Currently we write MAC address to pci config space byte by byte,
> > > this means that we have an intermediate step where mac is wrong.
> > > This patch introduced a new control command to set MAC address
> > > in one time.
> > > 
> > > VIRTIO_NET_F_CTRL_MAC_ADDR is a new feature bit for compatibility.
> > > 
> > > Signed-off-by: Amos Kong <akong@redhat.com>
> > > ---
> > >  drivers/net/virtio_net.c        | 24 +++++++++++++++++-------
> > >  include/uapi/linux/virtio_net.h |  8 +++++++-
> > >  2 files changed, 24 insertions(+), 8 deletions(-)
> > > 
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index 395ab4f..c8901b6 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -802,16 +802,25 @@ static int virtnet_set_mac_address(struct net_device
> > > *dev, void *p) struct virtnet_info *vi = netdev_priv(dev);
> > >  	struct virtio_device *vdev = vi->vdev;
> > >  	int ret;
> > > +	struct sockaddr *addr = p;
> > > +	struct scatterlist sg;
> > > 
> > > -	ret = eth_mac_addr(dev, p);
> > > -	if (ret)
> > > -		return ret;
> > > -
> > > -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> > > +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> > > +		sg_init_one(&sg, addr->sa_data, dev->addr_len);
> > > +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> > > +					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> > > +					  &sg, 1, 0)) {
> > > +			dev_warn(&vdev->dev,
> > > +				 "Failed to set mac address by vq command.\n");
> > > +			return -EINVAL;
> > > +		}
> > > +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
> > >  		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> > > -		                  dev->dev_addr, dev->addr_len);
> > > +				  addr->sa_data, dev->addr_len);
> > > +	}
> > > +	ret = eth_mac_addr(dev, p);
> > > 
> > 
> > The you will the validity check in eth_mac_addr which may result a wrong mac 
> > address to be set in the hardware (or is there any check in qemu) and a 
> > inconsistency bettween what kernel assumes and qemu has.
> > 
> > You can take a look at netvsc driver that calls eth_mac_addr() first and 
> > restore the software mac address when fail to enforce it to hardware.
> 
> Thanks for the catching, I will move eth_mac_addr() back to above,
> just restore addr if fail to send command.
> 
> I will also use DEFINE_PROP_BIT to fix migration issue, thanks.

And clear it if running with a compat machine type.

> > Thanks
> > > -	return 0;
> > > +	return ret;
> > >  }
> 
