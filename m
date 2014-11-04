From: Dan Williams <dcbw@redhat.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Tue, 04 Nov 2014 10:55:32 -0600
Message-ID: <1415120132.31049.11.camel@dcbw.local>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbaKDQzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 11:55:40 -0500
In-Reply-To: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
> Hi,
> 
> I wanted to understand what is going on the kernel-side when
> connecting to the Internet via a Huawei E173 USB web-stick (3rd
> Generation: UMTS / HSPA).
> 
> Especially the correlation between the diverse USB/NET kernel-drivers
> and how the networking is setup.

General overview:  there are many different types of WWAN devices and
they fall into a couple groups:

1) PPP-only via serial ports; IP packets are transmitted via a PPP
interface (eg, ppp0) created after sending some AT commands to the modem
over that serial port.  IP addressing happens via PPP's IPCP/IPV6CP
protocols.

2) Net interface with AT commands over serial ports: the modem provides
a 'net' interface that is activated with proprietary AT commands over a
serial port. IP addressing happens via either DHCP on that net interface
after the AT setup, or the IP/DNS details are queried via proprietary AT
commands.

3) Net interface with proprietary protocols: the modem provides a 'net'
interface that is activated via proprietary protocols (QMI, MBIM, CnS,
etc).  IP addressing happens either via DHCP on the net interface after
proprietary protocol setup, or the IP/DNS details are queried via
proprietary protocol commands.

It's often possible to know what category a device fits into, but even
devices from the same manufacturer with *the same model number* can fall
into different categories, because the firmware is different, or because
the firmware can switch between these categories using special commands.

> I have tested a Ubuntu trusty kernel on my Ubuntu/precise system and
> compared the configs to get the stuff run on 3.18-rc2+.
> Beyond the "option" driver, I required usb_serial / usb_wwan to be
> activated and some more ("cde-ether" or sth. sound similiar...).
> ( Currently, I am not sitting (it's a Windows machine) in front of my
> machine, so I cannot send you my latest kernel-config. )
> 
> As usually I looked into Documentation directory.
> So, my 1st question where do I get some informations in general on
> this topic - usb [1] or net subdirectory (seen from kernel-side)?
> I found a usb-serial kernel-doc [1].
> ( I have no Linux Git source so I cannot grep for patterns. )

None of those really have any information about WWAN specific setup, and
I fear that if documentation was added, it would be quickly out-of-date
because device manufacturers change things so frequently.

> The next mystery is what is network-manager doing in the background?
> I have seen that modem-manager is invoked, but as said I would like to
> understand the "internas" (means check the logs, turn on some
> debugging kernel-space/user-space, etc.).

NetworkManager uses ModemManager for all WWAN control, NM only handles
the configuration storage and IP addressing parts of the setup.
ModemManager handles modem hardware detection, capability detection,
WWAN registration and setup, signal strength reporting, network
connection initiation, and bearer IP addressing method determination.

If you want more information from ModemManager, you can run "mmcli
--help" or "mmcli --set-logging=debug".

> I am not sure but syncing with 3G network seems to take a while since
> I really can connect to the Internet.

What do you mean by "syncing"?

Dan
