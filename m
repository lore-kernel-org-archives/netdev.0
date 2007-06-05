From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bugfix GFP_KERNEL -> GFP_ATOMIC in
	spin_locked region
Date: Mon, 4 Jun 2007 21:00:18 -0700
Message-ID: <20070604210018.0eaa20a0.akpm@linux-foundation.org>
References: <87odjvu1on.fsf@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sumant Patro <sumant.patro@lsi.com>,
	linux-usb-devel@lists.sourceforge.net, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@lists.osdl.org, Seokmann Ju <seokmann.ju@lsil.com>
To: Yoann Padioleau <padator@wanadoo.fr>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87odjvu1on.fsf@wanadoo.fr>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2007 18:25:28 +0200 Yoann Padioleau <padator@wanadoo.fr> wrote:

> 
> In a few files a function such as usb_submit_urb is taking GFP_KERNEL
> as an argument whereas this function call is inside a
> spin_lock_irqsave region of code. Documentation says that it must be
> GFP_ATOMIC instead.
> 
> Me and my colleagues have made a tool targeting program
> transformations in device drivers. We have designed a scripting
> language for specifying easily program transformations and a
> transformation engine for performing them. In the spirit of Linux
> development practice, the language is based on the patch syntax. We
> call our scripts "semantic patches" because as opposed to traditional
> patches, our semantic patches do not work at the line level but on a
> high level representation of the C program.
> 
> FYI here is our semantic patch detecting invalid use of GFP_KERNEL and
> fixing the problem:
> 
> @@
> identifier fn;
> @@
> 
>  spin_lock_irqsave(...)
>  ... when != spin_unlock_irqrestore(...)
>  fn(...,
> - GFP_KERNEL
> + GFP_ATOMIC
>    ,...
>    )

I think I read that paper.

> And now the real patch resulting from the automated transformation:
> 
>  net/wan/lmc/lmc_main.c        |    2 +-
>  scsi/megaraid/megaraid_mm.c   |    2 +-
>  usb/serial/io_ti.c            |    2 +-
>  usb/serial/ti_usb_3410_5052.c |    2 +-
>  usb/serial/whiteheat.c        |    6 +++---
>  5 files changed, 7 insertions(+), 7 deletions(-)

This patch covers three areas of maintainer responsibility, so poor old me
has to split it up and redo the changelogs.  Oh well.

> 
> diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
> index ae132c1..750b3ef 100644
> --- a/drivers/net/wan/lmc/lmc_main.c
> +++ b/drivers/net/wan/lmc/lmc_main.c
> @@ -483,7 +483,7 @@ #endif /* end ifdef _DBG_EVENTLOG */
>                              break;
>                      }
>  
> -                    data = kmalloc(xc.len, GFP_KERNEL);
> +                    data = kmalloc(xc.len, GFP_ATOMIC);
>                      if(data == 0x0){
>                              printk(KERN_WARNING "%s: Failed to allocate memory for copy\n", dev->name);
>                              ret = -ENOMEM;

A few lines later we do:

	if(copy_from_user(data, xc.data, xc.len))

which also is illegal under spinlock.


Frankly, I think that a better use of this tool would be to just report on
the errors, let humans fix them up.

Nobody maintains this ATM code afaik.

> index e075a52..edee220 100644
> --- a/drivers/scsi/megaraid/megaraid_mm.c
> +++ b/drivers/scsi/megaraid/megaraid_mm.c
> @@ -547,7 +547,7 @@ mraid_mm_attach_buf(mraid_mmadp_t *adp, 
>  
>  	kioc->pool_index	= right_pool;
>  	kioc->free_buf		= 1;
> -	kioc->buf_vaddr 	= pci_pool_alloc(pool->handle, GFP_KERNEL,
> +	kioc->buf_vaddr 	= pci_pool_alloc(pool->handle, GFP_ATOMIC,
>  							&kioc->buf_paddr);
>  	spin_unlock_irqrestore(&pool->lock, flags);

Again, a better fix would probably be to move the pci_pool_alloc() to
before the spin_lock_irqsave(), so we can continue to use the stronger
GFP_KERNEL.

But the locking in there looks basically nonsensical or wrong anyway.  It
appears that local variable `right_pool' cannot be validly used unless
we're holding pool->lock for the whole duration.

Somebody does maintain the megaraid driver, but I'm not sure who, and 
the MAINTAINERS file isn't very useful.  So I'll spray it around a bit.
We definitely have bugs in there.

> diff --git a/drivers/usb/serial/io_ti.c b/drivers/usb/serial/io_ti.c
> index 544098d..9ec38e3 100644
> --- a/drivers/usb/serial/io_ti.c
> +++ b/drivers/usb/serial/io_ti.c
> @@ -2351,7 +2351,7 @@ static int restart_read(struct edgeport_
>  		urb->complete = edge_bulk_in_callback;
>  		urb->context = edge_port;
>  		urb->dev = edge_port->port->serial->dev;
> -		status = usb_submit_urb(urb, GFP_KERNEL);
> +		status = usb_submit_urb(urb, GFP_ATOMIC);
>  	}
>  	edge_port->ep_read_urb_state = EDGE_READ_URB_RUNNING;
>  	edge_port->shadow_mcr |= MCR_RTS;
> diff --git a/drivers/usb/serial/ti_usb_3410_5052.c b/drivers/usb/serial/ti_usb_3410_5052.c
> index 4203e2b..10dc36f 100644
> --- a/drivers/usb/serial/ti_usb_3410_5052.c
> +++ b/drivers/usb/serial/ti_usb_3410_5052.c
> @@ -1559,7 +1559,7 @@ static int ti_restart_read(struct ti_por
>  		urb->complete = ti_bulk_in_callback;
>  		urb->context = tport;
>  		urb->dev = tport->tp_port->serial->dev;
> -		status = usb_submit_urb(urb, GFP_KERNEL);
> +		status = usb_submit_urb(urb, GFP_ATOMIC);
>  	}
>  	tport->tp_read_urb_state = TI_READ_URB_RUNNING;
>  
> diff --git a/drivers/usb/serial/whiteheat.c b/drivers/usb/serial/whiteheat.c
> index 27c5f8f..1b01207 100644
> --- a/drivers/usb/serial/whiteheat.c
> +++ b/drivers/usb/serial/whiteheat.c
> @@ -1116,7 +1116,7 @@ static int firm_send_command (struct usb
>  	memcpy (&transfer_buffer[1], data, datasize);
>  	command_port->write_urb->transfer_buffer_length = datasize + 1;
>  	command_port->write_urb->dev = port->serial->dev;
> -	retval = usb_submit_urb (command_port->write_urb, GFP_KERNEL);
> +	retval = usb_submit_urb (command_port->write_urb, GFP_ATOMIC);
>  	if (retval) {
>  		dbg("%s - submit urb failed", __FUNCTION__);
>  		goto exit;
> @@ -1316,7 +1316,7 @@ static int start_command_port(struct usb
>  		usb_clear_halt(serial->dev, command_port->read_urb->pipe);
>  
>  		command_port->read_urb->dev = serial->dev;
> -		retval = usb_submit_urb(command_port->read_urb, GFP_KERNEL);
> +		retval = usb_submit_urb(command_port->read_urb, GFP_ATOMIC);
>  		if (retval) {
>  			err("%s - failed submitting read urb, error %d", __FUNCTION__, retval);
>  			goto exit;
> @@ -1363,7 +1363,7 @@ static int start_port_read(struct usb_se
>  		wrap = list_entry(tmp, struct whiteheat_urb_wrap, list);
>  		urb = wrap->urb;
>  		urb->dev = port->serial->dev;
> -		retval = usb_submit_urb(urb, GFP_KERNEL);
> +		retval = usb_submit_urb(urb, GFP_ATOMIC);
>  		if (retval) {
>  			list_add(tmp, &info->rx_urbs_free);
>  			list_for_each_safe(tmp, tmp2, &info->rx_urbs_submitted) {

This part might make sense so I'll queue it for the USB guys to look at.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
