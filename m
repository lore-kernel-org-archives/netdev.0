From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small
 buffer XDP receive
Date: Wed, 25 Jan 2017 16:45:25 +0200
Message-ID: <20170125163003-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
 <20170123230809-mutt-send-email-mst@kernel.org>
 <20170124.144328.2195698124358175034.davem@davemloft.net>
 <20170124215412-mutt-send-email-mst@kernel.org>
 <a129524e-c4af-5c67-5397-dec992c70fa1@redhat.com>
 <20170125051810-mutt-send-email-mst@kernel.org>
 <58882355.70307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47016 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750748AbdAYOp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 09:45:26 -0500
Content-Disposition: inline
In-Reply-To: <58882355.70307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 08:02:29PM -0800, John Fastabend wrote:
> On 17-01-24 07:23 PM, Michael S. Tsirkin wrote:
> > On Wed, Jan 25, 2017 at 10:57:12AM +0800, Jason Wang wrote:
> >>
> >>
> >> On 2017年01月25日 04:08, Michael S. Tsirkin wrote:
> >>> On Tue, Jan 24, 2017 at 02:43:28PM -0500, David Miller wrote:
> >>>> From: "Michael S. Tsirkin" <mst@redhat.com>
> >>>> Date: Mon, 23 Jan 2017 23:08:35 +0200
> >>>>
> >>>>> On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
> >>>>>> In the small buffer case during driver unload we currently use
> >>>>>> put_page instead of dev_kfree_skb. Resolve this by adding a check
> >>>>>> for virtnet mode when checking XDP queue type. Also name the
> >>>>>> function so that the code reads correctly to match the additional
> >>>>>> check.
> >>>>>>
> >>>>>> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
> >>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>>>>> Acked-by: Jason Wang <jasowang@redhat.com>
> >>>>> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> >>>>>
> >>>>> I think we definitely want this one in -net as it's
> >>>>> a bugfix.
> >>>> This whole series is a bug fix, we must have adjust_header XDP
> >>>> support in the virtio_net driver before v4.10 goes out, it is
> >>>> a requires base feature for XDP.
> >>> I have to say device resets outside probe have a huge potential
> >>> to uncover hypervisor bugs.
> >>
> >> Maybe not if it reuses most of current codes? Since we've already used them
> >> in sleep or hibernation?
> >>
> >> Thanks
> > 
> > Except almost no one uses sleep or hybernate with VMs.  I'm not saying
> > it's a bad idea, just that it needs a lot of testing before release and
> > we won't get enough if we merge at this point.
> > 
> 
> Then it would seem like a good thing to have another user of these paths and
> find the bugs versus letting them sit there for some poor folks who do use
> sleep/hybernate.

Absolutely. But -rc6 is not the time to test waters IMO.

> >>>   I am rather uncomfortable
> >>> doing that after -rc1.
> >>>
> >>> How about a module option to disable it by default?
> >>> We can then ship a partial implementation in 4.10
> >>> and work on completing it in 4.11.
> >>>
> 
> Ugh I would prefer to avoid module options. This will only happen if users
> push XDP program into driver anyways.

Again I agree, it's an idea for a stopgap measure so we can have
something in 4.10 - and also assuming that 256b headroom is a must.

> > 
> > To clarify, I'm thinking an option similar to enable_xdp,
> > and have all packets have a 256 byte headroom for 4.10.
> 
> An option where? In QEMU side, in driver? Is the reset really that bad, coming
> from a hardware driver side lots of configuration changes can cause resets. I
> agree its not overly elegant but could follow on patches be used to make it
> prettier if possible.

Again I agree and it's not that bad it's just not something we should
do past rc5.

> I know folks prefer to avoid tuning knobs but I think exposing the headroom
> configuration to users might not be a bad idea. After all these same users are
> already programming maps and ebpf codes. A simple tuning knob should not be a
> big deal and reasonable defaults would of course be used. That is a net-next
> debate though.

No arguments from my side here.

> > 
> > Consider our options for 4.11.
> > 
> 
> Finally just to point out here are the drivers with XDP support on latest
> net tree,
> 
> 	mlx/mlx5
> 	mlx/mlx4
> 	qlogic/qede
> 	netronome/nfp
> 	virtio_net
> 
> And here is the list of adjust header support,
> 
> 	mlx/mlx4

Above seems to imply an interface for userspace to detect the amount
of head space would be benefitial.

> 
> So we currently have the same feature gap on all the other drivers except one.
> Although I do not think that is a very good excuse. Lets figure out what we
> should do about virtio.
> 
> Thanks,
> John

If we can simply defer adjust_head patches to 4.11 then that's fine.

-- 
MST
