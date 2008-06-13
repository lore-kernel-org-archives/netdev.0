From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [RFC][PATCH 0/2] Making use of VNICs in the sfc driver
Date: Fri, 13 Jun 2008 21:12:30 +0100
Message-ID: <4852D4AE.5020206@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:41644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbYFMU1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 16:27:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Solarflare NIC (sfc driver accepted into 2.6.26), in addition to being
a standard net device, has a number of advanced features.  The main one is
support for multiple virtual NIC interfaces that can be accessed directly
by untrusted users to send and receive traffic efficiently.

This email includes brief description of how we can use these features,
discusses changes needed in the sfc driver to support these uses, and a
proposed patch to sfc, and an example usage for an MTD driver.

We invite comments and review.  Are there existing features in the kernel
we could use to solve these problems?  Would a more generic approach
(usable by other drivers) be better?


What exists at present
======================

We currently use these V-NICs for:

 1) Accelerated hypervisor-bypass drivers for virtualised guest OSs.
    Support for this has been accepted into Xen[1].

 2) Openonload[2] -- a GPLed user-level network stack.  This provides
    low-latency and low-overhead networking (particularly suited to HPC
    and fin-serv applications).

Our existing implementations place these extended features in separate
drivers.  Inevitably some coordination with the sfc driver is required, so
we've added an API to sfc we call "driverlink".  This allows the primary
driver (sfc) to initialise the hardware, and secondary drivers to attach
and register a set of callbacks, which include:

 - probe and remove (modeled on pci hotplug)
 - notification of link state changes
 - management of MTU changes
 - forwarding of internal NIC management events
 - suspend and resume
 - data-path intercepts

The suspend and resume callbacks are needed when making certain global
configuration changes that affect all users and also when resetting the
hardware.

The data-path packet intercepts give client drivers an opportunity to
inspect incoming and outgoing packets, and veto them.  They are needed
partly because the filtering of received packets onto V-NICs is imperfect,
and in Xen to spot certain control plane updates efficiently.

We also use this driverlink API to support an in-kernel MTD driver which
allows a userland utility to program PXE boot images into the flash.  The
MTD driver is included in this patch series.


Summary of requirements
=======================

- A means to support a primary driver that initialises hardware, and
 secondary drivers which assume the hardware is already initialised,
 including discovery and hot-plug-like suspend and resume.

- Notification for link state changes, negotiation of MTU changes and
 forwarding of NIC-specific management events.

- Inspection and filtering of the data-path.


We have considered alternative approaches for these, such as rtnetlink for
link state notification, but this approach is much more complex.

There appear to be some similarities with the CNIC APIs that are proposed
for the bnx2 driver [3] and possibly some of the functionality in
net/cxgb3_offload.c

--

We would appreciate review and comments on this proposal, and any
suggestions for better ways to achieve the requirements.

Two patches follow. Please excuse the excessive commenting:
[PATCH 1/2] Added driverlink including resource dimensioning
[PATCH 2/2] An MTD driver for flash and EEPROM parts as an example of
driverlink usage.


[1]http://lists.xensource.com/archives/html/xen-devel/2008-02/msg00507.html
[2]http://www.openonload.org/
[3]http://thread.gmane.org/gmane.linux.iscsi.open-iscsi/1112/focus=1132

Thanks

-- 
Rob Stonehouse

