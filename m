From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert tg3 driver to request_firmware()
Date: Wed, 18 Jun 2008 10:54:10 -0400
Message-ID: <48592192.6060501@garzik.org>
References: <1213799313.4794.20.camel@fc6.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernelnewbies@nl.linux.org, kernel-janitors@vger.kernel.org,
	dwmw2@infradead.org, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56139 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbYFROyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 10:54:19 -0400
In-Reply-To: <1213799313.4794.20.camel@fc6.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jaswinder Singh wrote:
> Firmware blob is big-endian starts with version numbers, 
> followed by start address and length. 
> length = end_address_of_bss - start_address_of_text.
> Remainder is the blob to be loaded contiguously from start address.
> 
> Signed-off-by: Jaswinder Singh <jaswinder@infradead.org>
> --
> drivers/net/Kconfig              |    8
> drivers/net/tg3.c                |  782 ++++-----------------------------------
> drivers/net/tg3.h                |    4
> firmware/Makefile                |    2
> firmware/WHENCE                  |   19
> firmware/tigon/tg3.bin.ihex      |  175 ++++++++
> firmware/tigon/tg3_tso.bin.ihex  |  446 ++++++++++++++++++++++
> firmware/tigon/tg3_tso5.bin.ihex |  252 ++++++++++++
> 8 files changed, 992 insertions(+), 696 deletions(-)
> create mode 100644 firmware/tigon/tg3.bin.ihex
> create mode 100644 firmware/tigon/tg3_tso.bin.ihex
> create mode 100644 firmware/tigon/tg3_tso5.bin.ihex

Sigh, this has the same problems as the last patch.

* the Kconfig for the firmware should default to 'Y', to make it harder 
for users to create a non-working driver.

* request_firmware() capability is clearly and obviously a separate 
logical change, and should not be included in the same patch as firmware 
separation.

It just makes the patch longer and more difficult to read and review 
with the two separate changes mushed together.  Having separate patches 
also means it is easier to test and validate the loadable firmware approach.

* the firmware should live in the same dir as the driver, just like it 
has for its entire lifetime until now.  It's silly to create a driver 
hierarchy in firmware/ that parallels the rest of the tree

* fedora-rawhide, debian-unstable, and similar targets must already be 
prepped for firmware installs (both from the kernel and via external 
firmware packages like ipw2200-firmware).

* all net driver patches should get copied to netdev@vger.kernel.org, 
which is where networking changes are discussed


This patch should not create ANY operational differences for users. 
Requiring additional steps such as "make firmware_install" in order for 
the user to achieve the same working driver as they had in the last 
kernel is an example of such a [script-breaking] operational difference.

We have to make it tough for users to screw this up.  It's too easy to 
create a non-working driver, with request_firmware()...   as existing 
distro support for firmwares has already proven in the field.

	Jeff


