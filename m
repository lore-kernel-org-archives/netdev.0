From: Anders =?iso-8859-1?Q?Grafstr=F6m?=
	<grfstrm@users.sourceforge.net>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Thu, 26 Oct 2006 01:36:26 +0200 (CEST)
Message-ID: <3699.82.182.159.28.1161819386.squirrel@webmail.sys.kth.se>
References: <453F9D4A.8090306@users.sourceforge.net>
    <20061025185656.GA19037@electric-eye.fr.zoreil.com>
    <453FC693.10705@intel.com> <453FD677.7060405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.kth.se ([130.237.48.97]:15274 "EHLO mx3.kth.se")
	by vger.kernel.org with ESMTP id S1751116AbWJYXg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 19:36:29 -0400
In-Reply-To: <453FD677.7060405@intel.com>
To: "Auke Kok" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Allthough the spec itself didn't talk about phy reset times, I've ran this
> patch with
> some debugging output on a few boxes and did some speed/duplex settings,
> and the PHY
> reset returned succesfull after the very first mdio_read, which is before
> any msleep(10)
> is executed. That is also expected behaviour.
>
> I think you might be confusing this with a MAC reset, which has a
> documented 10usec
> timeout (see 8255x developers manual). The driver already adheres to this
> by doing a
> 20usec delay after software/selective resets.
>
> which gets us back to the original problem: how did your driver end up in
> loopback mode?
> (and, how did you figure out that it did??).


This is what the 2.4.33.3 driver does:

void
e100_phy_reset(struct e100_private *bdp)
{
        u16 ctrl_reg;
        ctrl_reg = BMCR_RESET;
        e100_mdi_write(bdp, MII_BMCR, bdp->phy_addr, ctrl_reg);
        /* ieee 802.3 : The reset process shall be completed       */
        /* within 0.5 seconds from the settting of PHY reset bit.  */
        set_current_state(TASK_UNINTERRUPTIBLE);
        schedule_timeout(HZ / 2);
}

And here
http://www.cs.helsinki.fi/linux/linux-kernel/2003-23/1245.html
I found this entry:

<scott.feldman@intel.com> (03/06/08 1.1218)
[e100] misc
<...>
* Add 1/2 second delay after PHY reset to allow link partner to
see and respond to reset, per IEEE 802.3.


I ran mii-diag when the LEDs went out and the register dump
said it was in loopback. It is somewhat difficult reproduce.
It seems to be timing dependent, something else has to occur
at the same time.
I must confess I have only seen it with the 2.6.13 kernel.
I have not been able to reproduce it with 2.6.18.
But I have found no change in the driver that would fix it so
I suspect the problem is still there.

I have tried adding debug output to see if I can read back the
RESET bit in set state, but then the problem refuses to show
so I don't think I can rule out an unfinished PHY reset.

Anders


