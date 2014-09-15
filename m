From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: DSA and skb->protocol
Date: Mon, 15 Sep 2014 12:54:24 -0700
Message-ID: <541743F0.4090604@gmail.com>
References: <20140914153751.GA28585@lunn.ch> <5417223D.6070408@intel.com> <20140915183246.GG4255@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: seugene@marvell.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38713 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606AbaIOTyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:54:35 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so6993754pdb.14
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 12:54:34 -0700 (PDT)
In-Reply-To: <20140915183246.GG4255@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 11:32 AM, Andrew Lunn wrote:
>>> making me think it is not actually needed to change
>>> skb->protocol. When i remove this from edsa_xmit(), the warning goes
>>> away and networking seems to work O.K.
>>>
>>> Is this the right fix? Should we remove this setting of skb->protocol
>>> in the other dsa xmit functions?
>>>
>>> Thanks
>>> 	Andrew
>>>
>>
>> No, if anything they should all be using ETH_P_XDSA to indicate the
>> protocol between the switch and the host network interface.  When you
>> triggered this issue did you by any chance change some of the settings
>> on the host netdev for the switch?
> 
> This is the first time i've used DSA. I'm adding support for a new
> board which has a switch. So it is not too easy for me to go backwards
> and see when the WARNING started appearing.

We probably need something like a fix_feature() callback and/or a
NETDEV_FEAT_CHANGE() notifier callback to make sure we properly
recompute the slave network devices features based on the master network
device.

>  
>> The fix would probably be to update skb_network_protocol so that it can
>> sort out ETH_P_XDSA tags and get the Ethertype from the frame.
> 
> I'm not sure how easy getting the correct Ethertype from the frame
> is. The DSA tag can go in different places, depending on what tagging
> protocol is used.
> 
> For EDSA, which is what the board/switch i'm using uses, the tag is
> placed between the source address and the ethertype. If the frame is
> not an 802.1q, the tag is 8 bytes. If it is 802.1q the tag is 6
> bytes. The first 2 bytes are an Ethertype, indicating EDSA is being
> used. You need to look at byte 4 of the tag to know how long it is, in
> order to find the second Ethertype in the frame, for the SDU.
> 
> Similarly DSA tagging, is either 2 bytes or 4 bytes, and you need to
> look at byte 0 of the tag to determine its length. There is no
> Ethertype to know that DSA is being used.
> 
> Trailer tagging is different. It places 4 bytes at the end of the
> frame, applying padding for frames < 60 bytes. The Ethertype is not
> touched.
> 
> Florian recently added brcm tagging. This again goes between the
> Source address and the Ethertype, and does not define a valid
> Ethertype.
> 
> So unless you know what tagging protocol is in use, it is very hard to
> peer inside the frame to work out what the real SDU Ethertype is. So
> it seems easier to just pass it in skb->protocol.

Right, which is probably why the tag xmit() functions do override
skb->protocol to directly provide a value to the master device driver,
that way we do not have to go deep down into dissecting the frame.

I am not sure if there are possible scenarios where we may have to
handle mixed EDSA+DSA traffic, I suppose that might exist with a
combination of Marvell switches. If that's the case, we still need a
per-SKB information as opposed to looking directly into dev->dsa_ptr.
--
Florian
