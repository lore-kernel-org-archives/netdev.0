From: Dan Williams <dcbw@redhat.com>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Mon, 22 Oct 2007 11:57:25 -0400
Message-ID: <1193068645.30205.22.camel@localhost.localdomain>
References: <20071022005857.GA6317@nineveh.local>  <471C6BEC.4010604@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530AbXJVP6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:58:48 -0400
In-Reply-To: <471C6BEC.4010604@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-22 at 13:22 +0400, Denis V. Lunev wrote:
> We have spent some time with the problem with Alexey and there are no 
> guesses for now.
> 
> Is it possible to name exact version of Network Manager and all 
> libraries related + provide us an output of strace with full buffers 
> send/received from netlink. Something like
>      strace -v -x -s 32768 <nm>

NM uses netlink in two places; libnl (from Thomas Graf) and some custom
code for listening for interface up/down events and wireless events.

It looks like that code comes from libnl's lib/handlers.c where it
thinks the received message is invalid.

I'm pretty sure the code that checks carrier status of the device isn't
libnl code; so maybe the error message (which should get fixed of
course) isn't in the same path as the link detection.

The link detection comes from src/nm-netlink-monitor.c, so maybe we
should look at debugging there.

Dan

> Regards,
> 	Den
> 
> Joseph Fannin wrote:
> > Network Manager (the freedesktop.org one) fails to work with Linus's
> > current git on a couple of different boxes I have here.  All the boxes
> > have different NIC types, with different drivers.
> > 
> > I've bisected it down to cd40b7d3983c708aabe3d3008ec64ffce56d33b0 ,
> > "[NET]: make netlink user -> kernel interface synchronious".  I've
> > double checked this by testing the kernel as of the immediately
> > previous commit; Network Manager works with that one, as it did on all
> > my machines in 2.6.23-mm1.
> > 
> > The netlink change seems to confuse N-M, and it somehow decides that
> > there's no link beat, so doesn't try to bring up the interface.  If I
> > run "ifconfig eth0 up", N-M will decide there's a carrier after all
> > and takes over.  Ethtool detects the link state correctly even with
> > the interface down.
> > 
> > If I down the interface again with ifconfig, N-M brings it right back
> > up without a problem, but if I kill N-M, it'll down the interface
> > before it exits, and fail in the same way as before when restarted.
> > 
> > N-M also emits this error:
> > 
> > "-- Error: Invalid message: type=DONE length=20 flags=<MULTI> sequence-nr=1193012574 pid=1185943630"
> > 
> > ...which it doesn't do on kernels where it works normally.
> > strace'ing NetworkManager shows that it prints that message just after
> > talking over a netlink socket.
> > 
> > Networking otherwise works fine here with the latest git and N-M, if I
> > use the ifconfig "trick" to get the link up.
> > 
> > --
> > Joseph Fannin
> > jfannin@gmail.com
> > 
> > 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

