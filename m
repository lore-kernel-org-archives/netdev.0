From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Configuring ethernet link fails with No such device
Date: Mon, 11 Apr 2016 16:10:53 -0700
Message-ID: <570C2EFD.6070602@gmail.com>
References: <67b662523c63277fa95a59472cbf018f@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	u.kleine-koenig@pengutronix.de, bryan.wu@canonical.com,
	bob.ham@collabora.com, Andrew Lunn <andrew@lunn.ch>
To: Stefan Agner <stefan@agner.ch>,
	systemd-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35720 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbcDKXM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 19:12:57 -0400
Received: by mail-pf0-f173.google.com with SMTP id n1so877999pfn.2
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 16:12:56 -0700 (PDT)
In-Reply-To: <67b662523c63277fa95a59472cbf018f@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/16 15:46, Stefan Agner wrote:
> Hi All,
> 
> I traced an issue in which we tried configuring duplex mode and speed in
> a systemd-udevd .link file failed with the following error:
> "Could not set speed or duplex of eth0 to 0 Mbps (half): No such device"
> 
> The FEC driver (fec_main.c) does not initialize phy_dev until the device
> has been opened, and therefor the callback fec_enet_(get|set)_settings
> returns -19.
> 
> What is the expectation/definition when link configuration should be
> possible? Only after the network device got opened or before?

It seems to me like systemd tries to configure the device while we are
still opening it, which is arguably something that can be done, but you
are in a transient state, the interface is not completely ready yet.

> 
> Or in other words: Is this a Kernel or systemd issue? At what point is
> link configuration "guaranteed" to work?

Past ndo_open() had a chance to return, therefore connect to the PHY
device, is when the configuration/information querying is able to succeed.

> 
> It seems that the FEC driver used to probe the PHY earlier, it has been
> moved to the open callback with commit 418bd0d4df ("netdev/fec: fix
> ifconfig eth0 down hang issue")...

Part of the reason for doing that, is that probing for the PHY during
the driver's probe function could leave you with unused HW that is
powered on for no good reason. Until we get into ndo_open, we have no
clue if the interface is going to be used or not, so it is better to
move part of the HW initialization as late as possible in the process.

> 
> There has been a similar report on the systemd-devel mailing list a
> while ago, probably the same underlying issue:
> https://www.mail-archive.com/systemd-devel@lists.freedesktop.org/msg33186.html
> 
> --
> Stefan
> 


-- 
Florian
