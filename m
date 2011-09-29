From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 17:06:50 -0700
Message-ID: <CAB_+Fg5ZzC43XcVjoByepZvA4Mknu6PkRWzpUju+KAQnoMb8JQ@mail.gmail.com>
References: <4E82C0DD.6010304@intel.com>
	<alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi>
	<4E82E0EE.1050600@intel.com>
	<4E82E5B5.1050206@intel.com>
	<alpine.DEB.2.00.1109281226480.21709@wel-95.cs.helsinki.fi>
	<4E82FAD6.1010708@intel.com>
	<alpine.DEB.2.00.1109281418280.21709@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:41729 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab1I2AGy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 20:06:54 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8T06q10031136
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:06:53 -0700
Received: from ywt2 (ywt2.prod.google.com [10.192.20.2])
	by hpaq13.eem.corp.google.com with ESMTP id p8T04rix015341
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:06:51 -0700
Received: by ywt2 with SMTP id 2so80386ywt.26
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:06:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1109281418280.21709@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Could you please clarify this case for me-

skb =3D=3D tp->lost_skb_hint
If skb is sacked, doesn't tcp_mark_head_lost() already increment
lost_cnt_hint, in which case you won't need to do it here?

Nandita

On Wed, Sep 28, 2011 at 4:29 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Wed, 28 Sep 2011, Yan, Zheng wrote:
>
>> > But is the non-SACKed case really handled right when hint =3D=3D s=
kb by the
>> > sacktag_one. We move the seqno in between and then before(x->newse=
q,
>> > x->newseq) check returns false?
>> >
>> you are right, thank you.
>>
>> really hope my patch is correct this time :)
>> ---
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 21fab3e..a04622e 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -1390,8 +1390,7 @@ static int tcp_shifted_skb(struct sock *sk, st=
ruct sk_buff *skb,
>> =A0 =A0 =A0 BUG_ON(!pcount);
>>
>> =A0 =A0 =A0 /* Tweak before seqno plays */
>> - =A0 =A0 if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hi=
nt &&
>> - =A0 =A0 =A0 =A0 !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SK=
B_CB(skb)->seq))
>> + =A0 =A0 if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hi=
nt =3D=3D skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->lost_cnt_hint +=3D pcount;
>>
>> =A0 =A0 =A0 TCP_SKB_CB(prev)->end_seq +=3D shifted;
>
> It also looks a lot nicer now and more obvious. According to my curre=
nt
> understanding, feel free to add this once doing the proper submission=
 with
> Signed-off etc. (please also remove the comment too as seqnos have no
> longer any significance here):
>
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>
> ...but it certainly wouldn't hurt if also somebody else has pair of e=
yes
> to spare to confirm that we (both) are now in agreement what the code
> really says.
>
>
> --
> =A0i.
