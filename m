From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv4: Use binary search to choose tcp PMTU probe_size
Date: Mon, 16 Feb 2015 18:59:02 -0500
Message-ID: <CABrhC0nFATp5brGAuSxKTywQQ+MDpwWsCyvZLNxSeLLniQz6BA@mail.gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	<1423815405-32644-3-git-send-email-fan.du@intel.com>
	<CABrhC0mPhY1u5rb=KsaF96fLqw_QYLUGm_D9_Yhn655JxLN1Xw@mail.gmail.com>
	<54E17FA4.1000104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:32997 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbBPX7E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 18:59:04 -0500
Received: by lbvp9 with SMTP id p9so1473310lbv.0
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 15:59:02 -0800 (PST)
In-Reply-To: <54E17FA4.1000104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 12:27 AM, Fan Du <fengyuleidian0615@gmail.com> =
wrote:
> =E4=BA=8E 2015=E5=B9=B402=E6=9C=8814=E6=97=A5 01:52, John Heffner =E5=
=86=99=E9=81=93:
>
>> On Fri, Feb 13, 2015 at 3:16 AM, Fan Du <fan.du@intel.com> wrote:
>>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>>> index 0732b78..9d1cfe0 100644
>>> --- a/net/ipv4/tcp_timer.c
>>> +++ b/net/ipv4/tcp_timer.c
>>> @@ -113,7 +113,7 @@ static void tcp_mtu_probing(struct
>>> inet_connection_sock *icsk, struct sock *sk)
>>>                          struct tcp_sock *tp =3D tcp_sk(sk);
>>>                          int mss;
>>>
>>> -                       mss =3D tcp_mtu_to_mss(sk,
>>> icsk->icsk_mtup.search_low) >> 1;
>>> +                       mss =3D tcp_mtu_to_mss(sk,
>>> icsk->icsk_mtup.search_low);
>>>                          mss =3D min(net->ipv4.sysctl_tcp_base_mss,=
 mss);
>>>                          mss =3D max(mss, 68 - tp->tcp_header_len);
>>>                          icsk->icsk_mtup.search_low =3D tcp_mss_to_=
mtu(sk,
>>> mss);
>>
>>
>> Why did you change this?  I think this breaks black hole detection.
>
> hmm, I misunderstood this part.
> In case of pure black hole detection, lowering the current tcp mss in=
stead
> of search_low,
> will make more sense, as current tcp mss still got lost.
>
> -                       mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.se=
arch_low)
>>> 1;
> +                       /* try mss smaller than current mss */
> +                       mss =3D tcp_current_mss(sk) >> 1;
>
> Black hole seems more like a misconfiguration in administrative level=
 on
> intermediate node,
> rather than a stack issue, why keep shrinking mss to get packet throu=
gh with
> poor performance?

The idea here is to make it robust to route changes, where the new
path has a lower MTU.  This also protects us against paths that have a
lower MTU than the base mss (which you're also trying to raise in this
patch series).

Thanks,
  -John
