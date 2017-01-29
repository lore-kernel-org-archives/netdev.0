From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [BUG/RFC] vhost: net: big endian viring access despite virtio 1
Date: Sun, 29 Jan 2017 02:35:08 +0200
Message-ID: <20170129023459-mutt-send-email-mst@kernel.org>
References: <a08f491a-1320-607e-f450-d32ce2c9e2f5@linux.vnet.ibm.com>
	<20170126211511-mutt-send-email-mst@kernel.org>
	<f5c0779f-f7b0-0e0c-5f20-4161b5c70394@linux.vnet.ibm.com>
	<20170127143747.1313d9ee@bahia.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Greg Kurz <groug@kaod.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170127143747.1313d9ee@bahia.lan>
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

On Fri, Jan 27, 2017 at 02:37:47PM +0100, Greg Kurz wrote:
> On Fri, 27 Jan 2017 13:24:13 +0100
> Halil Pasic <pasic@linux.vnet.ibm.com> wrote:
> 
> > On 01/26/2017 08:20 PM, Michael S. Tsirkin wrote:
> > > On Thu, Jan 26, 2017 at 06:39:14PM +0100, Halil Pasic wrote:  
> > >>
> > >> Hi!
> > >>
> > >> Recently I have been investigating some strange migration problems on
> > >> s390x.
> > >>
> > >> It turned out under certain circumstances vhost_net corrupts avail.idx by
> > >> using wrong endianness.  
> > 
> > [..]
> > 
> > >> -------------------------8<--------------  
> > >> >From b26e2bbdc03832a0204ee2b42967a1b49a277dc8 Mon Sep 17 00:00:00 2001  
> > >> From: Halil Pasic <pasic@linux.vnet.ibm.com>
> > >> Date: Thu, 26 Jan 2017 00:06:15 +0100
> > >> Subject: [PATCH] vhost: remove useless/dangerous reset of is_le
> > >>
> > >> The reset of is_le does no good, but it contributes its fair share to a
> > >> bug in vhost_net, which occurs if we have some oldubufs when stopping and
> > >> setting a fd = -1 as a backend. Instead of doing something convoluted in
> > >> vhost_net, let's just get rid of the reset.
> > >>
> > >> Signed-off-by: Halil Pasic <pasic@linux.vnet.ibm.com>
> > >> Fixes: commit 2751c9882b94 
> > >> ---
> > >>  drivers/vhost/vhost.c | 4 +---
> > >>  1 file changed, 1 insertion(+), 3 deletions(-)
> > >>
> > >> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > >> index d643260..08072a2 100644
> > >> --- a/drivers/vhost/vhost.c
> > >> +++ b/drivers/vhost/vhost.c
> > >> @@ -1714,10 +1714,8 @@ int vhost_vq_init_access(struct vhost_virtqueue *vq)
> > >>         int r;
> > >>         bool is_le = vq->is_le;
> > >>
> > >> -       if (!vq->private_data) {
> > >> -               vhost_reset_is_le(vq);
> > >> +       if (!vq->private_data)
> > >>                 return 0;
> > >> -       }
> > >>
> > >>         vhost_init_is_le(vq);  
> > > 
> > > 
> > > I think you do need to reset it, just maybe within vhost_init_is_le.
> > > 
> > >         if (vhost_has_feature(vq, VIRTIO_F_VERSION_1))
> > >                 vq->is_le = true;
> > > 	else
> > > 		vhost_reset_is_le(vq);
> > > 
> > >   
> > 
> > That is a very good point! I have overlooked that while the 
> > CONFIG_VHOST_CROSS_ENDIAN_LEGACY variant
> > 
> > static void vhost_init_is_le(struct vhost_virtqueue *vq)
> > {
> >         /* Note for legacy virtio: user_be is initialized at reset time
> >          * according to the host endianness. If userspace does not set an
> >          * explicit endianness, the default behavior is native endian, as
> >          * expected by legacy virtio.
> >          */
> >         vq->is_le = vhost_has_feature(vq, VIRTIO_F_VERSION_1) || !vq->user_be;
> > }
> > 
> > is fine the other variant 
> > 
> > static void vhost_init_is_le(struct vhost_virtqueue *vq)
> > {
> >         if (vhost_has_feature(vq, VIRTIO_F_VERSION_1))
> >                 vq->is_le = true;
> > }
> > is a very strange initializer (makes assumptions about the state
> > to be initialized).
> > 
> > I agree, setting native endianness there sounds very reasonable.
> > 
> > I have a question regarding readability. IMHO the relationship
> > of reset_is_le and int_is_le is a bit confusing, and I'm afraid
> > it could become even more confusing with using reset in one of
> > the init_is_le's.
> > 
> > How about we do the following?
> > 
> > static void vhost_init_is_le(struct vhost_virtqueue *vq)
> > {
> >         if (vhost_has_feature(vq, VIRTIO_F_VERSION_1))
> >                 vq->is_le = true;
> > +       else
> > +               vq->is_le = virtio_legacy_is_little_endian();
> > 
> > }
> > 
> > static void vhost_reset_is_le(struct vhost_virtqueue *vq)
> > {
> > -       vq->is_le = virtio_legacy_is_little_endian();
> > +       vhost_init_is_le(vq);
> > }
> > 
> > That way we would have correct endianness both after reset
> > and after init, I think :).
> > 
> 
> Yes, I think this is what we need.
> 
> Cheers.

OK, pls test this patch.

> --
> Greg
> 
> > Thank you very much!
> > 
> > Halil
> > 
> > 
