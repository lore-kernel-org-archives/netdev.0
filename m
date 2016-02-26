From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC 0/3] intermediate representation for jit and cls_u32
 conversion
Date: Fri, 26 Feb 2016 10:53:00 -0800
Message-ID: <20160226185258.GA51957@ast-mbp.thefacebook.com>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
 <56CF43D8.1010106@gmail.com>
 <20160226114036.GA2523@salvia>
 <56D07261.1060302@gmail.com>
 <20160226161948.GA4667@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35940 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbcBZSxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 13:53:06 -0500
Received: by mail-pf0-f177.google.com with SMTP id e127so56582545pfe.3
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 10:53:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160226161948.GA4667@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 05:19:48PM +0100, Pablo Neira Ayuso wrote:
> 
> Good, I'm all for reaching those numbers, we can optimize the generic
> IR if this ever becomes the bottleneck.

The 'generic IR' got mentioned hundred times in this thread,
but what was proposed is not generic. It doesn't even
fully fit u32. Here is why:

> This structure contains a protocol description (defined by struct
> net_ir_proto_desc) that is the initial node of the protocol graph that
> describes the protocol translation. This initial node starts from lower
> supported layer as base (eg. link-layer) then describing the upper
> protocols up to the transport protocols through the following structure:
> 
>  struct net_ir_proto_desc {
>        enum net_ir_payload_bases               base;
>        u32                                     protonum;
>        int                                     (*jit)(struct net_ir_jit_ctx *ctx,
>                                                       const struct net_ir_expr *expr,
>                                                       void *data);
>        const struct net_ir_proto_desc          *protocols[];
>  };

The above representation has builtin concept of protocols, whereas
u32 is protocol agnostic and fits this particular intel nic better.

>  struct net_ir_jit_desc {
>        enum net_ir_payload_bases               base;
>        const struct net_ir_proto_desc          *proto_desc;
>        int                                     (*verdict)(struct net_ir_jit_ctx *ctx,
>                                                           enum net_ir_stmt_verdict verdict,
>                                                           void *data);
>  };

imo the above is a misuse of JIT abbreviation.
Typically JIT means compiling to machine code that can be executed
directly. Converting one representation to another is not really JIT.
Also IR stands for _intermediate_ representation. It is a transitional
state when compiler converts high level language into machine code.
In this case the proposed format is protocol specific syntax tree,
so probably should be called as such.

imo the HW guys should be free to pick whatever representation
we have today and offload it. If u32 is convenient and applies
to HW architecture better, the driver should take u32 tree and
map it to HW (which is what was done already). When/If another
HW comes along with similar HW architecture we can generalize
and reuse u32->ixgbe code. And it should be done by developers
who actually have the HW and can test on it. Trying to 'generalize'
u32->ixgbe code without 2nd HW is not going to be successful.
