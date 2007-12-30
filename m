From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Sun, 30 Dec 2007 01:15:00 +0000
Message-ID: <20071230011500.GA30997@nuim.ie>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie>
 <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net>
 <20071221133106.GA7995@nuim.ie>
 <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:48924 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750782AbXL3BO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2007 20:14:56 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTU005RE8ST3310@mango.nuim.ie> for
 netdev@vger.kernel.org; Sun, 30 Dec 2007 01:14:53 +0000 (GMT)
In-reply-to: <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 21 Dec 2007, Ilpo J=E4rvinen wrote:

> > I need to re-read properly, but I think the same problem affects th=
e
> > microsecond values where TCP_CONG_RTT_STAMP is set (used by vegas, =
veno,
> > yeah, illinois).  I might follow up with another patch which change=
s the
> > behaviour where TCP_CONG_RTT_STAMP when I'm more sure of that.
>
> Please do, you might have to remove fully_acked checks to do that rig=
ht=20
> though so it won't be as straight-forward change as this one and requ=
ires=20
> some amount of thinking to result in a right thing.

The TCP_CONG_RTT_STAMP code does need to be fixed similarly.  A combine=
d
patch will follow this mail.  As I understand it, the fully_acked check=
s
kick in where the ACK is a portion of a TSO chunk and doesn't completel=
y
ACK that chunk.  Leaving the checks in place means you get one rtt for =
each
TSO chunk, based on the ACK for the last byte of the chunk.  This rtt
therefore is the maximum available and includes the time-lag between th=
e
first and last chunk being acked.  Removing the tests gives you an RTT
value for each ACK in a tso chunk, including the minimum and maximum.  =
It
seems the minimum rtt is the best indicator of congestion.  On the othe=
r
hand having all available RTTs gives the congestion avoidance greater
knowledge of how the RTT is evolving (albeit somewhat coloured by TSO
delays which don't seem too severe in my tests).

The patch I'll suggest for now takes all RTT values available, rather t=
han
the old maximum or adding extra logic to pluck out the minimum.

I've captured some rtt values from timestamps and from
tcp_clean_rtx_queue() to demonstrate the effect of this patch:

http://www.hamilton.ie/gavinmc/linux/tcp_clean_rtx_queue.html#usec

As always, comments are most welcome,

Gavin

