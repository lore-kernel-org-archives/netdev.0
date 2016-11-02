From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Wed, 2 Nov 2016 14:29:58 -0400
Message-ID: <008b7d7d-74af-0341-0c16-40aafde5a223@pobox.com>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-10-31 04:14 AM, Hayes Wang wrote:
>>>>> The r8152 driver has been broken since (approx) 3.16.xx
>>>>> when support was added for hardware RX checksums
>>>>> on newer chip versions.  Symptoms include random
>>>>> segfaults and silent data corruption over NFS.
>>>>>
>>>>> The hardware checksum logig does not work on the VER_02
>>>>> dongles I have here when used with a slow embedded system CPU.
>>>>> Google reveals others reporting similar issues on Raspberry Pi.
...
> Our hw engineer says only VER_01 has the issue about rx checksum.
> I need more information for checking it.

I have poked at it some more, and thus far it appears that it is
only necessary to disable TCP rx checksums.  The system doesn't crash
when only IP/UDP checksums are enabled, but does when TCP checksums are on.

This happens regardless of whether RX_AGG is disabled or enabled,
and increasing/decreasing the number of RX URBs (RTL8152_MAX_RX)
doesn't seem to affect it.

lsusb -vv (from an x86 system, not the failing embedded system) follows:

Bus 001 Device 004: ID 0bda:8152 Realtek Semiconductor Corp.
Device Descriptor:
   bLength                18
   bDescriptorType         1
   bcdUSB               2.10
   bDeviceClass            0 (Defined at Interface level)
   bDeviceSubClass         0
   bDeviceProtocol         0
   bMaxPacketSize0        64
   idVendor           0x0bda Realtek Semiconductor Corp.
   idProduct          0x8152
   bcdDevice           20.00
   iManufacturer           1 Realtek
   iProduct                2 USB 10/100 LAN
   iSerial                 3 84E71400257D
   bNumConfigurations      2
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
     MaxPower              100mA
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       0
       bNumEndpoints           3
       bInterfaceClass       255 Vendor Specific Class
       bInterfaceSubClass    255 Vendor Specific Subclass
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
         wMaxPacketSize     0x0200  1x 512 bytes
         bInterval               0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x02  EP 2 OUT
         bmAttributes            2
           Transfer Type            Bulk
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0200  1x 512 bytes
         bInterval               0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0002  1x 2 bytes
         bInterval               8
   Configuration Descriptor:
     bLength                 9
     bDescriptorType         2
     wTotalLength           80
     bNumInterfaces          2
     bConfigurationValue     2
     iConfiguration          0
     bmAttributes         0xa0
       (Bus Powered)
       Remote Wakeup
     MaxPower              100mA
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        0
       bAlternateSetting       0
       bNumEndpoints           1
       bInterfaceClass         2 Communications
       bInterfaceSubClass      6 Ethernet Networking
       bInterfaceProtocol      0
       iInterface              5 CDC Communications Control
       CDC Header:
         bcdCDC               1.10
       CDC Union:
         bMasterInterface        0
         bSlaveInterface         1
       CDC Ethernet:
         iMacAddress                      3 84E71400257D
         bmEthernetStatistics    0x00000000
         wMaxSegmentSize               1514
         wNumberMCFilters            0x0000
         bNumberPowerFilters              0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x83  EP 3 IN
         bmAttributes            3
           Transfer Type            Interrupt
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0010  1x 16 bytes
         bInterval               8
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        1
       bAlternateSetting       0
       bNumEndpoints           0
       bInterfaceClass        10 CDC Data
       bInterfaceSubClass      0 Unused
       bInterfaceProtocol      0
       iInterface              0
     Interface Descriptor:
       bLength                 9
       bDescriptorType         4
       bInterfaceNumber        1
       bAlternateSetting       1
       bNumEndpoints           2
       bInterfaceClass        10 CDC Data
       bInterfaceSubClass      0 Unused
       bInterfaceProtocol      0
       iInterface              4 Ethernet Data
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x81  EP 1 IN
         bmAttributes            2
           Transfer Type            Bulk
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0200  1x 512 bytes
         bInterval               0
       Endpoint Descriptor:
         bLength                 7
         bDescriptorType         5
         bEndpointAddress     0x02  EP 2 OUT
         bmAttributes            2
           Transfer Type            Bulk
           Synch Type               None
           Usage Type               Data
         wMaxPacketSize     0x0200  1x 512 bytes
         bInterval               0
Binary Object Store Descriptor:
   bLength                 5
   bDescriptorType        15
   wTotalLength           12
   bNumDeviceCaps          1
   USB 2.0 Extension Device Capability:
     bLength                 7
     bDescriptorType        16
     bDevCapabilityType      2
     bmAttributes   0x00000002
       Link Power Management (LPM) Supported
Device Status:     0x0000
   (Bus Powered)
