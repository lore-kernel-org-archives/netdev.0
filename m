From: Li Yu <raise.sail@gmail.com>
Subject: Re: v3 for tcp friends?
Date: Wed, 23 Jan 2013 15:58:46 +0800
Message-ID: <50FF9836.4060106@gmail.com>
References: <20120903.154833.1547153833820955116.davem@davemloft.net>  <CAEkNxbGJ6OGy3HDSeToXO_cDt7azpRZvy_CbQH0_UJ_mCS2s3w@mail.gmail.com>  <20120904.125841.2293649688957878987.davem@davemloft.net>  <50FCEE64.80203@gmail.com> <50FCEEC5.9010404@gmail.com>  <CA+WLrf8xuJ3UXK-tZQykuTPMXu67WsNKWNuNzBKk7MBAidW-CQ@mail.gmail.com>  <CAEkNxbH0MAAU9oiwwrFTbMJP1yzfNdxD5NDdZOqGnvhTLvodoQ@mail.gmail.com>  <50FF5592.60008@gmail.com>  <50FF7F64.2060902@gmail.com> <1358923606.12374.746.camel@edumazet-glaptop> <50FF8F75.4000903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bruce Curtis <brutus@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:49740 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887Ab3AWH67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 02:58:59 -0500
Received: by mail-pa0-f48.google.com with SMTP id fa1so4621731pad.21
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 23:58:59 -0800 (PST)
In-Reply-To: <50FF8F75.4000903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 15:21, Li Yu =E5=86=99=E9=
=81=93:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8823=E6=97=A5 14:46, Eric Dumazet =E5=
=86=99=E9=81=93:
>> On Wed, 2013-01-23 at 14:12 +0800, Li Yu wrote:
>>> Oops, this hang is not since TCP friends patch!
>>>
>>> sk_sndbuf_get() is broken by 32 bits integer overflow
>>> because of so large value in net.ipv4.tcp_{rmem,wmem}.
>>>
>>> but this hang also can be found in net-next.git
>>> (3.8.0-rc3+), if we run below commands, then all new
>>> TCP connections stop working!
>>>
>>> # when TCP friends is disabled
>>> sysctl -w net.ipv4.tcp_rmem=3D"4096 4294967296 4294967296" # 4GB
>>> sysctl -w net.ipv4.tcp_wmem=3D"4096 4294967296 4294967296"
>>
>> Right we need to make sure we dont overflow.
>>
>> Try the following fix :
>>
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index a25e1d2..1459145 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -549,14 +549,16 @@ static struct ctl_table ipv4_table[] =3D {
>>           .data        =3D &sysctl_tcp_wmem,
>>           .maxlen        =3D sizeof(sysctl_tcp_wmem),
>>           .mode        =3D 0644,
>> -        .proc_handler    =3D proc_dointvec
>> +        .extra1        =3D &zero,
>> +        .proc_handler    =3D proc_dointvec_minmax
>>       },
>>       {
>>           .procname    =3D "tcp_rmem",
>>           .data        =3D &sysctl_tcp_rmem,
>>           .maxlen        =3D sizeof(sysctl_tcp_rmem),
>>           .mode        =3D 0644,
>> -        .proc_handler    =3D proc_dointvec
>> +        .extra1        =3D &zero,
>> +        .proc_handler    =3D proc_dointvec_minmax
>>       },
>>       {
>>           .procname    =3D "tcp_app_win",
>>
>>
>>
> Thanks for so quick reply, I will test it soon.
>
> however I suspect whether this patch could fix overflow if we merged =
TCP
> friends patch in future.
>

Tested on 3.7.0-rc1+, but bug is still alive
with disabled TCP friends ...

Thanks

Yu

> With TCP friends, we have source like below, or TCP friends should ca=
re
> this ?
>
> static inline int sk_sndbuf_get(const struct sock *sk)
> {
>          if (sk->sk_friend)
>                  return sk->sk_sndbuf + sk->sk_friend->sk_rcvbuf;
>          else
>                  return sk->sk_sndbuf;
> }
>
> static inline bool sk_stream_memory_free(const struct sock *sk)
> {
>          return sk_wmem_queued_get(sk) < sk_sndbuf_get(sk);
> }
>
> So sk_sndbuf_get() still may be overflow when we have right value in
> net.ipv4.tcp_{rmem,wmem}.
>
> Thanks
