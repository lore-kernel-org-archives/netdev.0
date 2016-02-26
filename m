From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/3] intermediate representation for jit and cls_u32
 conversion
Date: Fri, 26 Feb 2016 17:19:48 +0100
Message-ID: <20160226161948.GA4667@salvia>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
 <56CF43D8.1010106@gmail.com>
 <20160226114036.GA2523@salvia>
 <56D07261.1060302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	horms@verge.net.au
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44720 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbcBZQTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 11:19:53 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 33EEFED06C
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 17:19:52 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1A29CDA38F
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 17:19:52 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BACF8DA392
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 17:19:49 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <56D07261.1060302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 07:42:25AM -0800, John Fastabend wrote:
> On 16-02-26 03:47 AM, Pablo Neira Ayuso wrote:
> > The parser on the backend is not the way to go.  I would expect it
> > will not take long time until we see other people copying/pasting it
> > and adapting it to their need just because they don't find the way/put
> > the care to make it fit in the infrastructure / abstract it the right
> > way.
> > 
> > ... And then we will get complexity spread out all over the place, in
> > every single driver. This will be unmaintainable.
> > 
> > The frontend parser should be generic to everyone, it should be placed
> > in the core, so everyone will take care of improving it.
> > 
> > Let's make a summary picture to clarify this:
> > 
> > 
> >             core                               drivers
> >           -------                             ---------
> >         1 per frontend                       1 per driver
> > 
> >   [ people from all vendors ]           [     code consuming    ]
> >   [  working to improve     ]           [   IR representation   ]
> >   [   the common parser     ]
> >   [     and improve IR      ]
> > 
> >      Complexity goes here
> >        in the form of
> >        infrastructure
> > 
> 
> I understand the ideal here but I don't see the need for it yet. I'm
> writing the ebpf parser now and evolving the u32 frontend to support
> new use cases. I guess all the added complexity in this series comes
> from nft? My big concern is performance and I just don't believe
> its much complexity to take u32,flower,etc into the driver. Or
> if we don't like that flower to u32 can be done with a static jump
> table you don't need ASTs and such for that.

Well, you can probably make a in-kernel compiler-like thing without
ASTs, but that doesn't mean it will look nice.

> Maybe it would help to see the nft implementation as that seems to
> be the only reason to do this in my mind. And I'm not so keen to
> cause overhead on the tc side to support nft. With your AST I still
> need a eBPF hook so having three hooks seems fine to me nft, tc, and
> ebpf.

I see no reason to have as many hooks as frontends to start with. If
you find limitations with the IR that are unfixable for any of the
existing frontends in the future, then we can add direct hook as final
solution.

But going the other way around, ie. adding one hook per frontend when
we can already represent several of them with this representation,
that makes no sense to me.

> >>> * Avoid exposing low-level frontend details to the backend, such as
> >>>   structure layouts. If the frontend needs to be updated to support a
> >>>   new software feature, it is desiderable that such changes don't
> >>>   trigger large updates to every driver supporting offloads.
> >>>
> >>> * Having a common parser for every frontend, instead of allowing each
> >>>   backend driver to re-invent the wheel with its own parser, this is
> >>>   just spreading out complexity all over the place.
> >>
> >>
> >> I think we should make helper routines and build a library for driver
> >> writers instead. This way each driver writer can call stub functions
> >> to do things like validate u32 against a model.h header or something
> >> along these lines. This keeps flexibility IMO and lets us optimize
> >> the backends for the specific hardware. Remember we eventually need
> >> to get to 100k's of updates a second to compete with user space APIs
> >> if you want this to work on high-end devices. If you don't get here
> >> it wont be usable for a class of systems and we will just lift the
> >> functions into user space for performance reasons. I'm sceptical that
> >> converting from shiny classifier to software IR and then hw IR is
> >> going to be efficient when I can go direct from classifier to hw IR.
> > 
> > To me this sounds like trying to microptimize the control plane code
> > by reducing the amount of code to translate it into hardware.
> > However, this comes at the cost of increasing the overall complexity
> > in the backend.
> 
> Fine by me I can deal with it.

Good.

> > I think we have to make an effort to provide generic solutions, Linux
> > is a generic purpose stack.
> 
> I'm OK with that but not at the expense of making your high-end devices
> not usable. And this feature is really IMO targeted at high-end devices
> for the moment.
>
> > Look at the problem from another perspective based on this statement:
> > 
> > "ioctl()/setsockopt()/system call of choice plus fixed layout
> > structures are faster control planes than Netlink."
> > 
> > Answer: Yes, that's probably right, they require way less code to
> > build and to parse a message. However, *we are telling everyone that
> > people should use Netlink".
> > 
> > Why?
> > 
> > Because it helps us avoid exposing the low level details of our
> > implementation and that makes it more more extensible in the kind of
> > evolutionary development that we have.
> > 
> > Should we microoptimize the control plane path through avoiding
> > abstractions? I don't think so.
> > 
> 
> Bottom line I need at least 50k updates per second or so to be
> competitive ideally I want to get to 100k or more. Without this
> its not usable for a bunch of use cases.

Good, I'm all for reaching those numbers, we can optimize the generic
IR if this ever becomes the bottleneck.

> > Another example, look at this structure (what we currently have in
> > net-next):
> > 
> >  struct tc_cls_u32_knode {
> >         struct tcf_exts *exts;
> >         struct tc_u32_sel *sel;
> >         u32 handle;
> >         u32 val;
> >         u32 mask;
> >         u32 link_handle;
> >         u8 fshift;
> >  };
> > 
> > Downside is we expose frontend details to the backend.
> > 
> > * You're exposing structure layouts to the backend, (see
> >   tcf_exts struct). Another clear symptom to me that this is not the
> >   way to go are those #ifdefs in the backend driver code to check if the
> >   tc action API is set. If someone needs to extend the tc action API and
> >   we get lots of driver using this in the future, that poor guy
> >   extending tc action will have to mangle quite a lot of driver code.
> > 
> 
> Agreed the ifdefs are likely not ideal.

Thanks.

> > * Why the driver should care if tc-u32 uses link_handles to connect rules
> >   and such?
> > 
> > So better pass the driver something generic that it can translate.
> > With common IR (after one more patches I have here) this will look
> > like:
> > 
> >  struct tc_cls_u32_knode {
> >         u32                     handle;
> >         struct net_ir_ast       ast;
> >  };
> > 
> >> Also the IR here only maps easily to a specific set of hardware. For
> >> example it doesn't really map well to some of my more programmable
> >> devices that want to consume "programs" more like BPF. So I don't see
> >> any universal IR being possible. At best you get a set of IRs
> >> dependent on the underlying architecture.
> > 
> > Universal sounds too ambicious, I called this generic. Generic in the
> > sense of trying to unify and provide as much common infrastructure as
> > possible. We probably cannot escape having some specificities for some
> > of the frontends we have, so we'll have to pass this specific info as
> > decoration to the driver, but that's should not be an excuse to skip
> > having something common for everyone IMO.
> > 
> > Anyway I'd suggest you go have a look at the IR and see what you send
> > incremental patches to improve what you cannot represent in a generic
> > way.
> > 
> 
> I looked at it and want to know what it does to performance. Also I
> think ebpf is a better IR if we want an IR so why not lower it to ebpf
> if we want the generic object.

So you indicate that my simple IR representation adds complexity, and
you want to fix that by using a bytecode-based final representation
instead? Sorry, that doesn't make sense to me.

> >>> The tc-u32 parser is a bit complicated because of having the matching
> >>> spread out in different rules through links, but John already came up a
> >>> basic parser than should be placed in the frontend so everyone can
> >>> improve it to generate more expressive ast.
> >>>
> >>> Note: I don't have access to ixgbe hardware, so I have validated this
> >>> patchset by splicing main parts of the ixgbe backend jit code in simple
> >>> debugging patches that I have here. Quite rudimentary but it has passed
> >>> some basic tests, may still have gotten anything broken. Anyway, the
> >>> main goal is to generate debate on this.
> >>>
> >>
> >> Yep lets debate the general approach. I can deal with ixgbe details.
> >> My reaction is this seems overkill I only see offloads popping up for
> >> flower, u32, nft, and bpf at the moment. Flower doesn't need heavy
> >> overhead due to its simplicity. u32 can be done with some basic helpers
> >> for devices like ixgbe. I think nft can be done the same. bpf is its own
> >> beast that doesn't map well to another IR its more or less its own IR
> >> anyways.
> >>
> >> If we need/want a IR I would go for something instruction based
> >> like ebpf over this.
> > 
> > bpf is a final representation from a compiler perspective, it is
> > bytecode, I don't think it is meant to be designed as an intermediate
> > representation.
> 
> Well its just a set of instructions and each driver writer would write
> their own jit just the same as the AST. Also it would save me having to
> write two jits one for NFT-IR and one for BPF so I would prefer to just
> do one and use it as the generic IR its not so bad to convert u32 into
> it for example. If we need two ebpf-jit, nft-jit I mind as well have
> three tc-jit, nft-jit, and ebpf-jit and optimize each one for their
> targeted front-ends.

I told during Netconf that you can use this IR infrastructure to
generate bpf on the backend side. That would basically allow jitting
in software every frontend, but that is a different front. Anyway I
don't understand you want to use bpf as IR. That's a final
representation that is quite complex because of quite wide instruction
set. This is just adding more complexity which is exactly one of your
concerns.
