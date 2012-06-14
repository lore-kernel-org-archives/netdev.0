From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 11:40:44 +0200
Message-ID: <CAL8zT=hz5Gbwaa8_uHghAzt0bO5KSzgBV_TmNdpJMRFR09a-Kw@mail.gmail.com>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
 <1339665719.22704.692.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:56854 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab2FNJlF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 05:41:05 -0400
Received: by wibhj8 with SMTP id hj8so6309183wib.1
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 02:41:04 -0700 (PDT)
In-Reply-To: <1339665719.22704.692.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/14 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-06-14 at 10:58 +0200, Jean-Michel Hautbois wrote:
>> Hi all,
>>
>> I have bisected a regression which concerns TX throughput when using=
 bonding.
>> I tested only with 10Gbps cards, as it appears when bandwidth need i=
s
>> over 1Gbps on my machine.
>> I send UDP multicast packets over bonding and observe the tc result.
>>
>> When KO :
>> $>tc -s -d qdisc show dev eth1
>> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap =C2=A01 2 2 2 1 2 =
0 0 1 1
>> 1 1 1 1 1 1
>> =C2=A0Sent 1106527591 bytes 273802 pkt (dropped 306419, overlimits 0=
 requeues 223)
>> =C2=A0backlog 0b 0p requeues 223
>>
>> Ok course, when OK, dropped is 0.
>> $>tc -s -d qdisc show dev eth1
>> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap =C2=A01 2 2 2 1 2 =
0 0 1 1
>> 1 1 1 1 1 1
>> =C2=A0Sent 1648662087 bytes 408009 pkt (dropped 0, overlimits 0 requ=
eues 0)
>> =C2=A0backlog 0b 0p requeues 0
>>
>>
>> Here is the incriminated commit:
>>
>> fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 is the first bad commit
>> commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5
>
>> =C2=A0 =C2=A0 net: Introduce skb_orphan_try()
>
> So you are saying that if you make skb_orphan_try() doing nothing, it
> solves your problem ?
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd09819..6df40dd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2096,6 +2096,7 @@ static int dev_gso_segment(struct sk_buff *skb,=
 netdev_features_t features)
> =C2=A0*/
> =C2=A0static inline void skb_orphan_try(struct sk_buff *skb)
> =C2=A0{
> +#if 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sock *sk =3D skb->sk;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sk && !skb_shinfo(skb)->tx_flags) {
> @@ -2106,6 +2107,7 @@ static inline void skb_orphan_try(struct sk_buf=
f *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0skb->rxhash =3D sk->sk_hash;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb_orphan(skb=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +#endif
> =C2=A0}
>
> =C2=A0static bool can_checksum_protocol(netdev_features_t features, _=
_be16 protocol)
>

Yes :

[09:44:46]root@debian:~# uname -r
3.2.0
[09:44:50]root@debian:~# tc -s -d qdisc show dev eth1
qdisc mq 0: root
 Sent 11786861758 bytes 2916943 pkt (dropped 0, overlimits 0 requeues 0=
)
 backlog 0b 0p requeues 0

JM
