From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Fri, 28 Aug 2015 21:11:56 -0400
Message-ID: <55E106DC.5040802@redhat.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
	<20150825.230641.773630246486190390.davem@davemloft.net>
	<AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
	<55DE98AF.8000503@cumulusnetworks.com>
	<2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com>
	<55DFA1A3.30601@redhat.com>
	<691CF770-DDF3-4AC9-B99C-9640992037C5@cumulusnetworks.com>
	<55E05486.5090500@redhat.com>
	<B05F9EE8-169A-4E9E-8929-24ED64F8EBE9@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>, wkok@cumulusnetworks.com,
	David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <B05F9EE8-169A-4E9E-8929-24ED64F8EBE9@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 08/28/2015 11:26 AM, Nikolay Aleksandrov wrote:
>=20
>> On Aug 28, 2015, at 5:31 AM, Vlad Yasevich <vyasevic@redhat.com> wrote=
:
>>
>> On 08/27/2015 10:17 PM, Nikolay Aleksandrov wrote:
>>>
>>>> On Aug 27, 2015, at 4:47 PM, Vlad Yasevich <vyasevic@redhat.com> wro=
te:
>>>>
>>>> On 08/27/2015 05:02 PM, Nikolay Aleksandrov wrote:
>>>>>
>>>>>> On Aug 26, 2015, at 9:57 PM, roopa <roopa@cumulusnetworks.com> wro=
te:
>>>>>>
>>>>>> On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>>>>>>>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net>=
 wrote:
>>>>>>>>
>>>>>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>>>>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>>>>>>>
>>>>>>>>> Certainly, that should be done and I will look into it, but the
>>>>>>>>> essence of this patch is a bit different. The problem here is n=
ot
>>>>>>>>> the size of the fdb entries, it=E2=80=99s more the number of th=
em - having
>>>>>>>>> 96000 entries (even if they were 1 byte ones) is just way too m=
uch
>>>>>>>>> especially when the fdb hash size is small and static. We could=
 work
>>>>>>>>> on making it dynamic though, but still these type of local entr=
ies
>>>>>>>>> per vlan per port can easily be avoided with this option.
>>>>>>>> 96000 bits can be stored in 12k.  Get where I'm going with this?
>>>>>>>>
>>>>>>>> Look at the problem sideways.
>>>>>>> Oh okay, I misunderstood your previous comment. I=E2=80=99ll look=
 into that.
>>>>>>>
>>>>>> I just wanted to add the other problems we have had with keeping t=
hese macs (mostly from userspace POV):
>>>>>> - add/del netlink notification storms
>>>>>> - and large netlink dumps
>>>>>>
>>>>>> In addition to in-kernel optimizations, will be nice to have a sol=
ution that reduces the burden on userspace. That will need a newer netlin=
k dump format for fdbs. Considering all the changes needed, Nikolays patc=
h seems less intrusive.
>>>>>
>>>>> Right, we need to take these into account as well. I=E2=80=99ll con=
tinue the discussion on this (or restart it) because
>>>>> I looked into using a bitmap for the local entries only and while i=
t fixes the scalability issue, it presents
>>>>> a few new ones which are mostly related to the fact that these entr=
ies now exist only without a vlan
>>>>> and if a new mac comes along which matches one of these but is in a=
 vlan, the entry will get created
>>>>> in br_fdb_update() unless we add a second lookup, but that will slo=
w down the learning path.
>>>>> Also this change requires an update of every fdb function that uses=
 the vid as a key (every fdb function?!)
>>>>> because now we can have the mac in two places instead of one which =
is a pretty big churn with lots
>>>>> of conditionals all over the place and I don=E2=80=99t like it. Add=
ing this complexity for the local addresses only
>>>>> seems like an overkill, so I think to drop this issue for now.
>>>>
>>>> I seem to recall Roopa and I and maybe a few others have discussing =
this a few
>>>> years ago at plumbers, I can't remember the details any more.  All t=
hese local
>>>> addresses add a ton of confusion.  Does anyone (Stephen?) remember w=
hat the
>>>> original reason was for all these local addresses? I wonder if we ca=
n have
>>>> a nob to disable all of them (not just per vlan)?  That might be cle=
aner and
>>>> easier to swallow.
>>>>
>>>
>>> Right, this would be the easiest way and if the others agree - I=E2=80=
=99ll post a patch for it so we can
>>> have some way to resolve it today and even if we fix the scalability =
issue, this is still a valid case
>>> that some people don=E2=80=99t want local fdbs installed automaticall=
y.
>>> Any objections to this ?
>>>
>>>>> This patch (that works around the initial problem) also has these i=
ssues.
>>>>> Note that one way to take care of this in a more straight-forward w=
ay would be to have each entry
>>>>> with some sort of a bitmap (like Vlad has tried earlier) and then w=
e can combine the paths so most
>>>>> of these issues disappear, but that will not be easy as was already=
 commented earlier. I=E2=80=99ve looked
>>>>> briefly into doing this with rhashtable so we can keep the memory f=
ootprint for each entry relatively
>>>>> small but it still affects the performance and we can have thousand=
s of resizes happening.=20
>>>>>
>>>>
>>>> So, one of the earlier approaches that I've tried (before rhashtable=
 was
>>>> in the kernel) was to have a hash of vlan ids each with a data struc=
ture
>>>> pointing to a list of ports for a given vlan as well as a list of fd=
bs for
>>>> a given vlan.  As far as scalability goes, that's really the best ap=
proach.
>>>> It would also allow us to do packet accounting per vlan.  The only c=
oncern
>>>> at the time was performance of ingress lookup.   I think rhashtables=
 might
>>>> help with this as well as ability to grow the footprint of the vlan =
hash
>>>> table dynamically.
>>>>
>>>> -vlad
>>>>
>>> I=E2=80=99ll look into it but I=E2=80=99m guessing the learning will =
become a more complicated process with additional=20
>>> allocations and some hash handling.
>>
>> I don't remember learning being all that complicated.  The hash only c=
hanged under
>> rtnl when vlans were added/removed.  The nice this is that we wouldn't=
 need
>> to rebalance, because if the vlan is removed all fdb links get removed=
 too.  They
>> don't move to another bucket (But that was with static hash.  Need to =
look at rhash in
>> more detail).
>>
>> If you want, I might still have patches hanging around on my machine t=
hat had a hash
>> table implementation.  I can send them to you.
>>
>> -vlad
>>
>=20
> :-) Okay, I=E2=80=99m putting the crystal ball away. If you could send =
me these patches it=E2=80=99d be great so
> I don=E2=80=99t have to start this from scratch.
>=20

So, I forgot that I lost an old disk that had all that code, so I am a bi=
t bummed about
that.  I did however find the series that got posted.
http://www.spinics.net/lists/netdev/msg219737.html

That was the series where I briefly switch from bitmaps to hash and list.
However, I see that the fdb code that was playing with never got posted..=
.

Sorry.

-vlad

> Thanks,
>  Nik
>=20
>>>
>>>>> On the notification side if we can fix that, we can actually delete=
 the 96000 entries without creating a
>>>>> huge notification storm and do a user-land workaround of the origin=
al issue, so I=E2=80=99ll look into that next.
>>>>>
>>>>> Any comments or ideas are very welcome.
>>>>>
>>>>> Thank you,
>>>>> Nik
>=20
