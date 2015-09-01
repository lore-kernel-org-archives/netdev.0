From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] skbuff: Fix skb checksum flag on skb pull
Date: Tue, 1 Sep 2015 12:20:09 -0700
Message-ID: <CALnjE+p0wa7ovOxn3E164GkZ35OLY-LM7-JA42E1K5AOycpZ0Q@mail.gmail.com>
References: <1441061746-1492-1-git-send-email-pshelar@nicira.com>
	<CALx6S34JrU5_S7wtSQsBHSVeUFjryHeJtGsCoZEdUtyy7F+__A@mail.gmail.com>
	<CALnjE+q8N3y9D+9SVqm3w6f3KwBNtXW8A9RtVe5NFMA8aftbdA@mail.gmail.com>
	<CALx6S36w0wYWXPwanxZeR=bdxHYZ=hOJFtk+j=jFAjmdgfDnRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33785 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbIATUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 15:20:10 -0400
Received: by iofh134 with SMTP id h134so13322110iof.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 12:20:09 -0700 (PDT)
In-Reply-To: <CALx6S36w0wYWXPwanxZeR=bdxHYZ=hOJFtk+j=jFAjmdgfDnRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 7:19 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Aug 31, 2015 at 10:15 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Mon, Aug 31, 2015 at 9:12 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Mon, Aug 31, 2015 at 3:55 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>>> VXLAN device can receive skb with checksum partial. But the checksum
>>>> offset could be in outer header which is pulled on receive. Such skb
>>>> can cause the panic when checksum is calculated on skb. Following patch
>>>> fixes the bug by setting checksum unnecessary while pulling outer header.
>>>>
>>> Okay, I think I understand what you are doing. I suggest in the
>>> openvswitch path, if there is a checksum CHECKSUM_PARTIAL that refers
>>> to the outer headers which must have been verified at this point then
>>> set to CHECKSUM_NONE-- assuming CHECKSUM_UNNECESSARY on the inner
>>> header is not correct in this case. If the CHECKSUM_PARTIAL refers to
>>> the inner header then you can call skb_checksum_help to resolve an
>>> inner checksum.
>>>
>>
>> That would be OVS specific fix, But I do see skb_checksum_help()
>> called in multiple places outside OVS that could result in similar
>> kernel panic. Therefore I want to solve it up in networking stack
>> rather than in OVS.
>>
> Please try to reproduce this out of OVS from the top of the tree then
> and report down exactly where panic is occurring the code. Unlike most
> of the of the other cases where skb_checksum_help() is being called
> this in the RX path so skb is probably not pulled over the checksum
> offset for those. Even so, if the skb is pulled beyond the checksum
> offset then this should result in a negative offset in
> skb_checksum_start_offset(skb) which should be okay. It looks like
> this in itself should not be causing your panic.
>

ip_do_fragment() also calls skb_checksum_help() that can results in
similar panic. But it is not easy to reproduce it in this case due to
call site is in exception path.
The negative checksum offset can atleast cause assert failure in
skb_checksum_help(). I will send patch to fix that.
