From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Wed, 14 Jun 2017 16:49:37 +0200
Message-ID: <f99f714e-2522-3b6e-6619-7a82db2b76db@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
 <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
 <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
 <51eb8306-64e5-f528-d663-be80c73098f1@free.fr>
 <6edad982-713a-1b38-d9f0-e763c70c4f95@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:24174 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751750AbdFNOtu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:49:50 -0400
In-Reply-To: <6edad982-713a-1b38-d9f0-e763c70c4f95@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/2017 17:50, Florian Fainelli wrote:

> On 06/13/2017 08:47 AM, Mason wrote:
>
>> If I unplug/replug the cable, ping still works afterward.
>> (Packet RX appears to be *not* wedged)
>>
>> If I toggle the link state in SW (set link down/set link up),
>> I can no longer ping afterward.
>> (Packet RX appears to be wedged, so ARP replies are not seen)
>>
>> Maybe the two experiments are too unrelated to consider
>> the different results relevant in any way?
> 
> No, they are not, this really tells you that whatever your ndo_open()
> and ndo_stop() functions do, they are currently broken with your
> particular HW. I have seen numerous problems on some of our older
> platforms using bcmgenet where the PHY needs to be reset *before* any
> MAC activity occurs, and any MAC activity even qualifies as a reset of
> the MAC itself, we can perform a PHY reset there because the PHY is
> internal, that may not be an option, and your HW is different anyway.

I have logged *all* register writes, to compare state after probe,
after open, and after close. I do see a few odd values...
I'm still deep in the maze, but I may find an exit eventually.

What state is probe supposed to leave the HW in?
What state is open  supposed to leave the HW in?

I'm thinking that I could reset the entire block in close.

Regards.


Found ethernet phy : AR8035
[    0.852746] libphy: Fixed MDIO Bus: probed
[    0.856975] ++ETH++ gw8  0xf0026424 0x00		# ETH_SW_RESET
[    0.870942] ++ETH++ gw8  0xf0026424 0x01		# ETH_SW_RESET
[    0.874894] ++ETH++ gw16 0xf0026420 0x0050		# ETH_MDIO_CLK_DIV
[    0.879101] libphy: nb8800-mii: probed
[    0.885005] ++ETH++ gw8  0xf0026000 0x1c		# ETH_MAC_CORE_TRANSMIT_CONTROL
[    0.888967] ++ETH++ gw8  0xf0026001 0x05		# ETH_MAC_CORE_TRANSMIT_CONTROL
[    0.892911] ++ETH++ gw8  0xf0026004 0x22		# ETH_MAC_CORE_RECEIVE_CONTROL
[    0.896855] ++ETH++ gw8  0xf0026008 0x04		# ETH_MAC_CORE_RANDOM_SEED
[    0.900815] ++ETH++ gw8  0xf0026014 0x0c		# ETH_MAC_CORE_TRANSMIT_SINGLE_DEFERRAL
[    0.904758] ++ETH++ gw8  0xf0026051 0x00		# ETH_MAC_CORE_THRESHOLDS
[    0.908700] ++ETH++ gw8  0xf0026052 0xff		# ETH_MAC_CORE_THRESHOLDS
[    0.912643] ++ETH++ gw8  0xf0026054 0x40		# ETH_MAC_CORE_BUFFER_SIZE_TX_AND_ETH_MAC_CORE_FIFO_CONTROL
[    0.916586] ++ETH++ gw32 0xf0026100 0x000002fe	# TRANSMIT_CHANNEL_CONTROL
[    0.921054] ++ETH++ gw32 0xf0026118 0x003cc4a4	# TRANSMIT_INTERRUPT_TIME
[    0.925521] ++ETH++ gw32 0xf0026200 0x000002fe	# RECEIVE_CHANNEL_CONTROL
[    0.929990] ++ETH++ gw32 0xf0026218 0x00004dc8	# RECEIVE_INTERRUPT_TIME
[    0.934456] ++ETH++ gw8  0xf0026060 0x00		# ETH_MAC_CORE_PAUSE_QUANTA
[    0.938398] ++ETH++ gw8  0xf0026061 0xc3		# ETH_MAC_CORE_PAUSE_QUANTA
[    0.942338] ++ETH++ gw8  0xf002602e 0x00		# ETH_MAC_CORE_MULTICAST_ADDRESS1
[    0.946283] ++ETH++ gw8  0xf0026400 0x01		# ETH_GPIO_PAD_MODE
[    0.950226] ++ETH++ gw32 0xf0026200 0x0000028e	# RECEIVE_CHANNEL_CONTROL
[    0.954695] ++ETH++ gw8  0xf002606a 0x00		# ETH_MAC_CORE_SOURCE_ADDRESS0
[    0.958638] ++ETH++ gw8  0xf002606b 0x16		# ETH_MAC_CORE_SOURCE_ADDRESS0
[    0.962581] ++ETH++ gw8  0xf002606c 0xe8		# ETH_MAC_CORE_SOURCE_ADDRESS1
[    0.966523] ++ETH++ gw8  0xf002606d 0x4d		# ETH_MAC_CORE_SOURCE_ADDRESS1
[    0.970465] ++ETH++ gw8  0xf002606e 0x7f		# ETH_MAC_CORE_SOURCE_ADDRESS1
[    0.974408] ++ETH++ gw8  0xf002606f 0xc4		# ETH_MAC_CORE_SOURCE_ADDRESS1
[    0.978349] ++ETH++ gw8  0xf002603c 0x00		# ETH_MAC_CORE_UNICAST_ADDRESS0
[    0.982291] ++ETH++ gw8  0xf002603d 0x16		# ETH_MAC_CORE_UNICAST_ADDRESS0
[    0.986234] ++ETH++ gw8  0xf002603e 0xe8		# ETH_MAC_CORE_UNICAST_ADDRESS0
[    0.990176] ++ETH++ gw8  0xf002603f 0x4d		# ETH_MAC_CORE_UNICAST_ADDRESS0
[    0.994118] ++ETH++ gw8  0xf0026040 0x7f		# ETH_MAC_CORE_UNICAST_ADDRESS1
[    0.998060] ++ETH++ gw8  0xf0026041 0xc4		# ETH_MAC_CORE_UNICAST_ADDRESS1
[    1.002435] nb8800 26000.ethernet eth0: MAC address 00:16:e8:4d:7f:c4

# ip link set eth0 up
[   33.202058] ENTER nb8800_open
[   33.205134] ++ETH++ gw32 0xf0026204 0x0000000f	# RECEIVE_CHANNEL_STATUS
[   33.209610] ++ETH++ gw32 0xf0026104 0x0000000f	# TRANSMIT_CHANNEL_STATUS
[   33.214626] ++ETH++ gw32 0xf002620c 0x9de36000	# RECEIVE_DESCRIPTOR_ADDRESS
[   33.219138] ++ETH++ gw8  0xf0026004 0x23		# ETH_MAC_CORE_RECEIVE_CONTROL
[   33.223097] ++ETH++ gw8  0xf0026000 0x1d		# ETH_MAC_CORE_TRANSMIT_CONTROL
[   33.227054] nb8800_mdio_write: reg=0 val=8000	# by genphy_soft_reset()
[   33.339579] nb8800_mdio_write: reg=0 val=0000	# by at803x_resume()
[   33.370911] nb8800_mdio_write: reg=18 val=ec00	# by at803x_config_intr()
[   33.384357] ++ETH++ gw32 0xf0026200 0x0000028f	# RECEIVE_CHANNEL_CONTROL
[   33.393330] EXIT  nb8800_open

[   33.393332] ENTER nb8800_stop
[   33.421731] nb8800_mdio_write: reg=9 val=0200	# by genphy_config_aneg()
[   33.444062] nb8800_mdio_write: reg=0 val=1200	# by genphy_restart_aneg()
[   33.466411] nb8800_mdio_write: reg=18 val=0000	# by at803x_config_intr() from phy_stop()
[   33.488859] ++ETH++ gw8  0xf0026004 0x03		# ETH_MAC_CORE_RECEIVE_CONTROL
[   33.492805] ++ETH++ gw8  0xf0026044 0x04		# ETH_MAC_CORE_MAC_MODE  *WHY ??*
[   33.496748] ++ETH++ gw32 0xf002610c 0x9dcac000	\
[   33.501217] ++ETH++ gw32 0xf0026100 0x000002ff	|
[   33.505750] ++ETH++ gw32 0xf0026104 0x00000004	| IRQ?
[   33.510213] ++ETH++ gw32 0xf0026204 0x00000004	| 
[   33.514674] ++ETH++ gw32 0xf0026218 0x003cc4a4	|
[   33.519146] ++ETH++ gw32 0xf0026104 0x00000001	/
[   33.605719] ++ETH++ gw32 0xf002610c 0x9dcac000	\
[   33.610187] ++ETH++ gw32 0xf0026100 0x000002ff	|
[   33.614717] ++ETH++ gw32 0xf0026104 0x00000004	| ANOTHER IRQ?
[   33.619178] ++ETH++ gw32 0xf0026204 0x00000004	|
[   33.623637] ++ETH++ gw32 0xf0026218 0x003cc4a4	|
[   33.628106] ++ETH++ gw32 0xf0026104 0x00000001	/
[   33.714689] ++ETH++ gw32 0xf002610c 0x9dcac000	|
[   33.719156] ++ETH++ gw32 0xf0026100 0x000002ff	| ANOTHER IRQ?
[   33.723686] ++ETH++ gw32 0xf0026104 0x00000004	|
[   33.724625] ++ETH++ gw8  0xf0026004 0x23		# ETH_MAC_CORE_RECEIVE_CONTROL
[   33.724627] ++ETH++ gw8  0xf0026044 0x00		# ETH_MAC_CORE_MAC_MODE *AGAIN ??*
[   33.724640] ++ETH++ gw32 0xf002620c 0x9de36000
[   33.724642] ++ETH++ gw8  0xf0026004 0x22		# ETH_MAC_CORE_RECEIVE_CONTROL AGAIN
[   33.724644] ++ETH++ gw8  0xf0026000 0x1c		# ETH_MAC_CORE_TRANSMIT_CONTROL
[   33.724690] nb8800_mdio_write: reg=18 val=0000	# by at803x_config_intr() from phy_disable_interrupts()
[   33.724913] nb8800_mdio_write: reg=0 val=1800	# by at803x_suspend() from phy_suspend()
[   33.819562] ++ETH++ gw32 0xf0026204 0x00000004
[   33.824021] ++ETH++ gw32 0xf0026218 0x003cc4a4
[   33.828518] EXIT  nb8800_stop

[   33.831505] ENTER nb8800_open
[   33.834491] ++ETH++ gw32 0xf0026204 0x0000000f
[   33.838959] ++ETH++ gw32 0xf0026104 0x0000000f
[   33.843970] ++ETH++ gw32 0xf002620c 0x9dc1e000
[   33.848449] ++ETH++ gw8  0xf0026004 0x23
[   33.852396] ++ETH++ gw8  0xf0026000 0x1d
[   33.856343] nb8800_mdio_write: reg=0 val=8000
[   33.969686] nb8800_mdio_write: reg=0 val=0000
[   34.001128] nb8800_mdio_write: reg=18 val=ec00
[   34.014631] ++ETH++ gw32 0xf0026200 0x06100a8f	# RECEIVE_CHANNEL_CONTROL
[   34.023592] EXIT  nb8800_open

[   34.023760] nb8800_mdio_write: reg=9 val=0200
[   34.023890] nb8800_mdio_write: reg=0 val=1200
[   34.023991] nb8800_mdio_write: reg=18 val=0000
[   34.024122] nb8800_mdio_write: reg=18 val=ec00
[   34.200493] ++ETH++ gw8  0xf002602e 0x00
[   34.204473] ++ETH++ gw8  0xf002602e 0x00
[   34.208418] ++ETH++ gw8  0xf0026028 0x01
[   34.212363] ++ETH++ gw8  0xf0026029 0x00
[   34.216305] ++ETH++ gw8  0xf002602a 0x5e
[   34.220248] ++ETH++ gw8  0xf002602b 0x00
[   34.224190] ++ETH++ gw8  0xf002602c 0x00
[   34.228132] ++ETH++ gw8  0xf002602d 0x01
[   34.232073] ++ETH++ gw8  0xf002602e 0xff
[   36.738162] nb8800_mdio_write: reg=18 val=0000
[   36.769615] nb8800_mdio_write: reg=18 val=ec00
[   36.836941] ++ETH++ gw8  0xf0026050 0x01
[   36.840884] ++ETH++ gw8  0xf002601c 0xff
[   36.844829] ++ETH++ gw8  0xf0026044 0x81
[   36.848780] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
[   36.865544] nb8800_mdio_write: reg=18 val=ec00
