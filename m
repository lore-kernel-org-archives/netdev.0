From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 00/13] Adding a USB CDC MBIM driver
Date: Mon, 22 Oct 2012 22:56:27 +0200
Message-ID: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48602 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085Ab2JVU5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[for those who reviewed v1 of this series: patch #1 is the only one
changed in v2]

The USB Communications Device Class "Mobile Broadband Interface Model"
(MBIM) is the USB-IFs alternative to the current chipset/vendor
specific solutions to "Mobile Broadband" device management. The
specification, including the management protocol description, can be
downloaded from http://www.usb.org/developers/devclass_docs#approved

This driver implementing most MBIM features with the exception of
32bit NTB and NDP headers.

An important design principle has been reusing as much as possible of
existing kernel code, in particular the cdc_ncm and cdc_wdm drivers.
The CDC MBIM protocol is based on CDC NCM, and much of the setup and
framing logic is very similar.

One important addition in MBIM compared to NCM is the new control
protocol embedded in CDC commands.  This protocol is comprehensive and
support a number of policy decisions necessary for modern mobile
broadband devices often having multiple radio interfaces.  Based on
early comments and the experiences with the qmi_wwan driver, knowledge
of the control protocol has been kept completely out of the driver.
This is userspace material.  Like with qmi_wwan, a control protocol
interface is exported to userspace using the cdc_wdm subdriver API,
associating a /dev/cdc-wdmX character device with the network device
for the management application.

Patch 1 works around a firmware bug in one of the MBIM test devices

Patch 2 adds new MBIM definitions to the cdc.h header file

Patches 3 to 8 refactor the cdc_ncm driver to enable reusing common
parts for MBIM.

Patches 9 and 10 add the new cdc_mbim driver

Patch 11 prevents cdc_ncm from binding to backward compatible MBIM
devices

Patches 12 and 13 extend the MBIM driver to support multiplexed
sessions

The changes to the cdc_ncm driver has been tested and verified to work
with an Ericsson F5521gw device.  The new cdc_mbim driver has been
tested with a Huawei E367u-2 device with MBIM firmware, and other
currently undisclosed devices.

Enjoy!

patch series changelog:
v2:
 - dropped v1 patch 1
 - reworked the firmware bug workaround in v1 patch 2 (which is now 1)
 - acks noted



Bj=C3=B8rn Mork (9):
  net: cdc_ncm: workaround NTB input size firmware bug
  net: cdc_ncm: process chained NDPs
  net: cdc_ncm: splitting rx_fixup for code reuse
  net: cdc_ncm: refactoring for tx multiplexing
  net: cdc_ncm: export shared symbols and definitions
  net: cdc_mbim: build the MBIM driver
  net: cdc_ncm: do not bind to NCM compatible MBIM devices
  net: cdc_ncm: map MBIM IPS SessionID to VLAN ID
  net: cdc_mbim: Device Service Stream support

Greg Suarez (4):
  USB: cdc: add MBIM constants and structures
  net: cdc_ncm: adding MBIM support to ncm_setup
  net: cdc_ncm: refactor bind preparing for MBIM support
  net: cdc_mbim: adding MBIM driver

 drivers/net/usb/Kconfig     |   18 ++
 drivers/net/usb/Makefile    |    1 +
 drivers/net/usb/cdc_mbim.c  |  412 ++++++++++++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c   |  584 ++++++++++++++++++++---------------=
--------
 include/linux/usb/cdc.h     |   23 ++
 include/linux/usb/cdc_ncm.h |  134 ++++++++++
 6 files changed, 861 insertions(+), 311 deletions(-)
 create mode 100644 drivers/net/usb/cdc_mbim.c
 create mode 100644 include/linux/usb/cdc_ncm.h

--=20
1.7.10.4
