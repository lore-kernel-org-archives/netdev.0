From: James Hughes <james.hughes@raspberrypi.org>
Subject: Re: Use of skb_unclone in drivers
Date: Tue, 18 Apr 2017 09:34:10 +0100
Message-ID: <CAE_XsMLghPZTe69-eUF322U53gZcUfXzu-0VScf7yNCrLkgOBA@mail.gmail.com>
References: <CAE_XsMLcUbCdJvzkW8E0rh7NjJHG8vEa-PhKgR3RzzFHaGBS6w@mail.gmail.com>
 <1492445232.10587.107.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00252a01.pphosted.com ([62.209.51.214]:55168 "EHLO
        mx07-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755461AbdDRI43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 04:56:29 -0400
Received: from pps.filterd (m0102628.ppops.net [127.0.0.1])
        by mx07-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I8NPpc025825
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:34:12 +0100
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
        by mx07-00252a01.pphosted.com with ESMTP id 29u8x09tvu-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:34:11 +0100
Received: by mail-wm0-f70.google.com with SMTP id b87so3681279wmi.14
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 01:34:11 -0700 (PDT)
In-Reply-To: <1492445232.10587.107.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

Quick check on that function - very similar to unclone which we know
ameliorates the issue, just has the headroom parameter rather than
priority. So clearly the right way to go. Just one more question I
hope - where is the appropriate  place for the skb_cow_head call in
the driver - at the main entry point, or closer or in the function(s)
that may alter the header itself?

James

(Apologies to Eric for originally sending him this message rather than
to netdev - was doing it all from a phone and screwed it up)

On 17 April 2017 at 17:07, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-04-17 at 16:02 +0100, James Hughes wrote:
>> Netdevs,
>>
>> We have recently got to the bottom of an issue which we have been
>> encountering on a Raspberry Pi being used as an access point, and we
>> need a bit of advice on the correct way of fixing the issue.
>>
>> The set up is a Raspberry Pi 3 running hostapd on its inbuilt wireless
>> adaptor (Brcm43438 ), bridged to the built in ethernet adaptor
>> (smsc9514). Using the standard drivers for these devices as of 4.9
>> (looking at 4.11, no changes noted that would affect the issue. I will
>> be trying the latest kernel once I get back in to the office).
>>
>> We were encountering an error in the Brcm Wireless driver that after
>> investigation was a skb_buff being corrupted by an action in the smsc
>> Ethernet driver. Further digging shows that the bridge was cloning an
>> incoming skb from the Ethernet, then sending it out to both the
>> Ethernet and wlan ports. This mean that both the Ethernet driver and
>> the wireless driver were looking at the same physical data, and one or
>> both were altering that data in different ways (varied headers) ,
>> which mean that headers were corrupted. This was only happening on
>> broadcast packets.
>>
>> We can fix the issue by, in the drivers, using skb_unclone in
>> appropriate places in the driver.
>>
>> So now to the questions. Is adding the unclone to the drivers the
>> correct way of dealing with this issue? Examining other drivers shows
>> that unclone is not particularly common, presumably in many cases,
>> where the driver does not alter the skb, it doesn't matter. However,
>> in any case where a driver may add header information to the skb (as
>> is the case with the Brcm wireless driver), when the incoming skb has
>> been cloned, the results must surely be undetermined unless an unclone
>> is performed.
>>
>> Or, is the bridging code making a mistake by cloning the skb and
>> passing it to multiple recipients?
>>
>
>
> bridge code is fine.
>
> Problem is that some drivers lack calls to skb_cow_head() before they
> mess with headers.
>
>
>
>
>
>



-- 
James Hughes
Principal Software Engineer,
Raspberry Pi (Trading) Ltd
