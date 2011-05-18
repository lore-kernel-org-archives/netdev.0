From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 14:06:33 +0200
Message-ID: <BANLkTimoOVytWWTS7Uph_J1401Yxrqr5ug@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	<1305707358.2983.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59295 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932763Ab1ERMGd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 08:06:33 -0400
Received: by pvg12 with SMTP id 12so672665pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 05:06:33 -0700 (PDT)
In-Reply-To: <1305707358.2983.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 18 mai 2011 =E0 10:06 +0200, Jacek Luczak a =E9crit :
>> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
>
>> > If you're removing items from this list, you must be a writer here=
, with
>> > exclusive access. So rcu_read_lock()/rcu_read_unlock() is not nece=
ssary.
>>
>> I could agree to some extend ... but strict RCU section IMO is neede=
d here.
>> I can check this if the issue exists.
>>
>
> I can tell you for sure rcu_read_lock() is not needed here. Its only
> showing confusion from code's author.
>
> Please read Documentation/RCU/listRCU.txt for concise explanations,
> line 117.
>
>
>> > Therefore, I guess following code is better :
>> >
>> > list_for_each_entry(addr, &bp->address_list, list) {
>> > =A0 =A0 =A0 =A0list_del_rcu(&addr->list);
>> > =A0 =A0 =A0 =A0call_rcu(&addr->rcu, sctp_local_addr_free);
>> > =A0 =A0 =A0 =A0SCTP_DBG_OBJCNT_DEC(addr);
>> > }
>> >
>> > Then, why dont you fix sctp_bind_addr_clean() instead ?
>> >
>> > if 'struct sctp_sockaddr_entry' is recu protected, then all frees =
should
>> > be protected as well.
>>
>> The _clean() as claimed by Vlad is called many times from various pl=
aces
>> in code and this could give a overhead. I guess Vlad would need to c=
omment.
>
> I guess a full review of this code is needed. You'll have to prove
> sctp_bind_addr_clean() is always called after one RCU grace period if
> you want to leave it as is.

Eric this is actually good point which I think did not found at first
glance. As the original
issue occurs between _clean() and _conflict() then if the former is
used here and
there we can hit the grace period not only in that case. By that then
_clean() should
be ,,fixed''. Right?

-Jacek
