From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Tue, 27 Mar 2012 01:17:07 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD1257E@TK5EX14MBXC222.redmond.corp.microsoft.com>
References: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
 <1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
 <20120326231017.GA30684@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:2878 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751828Ab2C0BRf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 21:17:35 -0400
In-Reply-To: <20120326231017.GA30684@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Monday, March 26, 2012 7:10 PM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
> watermark
> 
> On Mon, Mar 26, 2012 at 03:18:24PM -0700, Haiyang Zhang wrote:
> > In the existing code, we only stop queue when the ringbuffer is full,
> > so the current packet has to be dropped or retried from upper layer.
> >
> > This patch stops the tx queue when available ringbuffer is below the
> > low watermark. So the ringbuffer still has small amount of space
> > available for the current packet. This will reduce the overhead of
> > retries on sending.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/hv/ring_buffer.c        |   15 +++++++++++++++
> >  drivers/net/hyperv/hyperv_net.h |    3 +++
> >  drivers/net/hyperv/netvsc.c     |   23 +++++++++++++++++++----
> >  drivers/net/hyperv/netvsc_drv.c |   16 +++++++++++++++-
> >  include/linux/hyperv.h          |    3 +++
> >  5 files changed, 55 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c index
> > 8af25a0..8cc3f63 100644
> > --- a/drivers/hv/ring_buffer.c
> > +++ b/drivers/hv/ring_buffer.c
> > @@ -23,6 +23,7 @@
> >   */
> >  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >
> > +#include <linux/module.h>
> >  #include <linux/kernel.h>
> >  #include <linux/mm.h>
> >  #include <linux/hyperv.h>
> > @@ -160,6 +161,20 @@ hv_get_ring_buffersize(struct
> hv_ring_buffer_info
> > *ring_info)  }
> >
> >  /*
> > + * Get the percentage of available bytes to write in the ring.
> > + * The return value is in range from 0 to 100.
> > + */
> > +u32 hv_ringbuf_avail_percent(struct hv_ring_buffer_info *ring_info) {
> > +	u32 avail_read, avail_write;
> > +
> > +	hv_get_ringbuffer_availbytes(ring_info, &avail_read, &avail_write);
> > +
> > +	return avail_write * 100 / hv_get_ring_buffersize(ring_info);
> > +}
> > +EXPORT_SYMBOL(hv_ringbuf_avail_percent);
> 
> That makes no sense, what happens 1 second later to the buffer?  You can't
> expect this result to be valid anymore, right?

It's not necessary to be very precise for the flow control, just a rough 
estimate on how full the buffer is enough. We only want to keep a small
amount of buffer to be available, so the outgoing packets don't need to
be retried.

> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -51,6 +51,16 @@ static int ring_size = 128;
> > module_param(ring_size, int, S_IRUGO);  MODULE_PARM_DESC(ring_size,
> > "Ring buffer size (# of pages)");
> >
> > +uint ring_avail_percent_hiwater = 20;
> > +module_param(ring_avail_percent_hiwater, uint, S_IRUGO | S_IWUSR);
> > +MODULE_PARM_DESC(ring_avail_percent_hiwater,
> > +	"Ring buffer available percentiles to wake up xmit queue");
> > +
> > +uint ring_avail_percent_lowater = 10;
> > +module_param(ring_avail_percent_lowater, uint, S_IRUGO | S_IWUSR);
> > +MODULE_PARM_DESC(ring_avail_percent_lowater,
> > +	"Ring buffer available percentiles to stop xmit queue");
> 
> Eeek, no, how in the world is someone supposed to know to set these things?
> 
> Please make this work "automatically", otherwise no one will ever get it right.
> Don't make it tunable as a way out of making a decision on how the driver
> should work.

I will remove the tunables. The default values here work fine in our tests.

Thanks,
- Haiyang
