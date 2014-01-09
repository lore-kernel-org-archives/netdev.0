From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Thu, 9 Jan 2014 21:07:58 +0000
Message-ID: <1389301678.2025.41.camel@bwh-desktop.uk.level5networks.com>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Giri Reddy <giri.reddy@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26596 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757442AbaAIVIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:08:02 -0500
In-Reply-To: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 18:21 +0000, Giri Reddy wrote:
> I'm implementing a new interface for upgrading the firmware for our next
> generation of Qlogic drivers. We need to transfer control information
> between userspace and driver, in addition to the firmware payload. I'm
> considering using 'SIOCDEVPRIVATE' ioctl interface to pass control
> information between userland and driver.
> 
> I also see comments in the source (include/linux/sockios.h) that
> 'SIOCDEVPRIVATE' will be deprecated 2.5.x. What is the current status of
> deprecation in the latest versions of the kernel?

It is still supported and unlikely to be removed, but no in-tree driver
will be allowed to expose new operations this way.

> Are we still allowed to use 'SIOCDEVPRIVATE' in drivers if there the
> deprecation efforts are on hold.
> 
> Any input will be appreciated.

The existing interfaces used for firmware update are:

1. ethtool ETHTOOL_FLASHDEV command.  Userland program installs a
firmware blob under /lib/firmware and then issues this command using
ioctl().  It can specify which flash partition is to be written.  Driver
loads and writes the entire blob and (presumably) resets the chip if
necessary.  There is no way to read the old firmware.

Example drivers: bna, cxgb4, be2net, vxge

2. MTD driver plus ethtool ETHTOOL_RESET command.  The flash
partition(s) containing firmware are exposed as separate devices with
names that indicate what they all are.  Userland can read and write the
firmware through /dev/mtd* or /dev/mtdblock*.  It can reset the chip
after writing firmware, using ioctl().  This is flexible but relatively
complicated for userland to use.

Example driver: sfc

3. ethtool ETHTOOL_{G,S}EEPROM commands.  Userland program sends these
commands using ioctl().  There is no clean way to expose more than one
flash partition, e.g. for controller, PHY, and net-boot firmware.

Example driver: bnx2

Please choose one of the above and don't invent another one.  (There are
already several other interfaces in use that are too horrible to mention
here.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
