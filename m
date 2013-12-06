From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] virtio_net: multicast address list never sent to host
Date: Fri, 6 Dec 2013 14:51:45 -0800
Message-ID: <20131206145145.29d204f9@nehalam.linuxnetplumber.net>
References: <20131205152052.064319c9@nehalam.linuxnetplumber.net>
	<52A1E16B.8050507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:52937 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759212Ab3LFWvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 17:51:49 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so1876998pbb.31
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 14:51:48 -0800 (PST)
In-Reply-To: <52A1E16B.8050507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Dec 2013 09:38:35 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> > -		sgs[out_num++] = out;
> > -	if (in)
> > -		sgs[out_num + in_num++] = in;
> > +	while (out_cnt-- > 0)
> > +		sgs[out_num++] = out++;  
> 
> I think we can skip sg_count and just use
>         while ((sg = sg_next(out)) != NULL)
>                 sgs[out_num++] = sg;
> 
> And we can probably do this loop for both 'in' and 'out' pointers.
> 
> -vlad


That won't work because callers pass a list with a single element,
as in:

> static int virtnet_set_mac_address(struct net_device *dev, void *p)
> {
> 	struct virtnet_info *vi = netdev_priv(dev);
> 	struct virtio_device *vdev = vi->vdev;
> 	int ret;
> 	struct sockaddr *addr = p;
> 	struct scatterlist sg;
> 
> 	ret = eth_prepare_mac_addr_change(dev, p);
> 	if (ret)
> 		return ret;
> 
> 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> 		sg_init_one(&sg, addr->sa_data, dev->addr_len);
> 		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> 					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> 					  &sg, NULL)) {
> 			dev_warn(&vdev->dev,
