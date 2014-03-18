From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet OOM handling - possible CPU starvation?
Date: Tue, 18 Mar 2014 12:01:03 +0100
Message-ID: <1395140463.5069.15.camel@linux-fkkt.site>
References: <87ppljketj.fsf@nemi.mork.no>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E00AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58308 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754747AbaCRLBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 07:01:05 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E00AE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 10:29 +0000, David Laight wrote:
> From: Bj=C3=B8rn Mork

Hi,

> > To recall: The NCM and MBIM protocols aggregate packets before
> > transission over the USB link, requiring USB buffers with multiple
> > ethernet/IP packets.  Common code used by both cdc_mbim and cdc_ncm
> > currently cap the buffers at 32768 bytes (hard coded limit), which =
is
> > still too high for some embedded hosts.  This results in failures t=
o
> > allocate buffers in rx_submit (flags =3D=3D GFP_ATOMIC when it is c=
alled
> > from the URB callback):

True. We cannot rely on this working from a callback. So the correct
OOM response would happen from a delayed work queue.

> It really doesn't make much sense (to me) to transmit and receive
> aggregated packets from dynamically allocated skb.
> I'd have thought it much better to copy the ethernet frames to/from
> pre-allocated buffers.

That makes sense.

> The transmit side could have 2 buffers, and at most one active urb.
> So merges until the previous tx finishes (or 3 buffers and two
> active tx).

We had bad experiences with that scheme. It turns out that you
need to have two URBs in flight, because the time you lose waiting
for the next frame to begin is too high.
So you need at least three buffers.=20

	Regards
		Oliver
