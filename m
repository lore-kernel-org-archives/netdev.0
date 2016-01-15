From: Edward Cree <ecree@solarflare.com>
Subject: sfc userland MCDI - request for guidance
Date: Fri, 15 Jan 2016 17:34:04 +0000
Message-ID: <56992D8C.7090003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:49644 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752397AbcAOReO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 12:34:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a design problem with a few possible solutions and I'd like some
 guidance on which ones would be likely to be acceptable.

The sfc driver communicates with the hardware using a protocol called MCDI -
 Management Controller to Driver Interface - and for various reasons
 (ranging from test automation to configuration utilities) we would like to
 be able to do this from userspace.  We currently have two ways of handling
 this, neither of which is satisfactory.
One is to use libpci to talk directly to the hardware; however this is
 unsafe when the driver is loaded because both driver and userland could try
 to send MCDI commands at the same time using the same doorbell.
The other is a private ioctl which is implemented in the out-of-tree version
 of our driver.  However, as an ioctl it presumably would not be acceptable
 in-tree.

The possible solutions we've come up with so far are:
* Generic Netlink.  Define a netlink family for EFX_MCDI, registered at
  driver load time, and using ifindex to identify which device to send the
  MCDI to.  The MCDI payload would be sent over netlink as a binary blob,
  because converting it to attributes and back would be much unnecessary
  work (there are many commands and many many arguments).  The response from
  the hardware would be sent back to userland the same way.
* Sysfs.  Have a sysfs node attached to the net device, to which MCDI
  commands are written and from which the responses are read.  This does
  mean userland has to handle mutual exclusion, else it could get the
  response to another process's request.
* Have the driver reserve an extra VI ('Virtual Interface') on the NIC
  beyond its own requirements, and report the index of that VI in a sysfs
  node attached to the net device.  Then the userland app can read it, and
  use that VI to do its MCDI through libpci.  Since each VI has its own MCDI
  doorbell, this is safe, but involves libpci and requires that a VI always
  be reserved for this.  Again, mutual exclusion is left to userspace.
* Have firmware expose a fake MTD partition, writes to which are interpreted
  as MCDI commands to run; no modification to the driver would be needed.
  This is incredibly ugly and our firmware team would rather not do it :)

Are any of these appropriate?
