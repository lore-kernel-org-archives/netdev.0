From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: cxacru: USB ethernet port of CX82310-based ADSL routers?
Date: Wed, 1 Sep 2010 00:48:41 +0200
Message-ID: <201009010048.44644.linux@rainbow-software.org>
References: <201008312313.39171.linux@rainbow-software.org> <4C7D7F15.9040402@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: accessrunner-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7D7F15.9040402@simon.arlott.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 September 2010 00:15:49 Simon Arlott wrote:
> On 31/08/10 22:13, Ondrej Zary wrote:
> > Hello,
> > I have an ADSL router based on Conexant CX82310 chip. This chip provides
> > both ethernet and USB interfaces. The ethernet interface is often
> > internally connected to a 5-port switch (in my case too). The USB
> > interface works as an ethernet card in Windows (using proprietary
> > driver). In Linux, the cxacru driver binds to the device but does not
> > work (no wonder - it's doing firmware things in an attempt to bring an
> > ADSL modem up).
> >
> > I captured a log from Windows (device connect, DHCP and disconnect):
> > http://www.rainbow-software.org/linux_files/cx82310/cx-run-dhcp.log
> >
> > The commands seem to match the enums in cxacru
> > driver (and go to endpoint 1):
> > 0x84, 0x85, 0x90, 0x91, 0x92, 0x99 (unknown)
> > Data goes to/from endpoint 2 as ethernet frames (with something at the
> > beginning).
> >
> > I wonder how to implement support for this device in cxacru driver. Or
> > would be a separate driver better?
>
> Support for this shouldn't really go into the cxacru driver, as that's
> for an USB ATM interface (it depends on usbatm for actual ATM traffic)
> not ethernet.

That's what I was afraid of...

> Unfortunately it doesn't look like a trivial task to auto-detect which
> driver should handle it... your device itself claims to be an "ADSL
> Modem".

In fact, it does not. The idProduct text is from usb.ids file (which is often 
incorrect). The device says that it's "USB NET CARD" (iProduct). But I don't 
know if Linux can match drivers by iProduct string.

> You'd need to know what type of device it was before loading the
> firmware, which would further complicate auto-detection as some custom
> firmware may be required that attempts to probe the device and then
> accepts new firmware. I have no way of testing this on all the types of
> existing hardware: http://accessrunner.sourceforge.net/modems.shtml
>
> Does it happen to work as an ADSL modem too if you load the right
> firmware?
> d275d0fef591e2233654ea591eccb0d15211eb82  cxacru-fw.bin  624192
>
> There should be some flash memory you could try reading, however it
> may not contain anything useful.
>
> See "commands for interaction with the flash memory" in cxacru.c and
> http://simon.arlott.org/pub/cxacru/raw.c

Thanks, I'll try that, although I doubt that it will help.

> One possibility is to rewrite the flash to indicate that it's an
> ethernet class device, or just handle class 255 differently. It would
> be interesting to know what the windows driver does when the device
> class is changed. (I don't know which bytes in the flash memory
> correspond to that value as mine are all 00, hopefully if you can read
> yours you'll have an FF in that area.)
>
> Ignoring 0572:cb01 class 255 in the cxacru probe function would be an
> option... but I don't know how many existing users that would affect.

Maybe ignoring the device if class is 255 and iProduct is "USB NET CARD" (or 
does not contain "MODEM"?). 

> > lsusb output:
> >
> > Bus 001 Device 003: ID 0572:cb01 Conexant Systems (Rockwell), Inc.
> > GeekADSL Promax Q31 ADSL Modem Device Descriptor:
> >   bLength                18
> >   bDescriptorType         1
> >   bcdUSB               1.10
> >   bDeviceClass          255 Vendor Specific Class
> >   bDeviceSubClass         0
> >   bDeviceProtocol         0
> >   bMaxPacketSize0        64
> >   idVendor           0x0572 Conexant Systems (Rockwell), Inc.
> >   idProduct          0xcb01 GeekADSL Promax Q31 ADSL Modem
This is from usb.ids            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
(random string entered by someone on the internet)

> >   bcdDevice            1.00
> >   iManufacturer           1 -
> >   iProduct                2 USB NET CARD
This is from the device         ^^^^^^^^^^^^

> >   iSerial                 3 00000060
> >   bNumConfigurations      1
> >   Configuration Descriptor:
> >     bLength                 9
> >     bDescriptorType         2
> >     wTotalLength           67
> >     bNumInterfaces          1
> >     bConfigurationValue     1
> >     iConfiguration          0
> >     bmAttributes         0xc0
> >       Self Powered
> >     MaxPower               80mA
> >     Interface Descriptor:
> >       bLength                 9
> >       bDescriptorType         4
> >       bInterfaceNumber        0
> >       bAlternateSetting       0
> >       bNumEndpoints           7
> >       bInterfaceClass         0 (Defined at Interface level)
> >       bInterfaceSubClass      0
> >       bInterfaceProtocol      0
> >       iInterface              0
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x81  EP 1 IN
> >         bmAttributes            3
> >           Transfer Type            Interrupt
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               4
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x01  EP 1 OUT
> >         bmAttributes            3
> >           Transfer Type            Interrupt
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               4
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x82  EP 2 IN
> >         bmAttributes            2
> >           Transfer Type            Bulk
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               1
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x02  EP 2 OUT
> >         bmAttributes            2
> >           Transfer Type            Bulk
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               1
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x83  EP 3 IN
> >         bmAttributes            2
> >           Transfer Type            Bulk
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               1
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x03  EP 3 OUT
> >         bmAttributes            2
> >           Transfer Type            Bulk
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0040  1x 64 bytes
> >         bInterval               1
> >       Endpoint Descriptor:
> >         bLength                 7
> >         bDescriptorType         5
> >         bEndpointAddress     0x84  EP 4 IN
> >         bmAttributes            3
> >           Transfer Type            Interrupt
> >           Synch Type               None
> >           Usage Type               Data
> >         wMaxPacketSize     0x0008  1x 8 bytes
> >         bInterval               4
> > Device Status:     0x0001
> >   Self Powered
>
> The three versions of the hardware I have are below:
>
> Bus 002 Device 002: ID 0572:cafe Conexant Systems (Rockwell), Inc.
> AccessRunner ADSL Modem Device Descriptor:
>   bLength                18
>   bDescriptorType         1
>   bcdUSB               1.10
>   bDeviceClass            0 (Defined at Interface level)
>   bDeviceSubClass         0
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   idVendor           0x0572 Conexant Systems (Rockwell), Inc.
>   idProduct          0xcafe AccessRunner ADSL Modem
>   bcdDevice            0.01
>   iManufacturer           1 -
>   iProduct                2 ADSL USB MODEM
>   iSerial                 3 28217989
>   bNumConfigurations      1
>   Configuration Descriptor:
>     bLength                 9
>     bDescriptorType         2
>     wTotalLength           67
>     bNumInterfaces          1
>     bConfigurationValue     1
>     iConfiguration          0
>     bmAttributes         0xa0
>       (Bus Powered)
>       Remote Wakeup
>     MaxPower              500mA
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        0
>       bAlternateSetting       0
>       bNumEndpoints           7
>       bInterfaceClass         0 (Defined at Interface level)
>       bInterfaceSubClass      0
>       bInterfaceProtocol      0
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x81  EP 1 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x01  EP 1 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x82  EP 2 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x02  EP 2 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x83  EP 3 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x03  EP 3 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x84  EP 4 IN
>         bmAttributes            3
>           Transfer Type            Interrupt
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0008  1x 8 bytes
>         bInterval             200
> Device Status:     0x0001
>   Self Powered
>
> Bus 002 Device 002: ID 0eb0:3457
> Device Descriptor:
>   bLength                18
>   bDescriptorType         1
>   bcdUSB               1.10
>   bDeviceClass            0 (Defined at Interface level)
>   bDeviceSubClass         0
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   idVendor           0x0eb0
>   idProduct          0x3457
>   bcdDevice           90.06
>   iManufacturer           1 -
>   iProduct                2 ADSL USB MODEM
>   iSerial                 3 08298061
>   bNumConfigurations      1
>   Configuration Descriptor:
>     bLength                 9
>     bDescriptorType         2
>     wTotalLength           67
>     bNumInterfaces          1
>     bConfigurationValue     1
>     iConfiguration          0
>     bmAttributes         0xa0
>       (Bus Powered)
>       Remote Wakeup
>     MaxPower              500mA
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        0
>       bAlternateSetting       0
>       bNumEndpoints           7
>       bInterfaceClass         0 (Defined at Interface level)
>       bInterfaceSubClass      0
>       bInterfaceProtocol      0
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x81  EP 1 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x01  EP 1 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x82  EP 2 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x02  EP 2 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x83  EP 3 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x03  EP 3 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x84  EP 4 IN
>         bmAttributes            3
>           Transfer Type            Interrupt
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0008  1x 8 bytes
>         bInterval             200
> Device Status:     0x0001
>   Self Powered
>
> Bus 002 Device 005: ID 0572:cb00 Conexant Systems (Rockwell), Inc. E-Tech
> ADSL Modem v2 Device Descriptor:
>   bLength                18
>   bDescriptorType         1
>   bcdUSB               1.10
>   bDeviceClass            0 (Defined at Interface level)
>   bDeviceSubClass         0
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   idVendor           0x0572 Conexant Systems (Rockwell), Inc.
>   idProduct          0xcb00 E-Tech ADSL Modem v2
>   bcdDevice            0.01
>   iManufacturer           1 -
>   iProduct                2 ADSL USB MODEM
>   iSerial                 3 08298061
>   bNumConfigurations      1
>   Configuration Descriptor:
>     bLength                 9
>     bDescriptorType         2
>     wTotalLength           67
>     bNumInterfaces          1
>     bConfigurationValue     1
>     iConfiguration          0
>     bmAttributes         0x80
>       (Bus Powered)
>     MaxPower              500mA
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        0
>       bAlternateSetting       0
>       bNumEndpoints           7
>       bInterfaceClass         0 (Defined at Interface level)
>       bInterfaceSubClass      0
>       bInterfaceProtocol      0
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x81  EP 1 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x01  EP 1 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x82  EP 2 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x02  EP 2 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x83  EP 3 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x03  EP 3 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x84  EP 4 IN
>         bmAttributes            3
>           Transfer Type            Interrupt
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0008  1x 8 bytes
>         bInterval             200
> Device Status:     0x0001
>   Self Powered

All these devices seem to use bDeviceClass 0 and iProduct "ADSL USB MODEM".

-- 
Ondrej Zary
