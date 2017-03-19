From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola
 Droid 4
Date: Sun, 19 Mar 2017 10:02:55 -0700
Message-ID: <20170319170254.GB20572@atomide.com>
References: <20170319161957.6625-1-tony@atomide.com>
 <87lgs15iun.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, Marcel Partap <mpartap@gmx.net>,
        Michael Scott <michael.scott@linaro.org>
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:40522 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbdCSRDB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:03:01 -0400
Content-Disposition: inline
In-Reply-To: <87lgs15iun.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Bjørn Mork <bjorn@mork.no> [170319 09:33]:
> Tony Lindgren <tony@atomide.com> writes:
> 
> > This gets qmicli working with the MDM6600 modem.
> >
> > Cc: Bjørn Mork <bjorn@mork.no>
> > Reviewed-by: Sebastian Reichel <sre@kernel.org>
> > Tested-by: Sebastian Reichel <sre@kernel.org>
> > Signed-off-by: Tony Lindgren <tony@atomide.com>
> > ---
> >  drivers/net/usb/qmi_wwan.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> > --- a/drivers/net/usb/qmi_wwan.c
> > +++ b/drivers/net/usb/qmi_wwan.c
> > @@ -580,6 +580,10 @@ static const struct usb_device_id products[] = {
> >  		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPEC, 0x01, 0x69),
> >  		.driver_info        = (unsigned long)&qmi_wwan_info,
> >  	},
> > +	{	/* Motorola Mapphone devices with MDM6600 */
> > +		USB_VENDOR_AND_INTERFACE_INFO(0x22b8, USB_CLASS_VENDOR_SPEC, 0xfb, 0xff),
> 
> 
> This is a bit unusual, so I'd like to verify that it is correct.  Do you
> happen to have a "lsusb -v" or /sys/kernel/debug/usb/devices dump for
> this device?  Is this usage of vendor + class consistent with the
> Windows driver *.inf data?  Are you sure that the ff/fb/ff class is only
> used for QMI functions by this vendor ID? 

Well this is based on what the earlier Motorola mapphone v3.8 kernel has
for in drivers/net/usb/qcusbnet/qcusbnet.c driver:

+       { /* Motorola Xoom */
+       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2A70, 0xff, 0xfb, 0xff),
+       .driver_info = (unsigned long)&xoom_qc_netinfo
+       },
+       { /* MDM9600 */
+       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2E0A, 0xff, 0xfb, 0xff),
+       .driver_info = (unsigned long)&mdm9600_qc_netinfo
+       },

Where the "Motorola Xoom" id is also used for all mapphone devices
with MDM6600 variants.

Then xoom_qc_netinfo in the mapphone kernel has:

+static const struct driver_info xoom_qc_netinfo = {
+       .description   = "Xoom QCUSBNet Ethernet Device",
+       .flags         = FLAG_ETHER|FLAG_SEND_ZLP,
+       .bind          = xoom_qcnet_bind,
+       .unbind        = qcnet_unbind,
+       .data          = 0,
+       .manage_power  = qcnet_manage_power,
+};

And the v3.8 kernel also has drivers/usb/serial/mdm6600.c:

+static const struct usb_device_id mdm6600_id_table[] = {
+       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a70, 0xff, 0xff, 0xff) },
+        /* MDM9600 */
+       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2e0a, 0xff, 0xff, 0xff) },
+       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x900e, 0xff, 0xff, 0xff) },
+       { },
+};

And then in drivers/usb/serial/moto_flashqsc.c:

+static struct usb_device_id id_table[] = {
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a63, 0x0a, 0, 0)},
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x4281, 0x0a, 0, 0xfc)},
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2db4, 0x0a, 0, 0xfc)},
+       {USB_DEVICE(0x22b8, 0x4260)},
+       {USB_DEVICE(0x22b8, 0x426D)},
+       {},
+};

Where the 0x4260 and 0x426d seem to be for the flash mode of the
Wrigley3GLTE modem.

See also lsusb -v output below. No idea if there's a Windows driver
.inf file for this. Most likely whatever Windows driver is just using the
generic Android USB driver(s). I know the USB on droid 4 can be multiplexed
to have MDM6600 directly accessed, but I think that's only used for
debugging the modem as that mode needs to be selected in the bootloader
temporarily using volume keys.

With the configuration in my patch, modprobe of qmi_wwan produces four
wwan interfaces if that matters.

> The reason I ask is that I'd hate to have reports of other Motorola
> devices where ff/fb/ff was used for some other USB function.  Yes, that
> would be stupid.  But still... Experience shows that we cannot rule out
> stupid when we consider USB descriptors.

Yes thanks for checking. If you prefer to set it up in some other
way, or need more info, please let me know.

Regards,

Tony

8< --------------------
Bus 002 Device 002: ID 22b8:2a70  
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x22b8 
  idProduct          0x2a70 
  bcdDevice            0.00
  iManufacturer           1 Motorola, Incorporated
  iProduct                2 Flash MZ600
  iSerial                 0 
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength          251
    bNumInterfaces          9
    bConfigurationValue     1
    iConfiguration          3 Motorola Configuration
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 
      bInterfaceSubClass    255 
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
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x01  EP 1 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 
      bInterfaceSubClass    255 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 
      bInterfaceSubClass    255 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x83  EP 3 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        3
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 
      bInterfaceSubClass    255 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x84  EP 4 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x04  EP 4 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        4
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 
      bInterfaceSubClass    255 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x85  EP 5 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x86  EP 6 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x05  EP 5 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        5
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 
      bInterfaceSubClass    251 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x87  EP 7 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x88  EP 8 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x06  EP 6 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        6
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 
      bInterfaceSubClass    251 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x89  EP 9 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x8a  EP 10 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x07  EP 7 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        7
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 
      bInterfaceSubClass    251 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x8b  EP 11 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x8c  EP 12 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x08  EP 8 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        8
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 
      bInterfaceSubClass    251 
      bInterfaceProtocol    255 
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x8d  EP 13 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval               5
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x8e  EP 14 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x09  EP 9 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0040  1x 64 bytes
        bInterval              32
Device Status:     0x0000
  (Bus Powered)
