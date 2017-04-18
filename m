From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Use of skb_unclone in drivers
Date: Tue, 18 Apr 2017 09:34:33 -0700
Message-ID: <75112dc9-dd75-3473-b39d-0687cdff3391@gmail.com>
References: <CAE_XsMLcUbCdJvzkW8E0rh7NjJHG8vEa-PhKgR3RzzFHaGBS6w@mail.gmail.com>
 <1492445232.10587.107.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAE_XsMLghPZTe69-eUF322U53gZcUfXzu-0VScf7yNCrLkgOBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: James Hughes <james.hughes@raspberrypi.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:36532 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752358AbdDRQeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:34:36 -0400
Received: by mail-qt0-f169.google.com with SMTP id g60so63990086qtd.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:34:36 -0700 (PDT)
In-Reply-To: <CAE_XsMLghPZTe69-eUF322U53gZcUfXzu-0VScf7yNCrLkgOBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 01:34 AM, James Hughes wrote:
> Thanks,

(please don't top-post on netdev)

> 
> Quick check on that function - very similar to unclone which we know
> ameliorates the issue, just has the headroom parameter rather than
> priority. So clearly the right way to go. Just one more question I
> hope - where is the appropriate  place for the skb_cow_head call in
> the driver - at the main entry point, or closer or in the function(s)
> that may alter the header itself?

You should place the call to skb_cow_head() in the same function(s) that
do(es) the header(s) modifications, that way it's clear to the reader
what the intent is, and the code is reasonably easy to audit.

> 
> James
> 
> (Apologies to Eric for originally sending him this message rather than
> to netdev - was doing it all from a phone and screwed it up)
> 
> On 17 April 2017 at 17:07, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Mon, 2017-04-17 at 16:02 +0100, James Hughes wrote:
>>> Netdevs,
>>>
>>> We have recently got to the bottom of an issue which we have been
>>> encountering on a Raspberry Pi being used as an access point, and we
>>> need a bit of advice on the correct way of fixing the issue.
>>>
>>> The set up is a Raspberry Pi 3 running hostapd on its inbuilt wireless
>>> adaptor (Brcm43438 ), bridged to the built in ethernet adaptor
>>> (smsc9514). Using the standard drivers for these devices as of 4.9
>>> (looking at 4.11, no changes noted that would affect the issue. I will
>>> be trying the latest kernel once I get back in to the office).
>>>
>>> We were encountering an error in the Brcm Wireless driver that after
>>> investigation was a skb_buff being corrupted by an action in the smsc
>>> Ethernet driver. Further digging shows that the bridge was cloning an
>>> incoming skb from the Ethernet, then sending it out to both the
>>> Ethernet and wlan ports. This mean that both the Ethernet driver and
>>> the wireless driver were looking at the same physical data, and one or
>>> both were altering that data in different ways (varied headers) ,
>>> which mean that headers were corrupted. This was only happening on
>>> broadcast packets.
>>>
>>> We can fix the issue by, in the drivers, using skb_unclone in
>>> appropriate places in the driver.
>>>
>>> So now to the questions. Is adding the unclone to the drivers the
>>> correct way of dealing with this issue? Examining other drivers shows
>>> that unclone is not particularly common, presumably in many cases,
>>> where the driver does not alter the skb, it doesn't matter. However,
>>> in any case where a driver may add header information to the skb (as
>>> is the case with the Brcm wireless driver), when the incoming skb has
>>> been cloned, the results must surely be undetermined unless an unclone
>>> is performed.
>>>
>>> Or, is the bridging code making a mistake by cloning the skb and
>>> passing it to multiple recipients?
>>>
>>
>>
>> bridge code is fine.
>>
>> Problem is that some drivers lack calls to skb_cow_head() before they
>> mess with headers.
>>
>>
>>
>>
>>
>>
> 
> 
> 


-- 
Florian
