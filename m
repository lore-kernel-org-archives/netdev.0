From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Tue, 29 Nov 2016 21:37:37 -0800
Message-ID: <20161130053735.GB31581@ast-mbp.thefacebook.com>
References: <cover.1480424542.git.tgraf@suug.ch>
 <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
 <20161130001504.GA28238@ast-mbp.thefacebook.com>
 <583E3EF4.7030107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
        netdev@vger.kernel.org, daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33829 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbcK3Fhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 00:37:43 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so9513358pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 21:37:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <583E3EF4.7030107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 06:52:36PM -0800, John Fastabend wrote:
> On 16-11-29 04:15 PM, Alexei Starovoitov wrote:
> > On Tue, Nov 29, 2016 at 02:21:22PM +0100, Thomas Graf wrote:
> >> Registers new BPF program types which correspond to the LWT hooks:
> >>   - BPF_PROG_TYPE_LWT_IN   => dst_input()
> >>   - BPF_PROG_TYPE_LWT_OUT  => dst_output()
> >>   - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()
> >>
> >> The separate program types are required to differentiate between the
> >> capabilities each LWT hook allows:
> >>
> >>  * Programs attached to dst_input() or dst_output() are restricted and
> >>    may only read the data of an skb. This prevent modification and
> >>    possible invalidation of already validated packet headers on receive
> >>    and the construction of illegal headers while the IP headers are
> >>    still being assembled.
> >>
> >>  * Programs attached to lwtunnel_xmit() are allowed to modify packet
> >>    content as well as prepending an L2 header via a newly introduced
> >>    helper bpf_skb_push(). This is safe as lwtunnel_xmit() is invoked
> >>    after the IP header has been assembled completely.
> >>
> >> All BPF programs receive an skb with L3 headers attached and may return
> >> one of the following error codes:
> >>
> >>  BPF_OK - Continue routing as per nexthop
> >>  BPF_DROP - Drop skb and return EPERM
> >>  BPF_REDIRECT - Redirect skb to device as per redirect() helper.
> >>                 (Only valid in lwtunnel_xmit() context)
> >>
> >> The return codes are binary compatible with their TC_ACT_
> >> relatives to ease compatibility.
> >>
> >> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ...
> >> +#define LWT_BPF_MAX_HEADROOM 128
> > 
> > why 128?
> > btw I'm thinking for XDP to use 256, so metadata can be stored in there.
> > 
> 
> hopefully not too off-topic but for XDP I would like to see this get

definitely off-topic. lwt->headroom is existing concept. Too late
to do anything about it.

> passed down with the program. It would be more generic and drivers could
> configure the headroom on demand and more importantly verify that a
> program pushing data is not going to fail at runtime.

For xdp I think it will be problematic, since we'd have to check for
that value at prog array access to make sure tailcalls are not broken.
Mix and match won't be possible.
So what does 'configure the headroom on demand' buys us?
Isn't it much easier to tell all drivers "always reserve this much" ?
We burn the page anyway.
If it's configurable per driver, then we'd need an api
to retrieve it. Yet the program author doesn't care what the value is.
If program needs to do udp encap, it will try do it. No matter what.
If xdp_adjust_head() helper fails, the program will likely decide
to drop the packet. In some cases it may decide to punt to stack
for further processing, but for high performance dataplane code
it's highly unlikely.
If it's configurable to something that is not cache line boundary
hw dma performance may suffer and so on.
So I see only cons in such 'configurable headroom' and propose
to have fixed 256 bytes headroom for XDP
which is enough for any sensible encap and metadata.
