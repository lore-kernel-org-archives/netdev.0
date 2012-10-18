From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 00/14] Adding a USB CDC MBIM driver
Date: Thu, 18 Oct 2012 22:40:53 +0200
Message-ID: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Patch 1 and 2 are independent of the rest and only required to make
test devices with very large buffers work.

Patch 3 adds new MBIM definitions to the cdc.h header file

Patches 4 to 9 refactor the cdc_ncm driver to enable reusing common
parts for MBIM.

Patches 10 and 11 add the new cdc_mbim driver

Patch 12 prevents cdc_ncm from binding to backward compatible MBIM
devices

Patches 13 and 14 extend the MBIM driver to support multiplexed
sessions

The changes to the cdc_ncm driver has been tested and verified to work
with an Ericsson F5521gw device.  The new cdc_mbim driver has been
tested with a Huawei E367u-2 device with MBIM firmware, and other
currently undisclosed devices.

Enjoy!


Bj=C3=B8rn Mork (10):
  net: usbnet: make sure the queue lenght is at least 1
  net: cdc_ncm: use device rx_max value if update failed
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
 drivers/net/usb/cdc_mbim.c  |  412 ++++++++++++++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c   |  546 +++++++++++++++++++++--------------=
--------
 drivers/net/usb/usbnet.c    |    4 +-
 include/linux/usb/cdc.h     |   23 ++
 include/linux/usb/cdc_ncm.h |  134 +++++++++++
 7 files changed, 856 insertions(+), 282 deletions(-)
 create mode 100644 drivers/net/usb/cdc_mbim.c
 create mode 100644 include/linux/usb/cdc_ncm.h

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
