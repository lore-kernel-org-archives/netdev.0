From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress local mac
 install for all vlans
Date: Wed, 26 Aug 2015 08:52:32 -0400
Message-ID: <55DDB690.8060601@redhat.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>	<20150825.194222.390859854071446877.davem@davemloft.net>	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com> <CAN+pFwJKFeQJw_4mPEH5_WmHdBUn75FL+-Cq=YaR+FR-+cRfEw@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	toshiaki.makita1@gmail.com,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, wkok@cumulusnetworks.com
To: B Viswanath <marichika4@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967AbbHZMwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 08:52:34 -0400
In-Reply-To: <CAN+pFwJKFeQJw_4mPEH5_WmHdBUn75FL+-Cq=YaR+FR-+cRfEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 02:10 AM, B Viswanath wrote:
>>>
>>> I'd rather we fix the essence of the scalability problem than add
>>> more spaghetti code to the various bridge paths.
>>>
>>> Can we make the fdb entries smaller?
>>>
>>> Can we enhance how we store such local entries such that they live =
in
>>> a compact datastructure?  Perhaps the FDB can consist of a very den=
se
>>> lookup mechanism for local stuff sitting alongside the current tabl=
e.
>>
>> Certainly, that should be done and I will look into it, but the esse=
nce of this patch
>> is a bit different. The problem here is not the size of the fdb entr=
ies, it=E2=80=99s more the
>> number of them - having 96000 entries (even if they were 1 byte ones=
) is just way
>> too much especially when the fdb hash size is small and static. We c=
ould work on making
>> it dynamic though, but still these type of local entries per vlan pe=
r port can easily be avoided
>> with this option.
>>
>=20
> I was wondering if it is possible to assign a vlan bitmap for the FDB
> entry, instead of replicating the entry for each vlan. ( I believe
> Roopa has done something similar, but not so sure). This means that
> the number of FDB entries remain static for any number of vlans.
>=20
> I guess its more complicated than it sounds, but just wanted to know
> if its feasible at all.

I've actually had this done in one of the earlier attempts.  The issue =
was how
to compress it because there was absolutely no gain if you have a spars=
e vlan bitmap.

I even tried doing something along the lines of vlan_group array, but t=
hat can
explode to full size almost as fast.

What actually worked better was a hash table of vlans where each entry =
in the table
contained a bunch of data one of which was a list of fdbs for a given v=
lan.   It
didn't replicate fdbs but simply referenced the ones we cared about and=
 bumped the ref.

However, this made vlan look-ups slower since we now had a hash instead=
 of a bitmap lookup
and Stephen rejected it.

-vlad

>=20
> Thanks
> Vissu
>=20
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
