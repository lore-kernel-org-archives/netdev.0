From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Thu, 27 Aug 2015 19:47:47 -0400
Message-ID: <55DFA1A3.30601@redhat.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
	<20150825.230641.773630246486190390.davem@davemloft.net>
	<AB16F445-DCA7-437E-B6E1-B70FDC63E55A@cumulusnetworks.com>
	<55DE98AF.8000503@cumulusnetworks.com>
	<2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <2125A434-6529-4D5A-BA6B-9F64C6B7A8C0@cumulusnetworks.com>
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

On 08/27/2015 05:02 PM, Nikolay Aleksandrov wrote:
>=20
>> On Aug 26, 2015, at 9:57 PM, roopa <roopa@cumulusnetworks.com> wrote:
>>
>> On 8/26/15, 4:33 AM, Nikolay Aleksandrov wrote:
>>>> On Aug 25, 2015, at 11:06 PM, David Miller <davem@davemloft.net> wro=
te:
>>>>
>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>> Date: Tue, 25 Aug 2015 22:28:16 -0700
>>>>
>>>>> Certainly, that should be done and I will look into it, but the
>>>>> essence of this patch is a bit different. The problem here is not
>>>>> the size of the fdb entries, it=E2=80=99s more the number of them -=
 having
>>>>> 96000 entries (even if they were 1 byte ones) is just way too much
>>>>> especially when the fdb hash size is small and static. We could wor=
k
>>>>> on making it dynamic though, but still these type of local entries
>>>>> per vlan per port can easily be avoided with this option.
>>>> 96000 bits can be stored in 12k.  Get where I'm going with this?
>>>>
>>>> Look at the problem sideways.
>>> Oh okay, I misunderstood your previous comment. I=E2=80=99ll look int=
o that.
>>>
>> I just wanted to add the other problems we have had with keeping these=
 macs (mostly from userspace POV):
>> - add/del netlink notification storms
>> - and large netlink dumps
>>
>> In addition to in-kernel optimizations, will be nice to have a solutio=
n that reduces the burden on userspace. That will need a newer netlink du=
mp format for fdbs. Considering all the changes needed, Nikolays patch se=
ems less intrusive.
>=20
> Right, we need to take these into account as well. I=E2=80=99ll continu=
e the discussion on this (or restart it) because
> I looked into using a bitmap for the local entries only and while it fi=
xes the scalability issue, it presents
> a few new ones which are mostly related to the fact that these entries =
now exist only without a vlan
> and if a new mac comes along which matches one of these but is in a vla=
n, the entry will get created
> in br_fdb_update() unless we add a second lookup, but that will slow do=
wn the learning path.
> Also this change requires an update of every fdb function that uses the=
 vid as a key (every fdb function?!)
> because now we can have the mac in two places instead of one which is a=
 pretty big churn with lots
> of conditionals all over the place and I don=E2=80=99t like it. Adding =
this complexity for the local addresses only
> seems like an overkill, so I think to drop this issue for now.

I seem to recall Roopa and I and maybe a few others have discussing this =
a few
years ago at plumbers, I can't remember the details any more.  All these =
local
addresses add a ton of confusion.  Does anyone (Stephen?) remember what t=
he
original reason was for all these local addresses? I wonder if we can hav=
e
a nob to disable all of them (not just per vlan)?  That might be cleaner =
and
easier to swallow.

> This patch (that works around the initial problem) also has these issue=
s.
> Note that one way to take care of this in a more straight-forward way w=
ould be to have each entry
> with some sort of a bitmap (like Vlad has tried earlier) and then we ca=
n combine the paths so most
> of these issues disappear, but that will not be easy as was already com=
mented earlier. I=E2=80=99ve looked
> briefly into doing this with rhashtable so we can keep the memory footp=
rint for each entry relatively
> small but it still affects the performance and we can have thousands of=
 resizes happening.=20
>=20

So, one of the earlier approaches that I've tried (before rhashtable was
in the kernel) was to have a hash of vlan ids each with a data structure
pointing to a list of ports for a given vlan as well as a list of fdbs fo=
r
a given vlan.  As far as scalability goes, that's really the best approac=
h.
It would also allow us to do packet accounting per vlan.  The only concer=
n
at the time was performance of ingress lookup.   I think rhashtables migh=
t
help with this as well as ability to grow the footprint of the vlan hash
table dynamically.

-vlad

> On the notification side if we can fix that, we can actually delete the=
 96000 entries without creating a
> huge notification storm and do a user-land workaround of the original i=
ssue, so I=E2=80=99ll look into that next.
>=20
> Any comments or ideas are very welcome.
>=20
> Thank you,
>  Nik
>=20
