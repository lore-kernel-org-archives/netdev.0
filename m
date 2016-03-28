From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Mon, 28 Mar 2016 15:34:50 -0700
Message-ID: <CAM_iQpWDrR_z59UkCpSKKCowLmxZimSnQv-4SfbXRxN6tvQXSw@mail.gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	<1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpVDN_LPsa2XgVWoqMjrOYpg9JNjPJVwEvTuxPgYyWRWmg@mail.gmail.com>
	<1458870680.6473.13.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpUUhMNjx6=-5HCJvJepLstFR2UQHSBb-q3RZcYaOJ6pbg@mail.gmail.com>
	<1458929477.6473.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Wei Wang <weiwan@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:33208 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbcC1Wev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 18:34:51 -0400
Received: by mail-yw0-f174.google.com with SMTP id h65so100585042ywe.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 15:34:51 -0700 (PDT)
In-Reply-To: <1458929477.6473.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-03-25 at 10:17 -0700, Cong Wang wrote:
>
>> 1) sock lock protects the whole update: the whole check, update, recheck,
>> set logic, to make sure another CPU will not do the same to the same socket
>> at the same time.
>>
>> 2) the dst itself is safe, because it is always refcounted, and we use xchg()
>> to change the pointer in sk_dst_cache.
>>
>> Or am I still missing anything here?
>
> As TCP always lock the socket before doing its heavy stuff,
> it can use a variant of sk_dst_cache manipulations that do not use extra
> atomic operations.
>
> But UDP gets xchg() to safely exchange sk_dst_cache, because we do not
> feel locking the socket is needed for UDP for typical uses (! cork)
>
> If you hold the socket lock in ICMP handler, then it would be
> inconsistent with udp sendmsg() where we do not hold the socket lock.
>
> Since I believe udp sendmsg() is fine, I do believe you do not need to
> lock the socket, and then care about socket being owned by the user.

I see, seems the whole update logic is safe to become lock-free, then
commit 8141ed9fcedb278f4a3a78680591bef1e55f75fb can be just
reverted.

OTOH, other bh_lock_sock() callers need it to update queues etc.,
here we only need to check and update one single pointer in sk.

Steffen?

Thanks.
