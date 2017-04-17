From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Use of skb_unclone in drivers
Date: Mon, 17 Apr 2017 09:07:12 -0700
Message-ID: <1492445232.10587.107.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAE_XsMLcUbCdJvzkW8E0rh7NjJHG8vEa-PhKgR3RzzFHaGBS6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35929 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754157AbdDQQHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 12:07:14 -0400
Received: by mail-pg0-f49.google.com with SMTP id g2so73811844pge.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 09:07:14 -0700 (PDT)
In-Reply-To: <CAE_XsMLcUbCdJvzkW8E0rh7NjJHG8vEa-PhKgR3RzzFHaGBS6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 16:02 +0100, James Hughes wrote:
> Netdevs,
> 
> We have recently got to the bottom of an issue which we have been
> encountering on a Raspberry Pi being used as an access point, and we
> need a bit of advice on the correct way of fixing the issue.
> 
> The set up is a Raspberry Pi 3 running hostapd on its inbuilt wireless
> adaptor (Brcm43438 ), bridged to the built in ethernet adaptor
> (smsc9514). Using the standard drivers for these devices as of 4.9
> (looking at 4.11, no changes noted that would affect the issue. I will
> be trying the latest kernel once I get back in to the office).
> 
> We were encountering an error in the Brcm Wireless driver that after
> investigation was a skb_buff being corrupted by an action in the smsc
> Ethernet driver. Further digging shows that the bridge was cloning an
> incoming skb from the Ethernet, then sending it out to both the
> Ethernet and wlan ports. This mean that both the Ethernet driver and
> the wireless driver were looking at the same physical data, and one or
> both were altering that data in different ways (varied headers) ,
> which mean that headers were corrupted. This was only happening on
> broadcast packets.
> 
> We can fix the issue by, in the drivers, using skb_unclone in
> appropriate places in the driver.
> 
> So now to the questions. Is adding the unclone to the drivers the
> correct way of dealing with this issue? Examining other drivers shows
> that unclone is not particularly common, presumably in many cases,
> where the driver does not alter the skb, it doesn't matter. However,
> in any case where a driver may add header information to the skb (as
> is the case with the Brcm wireless driver), when the incoming skb has
> been cloned, the results must surely be undetermined unless an unclone
> is performed.
> 
> Or, is the bridging code making a mistake by cloning the skb and
> passing it to multiple recipients?
> 


bridge code is fine.

Problem is that some drivers lack calls to skb_cow_head() before they
mess with headers.
