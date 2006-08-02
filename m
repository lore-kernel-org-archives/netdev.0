From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Thu, 3 Aug 2006 00:16:29 +0200
Message-ID: <20060802221629.GB28282@electric-eye.fr.zoreil.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com> <20060728194933.GA14222@electric-eye.fr.zoreil.com> <20060728203437.GA6253@deprecation.cyrius.com> <20060802180244.GA32235@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42942 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932255AbWHBWSL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 18:18:11 -0400
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20060802180244.GA32235@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
[...]
> Sorry, to pester you, but I was wondering if you had a chance to look
> at the register dump.

No problem. It would have been easier with a decoded output of the register
dump though (see Lennert dump below).

Lines prefixed by '>' come from Realtek's driver. I have outlined the
differences which seem relevant to me.

0x00: MAC Address                      00:14:fd:10:27:74
> 00	0x00
> 01	0x14
> 02	0xfd
> 03	0x10
> 04	0x27
> 05	0x74

> 06	0x00
> 07	0x00

0x08: Multicast Address Filter     0x00000000 0x00000000
> 08	0x00
> 09	0x00
> 10	0x00
> 11	0x80
          ^^
/me scratches head

> 12	0x00
> 13	0x00
> 14	0x00
> 15	0x00

0x10: Dump Tally Counter Command   0xd7bbfec0 0xfb74b6fb
> 16	0xc0
> 17	0xfe
> 18	0xbb
> 19	0xdf

> 20	0x7b
> 21	0xb6
> 22	0x74
> 23	0xff

> 24	0x00
> 25	0x00
> 26	0x00
> 27	0x00

> 28	0x00
> 29	0x00
> 30	0x00
> 31	0x00

0x20: Tx Normal Priority Ring Addr 0x00000000 0x00000000
> 32	0x00
> 33	0x80
> 34	0x20
> 35	0x07

> 36	0x00
> 37	0x00
> 38	0x00
> 39	0x00

0x28: Tx High Priority Ring Addr   0xfffc3f00 0xfef7f6ad
> 40	0x00
> 41	0x3f
> 42	0xfc
> 43	0xff

> 44	0xac
> 45	0xf7
> 46	0xf7
> 47	0xfe

0x30: Flash memory read/write                 0x00000000
> 48	0x00
> 49	0x00
> 50	0x00
> 51	0x00

0x34: Early Rx Byte Count                              0
> 52	0x00
> 53	0x00

0x36: Early Rx Status                               0x00
> 54	0x08

0x37: Command                                       0x00
      Rx off, Tx off
> 55	0x0c
          ^^ -> CmdRxEnb | CmdTxEnb

If ChipCmd is not set, the driver will hardly work.

Lennert, your dump was taken while the kernel driver was down, right ?

> 56	0x00
> 57	0x00
> 58	0x00
> 59	0x00

0x3C: Interrupt Mask                              0x0000
> 60	0x7f
          ^^
> 61	0x00

        RxFIFOOver = 0x40,
        LinkChg    = 0x20,
        RxOverflow = 0x10,
        TxErr      = 0x08,
        TxOK       = 0x04,
        RxErr      = 0x02,
        RxOK       = 0x01,

0x0000 is typical of rtl8169_irq_mask_and_ack().
The device seems down.

0x3E: Interrupt Status                            0x0000
> 62	0x00
> 63	0x00

0x40: Tx Configuration                        0x10000000
> 64	0x00
> 65	0x07
          ^^
Realtek's driver uses an unlimited DMA burst (7) instead
of 1024 (6, see TX_DMA_BURST). Probably harmless.

> 66	0x00
> 67	0x13

0x44: Rx Configuration                        0x00000002
> 68	0x0e
          ^^
These bit should be set by the kernel driver through
rtl8169_set_rx_mode() when the device is brought up

The exact same value would require to replace (in rtl8169_set_rx_mode):
                rx_mode = AcceptBroadcast | AcceptMyPhys;
by:
                rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;


> 69	0xe7
> 70	0x00
> 71	0x00

0x48: Timer count                             0x95887845
> 72	0x24
> 73	0x57
> 74	0xaf
> 75	0x31

0x4C: Missed packet counter                     0x000000
> 76	0x00
> 77	0x00
> 78	0x00
> 79	0x00

0x50: EEPROM Command                                0x00
> 80	0x00

0x51: Config 0                                      0x04
> 81	0x04

0x52: Config 1                                      0x1f
> 82	0x1f

0x53: Config 2                                      0x10
> 83	0x10

0x54: Config 3                                      0x20
> 84	0x20

0x55: Config 4                                      0x80
> 85	0x80

0x56: Config 5                                      0x01
> 86	0x03
> 87	0x00

0x58: Timer interrupt                         0x00000000
> 88	0x00
> 89	0x00
> 90	0x00
> 91	0x00

0x5C: Multiple Interrupt Select                   0x0000
> 92	0x00
> 93	0x00

> 94	0x10
> 95	0x00

0x60: PHY access                              0x80001000
> 96	0x6d
> 97	0x79
> 98	0x01
> 99	0x80

0x64: TBI control and status                  0x00000000
> 100	0x00
> 101	0x00
> 102	0x00
> 103	0x00

0x68: TBI Autonegotiation advertisement (ANAR)    0x0000
> 104	0x00
> 105	0x00

0x6A: TBI Link partner ability (LPAR)             0x0000
> 106	0x00
> 107	0x00

0x6C: PHY status                                    0x6b
> 108	0x6b

> 109	0x00
> 110	0x00
> 111	0x00
> 112	0xff
> 113	0xfd
> 114	0xfb
> 115	0xff
> 116	0xfc
> 117	0x03
> 118	0x00
> 119	0x00
> 120	0x00
> 121	0xff
> 122	0xff
> 123	0xff
> 124	0x00
> 125	0x00
> 126	0x00
> 127	0x00
> 128	0x00
> 129	0x00
> 130	0x00
> 131	0x00

0x84: PM wakeup frame 0            0xbcfeef7f 0xdffffe9f
> 132	0x7f
> 133	0xef
> 134	0xfe
> 135	0xfc
> 136	0x9f
> 137	0xfe
> 138	0xff
> 139	0xdf

0x8C: PM wakeup frame 1            0xabf7cf3f 0xfffbdbbf
> 140	0x3f
> 141	0xcf
> 142	0xf7
> 143	0xab
> 144	0xbf
> 145	0xdb
> 146	0xfb
> 147	0xff

0x94: PM wakeup frame 2 (low)      0xdfbbfedf 0xbfbffffd
> 148	0xdf
> 149	0xff
> 150	0xfa
> 151	0xdf
> 152	0xfd
> 153	0xbf
> 154	0xbf
> 155	0xbf

0x9C: PM wakeup frame 2 (high)     0xaa75befc 0xcb5feaf9
> 156	0xfc
> 157	0xbe
> 158	0x75
> 159	0xaa
> 160	0xf9
> 161	0xea
> 162	0x5f
> 163	0xcb

0xA4: PM wakeup frame 3 (low)      0xbbdf6fdf 0xff7e75b7
> 164	0xdf
> 165	0x6f
> 166	0xdf
> 167	0xfb
> 168	0xb7
> 169	0x75
> 170	0x7e
> 171	0xff

0xAC: PM wakeup frame 3 (high)     0xbbdffbf9 0xfbfcffff
> 172	0xfd
> 173	0xfb
> 174	0xdf
> 175	0xbb
> 176	0xff
> 177	0xff
> 178	0x7c
> 179	0xff

0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbffa7f
> 180	0x9f
> 181	0xde
> 182	0x3b
> 183	0x7f
> 184	0x7f
> 185	0xfa
> 186	0xbf
> 187	0xbb

0xBC: PM wakeup frame 4 (high)     0xae9fbdcd 0x32c8bbff
> 188	0xcd
> 189	0xfd
> 190	0x9f
> 191	0xae
> 192	0xff
> 193	0xbb
> 194	0xc8
> 195	0x36

0xC4: Wakeup frame 0 CRC                          0x9aff
> 196	0xef
> 197	0xda
0xC6: Wakeup frame 1 CRC                          0xfdbf
> 198	0xff
> 199	0xff
0xC8: Wakeup frame 2 CRC                          0xaeff
> 200	0xff
> 201	0xae
0xCA: Wakeup frame 3 CRC                          0x6bfe
> 202	0xfe
> 203	0x6a
0xCC: Wakeup frame 4 CRC                          0xdc2f
> 204	0x2f
> 205	0xdc

> 206	0x00
> 207	0x00
> 208	0x00
> 209	0x00
> 210	0x00
> 211	0x00
> 212	0x00
> 213	0x00
> 214	0x00
> 215	0x00
> 216	0x00
> 217	0x00

0xDA: RX packet maximum size                      0x3fff
> 218	0xf2
          ^^
> 219	0x05
          ^^
Probably harmless: 1522 bytes max instead of max jumbo.

> 220	0x00
> 221	0x00
> 222	0x00
> 223	0x00

0xE0: C+ Command                                  0x2028
      RX checksumming
      PCI Multiple RW
> 224	0x08

Rx checksum is disabled in Realtek's driver. Probably harmless.

> 225	0x20

0xE2: Interrupt Mitigation                        0x0000
      TxTimer:       0
      TxPackets:     0
      RxTimer:       0
      RxPackets:     0
> 226	0x00
> 227	0x00

0xE4: Rx Ring Addr                 0x07bd4000 0x00000000
> 228	0x00
> 229	0x00
> 230	0x79
> 231	0x07

> 232	0x00
> 233	0x00
> 234	0x00
> 235	0x00

0xEC: Early Tx threshold                            0x3f
> 236	0x3f

> 237	0x00
> 238	0x00
> 239	0x00
> 240	0x00
> 241	0x80
> 242	0x00
> 243	0x00
> 244	0x00
> 245	0x00
> 246	0x00
> 247	0x00
> 248	0x02
> 249	0x00
> 250	0x00
> 251	0x00
> 252	0x00
> 253	0x00
> 254	0x00
> 255	0x00

-- 
Ueimor
