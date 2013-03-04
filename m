From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 23:24:23 -0500
Message-ID: <1362371063.3221.185.camel@thor.lan>
References: <1362355465.3221.82.camel@thor.lan>
	 <20130303.193313.408641189137321065.davem@davemloft.net>
	 <1362359178.3221.118.camel@thor.lan>
	 <20130303.213601.1201168888595187293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, samuel@sortiz.org,
	gregkh@linuxfoundation.org, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130303.213601.1201168888595187293.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-03-03 at 21:36 -0500, David Miller wrote:
> From: Peter Hurley <peter@hurleysoftware.com>
> Date: Sun, 03 Mar 2013 20:06:18 -0500
> 
> > But regardless, this function __cannot__ sleep holding the tty_lock().
> 
> So drop it across the schedule(), but recheck the termios after
> regrabbing it.

I'll have to do some research on that.

1) The code is using a deliberate snapshot.

	if (tty->termios.c_cflag & CLOCAL) {
		IRDA_DEBUG(1, "%s(), doing CLOCAL!\n", __func__ );
		do_clocal = 1;
	}

	.....

	while (1) {

		.........

		/*
		 * Check if link is ready now. Even if CLOCAL is
		 * specified, we cannot return before the IrCOMM link is
		 * ready
		 */
		if (!test_bit(ASYNCB_CLOSING, &port->flags) &&
		    (do_clocal || tty_port_carrier_raised(port)) &&
		    self->state == IRCOMM_TTY_READY)
		{
			break;
		}


2) The only reason this driver isn't using tty_port_block_til_ready() is
the lone state check:
		    self->state == IRCOMM_TTY_READY

I take it IRDA has some kind of virtual cabling protocol. But it's
unclear why this can't be implemented in the driver without duplicating
tty_port_block_til_ready(). For example, if the device can't do CLOCAL
open (meaning no underlying device attached prior to open) then why
specify that in the driver flags? Additionally, CLOCAL can be masked out
by the driver's set_termios() method. And then it could implement the
state check in its .carrier_raised() method.

3) The do_clocal snapshot is universally employed by every tty driver. I
don't mean that as some kind of lame excuse. But if this should change,
it should change across every tty driver with a really good reason.

4) Rechecking termios will change the way the user-space open() for this
device behaves. And I need to think more on how that might or might not
be a problem.

5) The code behavior pre-dates the 2005 check-in so I'll probably have
to do some code archaeology.


That's probably going to take some time.

In the meantime, while reviewing that code, I noticed there's a handful
of serious bugs in that one function that I'll send a patchset for.

Plus, someone could be back to me on if and why the driver needs to be
virtually cabled to open().

Regards,
Peter Hurley
