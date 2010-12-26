From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH v2] Broadcom CNIC core network driver: fix mem leak on
 allocation failures in cnic_alloc_uio_rings()
Date: Sun, 26 Dec 2010 21:57:39 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012262154420.20797@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net> <1293396850.7726.14.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John(Zongxi) Chen" <zongxi@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293396850.7726.14.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 26 Dec 2010, Joe Perches wrote:

> On Sun, 2010-12-26 at 21:30 +0100, Jesper Juhl wrote:
> > We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if 
> > either of the calls to dma_alloc_coherent() fail.
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> >  cnic.c |   10 ++++++++--
> > diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> []
> > -	if (!udev->l2_ring)
> > +	if (!udev->l2_ring) {
> > +		kfree(udev);
> >  		return -ENOMEM;
> > +	}
> []
> > -	if (!udev->l2_buf)
> > +	if (!udev->l2_buf) {
> > +		dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
> > +				  udev->l2_ring, udev->l2_ring_map);
> > +		kfree(udev);
> >  		return -ENOMEM;
> > +	}
> 
> Perhaps this would be more standard with a goto error / exit block
> 
> err_dma:
> 	dma_free_coherent();
> err_udev:
> 	kfree(udev);
> 	return -ENOMEM;
> 

I have no problem with that. It's functionally the same, but the object 
file size is smaller and, as you say, it's more standard. Good point, 
thanks.


We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if 
either of the calls to dma_alloc_coherent() fail. This patch fixes it by 
freeing both the memory allocated with kzalloc() and memory allocated with 
previous calls to dma_alloc_coherent() when there's a failure.

Thanks to  Joe Perches <joe@perches.com>  for suggesting a better 
implementation than my initial version.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 cnic.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

  compile tested only since I don't have the hardware to do a proper test.

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 92bac19..952afac 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -940,7 +940,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 					   &udev->l2_ring_map,
 					   GFP_KERNEL | __GFP_COMP);
 	if (!udev->l2_ring)
-		return -ENOMEM;
+		goto err_udev;
 
 	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
 	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
@@ -948,7 +948,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 					  &udev->l2_buf_map,
 					  GFP_KERNEL | __GFP_COMP);
 	if (!udev->l2_buf)
-		return -ENOMEM;
+		goto err_dma;
 
 	write_lock(&cnic_dev_lock);
 	list_add(&udev->list, &cnic_udev_list);
@@ -959,6 +959,12 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	cp->udev = udev;
 
 	return 0;
+ err_dma:
+	dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
+       			  udev->l2_ring, udev->l2_ring_map);
+ err_udev:
+	kfree(udev);
+	return -ENOMEM;
 }
 
 static int cnic_init_uio(struct cnic_dev *dev)



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
