From: Amos Kong <akong@redhat.com>
Subject: Re: [RFC] virtio_net: multicast address list never sent to host
Date: Mon, 16 Dec 2013 15:52:00 +0800
Message-ID: <20131216075200.GA14869@amosk.info>
References: <20131205152052.064319c9@nehalam.linuxnetplumber.net>
 <20131210082201.GA17498@amosk.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Williamson <alex.williamson@hp.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402Ab3LPHwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 02:52:07 -0500
Content-Disposition: inline
In-Reply-To: <20131210082201.GA17498@amosk.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 04:22:01PM +0800, Amos Kong wrote:
> On Thu, Dec 05, 2013 at 03:20:52PM -0800, Stephen Hemminger wrote:
> > 
> > The virtio_net driver never sends the second address list to
> > the host. This is because send command takes a pointer to scatter list
> > to send but only inserts that one entry into the scatter list that
> > is sent to the host.
> > 
> > This bug has been there since:
> > commit f565a7c259d71cc186753653d978c646d2354b36
> > Author: Alex Williamson <alex.williamson@hp.com>
> > Date:   Wed Feb 4 09:02:45 2009 +0000
> > 
> >     virtio_net: Add a MAC filter table
> > 
> > 
> > I also dropped the in argument since it is never used.
> 
> Hi Stephen,
> 
> I don't think this patch is necessary, did you touch some real
> problem?
>  
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >
> > --- a/drivers/net/virtio_net.c	2013-12-05 15:11:34.000000000 -0800
> > +++ b/drivers/net/virtio_net.c	2013-12-05 15:17:16.211568831 -0800
> > @@ -877,16 +877,16 @@ static netdev_tx_t start_xmit(struct sk_
> >   * never fail unless improperly formated.
> >   */
> >  static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> > -				 struct scatterlist *out,
> > -				 struct scatterlist *in)
> > +				 struct scatterlist *out, unsigned out_cnt)
> >  {
> >  	struct scatterlist *sgs[4], hdr, stat;
> 
> We save scatterlist point in sgs[], one list can have 0, 1 or more than 1 items.
> 
> In virtio_rng.c: virtqueue_add_sgs()
> 
>    /* Count them first. */
>    for (i = total_out = total_in = 0; i < out_sgs; i++) {
>            struct scatterlist *sg;
>            for (sg = sgs[i]; sg; sg = sg_next(sg))
>                    total_out++;
>    }
> 
> Each item of sgs[] will be visited, all the scatter entries of one scatterlist
> will also be visited.
> 
> In my testing (w/o this patch), multicast addresses can be sent to qemu.
> 
> guest) # ip maddr show
> 1:      lo
>         inet  224.0.0.1
>         inet6 ff02::1
>         inet6 ff01::1
> 2:      eth0
>         link  33:33:00:00:00:01
>         link  01:00:5e:00:00:01
>         link  33:33:ff:12:34:56
>         link  33:33:00:00:02:02
>         link  01:00:5e:00:00:fb
>         inet  224.0.0.251
>         inet  224.0.0.1
>         inet6 ff02::202
>         inet6 ff02::1:ff12:3456
>         inet6 ff02::1
>         inet6 ff01::1
> 
> qmp) { 'execute': 'query-rx-filter'}
> 
> {
>     "return": [
>         {
>             "promiscuous": false, 
>             "name": "vnet0", 
>             "main-mac": "52:54:00:12:34:56", 
>             "unicast": "normal", 
>             "vlan-table": [
>             ], 
>             "unicast-table": [
>             ], 
>             "multicast": "normal", 
>             "multicast-overflow": false, 
>             "unicast-overflow": false, 
>             "multicast-table": [
>                 "01:00:5e:00:00:fb", 
>                 "33:33:00:00:02:02", 
>                 "33:33:ff:12:34:56", 
>                 "01:00:5e:00:00:01", 
>                 "33:33:00:00:00:01"
>             ], 
>             "broadcast-allowed": false
>         }
>     ]
> }

Michael, Jason,   any thought?

 
> Thanks, Amos
