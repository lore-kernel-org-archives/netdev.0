From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc V3 7/9] macvtap: allow TUNSETIFF to create
 multiqueue device
Date: Thu, 6 Jun 2013 10:26:59 +0300
Message-ID: <20130606072659.GD5170@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
 <1370414192-5830-8-git-send-email-jasowang@redhat.com>
 <20130605104306.GG31830@redhat.com>
 <51AFFE59.2010808@redhat.com>
 <20130606065905.GA5170@redhat.com>
 <51B03674.2070400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51B03674.2070400@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 03:12:52PM +0800, Jason Wang wrote:
> On 06/06/2013 02:59 PM, Michael S. Tsirkin wrote:
> > On Thu, Jun 06, 2013 at 11:13:29AM +0800, Jason Wang wrote:
> >> On 06/05/2013 06:43 PM, Michael S. Tsirkin wrote:
> >>> On Wed, Jun 05, 2013 at 02:36:30PM +0800, Jason Wang wrote:
> >>>> Though the queue were in fact created by open(), we still need to add this check
> >>>> to be compatible with tuntap which can let mgmt software use a single API to
> >>>> manage queues. This patch only validates the device name and moves the TUNSETIFF
> >>>> to a helper.
> >>>>
> >>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>> The patch is OK, the description is confusing.
> >>> What you mean is simply:
> >>>
> >>> 	Allow IFF_MULTI_QUEUE in TUNSETIFF for macvtap, to match
> >>> 	tun behaviour.
> >>>
> >>> And if you put it like this, I would say make this
> >>> the last patch in the series, so userspace
> >>> can use IFF_MULTI_QUEUE to detect new versus old
> >>> behaviour.
> 
> [...]
> >>>> @@ -887,6 +888,44 @@ static void macvtap_put_vlan(struct macvlan_dev *vlan)
> >>>>  	dev_put(vlan->dev);
> >>>>  }
> >>>>  
> >>>> +static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
> >>>> +{
> >>>> +	struct macvtap_queue *q = file->private_data;
> >>>> +	struct net *net = current->nsproxy->net_ns;
> >>>> +	struct inode *inode = file_inode(file);
> >>>> +	struct net_device *dev, *dev2;
> >>>> +	struct ifreq ifr;
> >>>> +
> >>>> +	if (copy_from_user(&ifr, ifr_u, sizeof(struct ifreq)))
> >>>> +		return -EFAULT;
> >>>> +
> >>>> +	/* To keep the same behavior of tuntap, validate ifr_name */
> >>> So I'm not sure - why is it important to validate ifr_name here?
> >>> We ignore the name for all other flags - why is IFF_MULTI_QUEUE
> >>> special?
> >> It raises another question, why not validate ifname like tuntap? We
> >> should warn userspace about their error, otherwise they may create
> >> queues on the wrong device. In fact I want validate for both, but keep
> >> the behaviour w/o IFF_MULTI_QUEUE for backward compatibility.
> > Basically macvtap ignores ifr_name because it doesn't need it.
> > Making it ignore it without IFF_MULTI_QUEUE but
> > not with IFF_MULTI_QUEUE seems ugly.
> >
> > Do you think we'll need ifr_name at some point?
> > Why not validate then, when we actually do?
> >
> >
> >
> 
> If we want to be more compatible with tuntap to simplify userspace codes.
> 
> E.g: There's a userspace who want to create both taps and macvtaps using
> the same codes. For tuntap, we can let kernel name the device, so
> creating a mq device looks like:
> 
> open()
> tunsetiff()
> if_name = tungetiff()
> tunsetiff(if_name)
> ...
> tunsetiff(if_name)
> 
> For tuntap, if we specifies a wrong ifr_name, kernel will complains.
> We'd better do the same for macvtap.
> 
> [...]

I don't think we need to worry about returning same error to buggy
applications. Maybe it would make sense if we did it like this
the first time around, or maybe it won't, but adding
inconsistency between macvtap interfaces is even worse.

-- 
MST
