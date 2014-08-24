From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Sun, 24 Aug 2014 12:12:18 +0100
Message-ID: <20140824111218.GA32741@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37426 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbaHXLM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 07:12:28 -0400
Content-Disposition: inline
In-Reply-To: <53F9459B.2070801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/14 at 09:53pm, Jamal Hadi Salim wrote:
> On 08/22/14 18:53, Scott Feldman wrote:
>=20
> Ok, Scott - now i have looked at the patches on the plane and i am
> still not convinced ;->
>=20
> >The intent is to use openvswitch.ko=E2=80=99s struct sw_flow to prog=
ram hardware via the
> >ndo_swdev_flow_* ops, but otherwise be independent of OVS.  So the u=
pper layer of
> >the driver is struct sw_flow and any module above the driver can con=
struct a struct
> >sw_flow and push it down via ndo_swdev_flow_*.  So your non-OVS use-=
case should be
> >handled.  OVS is another use-case.  struct sw_flow should not be OVS=
-aware, but
> >rather a generic flow match/action sufficient to offload the data pl=
ane to HW.
>=20
>=20
> There is a legitimate case to be made for offloading OVS but *not*
> a basis for making it the offload interface.
> My suggestion is to make all OVS stuff a separate patchset.
> This thing needs to stand alone without OVS and we dont need
> to confuse the two.

I get what you are saying but I don't see that to be the case here. I
don't see how this series proposes the OVS case as *the* interface.
It proposes *a* interface which in this case is flow based with mask
support to accomodate the typical ntuple filter API in HW. OVS happens
to be one of the easiest to use examples as a consumer because it
already provides a flat flow representation.

That said, I already mentioned that I see a lot of value in having a
non OVS API example ASAP and I will be glad to help out John to achieve
that.

> Having said that:
> I believe in starting simple - by solving the basic functions of
> L2/3 offload first because those are well understood and fundamental.
> There is the simplicity of those network functions and then
> need to deal with tons of quarks that surround them....
> I think getting that right will help in understanding the issues and
> make this interface better. This is where i am going to focus my effo=
rt.

I thought this is exactly what is happening here. The flow key/mask
based API as proposed focuses on basic forwarding for L2-L4.

> Here's my view on flows in the patchset:
> What we need is ability to specify different types of classifiers.
> But leave L2 and 3 out of that - that should be part of the basic
> feature set.
>
> Your 15-tuple classifier should be one of those classifiers.
> This is because you *cannot possibly* have a universal classifier.
> The tc classifier/action API has got this part right. There is
> no ONE flow classifier but rather it has flexibility to add as many
> as you want.

Exactly and I never saw Jiri claim that swdev_flow_insert() would be
the only offload capability exposed by the API. I see no reason why
it could not also provide swdev_offset_match_insert() or
swdev_ebpf_insert() for the 2*next generation HW. I don't think it
makes sense to focus entirely on finding a single common denominator
and channel everything through a single function to represent all the
different generic and less generic offload capabilities. I believe
that doing so will raise the minimal HW requirements barrier HW too
much. I think we should start somewhere, learn and evolve.

> IOW:
> I should be able to specify a classifier that matches the
> definition of the openflow thing you are using. But then i should als=
o
> be able to create one based on 32 bit value/masks, one that classifie=
s
> strings, one that classifies metadata, my own pigeon observer
> classifier etc. And be able to attach them in combinations
> to select different things within the packet and act differently.

So essentially what you are saying is that the tc interface
(in particular cls and act) could be used as an API to achieve offloads=
=2E
Yes! I thought this was very clear and a given. I don't think that it
makes sense to force every offload API consumer through the tc interfac=
e
though. This comes back to my statements in a previous email. I don't
think we should require that all the offload decision complexity *has*
to live in the kernel. Quagga, nft, or OVS should be given an API to
influence this more directly (with the hardware complexity properly
abstracted). In-kernel users such as bridge, l3 (especially rules),
and tc itself could be handled through a cls/act derived API internally=
=2E

> Lets pick an example of the u32 classifier (or i could pick nftables)=
=2E
> Using your scheme i have to incur penalties to translating u32 to you=
r
> classifier and only achieve basic functionality; and now in addition
> i cant do 90% of my u32 features. And u32 is very implementable
> in hardware.

I don't fully understand the last claim. Given the specific ntuple
capabilities of a lot of hardware out there (let's assume a typical
5-tuple capability with N capacity for exact matches and M capacity for
wildcard matches) supporting a generic u32 offset-len-mask is not exact=
ly
trivial at all and I don't see how you can get around converting the
generic offset into a ntuple filter *at some point* to verify if the HW
can fullfil the generic offset match request or not. Could you share
what kind of HW you regard as a minimal requirement to base the offload
API on? Personally I'm highly interested in the existing limited tuple
filters and flow directors of NICs already available and their next
successors. I think that the code that Jiri proposes and what John is
planning to do makes a lot of sense in that context.
