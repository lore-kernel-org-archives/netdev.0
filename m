From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
	trafficon early packets
Date: Tue, 18 Dec 2007 17:54:15 +1100
Message-ID: <200712181754.16632.rusty@rustcorp.com.au>
References: <200712111242.28843.borntraeger@de.ibm.com>
	<47613277.3060403@qumranet.com>
	<200712131930.31602.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712131930.31602.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 14 December 2007 05:30:31 Christian Borntraeger wrote:
> Rusty, if you decide to apply my patch, there is one downside: The
> debugging code in virtio_ring sometimes triggers with a false positive:
>
> try_fill_recv calls vring_kick. Here we do a notify to the host. This might
> cause an immediate interrupt, triggering the poll routine before vring_kick
> can run END_USE. This is no real problem, as we dont touch the vq after
> notify.

Hmm, how about we just do something like this?  (needs previous enable_cb
patch)

> Christian, facing 64 guest cpus unconvering all kind of races

Heroic is the word which comes to mind... :)

Cheers,
Rusty.
---
virtio: flush buffers on open

Fix bug found by Christian Borntraeger: if the other side fills all
the registered network buffers before we enable NAPI, we will never
get an interrupt.  The simplest fix is to process the input queue once
on open.

Signed-off-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>

diff -r 1dd61213039c drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Tue Dec 18 17:34:18 2007 +1100
+++ b/drivers/net/virtio_net.c	Tue Dec 18 17:47:39 2007 +1100
@@ -326,6 +326,13 @@ static int virtnet_open(struct net_devic
 		return -ENOMEM;
 
 	napi_enable(&vi->napi);
+
+	/* If all buffers were filled by other side before we napi_enabled, we
+	 * won't get another interrupt, so process any outstanding packets
+	 * now.  virtnet_poll wants re-enable the queue, so we disable here. */
+	vi->rvq->vq_ops->disable_cb(vi->rvq);
+	netif_rx_schedule(vi->dev, &vi->napi);
+
 	return 0;
 }
 

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
