From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Thu, 1 Dec 2016 05:27:26 +0200
Message-ID: <20161201052657-mutt-send-email-mst@kernel.org>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
 <20161130152004-mutt-send-email-mst@kernel.org>
 <34EFBCA9F01B0748BEB6B629CE643AE60B0A7B68@szxeml561-mbx.china.huawei.com>
 <20161201051207-mutt-send-email-mst@kernel.org>
 <ee70cb92-3fd9-4148-77ba-739af30b04b6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: wangyunjian <wangyunjian@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        caihe <caihe@huawei.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58980 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751126AbcLADfF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 22:35:05 -0500
Content-Disposition: inline
In-Reply-To: <ee70cb92-3fd9-4148-77ba-739af30b04b6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 11:26:21AM +0800, Jason Wang wrote:
> 
> 
> On 2016年12月01日 11:21, Michael S. Tsirkin wrote:
> > On Thu, Dec 01, 2016 at 02:48:59AM +0000, wangyunjian wrote:
> > > > -----Original Message-----
> > > > From: Michael S. Tsirkin [mailto:mst@redhat.com]
> > > > Sent: Wednesday, November 30, 2016 9:41 PM
> > > > To: wangyunjian
> > > > Cc: jasowang@redhat.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; caihe
> > > > Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when meet errors
> > > > 
> > > > On Wed, Nov 30, 2016 at 08:10:57PM +0800, Yunjian Wang wrote:
> > > > > When we meet an error(err=-EBADFD) recvmsg,
> > > > How do you get EBADFD? Won't vhost_net_rx_peek_head_len
> > > > return 0 in this case, breaking the loop?
> > > We started many guest VMs while attaching/detaching some virtio-net nics for loop.
> > > The soft lockup might happened. The err is -EBADFD.
> > > 
> > OK, I'd like to figure out what happened here. why don't
> > we get 0 when we peek at the head?
> > 
> > EBADFD is from here:
> >          struct tun_struct *tun = __tun_get(tfile);
> > ...
> >          if (!tun)
> >                  return -EBADFD;
> > 
> > but then:
> > static int tun_peek_len(struct socket *sock)
> > {
> > 
> > ...
> > 
> >          struct tun_struct *tun;
> > ...
> >          tun = __tun_get(tfile);
> >          if (!tun)
> >                  return 0;
> > 
> > 
> > so peek len should return 0.
> > 
> > then while will exit:
> >          while ((sock_len = vhost_net_rx_peek_head_len(net, sock->sk)))
> > ...
> > 
> 
> Consider this case: user do ip link del link tap0 before recvmsg() but after
> tun_peek_len() ?

Sure, this can happen, but I think we'll just exit on the next loop,
won't we?

> > > meesage log:
> > > kernel:[609608.510180]BUG: soft lockup - CPU#18 stuck for 23s! [vhost-60898:126093]
> > > call trace:
> > > [<fffffffa0132967>]vhost_get_vq_desc+0x1e7/0x984 [vhost]
> > > [<fffffffa02037e6>]handle_rx+0x226/0x810 [vhost_net]
> > > [<fffffffa0203de5>]handle_rx_net+0x15/0x20 [vhost_net]
> > > [<fffffffa013160b>]vhost_worker+0xfb/0x1e0 [vhost]
> > > [<fffffffa0131510>]? vhost_dev_reset_owner+0x50/0x50 [vhost]
> > > [<fffffff810a5c7f>]kthread+0xcf/0xe0
> > > [<fffffff810a5bb0>]? kthread_create_on_node+0x140/0x140
> > > [<fffffff81648898>]ret_from_fork+0x58/0x90
> > > [<fffffff810a5bb0>]? kthread_create_on_node+0x140/0x140
> > So somehow you keep seeing something in tun when we peek.
> > IMO this is the problem we should try to fix.
> > Could you try debugging the root cause here?
> > 
> > > > > the error handling in vhost
> > > > > handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.
> > > > > 
> > > > > Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> > > > > ---
> > > > >   drivers/vhost/net.c | 3 +++
> > > > >   1 file changed, 3 insertions(+)
> > > > > 
> > > > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > > > index 5dc128a..edc470b 100644
> > > > > --- a/drivers/vhost/net.c
> > > > > +++ b/drivers/vhost/net.c
> > > > > @@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
> > > > >   			pr_debug("Discarded rx packet: "
> > > > >   				 " len %d, expected %zd\n", err, sock_len);
> > > > >   			vhost_discard_vq_desc(vq, headcount);
> > > > > +			/* Don't continue to do, when meet errors. */
> > > > > +			if (err < 0)
> > > > > +				goto out;
> > > > You might get e.g. EAGAIN and I think you need to retry
> > > > in this case.
> > > > 
> > > > >   			continue;
> > > > >   		}
> > > > >   		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
> > > > > -- 
> > > > > 1.9.5.msysgit.1
> > > > > 
