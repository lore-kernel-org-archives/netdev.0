From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: N_PPP_SYNC ldisc BUG: sleeping function called from invalid
 context
Date: Wed, 30 Sep 2009 17:47:04 +0100
Message-ID: <20090930174704.796b24b9@lxorguk.ukuu.org.uk>
References: <4AC37032.4030901@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35205 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754344AbZI3Qpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 12:45:46 -0400
In-Reply-To: <4AC37032.4030901@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  [<c026d39b>] tty_unthrottle+0x10/0x38
>  [<f8dcc31f>] ppp_sync_receive+0x168/0x170 [ppp_synctty]
>  [<f8fbb9ce>] handle_minor_recv+0x187/0x1cd [capi]
>  [<f8fbc19b>] capi_recv_message+0x1d9/0x24e [capi]

Really need to see the rest of the call trace to be sure

> Turns out the ppp_sync_receive() function (drivers/net/ppp_synctty.c
> line 385ff.) has a comment in front stating:
> 
> /*
>  * This can now be called from hard interrupt level as well
>  * as soft interrupt level or mainline.
>  */

Which is wrong. The flip_buffer_push -> rx processing path should never
be called from IRQ context and that was fixed for various drivers that
mis-set tty->low_latency, as well as in the PPP rework. The PPP case is
actually unrelated in many was.

> Opinions?

See how we got into that code direct from an IRQ path. The expectation of
the tty logic is that it gets processed from work queues either
specifically in driver or via tty_flip_buffer_push when tty->low_latency
= 0
