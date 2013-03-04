From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 20:06:18 -0500
Message-ID: <1362359178.3221.118.camel@thor.lan>
References: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
	 <20130303.174739.1195645942179862011.davem@davemloft.net>
	 <1362355465.3221.82.camel@thor.lan>
	 <20130303.193313.408641189137321065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, samuel@sortiz.org,
	gregkh@linuxfoundation.org, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout02.c08.mtsvc.net ([205.186.168.190]:42864 "EHLO
	mailout02.c08.mtsvc.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654Ab3CDBGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 20:06:47 -0500
In-Reply-To: <20130303.193313.408641189137321065.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-03 at 19:33 -0500, David Miller wrote:
> From: Peter Hurley <peter@hurleysoftware.com>
> Date: Sun, 03 Mar 2013 19:04:25 -0500
> 
> > All these are re-tested in the loop. What state test isn't repeated?
> 
> One that rechecks the non-blocking filp flag, the
> TTY_IO_ERROR tty flag and the termios settings.
> 
> Like I said, all of the state tests performed at the beginning of
> this function, before enterring the loop.

How is O_NONBLOCK going to change? This function is sitting on the
user-space open.

The filp parameter is only on this task stack. It hasn't been linked in
anywhere else. Because of course the file isn't open yet because this
function hasn't returned success.

The TTY_IO_ERROR flag is used by drivers (this one included) to turn
away concurrent reads and writes when shutting down. The tty core does
not set this. Now this driver might set this, if commanded to hangup via
ircomm_tty_hangup, but like I said that's already handled in the loop
by testing tty_hung_up_p.

The initial termios setting cflag settings are set by the driver open().
In this driver, its here:

	driver->init_termios    = tty_std_termios;
	driver->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL | CLOCAL;


Now, it's possible that one could construct an imaginary race, where the
tty has already been opened and that task now sets the termios without
CLOCAL and meanwhile a second task is racing this termios setting with
an open() of its own, but since there is no expectation from userspace
that those operations are serialized, there's no reason to serialize
them here.

But regardless, this function __cannot__ sleep holding the tty_lock().

Regards,
Peter Hurley
