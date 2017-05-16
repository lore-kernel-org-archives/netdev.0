From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Tue, 16 May 2017 12:50:56 +0200
Message-ID: <591AD990.901@aoifes.com>
References: <58F9FD64.80506@aoifes.com> <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com> <20170427130450.GL17172@lunn.ch>
 <59032D8B.1010801@aoifes.com> <20170428122259.GH13231@lunn.ch>
 <59105EA3.9030203@aoifes.com> <20170508123852.GI27709@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-00-5.dondominio.net ([31.214.176.18]:54413 "EHLO
        smtp-relay-00-5.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751426AbdEPKvA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 06:51:00 -0400
In-Reply-To: <20170508123852.GI27709@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/17 14:38, Andrew Lunn wrote:
>>> static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
>>> {
>>>          unsigned size;
>>>
>>>          /* Space needed for frame data + headers rounded up */
>>>          size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
>>>
>>>          /* Stopping point for hardware truncation */
>>>          return (size - 8) / sizeof(u32);
>>> }
>>>
>>> This is not going to be big enough for a frame with a DSA header.
>>>
>>
>> Then, would be a good fix add 8 bytes to the size variable in this function?
>
> Yes. Also look at the transmit code, is there again a limit based on
> the MTU.

Hi Andrew,

Adding 8 bytes (sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN + 8 
(EDSA_HLEN)) does not fix the error, because the interface keep having a 
maximum length of 1518 bytes (sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN).

The polling function of sky2 driver (sky2_poll) calls to the function 
sky2_status_intr (with the parameter struct sky2_hw *hw). The 
sky2_status_intr function gets the status of the list elements (struct 
sky2_status_le) from the sky2_hw parameter and, from the sky2_status_le, 
gets the maximum length (1518) and the status code (0x5f20010). When the 
latter function (sky2_status_intr) calls to the sky2_receive function 
with the parameters length and status, it reports about the error (rx 
error, status 0x5f20010
length 1518).

I don't know who sets the maximum length (1518) and the status code 
(0x5f20010) of the packets. Is it possible that these values to be set 
outside the sky2 code?

Thanks,

Rafa

>
>> Settings for marvell:
>>          Supported ports: [ TP ]
>>          Supported link modes:   10baseT/Half 10baseT/Full
>>                                  100baseT/Half 100baseT/Full
>>                                  1000baseT/Half 1000baseT/Full
>>          Supported pause frame use: No
>>          Supports auto-negotiation: Yes
>>          Advertised link modes:  10baseT/Half 10baseT/Full
>>                                  100baseT/Half 100baseT/Full
>>                                  1000baseT/Half 1000baseT/Full
>>          Advertised pause frame use: No
>>          Advertised auto-negotiation: No
>>          Speed: 1000Mb/s
>>          Duplex: Full
>>          Port: Twisted Pair
>>          PHYAD: 0
>>          Transceiver: internal
>>          Auto-negotiation: on
>>          MDI-X: Unknown
>>          Supports Wake-on: pg
>>          Wake-on: d
>>          Current message level: 0x000000ff (255)
>>                                 drv probe link timer ifdown ifup
>> rx_err tx_err
>>          Link detected: yes
>>
>
> So this suggests there is a real PHY there, and it is
> auto-negotiating.
>
> What we cannot see is the status for the PHY it connects to. But since
> this PHY has established a link, the other PHY is probably O.K. It is
> just a bit unsafe, since you are relying on reset behaviour. There is
> nothing in software configuring the second PHY to make it
> auto-negotiate.
>
> 	Andrew
>
>
