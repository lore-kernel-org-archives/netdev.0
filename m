From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Wed, 11 Mar 2015 10:13:46 -0700
Message-ID: <CAA93jw67hfoGPJyTWOz5ghuam725+18PviOK_hYkQ+RZjjqkXw@mail.gmail.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
	<55005829.5050406@gmail.com>
	<CAA93jw5GR_Mgx8rmrMmOLXsmeW2xsCy=5xYyzOiEFHAtY=mFeA@mail.gmail.com>
	<55006C14.6030209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33749 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbCKRNr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:13:47 -0400
Received: by oifz81 with SMTP id z81so9109433oif.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:13:46 -0700 (PDT)
In-Reply-To: <55006C14.6030209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 9:23 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> On 03/11/2015 09:03 AM, Dave Taht wrote:
>>
>> On Wed, Mar 11, 2015 at 7:58 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>>
>>> On 03/06/2015 01:47 PM, Alexander Duyck wrote:
>>>>
>>>> This patch is meant to collapse local and main into one by convert=
ing
>>>> tb_data from an array to a pointer.  Doing this allows us to point=
 the
>>>> local table into the main while maintaining the same variables in =
the
>>>> table.
>>>>
>>>> As such the tb_data was converted from an array to a pointer, and =
a new
>>>> array called data is added in order to still provide an object for
>>>> tb_data
>>>> to point to.
>>>>
>>>> In order to track the origin of the fib aliases a tb_id value was =
added
>>>> in
>>>> a hole that existed on 64b systems.  Using this we can also revers=
e the
>>>> merge in the event that custom FIB rules are enabled.
>>>>
>>>> With this patch I am seeing an improvement of 20ns to 30ns for rou=
ting
>>>> lookups as long as custom rules are not enabled, with custom rules
>>>> enabled
>>>> we fall back to split tables and the original behavior.
>>>>
>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>>>> ---
>>>>
>>>> Changes since the RFC:
>>>>    Added tb_id value so I could split main and local for custom ru=
les
>>>>    Added functionality to split tables if custom rules were enable=
d
>>>>    Added table replacement and unmerge functions
>>>>
>>>> I have done some testing on this to verify performance gains and t=
hat I
>>>> can
>>>> split the tables correctly when I enable custom rules, but this pa=
tch is
>>>> what I would consider to be high risk since I am certain there are
>>>> things I
>>>> have not considered.
>>>>
>>>> If this gets pulled into someone's switchdev tree instead of into
>>>> net-next I
>>>> would be perfectly fine with that as I am sure this can use some
>>>> additional
>>>> testing.
>>>
>>> Has anyone out there had a chance to review this patch?  I had sugg=
ested
>>> holding off on applying it to net-next for additional testing, but =
I
>>> haven't found anything, and the only related issue is the one issue
>>> Sabrina reported for the RTNL locking which was already in net-next
>>> anyway.
>>
>>
>> My environment consists largely of 32 bit routing platforms (openwrt=
)
>> running the current homenet routing protocol (babel), using, in
>> particular, the babeld source specific routing extensions ( see
>> http://arxiv.org/pdf/1403.0445v3.pdf  ) which do use multiple routin=
g
>> tables, and other uncommon things like p2p routes and odd netmasks
>> like /27 and /30.
>
>
> Can you define "use multiple routing tables"?  If you are adding othe=
r
> routing tables than local/main and adding custom rules to determine t=
he
> order then this latest patch should automatically be switched off.  T=
his
> patch only applies to the case where custom rules are not enabled, ot=
herwise
> it splits the tables and you are right back to two tables one for loc=
al and
> one for main.

OK, I am comforted. somewhat.

> This patch is based on work Dave Miller originally sent me to merge t=
he
> tables for local/main in order to improve performance in the standard=
 end
> user case.  As far as Quagga and such I am not that familiar with how=
 they
> configure the tables so I cannot say if there is a performance gain
> available or not.

Not so much concerned about performance as correctness. Well, am
concerned about performance too, on (massive or weird) route
updates... (and I am mostly commenting on the entire patchset not this
patch! Sorry for hijacking the thread)

On my specific bugaboo, atomic route changes, the relevant bit of
netlink userspace code that does a delete + add in babel is here:

https://github.com/boutier/babeld/blob/source-specific/kernel_netlink.c=
#L971

And in quagga,  somewhere in here:
http://git.savannah.gnu.org/gitweb/?p=3Dquagga.git;a=3Dblob;f=3Dzebra/r=
t_netlink.c;h=3D2350070c60cbd6801b0319e5a8ee0f82901a1b54;hb=3DHEAD

(I am not terribly familiar with other daemons, and only barely, quagga=
)

So far as I know these daemons do not do atomic updates/changes due to
an ancient, barely remembered bug in Linux ECMP, which for all I know
was fixed long ago. add + delete seemed to have had bugs, also (even
though it is saner to put in a new route superseding an old one, than
lose all the packets in between a delete + add)

The detailed netlink knowledge that is in "ip route" today to do a
change correctly has not made it up to any routing daemon folk I know
of - (I am too dumb to understand it myself!), and some communication
about what you are up to on the relevant mailing lists (like
quagga-dev, bird-users, babel-users,  ) might prove a fruitful
exchange of knowledge and ideas (outside of my specific bugaboo on
atomic updates!) up and down the stack, and reveal other known
bottlenecks and problems on their fronts.

https://lists.quagga.net/mailman/listinfo/quagga-dev
http://lists.alioth.debian.org/mailman/listinfo/babel-users
http://bird.network.cz/mailman/listinfo/bird-users

and a few others such as olsr, xorp, etc.

If you could provide an introduction to your work to these mailing
lists, that might gain more testers and feedback.

>> But: I simply can't keep up with you and this entire patchset change=
s
>> so dramatically how routing works that you make me nervous. I would
>> like to see quagga (and babeld) improved to use atomic updates in
>> particular (They do a delete + add for no good reason), and for
>> protocols like ospf, bgp, etc, to be actively tested on real traffic
>> loads on live data against this entire patchset.
>
>
> Yeah, looking back on it I probably shouldn't have sat on my patches =
for an
> entire release cycle before pushing them but as it was I was trying t=
o
> stretch things out over two releases.  As far as Quagga and such that=
 is
> several levels above this work as I have no idea about the internals =
of the
> user space routing daemons.

As noted, I think valuable feedback can be gained by an idea or
prisoner exchange with those folk.

>> Your 64 bit x86 benchmarks are very exciting and I do look forward t=
o
>> one day soon attempting to evaluate and benchmark these changes on
>> teeny 32 bit platforms both in the general case and in this
>> environment, and am mostly just hoping that others that are doing
>> higher end real world routing with big tables (such as BGP) are payi=
ng
>> more attention than I can.
>
>
> Merging the two tables is one of the requests that came out of netcon=
f this
> year.  I hadn't anticipated the amount of improvement that I have see=
n,
> though it makes sense since we are essentially reducing the memory
> utilization significantly as we reduce the backtrace and main table l=
ook-up
> to something like one tnode since in the case of most /24 subnets you=
 only
> have 3 or 4 addresses that are tracked in the trie and the route from=
 main
> will usually just end up overlapping with the .0 broadcast address.

Yes, they look pretty good! very shiny!

>
>> What test procedures are you using at present (and what is everyone =
else
>> using)?
>
>
> What I have been doing is mostly performance testing for different po=
rtions
> of the trie, performance of shortest path to find a match, performanc=
e of
> longest path to find a match, load/unload/reload interface, insert/de=
lete
> route or address, dumping route, fib_trie, and fib_triestat, and with=
 this
> most recent patch adding custom rules to force the tables to split.

If you can publish those tests somewhere perhaps folk like myself could=
 look
them over and add additional ones.


> - Alex

I am unsure as as to how to even look for multiple routing table
usage. My most complex test setup (which includes hip, the tinc vpn,
(I've heard strongswan is often tossed into table 222, but I am not
using that) and a couple source specific routes from babel), I just
did a walk of everything with:

for i in `seq 0 64000`; do echo table $i :; ip route show table $i;
done > tables.txt

it took a long time, but I stuck those results up at:

http://snapon.lab.bufferbloat.net/~d/routing_tables/tables.txt

that was on kernel 3.18. From what I think I now understand your
folding of these tables together will fall back to multiple tables in
my cases, in this patch, but it was the entire patchset that was
concerning me for the routing protocol users.

--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
