From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Wake on LAN for USB ethernet?
Date: Thu, 17 Jan 2013 16:12:14 -0800
Message-ID: <20130118001214.GA21137@xanatos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Cc: Alan Stern <stern@rowland.harvard.edu>, Greg KH <greg@kroah.com>,
	Oliver Neukum <oliver@neukum.org>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Petko Manolov <petkan@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39320 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab3ARAMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 19:12:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Is it reasonable to expect that Wake on LAN works if the target box is
connected via a USB-to-ethernet adapter?

One of my validation testers has a USB ethernet device that successfully
wakes up Windows from hibernate (S4), but it doesn't work under Linux.
Wake on LAN works fine with the hardwired ethernet port.  USB remote
wakeup from S3/S4 works fine with a USB keyboard.

So I need to figure out if it's an issue with the kernel, their test
suite, or the USB host controller.


I've experimented with USB ethernet devices with the pegasus driver with
no success.  Here's what I've tried:

1. Connect the USB to ethernet adapter to the rootport under the xHCI
(USB 3.0) host controller. (lsusb for the two devices I've tried is
attached)

2. Enable remote wakeup for all devices (including the PCI host) by
echoing 'enabled' to power/wakeup. (script for that attached)

3. Use ethtool to turn on WOL:
   sudo ethtool -s ethX wol g

4. Find the MAC address by running ifconfig and looking at the HWaddr
field.

5. Verify with wireshark that I can see the Magic WOL packet when I run
this command on another machine:
   sudo etherwake -i ethX macaddr

6. Suspend or hibernate the target machine, and then send the Magic WOL
packet from a second machine.


Am I missing any steps in testing this?  Does WOL just not work for USB
ethernet devices under Linux?  Perhaps just the pegasus driver doesn't
support WOL?

Note that I can't currently test USB remote wakeup for any devices under
the EHCI host controller on my Lenovo x230.  For some reason, whenever I
enable remote wakeup for the rate matching hub under the EHCI host, the
system will immediately resume when I attempt to suspend it.  Don't know
why yet.

Sarah Sharp

--zhXaljGHf11kAtnf
Content-Type: application/x-sh
Content-Disposition: attachment; filename="enable-usb-remote-wakeup.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0ADEV_PATH=3D"/sys"`udevadm info --name=3D/dev/bus/usb/$1/$2 --=
query=3Dpath`=0A=0Awhile true; do=0A	if [[ "`basename $DEV_PATH`" =3D=3D pc=
i* ]]; then=0A		break;=0A	fi=0A	echo Enabling remote wakeup for $DEV_PATH=
=0A	echo enabled > $DEV_PATH/power/wakeup=0A	DEV_PATH=3D`dirname $DEV_PATH`=
=0Adone=0A
--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="belkin-pegasus-lsusb.txt"


Bus 003 Device 013: ID 050d:0121 Belkin Components F5D5050 100Mbps Ethernet
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0         8
  idVendor           0x050d Belkin Components
  idProduct          0x0121 F5D5050 100Mbps Ethernet
  bcdDevice            1.01
  iManufacturer           1 ADMtek
  iProduct                2 USB To LAN Converter
  iSerial                 3 0001
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           39
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xa0
      (Bus Powered)
      Remote Wakeup
    MaxPower              160mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass         0 (Defined at Interface level)
      bInterfaceSubClass      0 
      bInterfaceProtocol      0 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval               1
Device Status:     0x0000
  (Bus Powered)

--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="smc-pegasus-lsusb.txt"


Bus 003 Device 012: ID 07a6:8513 ADMtek, Inc. AN8513 Ethernet
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass         0 
  bDeviceProtocol       255 
  bMaxPacketSize0         8
  idVendor           0x07a6 ADMtek, Inc.
  idProduct          0x8513 AN8513 Ethernet
  bcdDevice            2.01
  iManufacturer           1 USB
  iProduct                2 SMC2208USB/ETH
  iSerial                 3 33D0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           39
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xa0
      (Bus Powered)
      Remote Wakeup
    MaxPower              160mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass      1 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval               1
Device Status:     0x0002
  (Bus Powered)
  Remote Wakeup Enabled

--zhXaljGHf11kAtnf--
