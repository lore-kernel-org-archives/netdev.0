From: Tom Herbert <therbert@google.com>
Subject: Re: PATCH] net: Cache align dst refcnt
Date: Tue, 17 Dec 2013 11:51:02 -0800
Message-ID: <CA+mtBx9tdPRRgjoGLce1wizrbsoLLgzReEPMgPqwOiXMyiHvaA@mail.gmail.com>
References: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
	<1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:38698 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3LQTvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:51:03 -0500
Received: by mail-ie0-f171.google.com with SMTP id ar20so9069092iec.16
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 11:51:02 -0800 (PST)
In-Reply-To: <1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 10:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-17 at 10:15 -0800, Tom Herbert wrote:
>> ipv4_dst_check is coming up very high in perf top for TCP_RR tests and
>> it really is not doing much interesting. Looks like we have false
>> sharing with dst->refcnt. This patch cache aligns refcnt. There were
>> already some comments in the code that refcnt needs to be cache aligned.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  include/net/dst.h | 11 +++--------
>>  1 file changed, 3 insertions(+), 8 deletions(-)
>
> This is not needed. I wonder how you tested this.
>
Well I tested with simple netperf:

./super_netperf 200 -t TCP_RR -l 120 -H host -- -r 1,1

Without fix, ipv4_dst_check is 1.66% of CPU utilization (in top 10
functions). With fix, don't see ipv4_dst_check anymore and I don't see
any the cache misses being moved to other functions. This tiny
function is using more CPU that tcp_ack! :-(

> Problem was solved in commit 5635c10d976716
> ("net: make sure struct dst_entry refcount is aligned on 64 bytes")
>
> If this BUILD_BUG_ON() doesn't work for you, we should investigate !
>
Definitely not hitting the bug on. In any case, I'm wondering why is
cache alignment being hard coded here instead of using compiler
directives?

> static inline void dst_hold(struct dst_entry *dst)
> {
>         /*
>          * If your kernel compilation stops here, please check
>          * __pad_to_align_refcnt declaration in struct dst_entry
>          */
>         BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
>         atomic_inc(&dst->__refcnt);
> }
>
> Thanks
>
>
