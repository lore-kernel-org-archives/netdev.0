From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress local mac install for all vlans
Date: Fri, 28 Aug 2015 08:26:41 -0700
Message-ID: <B05F9EE8-169A-4E9E-8929-24ED64F8EBE9@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org> <20150825.194222.390859854071446877.davem@davemloft.net> <E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com> <20150825.230641.773630246486190390.davem@davemloft.net> <AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com> <55DE98AF.8000503@cumulusnetworks.com> <2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com> <55DFA1A3.30601@redhat.com> <691CF770-DDF3-4AC9-B99C-9640992037C5@cumulusnetworks.com> <55E05486.5090500@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	toshiaki.makita1@gmail.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, wkok@cumulusnetworks.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34910 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbH1P0l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 11:26:41 -0400
Received: by pacdd16 with SMTP id dd16so65932821pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 08:26:41 -0700 (PDT)
In-Reply-To: <55E05486.5090500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 28, 2015, at 5:31 AM, Vlad Yasevich <vyasevic@redhat.com> wrot=
e:
>=20
> On 08/27/2015 10:17 PM, Nikolay Aleksandrov wrote:
>>=20
>>> On Aug 27, 2015, at 4:47 PM, Vlad Yasevich <vyasevic@redhat.com> wr=
ote:
>>>=20
>>> On 08/27/2015 05:02 PM, Nikolay Aleksandrov wrote:
>>>>=20
>>>>> On Aug 26, 2015, at 9:57 PM, roopa <roopa@cumulusnetworks.com> wr=
ote:
>>>>>=20
>>>>> On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>>>>>>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net=
> wrote:
>>>>>>>=20
>>>>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>>>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>>>>>>=20
>>>>>>>> Certainly, that should be done and I will look into it, but th=
e
>>>>>>>> essence of this patch is a bit different. The problem here is =
not
>>>>>>>> the size of the fdb entries, it=E2=80=99s more the number of t=
hem - having
>>>>>>>> 96000 entries (even if they were 1 byte ones) is just way too =
much
>>>>>>>> especially when the fdb hash size is small and static. We coul=
d work
>>>>>>>> on making it dynamic though, but still these type of local ent=
ries
>>>>>>>> per vlan per port can easily be avoided with this option.
>>>>>>> 96000 bits can be stored in 12k.  Get where I'm going with this=
?
>>>>>>>=20
>>>>>>> Look at the problem sideways.
>>>>>> Oh okay, I misunderstood your previous comment. I=E2=80=99ll loo=
k into that.
>>>>>>=20
>>>>> I just wanted to add the other problems we have had with keeping =
these macs (mostly from userspace POV):
>>>>> - add/del netlink notification storms
>>>>> - and large netlink dumps
>>>>>=20
>>>>> In addition to in-kernel optimizations, will be nice to have a so=
lution that reduces the burden on userspace. That will need a newer net=
link dump format for fdbs. Considering all the changes needed, Nikolays=
 patch seems less intrusive.
>>>>=20
>>>> Right, we need to take these into account as well. I=E2=80=99ll co=
ntinue the discussion on this (or restart it) because
>>>> I looked into using a bitmap for the local entries only and while =
it fixes the scalability issue, it presents
>>>> a few new ones which are mostly related to the fact that these ent=
ries now exist only without a vlan
>>>> and if a new mac comes along which matches one of these but is in =
a vlan, the entry will get created
>>>> in br_fdb_update() unless we add a second lookup, but that will sl=
ow down the learning path.
>>>> Also this change requires an update of every fdb function that use=
s the vid as a key (every fdb function?!)
>>>> because now we can have the mac in two places instead of one which=
 is a pretty big churn with lots
>>>> of conditionals all over the place and I don=E2=80=99t like it. Ad=
ding this complexity for the local addresses only
>>>> seems like an overkill, so I think to drop this issue for now.
>>>=20
>>> I seem to recall Roopa and I and maybe a few others have discussing=
 this a few
>>> years ago at plumbers, I can't remember the details any more.  All =
these local
>>> addresses add a ton of confusion.  Does anyone (Stephen?) remember =
what the
>>> original reason was for all these local addresses? I wonder if we c=
an have
>>> a nob to disable all of them (not just per vlan)?  That might be cl=
eaner and
>>> easier to swallow.
>>>=20
>>=20
>> Right, this would be the easiest way and if the others agree - I=E2=80=
=99ll post a patch for it so we can
>> have some way to resolve it today and even if we fix the scalability=
 issue, this is still a valid case
>> that some people don=E2=80=99t want local fdbs installed automatical=
ly.
>> Any objections to this ?
>>=20
>>>> This patch (that works around the initial problem) also has these =
issues.
>>>> Note that one way to take care of this in a more straight-forward =
way would be to have each entry
>>>> with some sort of a bitmap (like Vlad has tried earlier) and then =
we can combine the paths so most
>>>> of these issues disappear, but that will not be easy as was alread=
y commented earlier. I=E2=80=99ve looked
>>>> briefly into doing this with rhashtable so we can keep the memory =
footprint for each entry relatively
>>>> small but it still affects the performance and we can have thousan=
ds of resizes happening.=20
>>>>=20
>>>=20
>>> So, one of the earlier approaches that I've tried (before rhashtabl=
e was
>>> in the kernel) was to have a hash of vlan ids each with a data stru=
cture
>>> pointing to a list of ports for a given vlan as well as a list of f=
dbs for
>>> a given vlan.  As far as scalability goes, that's really the best a=
pproach.
>>> It would also allow us to do packet accounting per vlan.  The only =
concern
>>> at the time was performance of ingress lookup.   I think rhashtable=
s might
>>> help with this as well as ability to grow the footprint of the vlan=
 hash
>>> table dynamically.
>>>=20
>>> -vlad
>>>=20
>> I=E2=80=99ll look into it but I=E2=80=99m guessing the learning will=
 become a more complicated process with additional=20
>> allocations and some hash handling.
>=20
> I don't remember learning being all that complicated.  The hash only =
changed under
> rtnl when vlans were added/removed.  The nice this is that we wouldn'=
t need
> to rebalance, because if the vlan is removed all fdb links get remove=
d too.  They
> don't move to another bucket (But that was with static hash.  Need to=
 look at rhash in
> more detail).
>=20
> If you want, I might still have patches hanging around on my machine =
that had a hash
> table implementation.  I can send them to you.
>=20
> -vlad
>=20

:-) Okay, I=E2=80=99m putting the crystal ball away. If you could send =
me these patches it=E2=80=99d be great so
I don=E2=80=99t have to start this from scratch.

Thanks,
 Nik

>>=20
>>>> On the notification side if we can fix that, we can actually delet=
e the 96000 entries without creating a
>>>> huge notification storm and do a user-land workaround of the origi=
nal issue, so I=E2=80=99ll look into that next.
>>>>=20
>>>> Any comments or ideas are very welcome.
>>>>=20
>>>> Thank you,
>>>> Nik
