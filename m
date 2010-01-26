From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 14:56:50 +0200
Message-ID: <87wrz5m3cd.fsf@purkki.valot.fi>
References: <87k4v5nuej.fsf@purkki.valot.fi> <4B5ED254.7010104@trash.net>
	<877hr5nkx0.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:34319 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab0AZM4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 07:56:54 -0500
In-Reply-To: <20100126.041610.226004766.davem@davemloft.net> (David Miller's message of "Tue\, 26 Jan 2010 04\:16\:10 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kalle.valo@iki.fi>
> Date: Tue, 26 Jan 2010 13:51:55 +0200
>
>> Let's take a bittorrent client as an example. The traffic it generates
>> is not important and it doesn't matter if bittorrent packets have
>> lower priority compared to other streams. What SO_PRIORITY value
>> should all bittorrent clients to use to mark their packets as low
>> priority (for example background class from IEEE 802.1d Annex G).
>
> This is a local policy decision.
>
> There is no universal way of doing any of this, really.

In my opinion we already now need a universal solution for the user
space applications to classify their streams. Having a local solution
doesn't get us far, people don't want to configure their laptops or
phones, they just want to use them :)

Having a well defined API for this makes it easier for everyone. Also
proprietary applications, like skype, can make use of QoS.

It doesn't matter how we map these internally in kernel, but the
interface to user space needs to be documented and maintained. I'm
willing to work on this, but we first need a concensus for the method.

I'm leaning towards using IPv4 DS/TOS and IPv6 Traffic Class fields
using IEEE 802.1d values. That way, with luck, the class of the packet
is visible even more than one hop. In fact cfg80211/mac80211 is
already doing this for IPv4:

/* Given a data frame determine the 802.1p/1d tag to use. */
unsigned int cfg80211_classify8021d(struct sk_buff *skb)
{
        unsigned int dscp;

        /* skb->priority values from 256->263 are magic values to
         * directly indicate a specific 802.1d priority.  This is used
         * to allow 802.1d priority to be passed directly in from VLAN
         * tags, etc.
          */
          if (skb->priority >= 256 && skb->priority <= 263)
             return skb->priority - 256;

             switch (skb->protocol) {
             case htons(ETH_P_IP):
                  dscp = ip_hdr(skb)->tos & 0xfc;
                       break;
                       default:
                        return 0;
                        }

                        return dscp >> 5;
}

http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=blob;f=net/wireless/util.c;h=be2ab8c59e3a9806425b2b958d87dfe50d80111d;hb=HEAD#l598

So the idea is that the three left most bits (Class Selector
Codepoints from DiffServ RFC 2474) would contain these values from
IEEE 802.1d-2004 Annex G:

0 best effort
1 background
2 (spare)
3 excellent effort
4 controlled load
5 video
6 voice
7 network control

What do people think of this? 

Feel free to flame, it was -20 C (-4 F) this morning. I would need
some warmth here :)

-- 
Kalle Valo
