From: "Jiri Klimes" <klimes@centrum.cz>
Subject: Re: XFRM structures binary compability
Date: Fri, 16 Jan 2009 14:40:02 +0100
Message-ID: <200901161440.3616@centrum.cz>
References: <200901091331.18342@centrum.cz> <496B56B7.3080703@trash.net> <20090114.145552.71463842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1009.centrum.cz ([90.183.38.139]:45577 "EHLO
	mail1009.centrum.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbZAPNkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 08:40:06 -0500
Received: by mail1009.centrum.cz id S738277637AbZAPNkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:40:02 +0100
In-Reply-To: <20090114.145552.71463842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 14 Jan 2009 14:55:52 -0800 (PST)

>From: Patrick McHardy <kaber@trash.net>
>Date: Mon, 12 Jan 2009 15:41:59 +0100
>
>> klimes@centrum.cz wrote:
>> > What causes my trouble is "xfrm_usersa_info" which is padded with 7 bytes at the end in 64-bit,
>> > so that the whole structure is 224 bytes in 64bit application against 220 bytes in 32bit (just 3-byte padding).
>> > An explicit 7-byte padding in the structure would cure the case, IMHO.
>>
>> That would break on 32 bit because userspace binaries compiled
>> with the old layout would send "short" messages. I'd suggest
>> to explicitly use the smaller value for the xfrm_msg_min checks
>> (i.e. replace sizeof by numerical constant).
>
>I'll commit the following and queue it up for -stable.
>
>Thanks.
>
>xfrm: For 32/64 compatability wrt. xfrm_usersa_info
>

David, I'm afraid the fix is not correct.
xfrm_msg_min is not used just for length check, but mainly to find start of the netlink attributes.
Therefore the patch will work for the case with no attributes. However it won't work properly in case
attributes are used (which is in most cases).
So, I suggest to revert the patch.

Alas, we have no other info about length of xfrm structures except for sizeof() that is unfortunately
different for 32- and 64-bit.

I see no solution to obtain 32/64-bit compatibility without impacting anybody :-(
My first proposal (padding structures explicitly) would bring 32/64 compatibility, but break existing
user applications. Nevertheless I'm afraid that any other solution (e.g. storing the length of the struct
directly in the message) would need to change the structures, causing backward compatibility break.
Either way, making a change (breaking backward compatibility) or letting things as they are (accepting
32/64-bit incompatibility), the status should be documented somewhere (man pages?).

BTW, xfrm_userpolicy_info is the same story as xfrm_usersa_info. xfrm_userpolicy_info is 164 bytes long on 32-bit.
However it has 168 bytes on 64-bit (4 byte pad at the end).

Regards,
Jiri Klimes


