From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Question on switchdev
Date: Mon, 29 Feb 2016 23:29:34 +0100
Message-ID: <20160229222934.GA4904@lunn.ch>
References: <56D4BB74.2010109@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45851 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbcB2W3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 17:29:38 -0500
Content-Disposition: inline
In-Reply-To: <56D4BB74.2010109@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 29, 2016 at 04:43:16PM -0500, Murali Karicheri wrote:

Hi Murali

Please can you get your email client to wrap lines at ~ 75 characters.

> TI Keystone netcp h/w has a switch. It has n slave ports and 1 host
> port. Currently the netcp driver disables the switch functionality
> which makes them appear as n nic ports. However we have requirement
> to add switch support in the driver. I have reviewed the
> experimental driver documentation
> Documentation/networking/switchdev.txt and would like to understand
> it better so that I can add this support to keystone netcp driver.
 
> NetCP h/w has a 1 (host port) x n (slave port) switch. It can do
> layer 2 forwarding between ports. In the switch mode, host driver
> provides the frame to the switch and switch uses the filter data
> base (AKA ALE table, Address Learning Engine table) to forward the
> packet. There is a piece of information available per frame (meta
> data) to decide if frame to be forwarded to a particular port or use
> the fdb for forward decisions.

This makes is sound like a good fit for DSA.

Documentation/networking/dsa/dsa.txt.

You probably need to implement a new tagging protocol in
net/dsa/tag_*.c and a driver in drivers/net/dsa/

> 1. How does port netdev differ from regular netdev that carries data
>    when registering netdev? Any example you can point to?

They don't differ at all. You consider each port of the switch to be a
normal Linux interface.

> 2. I assume port netdev will appear as an interface in ifconfig -a
>    command and it is not assigned an IP address. Correct?

The user can assign an address, if they want. It is a normal Linux
interface. They can also create a bridge, and add the interface to the
bridge. An advanced DSA driver will keep track of which interfaces are
in which bridge, and if possible, offload the bridge to the hardware.

> 3. with 1xn switch, so we have n + 1 netdev registered with net
>    core? I assume, only 1 netdev is for data plane and the rest are
>    control plane. Is this correct?

No. You only have netdev devices for the external ports of the
switch. The other port is known as the cpu port, and does not have a
netdev.

> 4. We have bunch of port specific configuration that we would like
> to control or configure from use space using standard tools. For
> example, switch port state, flow control etc. Is that possible to
> add using this framework? ethtool update needed for this?

The whole idea here is that the switch ports are normal Linux
interface. You use normal linux APIs to configure them. You probably
don't need to add any new features.

One key things to get your head around. The switch is a hardware
accelerator for the Linux stack. You have to think how you can make
your switch accelerate the Linux stack. It takes people a while to get
this.

      Andrew
