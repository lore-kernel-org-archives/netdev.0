From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 03/13] xen-netback: implement TX persistent grants
Date: Wed, 3 Jun 2015 17:07:59 +0000
Message-ID: <B1B43019-3C94-4FBA-9139-7683FEC2901E@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
 <20150519152342.GB26335@zion.uk.xensource.com>
 <30CF0FF9-3B1D-48AF-AFB4-73E20C404357@neclab.eu>
 <20150602145359.GP19403@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:37579 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964867AbbFCRIQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 13:08:16 -0400
In-Reply-To: <20150602145359.GP19403@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <A86F271D6B36854293ADAC7AC17FBE6D@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02 Jun 2015, at 16:53, Wei Liu <wei.liu2@citrix.com> wrote:

> On Fri, May 22, 2015 at 10:24:39AM +0000, Joao Martins wrote:
>>=20
>> On 19 May 2015, at 17:23, Wei Liu <wei.liu2@citrix.com> wrote:
>>> On Tue, May 12, 2015 at 07:18:27PM +0200, Joao Martins wrote:
>>>> Introduces persistent grants for TX path which follows similar cod=
e path
>>>> as the grant mapping.
>>>>=20
>>>> It starts by checking if there's a persistent grant available for =
header
>>>> and frags grefs and if so setting it in tx_pgrants. If no persiste=
nt grant
>>>> is found in the tree for the header it will resort to grant copy (=
but
>>>> preparing the map ops and add them laster). For the frags it will =
use the
>>>                                    ^
>>>                                    later
>>>=20
>>>> tree page pool, and in case of no pages it fallbacks to grant map/=
unmap
>>>> using mmap_pages. When skb destructor callback gets called we rele=
ase the
>>>> slot and persistent grant within the callback to avoid waking up t=
he
>>>> dealloc thread. As long as there are no unmaps to done the dealloc=
 thread
>>>> will remain inactive.
>>>>=20
>>>=20
>>> This scheme looks complicated. Can we just only use one
>>> scheme at a time? What's the rationale for using this combined sche=
me?
>>> Maybe you're thinking about using a max_grants < ring_size to save
>>> memory?
>>=20
>> Yes, my purpose was to allow a max_grants < ring_size to save amount=
 of
>> memory mapped. I did a bulk transfer test with iperf and the max amo=
unt of
>> grants in tree was <160 TX gnts, without affecting the max performan=
ce;
>> tough using pktgen fills the tree completely.
>> The second reason is to handle the case for a (malicious?) frontend =
providing
>> more grefs than the max allowed in which I would fallback to grant m=
ap/unmap.
>>=20
>=20
> This is indeed a valid concern. The only method is to expires oldest
> grant when that happens -- but this is just complexity in another pla=
ce,
> not really simplifying anything.
>=20
>>>=20
>>> Only skim the patch. I will do detailed reviews after we're sure th=
is is
>>> the right way to go.
>>>=20
> [...]
>>>=20
>>> Under what circumstance can we retrieve a already in use persistent
>>> grant? You seem to suggest this is a bug in RX case.
>>=20
>> A guest could share try to share the same mapped page in multiple fr=
ags,
>> in which case I fallback to map/unmap. I think this is a limitation =
in
>> the way we manage the persistent gnts where we can only have a singl=
e
>> reference of a persistent grant inflight.
>>=20
>=20
> How much harder would it be to ref-count inflight grants? Would that
> simplify or perplex things? I'm just asking, not suggesting you shoul=
d
> choose ref-counting over current scheme.
>=20
> In principle I favour simple code path over optimisation for every
> possible corner case.

ref-counting the persistent grants would mean eliminating the check for
EBUSY on xenvif_pgrant_new, but though it isn=92t that much of a simpli=
fication.

What would simplify a lot is if I grant map when we don=92t get a persi=
stent_gnt
in xenvif_pgrant_new() and add it to the tree there instead of doing on=
 xenvif_tx_check_gop.
Since this happens only once for persistent grants (and up to ring size=
), I believe it
wouldn't hurt performance.

This way we would remove a lot of the checks in xenvif_tx_check_gop and
hopefully leaving those parts (almost) intact mainly to be used for gra=
nt
map/unmap case. The reason I didn=92t do it because I wanted to reuse t=
he
grant map code and thought that preference was given towards batching t=
he
grant maps. But it looks that it definitely makes things more complicat=
ed
and adds more corner cases.

The same goes for the RX case where this change would remove a lot of t=
he code
for adding the grant maps (thus sharing a lot from the TX part) besides=
 removing the
mixed initial grant copy + map. What do you think?

Joao
