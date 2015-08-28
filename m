From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Fri, 28 Aug 2015 08:31:02 -0400
Message-ID: <55E05486.5090500@redhat.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
	<20150825.230641.773630246486190390.davem@davemloft.net>
	<AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
	<55DE98AF.8000503@cumulusnetworks.com>
	<2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com>
	<55DFA1A3.30601@redhat.com>
	<691CF770-DDF3-4AC9-B99C-9640992037C5@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>, wkok@cumulusnetworks.com,
	David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <691CF770-DDF3-4AC9-B99C-9640992037C5@cumulusnetworks.com>
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

On 08/27/2015 10:17 PM, Nikolay Aleksandrov wrote:
>=20
>> On Aug 27, 2015, at 4:47 PM, Vlad Yasevich <vyasevic@redhat.com> wrote=
:
>>
>> On 08/27/2015 05:02 PM, Nikolay Aleksandrov wrote:
>>>
>>>> On Aug 26, 2015, at 9:57 PM, roopa <roopa@cumulusnetworks.com> wrote=
:
>>>>
>>>> On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>>>>>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net> w=
rote:
>>>>>>
>>>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>>>>>
>>>>>>> Certainly, that should be done and I will look into it, but the
>>>>>>> essence of this patch is a bit different. The problem here is not
>>>>>>> the size of the fdb entries, it=E2=80=99s more the number of them=
 - having
>>>>>>> 96000 entries (even if they were 1 byte ones) is just way too muc=
h
>>>>>>> especially when the fdb hash size is small and static. We could w=
ork
>>>>>>> on making it dynamic though, but still these type of local entrie=
s
>>>>>>> per vlan per port can easily be avoided with this option.
>>>>>> 96000 bits can be stored in 12k.  Get where I'm going with this?
>>>>>>
>>>>>> Look at the problem sideways.
>>>>> Oh okay, I misunderstood your previous comment. I=E2=80=99ll look i=
nto that.
>>>>>
>>>> I just wanted to add the other problems we have had with keeping the=
se macs (mostly from userspace POV):
>>>> - add/del netlink notification storms
>>>> - and large netlink dumps
>>>>
>>>> In addition to in-kernel optimizations, will be nice to have a solut=
ion that reduces the burden on userspace. That will need a newer netlink =
dump format for fdbs. Considering all the changes needed, Nikolays patch =
seems less intrusive.
>>>
>>> Right, we need to take these into account as well. I=E2=80=99ll conti=
nue the discussion on this (or restart it) because
>>> I looked into using a bitmap for the local entries only and while it =
fixes the scalability issue, it presents
>>> a few new ones which are mostly related to the fact that these entrie=
s now exist only without a vlan
>>> and if a new mac comes along which matches one of these but is in a v=
lan, the entry will get created
>>> in br_fdb_update() unless we add a second lookup, but that will slow =
down the learning path.
>>> Also this change requires an update of every fdb function that uses t=
he vid as a key (every fdb function?!)
>>> because now we can have the mac in two places instead of one which is=
 a pretty big churn with lots
>>> of conditionals all over the place and I don=E2=80=99t like it. Addin=
g this complexity for the local addresses only
>>> seems like an overkill, so I think to drop this issue for now.
>>
>> I seem to recall Roopa and I and maybe a few others have discussing th=
is a few
>> years ago at plumbers, I can't remember the details any more.  All the=
se local
>> addresses add a ton of confusion.  Does anyone (Stephen?) remember wha=
t the
>> original reason was for all these local addresses? I wonder if we can =
have
>> a nob to disable all of them (not just per vlan)?  That might be clean=
er and
>> easier to swallow.
>>
>=20
> Right, this would be the easiest way and if the others agree - I=E2=80=99=
ll post a patch for it so we can
> have some way to resolve it today and even if we fix the scalability is=
sue, this is still a valid case
> that some people don=E2=80=99t want local fdbs installed automatically.
> Any objections to this ?
>=20
>>> This patch (that works around the initial problem) also has these iss=
ues.
>>> Note that one way to take care of this in a more straight-forward way=
 would be to have each entry
>>> with some sort of a bitmap (like Vlad has tried earlier) and then we =
can combine the paths so most
>>> of these issues disappear, but that will not be easy as was already c=
ommented earlier. I=E2=80=99ve looked
>>> briefly into doing this with rhashtable so we can keep the memory foo=
tprint for each entry relatively
>>> small but it still affects the performance and we can have thousands =
of resizes happening.=20
>>>
>>
>> So, one of the earlier approaches that I've tried (before rhashtable w=
as
>> in the kernel) was to have a hash of vlan ids each with a data structu=
re
>> pointing to a list of ports for a given vlan as well as a list of fdbs=
 for
>> a given vlan.  As far as scalability goes, that's really the best appr=
oach.
>> It would also allow us to do packet accounting per vlan.  The only con=
cern
>> at the time was performance of ingress lookup.   I think rhashtables m=
ight
>> help with this as well as ability to grow the footprint of the vlan ha=
sh
>> table dynamically.
>>
>> -vlad
>>
> I=E2=80=99ll look into it but I=E2=80=99m guessing the learning will be=
come a more complicated process with additional=20
> allocations and some hash handling.

I don't remember learning being all that complicated.  The hash only chan=
ged under
rtnl when vlans were added/removed.  The nice this is that we wouldn't ne=
ed
to rebalance, because if the vlan is removed all fdb links get removed to=
o.  They
don't move to another bucket (But that was with static hash.  Need to loo=
k at rhash in
more detail).

If you want, I might still have patches hanging around on my machine that=
 had a hash
table implementation.  I can send them to you.

-vlad

>=20
>>> On the notification side if we can fix that, we can actually delete t=
he 96000 entries without creating a
>>> huge notification storm and do a user-land workaround of the original=
 issue, so I=E2=80=99ll look into that next.
>>>
>>> Any comments or ideas are very welcome.
>>>
>>> Thank you,
>>> Nik
>=20
