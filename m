From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Tue, 6 Jul 2004 23:29:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707032913.GA1822@havoc.gtf.org>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com> <1089170282.1038.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1089170282.1038.80.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2004 at 11:18:02PM -0400, jamal wrote:
> You dont return a 1 anywhere.

That OK in one model.


> Heres what i mean (substitute your code):
> if no more descriptors
> netif_stop_queue(dev)
> unlock
> return 1
> process packet and stash on ring
> return 0

When you are not dealing with fragments, the most optimal model
eliminates the overflow case completely, so your ->hard_start_xmit looks
like

	lock
	queue packet to DMA ring
	if (DMA ring full)
		netif_stop_queue()
	unlock

	return 0

If you can be sure -- by design -- that room is always available when
the queue is not stopped, then that's fine.

With fragments, you cannot be sure of this, if you do not wish to
reserve MY_HW_MAX_FRAGMENTS slots on the DMA.  Such a case would require
moving the "if no more descriptors" check up, and returning 1 when the
ring is empty.

But ideally, you should write the driver where such a condition does not
occur at all.

	Jeff
