From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 14:47:34 -0800
Message-ID: <20061214144734.03300fa6@freekitty>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty>
	<87odq6azel.fsf@sycorax.lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:38269 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964983AbWLNWri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:47:38 -0500
To: Alex Romosan <romosan@sycorax.lbl.gov>
In-Reply-To: <87odq6azel.fsf@sycorax.lbl.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 14:25:06 -0800
Alex Romosan <romosan@sycorax.lbl.gov> wrote:

> Stephen Hemminger <shemminger@osdl.org> writes:
> 
> > 4) What is the IRQ routing?
> >    There are two issues here, first the driver will never work with edge
> >    trigger IRQ's, some motherboards also have busted BIOS and chipsets
> >    that don't do MSI properly. A couple of module parameters are available
> >    to help:
> >       disable_msi=1   		avoids using MSI
> >       idle_timeout=10		polls for lost IRQ's every N ms (10)
> 
> i didn't take long to lock up the machine again. i've rebooted back
> into stock 2.6.20-rc1 and added the two module parameters above. cat
> /proc/interrupts now gives me:
> 
>  17:        203   IO-APIC-fasteoi   eth0, CMI8738
> 
> so i guess the MSI interrupts are disabled. we'll see how this works.

probably won't do much but now the IRQ ends up shared.

> > 5) What are the messages in the console log when problem happens?
> 
> kernel: NETDEV WATCHDOG: eth0: transmit timed out
> kernel: sky2 eth0: tx timeout
> kernel: sky2 eth0: transmit ring 402 .. 361 report=406 done=406
> kernel: sky2 status report lost?

The transmit timeout code trys to be smart, but doesn't really
recover properly if hardware is stuck.


> > 7) Please get a current version of ethtool from:
> >    git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
> >    and run ethtool register dump after a problem occurs:
> >       ethtool -d eth0
> 
> this is the output after it stopped working:
> 
> 
> PCI config
> ----------
> 00: ab 11 62 43 07 04 18 00 15 00 00 02 08 00 00 00
> 10: 04 c0 df fd 00 00 00 00 01 ce 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 62 14 8c 05
> 30: 00 00 00 00 48 00 00 00 00 00 00 00 03 01 00 00
> 40: 00 00 f0 01 00 80 a0 01 01 50 02 fe 00 20 00 14
> 50: 03 5c 00 80 00 00 00 01 00 00 00 01 05 e0 83 00
> 60: 0c 10 e0 fe 00 00 00 00 61 41 00 00 00 00 00 00
> 70: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> Control Registers
> -----------------
> Register Access Port             0x00
> LED Control/Status               0xA603164A
> Interrupt Source                 0x40000000
> Interrupt Mask                   0xC000001D
> Interrupt Hardware Error Source  0x00000000
> Interrupt Hardware Error Mask    0x2E003F3F
> 
> Bus Management Unit
> -------------------
> CSR Receive Queue 1              0x00010000
> CSR Sync Queue 1                 0xFFFFFFFF
> CSR Async Queue 1                0x00000000
> 
> MAC Addresses
> ---------------
> Addr 1            00 11 09 DA 39 A3
> Addr 2            00 11 09 DA 39 A3
> Addr 3            00 00 00 00 00 00
> 
> Connector type               0x4A (J)
> PMD type                     0x54 (T)
> PHY type                     0x80
> Chip Id                      0xB6 Yukon-2 EC
>  (rev 0)
> Ram Buffer                   0x0C
> 
> Status BMU:
> -----------
> Control                                0x0002220A
> Last Index                             0x07FF
> Put Index                              0x0601
> List Address                           0x000000007FBF8000
> Transmit 1 done index                  0x0196
> Transmit index threshold               0x000A
> 
> Status FIFO
> 	Write Pointer            0x16
> 	Read Pointer             0x16
> 	Level                    0x00
> 	Watermark                0x10
> 	ISR Watermark            0x10
> Status level
> 	Init 0x000030D4 Value 0x00000D00
> 	Test 0x04       Control 0x02
> TX status
> 	Init 0x0001E848 Value 0x0001E848
> 	Test 0x04       Control 0x02
> ISR
> 	Init 0x000009C4 Value 0x000009C4
> 	Test 0x04       Control 0x02
> 
> GMAC control             0x005A
> GPHY control             0x2002
> LINK control             0x02
> 
> GMAC 1
> Status                       0xD000
> Control                      0x1800
> Transmit                     0x1000
> Receive                      0xE000
> Transmit flow control        0xFFFF
> Transmit parameter           0xD7C4
> Serial mode                  0x221E
>       Source address:  00 11 09 DA 39 A3
>     Physical address:  00 11 09 DA 39 A3
> 
> Rx GMAC 1
> End Address                      0x0000007F
> Almost Full Thresh               0x00000070
> Control/Test                     0x0900228A
> FIFO Flush Mask                  0x000018FB
> FIFO Flush Threshold             0x0000000B
> Truncation Threshold             0x0000017C
> Upper Pause Threshold            0x00000000
> Lower Pause Threshold            0x00000081
> VLAN Tag                         0x00000074
> FIFO Write Pointer               0x00000000
> FIFO Write Level                 0x0000007B
> FIFO Read Pointer                0x00000000
> FIFO Read Level                  0x00000079
> 
> Tx GMAC 1
> End Address                      0x0000007F
> Almost Full Thresh               0x00000010
> Control/Test                     0x0102220A
> FIFO Flush Mask                  0x00000000
> FIFO Flush Threshold             0x00000000
> Truncation Threshold             0x00000000
> Upper Pause Threshold            0x00000000
> Lower Pause Threshold            0x00000081
> VLAN Tag                         0x0000002A
> FIFO Write Pointer               0x0000002A
> FIFO Write Level                 0x00000000
> FIFO Read Pointer                0x00000000
> FIFO Read Level                  0x0000002A
> 
> Receive Queue 1
> ---------------
> Buffer control                   0x05F8
> Byte Counter                     49408
> Descriptor Address               0x0000000076F4F810
> Status                           0x05EA0100
> Timestamp                        0x00000000
> BMU Control/Status               0x000061AA
> Done                             0x0000
> Request                          0x0000000076F4F810
> Csum1      Offset 52057 Piston   14
> Csum2      Offset 52057 Positing   14
> 
> Sync Transmit Queue 1
> ---------------
> Descriptor Address       0x0000000000000000
> Address Counter          0x0000000000000000
> Current Byte Counter             0
> BMU Control/Status               0x00000000
> Flag & FIFO Address              0x00000000
> 
> Control                          0x00000000
> Next                             0x00000000
> Data                     0x0000000000000000
> Status                           0x00000000
> Timestamp                        0x00000000
> Csum Start 0x0000 Pos    0 Write 0
> 
> Async Transmit Queue 1
> ---------------
> Buffer control                   0x053D
> Byte Counter                     49950
> Descriptor Address               0x0000000047237000
> Status                           0x000005EA
> Timestamp                        0x00010000
> BMU Control/Status               0x800011AA
> Done                             0x0000
> Request                          0x000000004723753D
> Csum Start 0x0032 Pos    0 Write 0
> 
> Receive RAMbuffer 1
> ---------------
> Start Address                    0x00000000
> End Address                      0x00000E7F
> Write Pointer                    0x00000079
> Read Pointer                     0x0000007E
> Upper Threshold/Pause Packets    0x00000D80
> Lower Threshold/Pause Packets    0x000003A0
> Upper Threshold/High Priority    0x00000AE0
> Lower Threshold/High Priority    0x00000740
> Packet Counter                   0x00000029
> Level                            0x00000E7B
> Test                             0x0002221A
> 
> Sync Transmit RAMbuffer 1
> ---------------
> Start Address                    0x00000000
> End Address                      0x00000000
> Write Pointer                    0x00000000
> Read Pointer                     0x00000000
> Packet Counter                   0x00000000
> Level                            0x00000000
> Test                             0x00000000
> 
> Async Transmit RAMbuffer 1
> ---------------
> Start Address                    0x00000E80
> End Address                      0x000017FF
> Write Pointer                    0x0000132A
> Read Pointer                     0x0000132A
> Packet Counter                   0x00000000
> Level                            0x00000000
> Test                             0x0002222A
> 
> i don't know if it helps but i am also including the output of ethtool
> while the card was still working:
> 
> 
> PCI config
> ----------
> 00: ab 11 62 43 07 04 10 00 15 00 00 02 08 00 00 00
> 10: 04 c0 df fd 00 00 00 00 01 ce 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 62 14 8c 05
> 30: 00 00 00 00 48 00 00 00 00 00 00 00 03 01 00 00
> 40: 00 00 f0 01 00 80 a0 01 01 50 02 fe 00 20 00 14
> 50: 03 5c 00 80 00 00 00 01 00 00 00 01 05 e0 83 00
> 60: 0c 10 e0 fe 00 00 00 00 61 41 00 00 00 00 00 00
> 70: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> Control Registers
> -----------------
> Register Access Port             0x00
> LED Control/Status               0xA603164A
> Interrupt Source                 0x00000000
> Interrupt Mask                   0xC000001D
> Interrupt Hardware Error Source  0x00000000
> Interrupt Hardware Error Mask    0x2E003F3F
> 
> Bus Management Unit
> -------------------
> CSR Receive Queue 1              0x00010000
> CSR Sync Queue 1                 0xFFFFFFFF
> CSR Async Queue 1                0x00000000
> 
> MAC Addresses
> ---------------
> Addr 1            00 11 09 DA 39 A3
> Addr 2            00 11 09 DA 39 A3
> Addr 3            00 00 00 00 00 00
> 
> Connector type               0x4A (J)
> PMD type                     0x54 (T)
> PHY type                     0x80
> Chip Id                      0xB6 Yukon-2 EC
>  (rev 0)
> Ram Buffer                   0x0C
> 
> Status BMU:
> -----------
> Control                                0x0002220A
> Last Index                             0x07FF
> Put Index                              0x00B8
> List Address                           0x000000007FBF8000
> Transmit 1 done index                  0x0057
> Transmit index threshold               0x000A
> 
> Status FIFO
> 	Write Pointer            0x08
> 	Read Pointer             0x08
> 	Level                    0x00
> 	Watermark                0x10
> 	ISR Watermark            0x10
> Status level
> 	Init 0x000030D4 Value 0x000030D4
> 	Test 0x04       Control 0x02
> TX status
> 	Init 0x0001E848 Value 0x0001E848
> 	Test 0x04       Control 0x02
> ISR
> 	Init 0x000009C4 Value 0x000009C4
> 	Test 0x04       Control 0x02
> 
> GMAC control             0x005A
> GPHY control             0x2002
> LINK control             0x02
> 
> GMAC 1
> Status                       0xD000
> Control                      0x1800
> Transmit                     0x1000
> Receive                      0xE000
> Transmit flow control        0xFFFF
> Transmit parameter           0xD7C4
> Serial mode                  0x221E
>       Source address:  00 11 09 DA 39 A3
>     Physical address:  00 11 09 DA 39 A3
> 
> Rx GMAC 1
> End Address                      0x0000007F
> Almost Full Thresh               0x00000070
> Control/Test                     0x0900228A
> FIFO Flush Mask                  0x000018FB
> FIFO Flush Threshold             0x0000000B
> Truncation Threshold             0x0000017C
> Upper Pause Threshold            0x00000000
> Lower Pause Threshold            0x00000081
> VLAN Tag                         0x00000027
> FIFO Write Pointer               0x00000000
> FIFO Write Level                 0x00000000
> FIFO Read Pointer                0x00000000
> FIFO Read Level                  0x00000027
> 
> Tx GMAC 1
> End Address                      0x0000007F
> Almost Full Thresh               0x00000010
> Control/Test                     0x0102220A
> FIFO Flush Mask                  0x00000000
> FIFO Flush Threshold             0x00000000
> Truncation Threshold             0x00000000
> Upper Pause Threshold            0x00000000
> Lower Pause Threshold            0x00000081
> VLAN Tag                         0x00000032
> FIFO Write Pointer               0x00000032
> FIFO Write Level                 0x00000000
> FIFO Read Pointer                0x00000000
> FIFO Read Level                  0x00000032
> 
> Receive Queue 1
> ---------------
> Buffer control                   0x05F8
> Byte Counter                     49408
> Descriptor Address               0x000000001727E010
> Status                           0x003C0100
> Timestamp                        0x00000000
> BMU Control/Status               0x000061AA
> Done                             0x0000
> Request                          0x000000001727E010
> Csum1      Offset 12632 Piston   14
> Csum2      Offset 12632 Positing   14
> 
> Sync Transmit Queue 1
> ---------------
> Descriptor Address       0x0000000000000000
> Address Counter          0x0000000000000000
> Current Byte Counter             0
> BMU Control/Status               0x00000000
> Flag & FIFO Address              0x00000000
> 
> Control                          0x00000000
> Next                             0x00000000
> Data                     0x0000000000000000
> Status                           0x00000000
> Timestamp                        0x00000000
> Csum Start 0x0000 Pos    0 Write 0
> 
> Async Transmit Queue 1
> ---------------
> Buffer control                   0x06CC
> Byte Counter                     49950
> Descriptor Address               0x0000000046AD23C6
> Status                           0x000005EA
> Timestamp                        0x00010000
> BMU Control/Status               0x800011AA
> Done                             0x0000
> Request                          0x0000000046AD2A92
> Csum Start 0x0032 Pos    0 Write 0
> 
> Receive RAMbuffer 1
> ---------------
> Start Address                    0x00000000
> End Address                      0x00000E7F
> Write Pointer                    0x00000427
> Read Pointer                     0x00000427
> Upper Threshold/Pause Packets    0x00000D80
> Lower Threshold/Pause Packets    0x000003A0
> Upper Threshold/High Priority    0x00000AE0
> Lower Threshold/High Priority    0x00000740
> Packet Counter                   0x00000000
> Level                            0x00000000
> Test                             0x0002221A
> 
> Sync Transmit RAMbuffer 1
> ---------------
> Start Address                    0x00000000
> End Address                      0x00000000
> Write Pointer                    0x00000000
> Read Pointer                     0x00000000
> Packet Counter                   0x00000000
> Level                            0x00000000
> Test                             0x00000000
> 
> Async Transmit RAMbuffer 1
> ---------------
> Start Address                    0x00000E80
> End Address                      0x000017FF
> Write Pointer                    0x000017B2
> Read Pointer                     0x000017B2
> Packet Counter                   0x00000000
> Level                            0x00000000
> Test                             0x0002222A
> 
> i'll try to lock up the networking again and if it still happens i'll
> swith to the vendor driver and see what that has to say.
> 

Another useful bit of information is the statistics (ethtool -S eth0).
When there were flow control bugs, they would show up as count of 1.

Are you doing jumbo frames (MTU > 1500)?

-- 
Stephen Hemminger <shemminger@osdl.org>
