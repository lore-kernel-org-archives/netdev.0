From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution
	statistics through ethtool
Date: Tue, 21 May 2013 11:35:15 +0300
Message-ID: <20130521083515.GA27391@redhat.com>
References: <1368735869-31076-1-git-send-email-sriram.narasimhan@hp.com>
	<20130519112800.GG19883@redhat.com>
	<228BD1969E90E94D8805535E22CE8EFF063CF133@G9W0717.americas.hpqcorp.net>
	<20130519200320.GA27407@redhat.com>
	<228BD1969E90E94D8805535E22CE8EFF063CF195@G9W0717.americas.hpqcorp.net>
	<20130520095900.GB8206@redhat.com>
	<228BD1969E90E94D8805535E22CE8EFF063D1429@G4W3207.americas.hpqcorp.net>
	<519B0200.90701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <519B0200.90701@redhat.com>
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

On Tue, May 21, 2013 at 01:11:28PM +0800, Jason Wang wrote:
> On 05/21/2013 09:26 AM, Narasimhan, Sriram wrote:
> >
> > -----Original Message-----
> > From: Michael S. Tsirkin [mailto:mst@redhat.com] 
> > Sent: Monday, May 20, 2013 2:59 AM
> > To: Narasimhan, Sriram
> > Cc: rusty@rustcorp.com.au; virtualization@lists.linux-foundation.org; kvm@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jason Wang
> > Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution statistics through ethtool
> >
> > On Sun, May 19, 2013 at 10:56:16PM +0000, Narasimhan, Sriram wrote:
> >> Hi Michael,
> >>
> >> Comments inline...
> >>
> >> -----Original Message-----
> >> From: Michael S. Tsirkin [mailto:mst@redhat.com] 
> >> Sent: Sunday, May 19, 2013 1:03 PM
> >> To: Narasimhan, Sriram
> >> Cc: rusty@rustcorp.com.au; virtualization@lists.linux-foundation.org; kvm@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jason Wang
> >> Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution statistics through ethtool
> >>
> >> On Sun, May 19, 2013 at 04:09:48PM +0000, Narasimhan, Sriram wrote:
> >>> Hi Michael,
> >>>
> >>> I was getting all packets on the same inbound queue which
> >>> is why I added this support to virtio-net (and some more
> >>> instrumentation at tun as well).  But, it turned out to be
> >>> my misconfiguration - I did not enable IFF_MULTI_QUEUE on
> >>> the tap device, so the real_num_tx_queues on tap netdev was 
> >>> always 1 (no tx distribution at tap).
> >> Interesting that qemu didn't fail.
> >>
> >> [Sriram] void tun_set_real_num_tx_queues() does not return 
> >> the EINVAL return from netif_set_real_num_tx_queues() for 
> >> txq > dev->num_tx_queues (which would be the case if the
> >> tap device were not created with IFF_MULTI_QUEUE).  I think
> >> it would be better to fix the code to disable the new 
> >> queue and fail tun_attach()
> > You mean fail TUNSETQUEUE?
> >
> > [Sriram] No I meant TUNSETIFF. FYI, I am using QEMU 1.4.50.
> > I created the tap device using tunctl.  This does not
> > specify the IFF_MULTI_QUEUE flag during create so 1 netdev
> > queue is allocated.  But, when the tun device is closed,
> > tun_detach decrements tun->numqueues from 1 to 0.
> >
> > The following were the options I passed to qemu: 
> > -netdev tap,id=hostnet1,vhost=on,ifname=tap1,queues=4 
> > -device virtio-net-pci,netdev=hostnet1,id=net1,
> > mac=52:54:00:9b:8e:24,mq=on,vectors=9,ctrl_vq=on
> >
> >
> >> in this scenario.  If you 
> >> agree, I can go ahead and create a separate patch for that.
> > Hmm I not sure I understand what happens, so hard for me to tell.
> >
> > I think this code was supposed to handle it:
> >         err = -EBUSY;
> >         if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
> >                 goto out;
> >
> > why doesn't it?
> >
> > [Sriram] This question was raised by Jason as well.
> > When QEMU is started with multiple queues on the tap 
> > device, it calls TUNSETIFF on the existing tap device with 
> > IFF_MULTI_QUEUE set.  The above code falls through since 
> > tun->numqueues = 0 due to the previous tun_detach() during 
> > close. At the end of this, tun_set_iff() sets TUN_TAP_MQ
> > flag for the tun data structure.  From that point onwards,
> > subsequent TUNSETIFF will fall through resulting in the
> > mismatch in #queues between tun and netdev structures. 
> >
> 
> Thanks, I think I get it. The problem is we only allocate a one queue
> netdevice when IFF_MULTI_QUEUE were not set. So reset the multiqueue
> flag for persist device should be forbidden. Looks like we need the
> following patch. Could you please test this?
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index f042b03..d4fc2bd 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1585,6 +1585,10 @@ static int tun_set_iff(struct net *net, struct
> file *file, struct ifreq *ifr)
>                 else
>                         return -EINVAL;
>  
> +               if (((ifr->ifr_flags & IFF_MULTI_QUEUE) ==
> IFF_MULTI_QUEUE) ^
> +                   ((tun->flags & TUN_TAP_MQ) == TUN_TAP_MQ))
> +                       return -EINVAL;
> +
>                 if (tun_not_capable(tun))
>                         return -EPERM;
>                 err = security_tun_dev_open(tun->security);

That's too complex I think. Let's convert to bool, like this:

/* Make sure we don't change IFF_MULTI_QUEUE flag */
if (!!(ifr->ifr_flags & IFF_MULTI_QUEUE) != !!(tun->flags & TUN_TAP_MQ))
                       return -EINVAL;


You'll want to mention it's a stable candidate when you post this
but I think you are not supposed to copy stable - davem does this himself. 

-- 
MST
