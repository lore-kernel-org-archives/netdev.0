From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Mon, 6 Jan 2014 07:26:28 -0500
Message-ID: <20140106122628.GA24280@hmsreliant.think-freely.org>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
 <52CA5CDA.1020503@gmail.com>
 <52CA612D.2000902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52CA612D.2000902@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 03:54:21PM +0800, Jason Wang wrote:
> On 01/06/2014 03:35 PM, John Fastabend wrote:
> > On 01/05/2014 07:21 PM, Jason Wang wrote:
> >> L2 fowarding offload will bypass the rx handler of real device. This
> >> will make
> >> the packet could not be forwarded to macvtap device. Another problem
> >> is the
> >> dev_hard_start_xmit() called for macvtap does not have any
> >> synchronization.
> >>
> >> Fix this by forbidding L2 forwarding for macvtap.
> >>
> >> Cc: John Fastabend <john.r.fastabend@intel.com>
> >> Cc: Neil Horman <nhorman@tuxdriver.com>
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >> ---
> >>   drivers/net/macvlan.c |    5 ++++-
> >>   1 files changed, 4 insertions(+), 1 deletions(-)
> >>
> >
> > I must be missing something.
> >
> > The lower layer device should set skb->dev to the correct macvtap
> > device on receive so that in netif_receive_skb_core() the macvtap
> > handler is hit. Skipping the macvlan receive handler should be OK
> > because the switching was done by the hardware. If I read macvtap.c
> > correctly macvlan_common_newlink() is called with 'dev' where 'dev'
> > is the macvtap device. Any idea what I'm missing? I guess I'll need
> > to setup a macvtap test case.
> 
> Unlike macvlan, macvtap depends on rx handler on the lower device to
> work. In this case macvlan_handle_frame() will call macvtap_receive().
> So doing netif_receive_skb_core() for macvtap device directly won't work
> since we need to forward the packet to userspace instead of kernel.
> 
> For net-next.git, it may work since commit
> 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 let macvtap device register an
> rx handler for itself.

I agree, this seems like it should already be fixed with the above commit.  With
this the macvlan rx handler should effectively be a no-op as far as the
reception of frames is concerned.  As long as the driver sets the dev correctly
to the macvtap device (and it appears to), macvtap will get frames to user
space, regardless of weather the software or hardware did the switching.  If
thats the case though, I think the solution is moving that fix to -stable
(pending testing of course), rather than comming up with a new fix.

> >
> > And what synchronization are you worried about on dev_hard_start_xmit()?
> > In the L2 forwarding offload case macvlan_open() clears the NETIF_F_LLTX
> > flag so HARD_TX_LOCK protects the driver txq. We might hit this warning
> > in dev_queue_xmit() though,
> >
> >   net_crit_ratelimited("Virtual device %s asks to queue packet!\n",
> >
> > Perhaps we can remove it.
> 
> The problem is macvtap does not call dev_queue_xmit() for macvlan
> device. It calls macvlan_start_xmit() directly from macvtap_get_user().
> So HARD_TX_LOCK was not done for the txq.
This seems to also be fixed by 6acf54f1cf0a6747bac9fea26f34cfc5a9029523.
Macvtap does, as of that commit use dev_queue_xmit for the transmission of
frames to the lowerdevice.

Regards
Neil
