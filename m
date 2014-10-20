From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v4 13/25] virtio_console: enable VQs early
Date: Mon, 20 Oct 2014 14:42:23 +0200
Message-ID: <20141020144223.5655dcbc.cornelia.huck@de.ibm.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
	<1413114332-626-14-git-send-email-mst-v4@redhat.com>
	<20141020120750.GA18561@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>, Paolo Bonzini <pbonzini@redhat.com>,
	Amit Shah <amit.shah@redhat.com>, v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141020120750.GA18561@casper.infradead.org>
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

On Mon, 20 Oct 2014 13:07:50 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> On 10/13/14 at 10:50am, Michael S. Tsirkin wrote:
> > virtio spec requires drivers to set DRIVER_OK before using VQs.
> > This is set automatically after probe returns, virtio console violated this
> > rule by adding inbufs, which causes the VQ to be used directly within
> > probe.
> > 
> > To fix, call virtio_device_ready before using VQs.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/char/virtio_console.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
> > index b585b47..6ebe8f6 100644
> > --- a/drivers/char/virtio_console.c
> > +++ b/drivers/char/virtio_console.c
> > @@ -1449,6 +1449,8 @@ static int add_port(struct ports_device *portdev, u32 id)
> >  	spin_lock_init(&port->outvq_lock);
> >  	init_waitqueue_head(&port->waitqueue);
> >  
> > +	virtio_device_ready(portdev->vdev);
> > +
> >  	/* Fill the in_vq with buffers so the host can send us data. */
> >  	nr_added_bufs = fill_queue(port->in_vq, &port->inbuf_lock);
> >  	if (!nr_added_bufs) {
> 
> Seems like probe and add_port() now both set VIRTIO_CONFIG_S_DRIVER_OK

I think we need to set this in the probe function instead, otherwise we
fail for multiqueue (which also wants to use the control queue early).

Completely untested patch below; I can send this with proper s-o-b if
it helps.

diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index bfa6400..cf7a561 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -1449,8 +1449,6 @@ static int add_port(struct ports_device *portdev, u32 id)
 	spin_lock_init(&port->outvq_lock);
 	init_waitqueue_head(&port->waitqueue);
 
-	virtio_device_ready(portdev->vdev);
-
 	/* Fill the in_vq with buffers so the host can send us data. */
 	nr_added_bufs = fill_queue(port->in_vq, &port->inbuf_lock);
 	if (!nr_added_bufs) {
@@ -2026,6 +2024,8 @@ static int virtcons_probe(struct virtio_device *vdev)
 	spin_lock_init(&portdev->ports_lock);
 	INIT_LIST_HEAD(&portdev->ports);
 
+	virtio_device_ready(portdev->vdev);
+
 	if (multiport) {
 		unsigned int nr_added_bufs;
