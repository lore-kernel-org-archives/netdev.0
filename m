From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress local mac install for all vlans
Date: Thu, 27 Aug 2015 14:02:05 -0700
Message-ID: <2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org> <20150825.194222.390859854071446877.davem@davemloft.net> <E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com> <20150825.230641.773630246486190390.davem@davemloft.net> <AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com> <55DE98AF.8000503@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevic@redhat.com, toshiaki.makita1@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	wkok@cumulusnetworks.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35206 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbH0VCI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:02:08 -0400
Received: by pacdd16 with SMTP id dd16so37381059pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:02:07 -0700 (PDT)
In-Reply-To: <55DE98AF.8000503@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 26, 2015, at 9:57 PM, roopa <roopa@cumulusnetworks.com> wrote:
>=20
> On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net> wr=
ote:
>>>=20
>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>>=20
>>>> Certainly, that should be done and I will look into it, but the
>>>> essence of this patch is a bit different. The problem here is not
>>>> the size of the fdb entries, it=E2=80=99s more the number of them =
- having
>>>> 96000 entries (even if they were 1 byte ones) is just way too much
>>>> especially when the fdb hash size is small and static. We could wo=
rk
>>>> on making it dynamic though, but still these type of local entries
>>>> per vlan per port can easily be avoided with this option.
>>> 96000 bits can be stored in 12k.  Get where I'm going with this?
>>>=20
>>> Look at the problem sideways.
>> Oh okay, I misunderstood your previous comment. I=E2=80=99ll look in=
to that.
>>=20
> I just wanted to add the other problems we have had with keeping thes=
e macs (mostly from userspace POV):
> - add/del netlink notification storms
> - and large netlink dumps
>=20
> In addition to in-kernel optimizations, will be nice to have a soluti=
on that reduces the burden on userspace. That will need a newer netlink=
 dump format for fdbs. Considering all the changes needed, Nikolays pat=
ch seems less intrusive.

Right, we need to take these into account as well. I=E2=80=99ll continu=
e the discussion on this (or restart it) because
I looked into using a bitmap for the local entries only and while it fi=
xes the scalability issue, it presents
a few new ones which are mostly related to the fact that these entries =
now exist only without a vlan
and if a new mac comes along which matches one of these but is in a vla=
n, the entry will get created
in br_fdb_update() unless we add a second lookup, but that will slow do=
wn the learning path.
Also this change requires an update of every fdb function that uses the=
 vid as a key (every fdb function?!)
because now we can have the mac in two places instead of one which is a=
 pretty big churn with lots
of conditionals all over the place and I don=E2=80=99t like it. Adding =
this complexity for the local addresses only
seems like an overkill, so I think to drop this issue for now.
This patch (that works around the initial problem) also has these issue=
s.
Note that one way to take care of this in a more straight-forward way w=
ould be to have each entry
with some sort of a bitmap (like Vlad has tried earlier) and then we ca=
n combine the paths so most
of these issues disappear, but that will not be easy as was already com=
mented earlier. I=E2=80=99ve looked
briefly into doing this with rhashtable so we can keep the memory footp=
rint for each entry relatively
small but it still affects the performance and we can have thousands of=
 resizes happening.=20

On the notification side if we can fix that, we can actually delete the=
 96000 entries without creating a
huge notification storm and do a user-land workaround of the original i=
ssue, so I=E2=80=99ll look into that next.

Any comments or ideas are very welcome.

Thank you,
 Nik
