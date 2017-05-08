From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Mon, 8 May 2017 14:03:47 +0200
Message-ID: <59105EA3.9030203@aoifes.com>
References: <58F9FD64.80506@aoifes.com> <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com> <20170427130450.GL17172@lunn.ch>
 <59032D8B.1010801@aoifes.com> <20170428122259.GH13231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-00-2.dondominio.net ([31.214.176.15]:32912 "EHLO
        smtp-relay-00-2.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751181AbdEHMDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 08:03:51 -0400
In-Reply-To: <20170428122259.GH13231@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/04/17 14:22, Andrew Lunn wrote:
>>> Since you are using DSA, you will have DSA tags enabled on frames
>>> to/from the switch. This adds an extra 8 byte header in the frame.  My
>>> guess is, it is this header, not the VLAN tag which is causing you MTU
>>> issues.
>>
>> But it is strange because, as I have said above, we have the same
>> configuration working properly on a kernel 4.1 (with OpenWrt), and
>> we have the MTU set to 1500.

Hi Andrew,

Sorry for the delay in my answer, I was out of the office.

>
> If you look at sky2.c:
>
> static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
> {
>          unsigned size;
>
>          /* Space needed for frame data + headers rounded up */
>          size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
>
>          /* Stopping point for hardware truncation */
>          return (size - 8) / sizeof(u32);
> }
>
> This is not going to be big enough for a frame with a DSA header.
>

Then, would be a good fix add 8 bytes to the size variable in this function?

>>> I think this is the first time i've seen sky2 used in a DSA
>>> setup. mv643xx or mvneta is generally what is used, when using Marvell
>>> chipsets. These drivers are more lenient about MTU, and are happy to
>>> pass frames with additional headers.
>>>
>>
>> We use the mv88e6xxx (as our switch is mv88e6176) and it depends on
>> DSA driver in the kernel (isn't it?).
>
> That is correct. But i was talking about the Ethernet interface. All
> the designs i've seen use an mv643xxx Ethernet interface, or an mvneta
> interface. This is the first time i've seen a sky2 used, which is why
> i'm not too surprised you have issues.
>
>>> Changing the MTU like this is not a good fix. It will allow you to
>>> receive frames which are bigger, but it also means the local network
>>> stack will generate bigger frames to be transmitted. You probably need
>>> to modify the sky2 driver to allow it to receive frames bigger than
>>> the interface MTU, by about 8 bytes.
>>
>> Should the DSA driver remove the DSA tags before pass the frames to
>> sky2 interface?
>
> The DSA driver is adding the DSA tags to the frame and passing these
> tagged frames to the sky2 interface. Frames going to/from the switch
> will always have such tags.
>
>>>> [ 4901.032989] sky2 0000:04:00.0 marvell: tx timeout
>>>> [ 4904.722670] sky2 0000:04:00.0 marvell: Link is up at 1000 Mbps,
>>>> full duplex, flow control both
>>>
>>> Between the sky2 and the switch, do you have two back-to-back PHYs or
>>> are you connecting the RGMII interfaces together?
>>
>> I think that we have two back-to-back PHYs, but I am going to double
>> check this with the hardware team.
>
> This could be your problem them. The mv88e6xxx switch driver assumes
> there is a straight rgmii-rgmii connection, no PHYs. So it hard
> configures the 'CPU' port to its fastest speed, with the link forced
> up. If you actually have a PHY there, this might not work so well. I
> don't know if the switch PHY is going to do autoneg correctly. Try
> using ethtool to look at the sky2 PHY and see what state it is in.
>
>        Andrew
>

The output of ethtool of sky2 interface is the following:

Settings for marvell:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: No
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 0
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown
         Supports Wake-on: pg
         Wake-on: d
         Current message level: 0x000000ff (255)
                                drv probe link timer ifdown ifup rx_err 
tx_err
         Link detected: yes


And the output of ethtool of eth2@marvell (interface that I have connected):

Settings for eth2:
         Supported ports: [ TP MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                              100baseT/Half 100baseT/Full
         Link partner advertised pause frame use: No
         Link partner advertised auto-negotiation: No
         Speed: 100Mb/s
         Duplex: Full
         Port: MII
         PHYAD: 2
         Transceiver: external
         Auto-negotiation: on
         Supports Wake-on: d
         Wake-on: d
         Link detected: yes


Do you see something strange in these outputs?

Thanks,

Rafa
