From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC 0/3] intermediate representation for jit and cls_u32
 conversion
Date: Thu, 25 Feb 2016 10:11:36 -0800
Message-ID: <56CF43D8.1010106@gmail.com>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36516 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcBYSLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 13:11:48 -0500
Received: by mail-pf0-f172.google.com with SMTP id e127so36764700pfe.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 10:11:48 -0800 (PST)
In-Reply-To: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 09:37 AM, Pablo Neira Ayuso wrote:
> Hi,
> 
> This patchset contains the core infrastructure for the generic
> intermediate representation that I presented during NetDev 1.1's
> nftables switchdev talk. This includes the basic infrastructure to
> convert the tc cls_u32 based on John's parser.
> 
> The main goals of this patchset are:
> 
> * Provide an unified abstract syntax tree (ast) that can be passed to
>   the backend driver for translation to internal representation. Then,
>   based on the backend description, generate the internal
>   representation. This should reduce the amount of code to maintain
>   in the driver since every frontend, via parser, generates the ast
>   that is consumed by the driver through one single ndo indirection.
> 

The trouble here is we lose a lot of the goodness of any particular
classifier this way. For example flower can be implemented with a
single jump table and this should translate into updates per second
being very high.

cls_u32 on the other hand is going to require more state and I believe
will be slightly slower in the updates per second benchmark because
it requires a set of jump tables.

My general argument here is _if_ we can build one universal ast why
don't we do this higher up the stack. I'm a bit confused on why we
think (a) all classifiers/nftables/etc can be pushed on to a single
IR and (b) all hw can consume a single IR if we actually believe this
lets whack the upper layers and make one tc classifer and unify it
with nftables so we don't have multiple things in the stack to offload.

> * Avoid exposing low-level frontend details to the backend, such as
>   structure layouts. If the frontend needs to be updated to support a
>   new software feature, it is desiderable that such changes don't
>   trigger large updates to every driver supporting offloads.
> 
> * Having a common parser for every frontend, instead of allowing each
>   backend driver to re-invent the wheel with its own parser, this is
>   just spreading out complexity all over the place.


I think we should make helper routines and build a library for driver
writers instead. This way each driver writer can call stub functions
to do things like validate u32 against a model.h header or something
along these lines. This keeps flexibility IMO and lets us optimize
the backends for the specific hardware. Remember we eventually need
to get to 100k's of updates a second to compete with user space APIs
if you want this to work on high-end devices. If you don't get here
it wont be usable for a class of systems and we will just lift the
functions into user space for performance reasons. I'm sceptical that
converting from shiny classifier to software IR and then hw IR is
going to be efficient when I can go direct from classifier to hw IR.

Also the IR here only maps easily to a specific set of hardware. For
example it doesn't really map well to some of my more programmable
devices that want to consume "programs" more like BPF. So I don't see
any universal IR being possible. At best you get a set of IRs
dependent on the underlying architecture.

> 
> A summary picture of the infrastructure looks like this:
> 
>                 parser
>         tc-u32 -------
>                        \            jit
>      tc-flower -------------- ast ------> Backend driver
>                        /
>            nft -------
> 
> So the idea is that every frontend implements a parser that builds the
> ast, then this ast is passed via ndo to the driver. The parser is common
> to everyone, is part of the common core infrastructure.

Same argument as above with some helper libs going from u32 to driver
is really minimal code. And what are the performance impact of taking
a simple classifier like flower to ast to backend.

Looking at the similarities between u32 and nft should we unify them in
the stack so that,

   nft ---- jit(u32)

and just run nft inside u32? Or

   nft ---- jit(ebpf)

and just offload u32 or ebpf? or

    u32 --- jit(nft)

any one of those combinations :)

> 
> The tc-u32 parser is a bit complicated because of having the matching
> spread out in different rules through links, but John already came up a
> basic parser than should be placed in the frontend so everyone can
> improve it to generate more expressive ast.
> 
> Note: I don't have access to ixgbe hardware, so I have validated this
> patchset by splicing main parts of the ixgbe backend jit code in simple
> debugging patches that I have here. Quite rudimentary but it has passed
> some basic tests, may still have gotten anything broken. Anyway, the
> main goal is to generate debate on this.
> 

Yep lets debate the general approach. I can deal with ixgbe details. My
reaction is this seems overkill I only see offloads popping up for
flower, u32, nft, and bpf at the moment. Flower doesn't need heavy
overhead due to its simplicity. u32 can be done with some basic helpers
for devices like ixgbe. I think nft can be done the same. bpf is its own
beast that doesn't map well to another IR its more or less its own IR
anyways.

If we need/want a IR I would go for something instruction based
like ebpf over this.

> Comments welcome, thanks.
> 
> Pablo Neira Ayuso (3):
>   net: ixgbe: add struct igxbe_filter
>   net: intermediate representation for jit translation
>   net: convert tc_u32 to use the intermediate representation
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 249 +++++++++---------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
>  include/net/ir.h                               | 173 +++++++++++++
>  include/net/pkt_cls.h                          |   3 +
>  net/core/Makefile                              |   2 +-
>  net/core/ir.c                                  | 219 ++++++++++++++++
>  net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++
>  8 files changed, 866 insertions(+), 240 deletions(-)
>  delete mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
>  create mode 100644 include/net/ir.h
>  create mode 100644 net/core/ir.c
> 
