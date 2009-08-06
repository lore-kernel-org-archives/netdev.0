From: Jussi Maki <joamaki@gmail.com>
Subject: Re: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Thu, 6 Aug 2009 09:32:37 +0300
Message-ID: <ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
References: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com>
	 <20090805.120831.66033097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:48623 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbZHFGch convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 02:32:37 -0400
Received: by qyk34 with SMTP id 34so630751qyk.33
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 23:32:37 -0700 (PDT)
In-Reply-To: <20090805.120831.66033097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Changing the (h >> 16) to ((h >> 16) ^ (h >> 24)) still has the same
problem as given in the example,
that is if you have a set of transports with incrementing addresses
(192.168.0.1-172.16.0.1, 192.168.0.2-172.16.0.2,..) they
still hash to the same value. The reason to this is that it's doing
src^dst in __xfrm4_daddr_saddr_hash.

Should I pursue with fixing the inlining issue in my patch or would
you have any suggestions how I could
fix this by perhaps modifying __xfrm4_daddr_saddr_hash?

On Wed, Aug 5, 2009 at 10:08 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: Jussi M=C3=A4ki <joamaki@gmail.com>
> Date: Wed, 5 Aug 2009 10:41:42 +0300
>
>> Hi,
>>
>> The current xfrm hash functions perform very poorly when a number of
>> policies have the same
>> last byte in source and destination addresses.
>>
>> For example with __xfrm_dst_hash, hmask of 0xfff:
>>
>> 192.168.0.1-172.16.0.1 hashes to 3258
>> 192.168.0.2-172.16.0.2 hashes to 3258
>> ... and so on.
>>
>> This patch addresses the issue by rewriting the xfrm
>> hash functions to use the Jenkins' hash function.
>>
>> Signed-off-by: Jussi Maki <joamaki@gmail.com>
>
> jhash expands to a lot of code, and given your description of the
> problem, you could have fixed it by adding 2 instructions (see below)
> instead of 20 or 30 (jhash instruction count) at every hash
> calculation site.
>
> Simply change every instance of:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(h >> 16)
>
> with
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0((h >> 16) ^ (h >> 24))
>
> As much as I love jhash, it's overkill for fixing this problem.
>
> And if we do end up using jhash, it should get inlined into a
> seperate non-inline function instead of expanding that monster
> 4 or 5 times throughout the XFRM code.
>
> I'm not applying this, either make the simple one-liner fix I
> suggested above work or move the jhash into a non-inline expansion.
>
