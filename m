From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC][PATCH] usbnet: Fix tx_bytes statistic running backward in cdc_ncm
Date: Fri, 27 Feb 2015 10:12:27 +0100
Message-ID: <87h9u73eh0.fsf@nemi.mork.no>
References: <1424979823.4444.46.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	ct-linux-kernel <linux-kernel@codethink.co.uk>,
	linux-usb@vger.kernel.org, Sami Farin <hvtaifwkbgefbaei@gmail.com>,
	Aleksander Morgado <aleksander@aleksander.es>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44039 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539AbbB0JMs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 04:12:48 -0500
In-Reply-To: <1424979823.4444.46.camel@xylophone.i.decadent.org.uk> (Ben
	Hutchings's message of "Thu, 26 Feb 2015 19:43:43 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben.hutchings@codethink.co.uk> writes:

> cdc_ncm disagrees with usbnet about how much framing overhead should
> be counted in the tx_bytes statistics, and tries 'fix' this by
> decrementing tx_bytes on the transmit path.  But statistics must neve=
r
> be decremented except due to roll-over; this will thoroughly confuse
> user-space.  Also, tx_bytes is only incremented by usbnet in the
> completion path.
>
> Fix this by requiring drivers that set FLAG_MULTI_FRAME to set a
> tx_bytes delta along with the tx_packets count.
>
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
> I noticed this bug while trying to fix the tx_packets statistic in as=
ix.
> It depends on the patch I just sent for that.  I don't have any hardw=
are
> to test this with, or any need to make it work.  If you want this fix=
,
> please test and re-submit it yoursef.

I tested this on an MBIM device, and it worked perfectly as-is.  Please
submit it without the RFC prefix.  This fixes a real and reported
problem with the cdc_ncm driver, so I'd claim it's "net" material along
with a stable Cc and

=46ixes: beeecd42c3b4 ("net: cdc_ncm/cdc_mbim: adding NCM protocol stat=
istics")

But you and David decide that, of course...


=46ixing this was actually on my TODO-list after a recent report showin=
g
one of the problems with the previous hack: The decremented tx_bytes
counter was never corrected if the URB transmission failed, possibly
ending up with a negative (i.e. very large since it is unsigned)
tx_bytes counter.

Thanks a lot.  I didn't know how to do this without introducing a new
callback or something.  Your solutions is very nice, and so obvious whe=
n
I see it.  Just brilliant :-)

Tested-by: Bj=C3=B8rn Mork <bjorn@mork.no>

And you might also want (if this is OK for Sami):

Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>


Sami wrote:

> I have this USB ID 12d1:157d, Sonera Opengate LTE.
> It says all is okay but no packets are moving.
=2E.
> ifconfig
> wwp3s0u1c2: flags=3D4291<UP,BROADCAST,RUNNING,NOARP,MULTICAST>  mtu 1=
500
>         inet 46.132.188.224  netmask 255.255.255.192  broadcast 46.13=
2.188.255
>         inet6 fe80::  prefixlen 64  scopeid 0x20<link>
>         ether 32:35:3a:64:2e:25  txqueuelen 1000  (Ethernet)
>         RX packets 0  bytes 0 (0.0 B)
>         RX errors 17764  dropped 0  overruns 0  frame 0
>         TX packets 6714  bytes 18446744073709268911 (1638.3 PiB)
>         TX errors 1427  dropped 0 overruns 0  carrier 0  collisions 0
>




Bj=C3=B8rn
