From: Nolan Leake <nolan@cumulusnetworks.com>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Sat, 23 Oct 2010 12:39:20 -0700
Message-ID: <1287862760.7499.225.camel@voxel>
References: <4CC2DB2C.3060908@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jim <jim876@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phong.sigbus.net ([65.49.35.42]:47012 "EHLO phong.sigbus.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758325Ab0JWTsH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 15:48:07 -0400
In-Reply-To: <4CC2DB2C.3060908@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-10-23 at 14:55 +0200, Jim wrote:
> After some checking noticed that apparently link isn't ready:
>  modprobe tun
>  tunctl -b
>  ifconfig tap0 192.168.20.1 up
> Gives:
> [   26.411932] ADDRCONF(NETDEV_UP): tap0: link is not ready
> 
> Bisected it all the way to this commit:
> 
> =================
> 
> # git bisect good
> bee31369ce16fc3898ec9a54161248c9eddb06bc is the first bad commit
> commit bee31369ce16fc3898ec9a54161248c9eddb06bc
> Author: Nolan Leake <nolan@cumulusnetworks.com>
> Date:   Tue Jul 27 13:53:43 2010 +0000
> 
>     tun: keep link (carrier) state up to date
> 
>     Currently, only ethtool can get accurate link state of a tap device.
>     With this patch, IFF_RUNNING and IF_OPER_UP/DOWN are kept up to date as
>     well.
> 
>     Signed-off-by: Nolan Leake <nolan@cumulusnetworks.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Hello Jim,

Thank you for the report and the bisect.  Please allow me to explain the
intention of this patch.

Previous to this patch, tun.c only kept the ethtool link state up to
date.  IFF_ and IF_OPER_ state were always RUNNING and UP, respectively.

Ethtool link state was (and is) controlled by mapping "tun device FD
open" to link up, and "tun device FD closed" to link down.  Obviously if
you've just used tunctl to create a tap device, and no process has yet
opened the /dev/net/tun backing FD, then this method establishes the
link as down.  Ethtool on a kernel that predates this patch will confirm
this.

What this patch does is make the IFF_RUNNING/IFF_OPER_UP state also
match this interpretation of link state.  Making RUNNING and OPER_UP
consistent with ethtool's concept of link state is, I believe,
consistent with how other ethernet devices work.  The presence of a
process that is sending and receiving packets via the tap device is a
decent analog of link-state for a physical ethernet device.

Could your use-case be solved by a udev rule that assigns the IP address
when the link state changes to UP/RUNNING?

If this is a common way to use tap devices, one possible solution is to
make newly created but unattached tap devices default to UP/RUNNING (and
presumably ethtool link-up, for consistency), and then only begin
accurately reporting link state for subsequent open/closes of
the /dev/net/tun device.

- nolan
