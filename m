From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next] ipv6: almost identical frag hashing funcs
 combined
Date: Wed, 1 Oct 2008 14:02:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810011309480.1034@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi>
 <20081001011838.GB970@ghostprotocols.net> <20081001.025426.33354887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-810970540-1222858618=:1034"
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Netdev <netdev@vger.kernel.org>, Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44009 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbYJALDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 07:03:36 -0400
In-Reply-To: <20081001.025426.33354887.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0810011400140.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-810970540-1222858618=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810011400141.1034@wrl-59.cs.helsinki.fi>

On Wed, 1 Oct 2008, David Miller wrote:

> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Tue, 30 Sep 2008 22:18:38 -0300
> 
> > Em Wed, Oct 01, 2008 at 01:57:47AM +0300, Ilpo Järvinen escreveu:
> > > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > 
> > Good stuff, I wonder if you can spot possible candidades by sorting by
> > function size... Or perhaps by function signature... perhaps a new dwarf
> > that looks just at the parameter types, ordering by type name, and
> > reducing typedefs :-)
> 
> So many cool tool ideas, so little time :-)

...And you haven't heard even a half of them... ;-)

Don't bother with dwarf, these can (mostly) be found on source level
quite easily. I've already experimented with real string processing method 
know as suffix tree (not that I know much about the actual algorithms, 
perhaps I should know better as Ukkonen can even be seen around here :-)). 
Of course there might be some other kind of things dwarves with suffix 
tree could find but it seems either too big or unsuitable hammer to this 
particular task.

Analysis is run in libstree (I didn't find any other lib which would have 
been even nearly usable). Its author announces that there are some bugs 
but it is quite usable still and in these kind of problems you don't 
necessary look for the definitive answer somebody else might be interested 
in but just look for needles from a haystack, and there will be plenty of 
them :-), so far I've seen some garbage occassionally.

I preprocess with large line length by indent to get rid of newlines and 
varying block bracing, the small libstree front-end of mine just gets rid 
of all syntax garbage known as white-space to avoid indentation spoiling 
the party...

I've not yet figured out how to efficiently handle (filter) the results
though, so that requires quite much of a human labor currently. Libstree
basically gives me all matches for a common sequence for given length,
and that doesn't give all that nice results if you give a length which is
smaller than the largest possible for a common block. So I can only find 
an unique result in case of the longest match, but then it might still not 
be the most obvious candidate (e.g., copy pasted include list which is 
hardly interesting, though I might one day figure out a tool to trim 
that down but that's still awaiting its eureka :-)).

Ultimately I'd want to combine sparse and libstree so that I can bind
types and variables within structurally similar entities. I haven't
read much sparse yet but I suspect I need to stuff something into it to 
distinguish #define'd content from other things to avoid generating
zillions of spurious matches we already "know of" :-). This would allow 
better handling for fuzziness in the middle, libstree provides something 
for it (I haven't even tried that though) but in general I wouldn't mind 
having something more powerful in expressing something syntax-wise (though 
doing the actual expressing would probably require inventing yal or some 
userspace c which is sort of frowned upon thing ;-)). With yal, its power 
migh start to resemble coccaine (or whatever it was named), that closed 
source tool they use to find those nearly pointless cannot be null here 
removal patches. I can imagine my tool being able to archive almost as 
pointless things as that :-).

Some examples what the trivial searcher has found already... try:

@net-next:
a4356b2920fd4861dd6c75f558749fa5c38a00e8
2cf46637b501794d7fe9e365f0a3046f5d1f5dfb

cbe2d128a01315fb4bd55b96cf8b963f5df28ea2 was found by other means though
(also this jhash_mix one was found "by other means", ie., I was evaluating   
the jhash libification things).

Then, diff -u net/ipv4/ipip.c net/ipv6/sit.c :-) (and also 
net/ipv4/ip_gre.c though that's already slightly more complicated what 
those other two are in many places, but still has lot of share code 
opportunities). Also, there are some similarities on how struct flowi is 
constructed (it's appearence may easily fool one to think it as a cheap 
operation but the initilizers don't look all that simple).

So far I've only played on tcp and net playground, I don't yet dare to try 
drivers/net as that would make me rather unhappy while going through all 
those endless file copy results :-).

I'm also thinking of some kind of auto error path combiner to convert
these automatically to goto form (though I'm not sure if that helps
binary size as gcc _might_ be wise enough here):

if (err)
	revert...;
	return;
...
if (err) {
	revertmore...;
	return;   
}
...
if (err) {
	revert...;
	revertmore...;
	revertmoreandmore...;
	return;
}  
...etc.

...finding those is a super trivial operation with a preprocessed source 
and a suffix tree (I'm not any expert of it but that's quite easy to see 
already when one gets hold of the basics) :-). Much harder problem is to 
do the actual code modification automatically since our semi-random style 
constructs here and there easily fool non-trivial scripts (probably 
sparse with source file offsets might help). This is something where a 
uniform style would make things thousand times easier but that's of course 
just utopia...

Btw, does somebody know a tool which can "diff" --side-by-side like any 
number of inputs? I'd be interested...


-- 
 i.
---696208474-810970540-1222858618=:1034--
