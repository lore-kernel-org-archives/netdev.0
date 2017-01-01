From: Ansis Atteka <aatteka@nicira.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Sat, 31 Dec 2016 16:07:39 -0800
Message-ID: <CAA=3Oqn5_5w+vrg9_7UtZ-5BEbZ9Pm=qdX3WoVZKaAkxcMXYXA@mail.gmail.com>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com> <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net> <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "mlord@pobox.com" <mlord@pobox.com>,
        "greg@kroah.com" <greg@kroah.com>,
        "romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 3:58 AM, Hayes Wang <hayeswang@realtek.com> wrote:
> Mark Lord <mlord@pobox.com>
> [...]
>> > Not sure why, because there really is no other way for the data to
>> > appear where it does at the beginning of that URB buffer.
>> >
>> > This does seem a rather unexpected burden to place upon someone
>> > reporting a regression in a USB network driver that corrupts user data.
>>
>> If you are the only person who can actively reproduce this, which
>> seems to be the case right now, this is unfortunately the only way to
>> reach a proper analysis and fix.
>
> I have tested it with iperf more than five days without any error.
> I would think if there is any other way to reproduce it.
>

For the past few days I have been debugging a similar data corruption
bug related to r8152 driver, but on x86-64 platform. Also, I think
that this data corruption bug has some serious security implications,
because it appears that "corrupted data" is actually 530 byte fragment
from one of the previous Ethernet frames that Realtek device just
received. See the ping test in the bottom of my email that
demonstrates this.

Besides the data corruption problem I am also experiencing another
serious problem that could be related and manifests itself in XHCI
module when Realtek Ethernet port receives packets at "high" rate (ie
10Mbps or higher). This second problem correlates with error messages
in kern.log printed by xhci-hcd. Ethernet connectivity is completely
lost at this time until I reload r8152 driver:

[ 2540.426240] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.426258] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f010 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.426259] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.426260] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f020 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.426334] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.426336] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f030 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.426372] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.426373] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f040 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.426488] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.426491] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f050 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.437020] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.437024] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f060 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.438239] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.438246] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f070 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0
[ 2540.438493] xhci_hcd 0000:0e:00.0: ERROR Transfer event TRB DMA ptr
not part of current TD ep_index 2 comp_code 13
[ 2540.438495] xhci_hcd 0000:0e:00.0: Looking for event-dma
00000000fff0f080 trb-start 00000000ff5c9fe0 trb-end 00000000ff5c9fe0
seg-start 00000000ff5c9000 seg-end 00000000ff5c9ff0


All of that is happening on my X86-64  Dell XPS15 9550 laptop that is
connected to Ethernet via Dell TB15 dock. This Dell TB 15 Dock uses
Realtek chip to provide Ethernet connectivity to laptop:

# lsusb
...
Bus 004 Device 003: ID 0bda:8153 Realtek Semiconductor Corp.
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               3.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0         9
  idVendor           0x0bda Realtek Semiconductor Corp.
  idProduct          0x8153
  bcdDevice           30.01
  iManufacturer           1 Realtek
  iProduct                2 USB 10/100/1000 LAN
  iSerial                 6 000001000000
  bNumConfigurations      2

This Realtek Ethernet port is connected to a XHCI ASMedia host
controller that also resides on Dell TB15 Dock. The dock itself is
connected via Thunderbolt 3 cable to laptop:

# lspci
....
0e:00.0 USB controller: ASMedia Technology Inc. ASM1042A USB 3.0 Host Controller


In my case it is easy to reproduce either of those two issues. Here
are my observations:
1. The Ethernet controller on Dell TB15 dock was working completely
fine while I had Windows 10 installed on my Laptop.
2. I have tried various Linux distributions - Ubuntu 16.10, Ubuntu
14.04, CentOS 7. All of them fail with "ERROR Transfer event TRB DMA
ptr not part of current TD ep_index 2 comp_code 13" error message
under high load.
3. I have tried Ubuntu 16.10 and Ubuntu 16.04. Both of them are
affected by this data corruption bug. I did not test for data
corruption on CentOS or other Linux distributions that come with older
Linux kernels than Ubuntu.
4. If I start two ping instances at the same time then it appears that
530 bytes from the first ping instance are occasionally "injected"
into ping payload of the second ping instance. Also, I was able to
reproduce this exact same issue with TCP.

sudo ping -i 0.05 -p ff -s 15000 10.33.75.80 # Sending 0xff as payload
....
15008 bytes from 10.33.75.80: icmp_seq=39 ttl=64 time=104 ms
wrong data byte #9822 should be 0xff but was 0x0
#16 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff
#9776 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#9808 ff ff ff ff ff ff ff ff ff ff ff ff ff ff 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0
#9840 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#9872 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#9904 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#9936 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#9968 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10032 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10064 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10096 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10128 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10160 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10192 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10224 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10256 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10288 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10320 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#10352 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#10384 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
...

sudo ping -i 0.05 -p 00 -s 15000 10.33.75.80 # Sending 0x00 as payload
...
15008 bytes from 10.33.75.80: icmp_seq=164 ttl=64 time=95.4 ms
wrong data byte #11302 should be 0x0 but was 0xff
#16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
...
#11248 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#11280 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ff ff ff ff ff ff ff ff ff ff
#11312 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11344 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11376 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11408 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11440 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11472 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11504 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11536 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11568 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11600 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11632 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11664 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11696 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11728 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11760 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11792 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff
#11824 ff ff ff ff ff ff ff ff 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#11856 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#11888 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
...
