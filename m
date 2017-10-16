From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 18:09:41 +0200
Message-ID: <20171016160941.GA13339@lunn.ch>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: Rodney Cummings <rodney.cummings@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 03:23:42PM +0000, Rodney Cummings wrote:
> I am concerned about this proposed change.
> 
> According to IEEE Std 802.1Q, a "higher layer entity" (i.e. end
> station) that is internal to the bridge (i.e. switch) can use the
> same individual global MAC address that the switch is using. That
> behavior is common.
>
> Use of a local semi-random MAC address is dangerous on
> Ethernet. Local MAC addresses can only be safely used in very narrow
> use cases, most of which are Wi-Fi. Generally speaking, local MAC
> addresses can be duplicated in the network, which causes many
> Ethernet protocols to break down. Therefore, general-purpose
> implementations like DSA cannot use a local MAC address in a
> reliable manner.

Hi Rodney

This is interesting. So i did some research. The Marvell Switch only
uses this MAC address for Pause frames. Nothing else.

802.3-2015 Section 2, Annex 31B says:

  The globally assigned 48-bit multicast address 01-80-C2-00-00-01 has
  been reserved for use in MAC Control PAUSE frames for inhibiting
  transmission of data frames from a DTE in a full duplex mode IEEE
  802.3 LAN. IEEE 802.1D-conformant bridges will not forward frames
  sent to this multicast destination address, regardless of the state
  of the bridge’s ports, or whether or not the bridge
  implements the MAC Control sublayer. To allow generic full duplex
  flow control, stations implementing the PAUSE operation shall
  instruct the MAC (e.g., through layer management) to enable
  reception of frames with destination address equal to this multicast
  address.

  NOTE—By definition, an IEEE 802.3 LAN operating in full
  duplex mode comprises exactly two stations, thus there is no
  ambiguity regarding the destination DTE’s identity. The use
  of a well-known multicast address relieves the MAC Control sublayer
  and its client from having to know, and maintain knowledge of, the
  individual 48-bit address of the other DTE in a full duplex
  environment.

  When MAC Control PFC operation (see Annex 31D and IEEE Std 802.1Q)
  has been enabled, MAC Control PAUSE operation shall be disabled.

So, received Pause frames never leave the MAC. They don't get bridged,
nor do they get passed up for host processing. They are purely point
to point between two MAC peers. The destination is unambiguous. It is
simple the other MAC peer. The destination address makes it clear it
is a pause frame, the the source address seems to be unneeded.

In this context, a random MAC addresses are safe.

In the more general case, i would agree with you. Collisions are
possible, causing problems.

   Andrew
