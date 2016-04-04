From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 00:04:39 +0200
Message-ID: <20160404220439.GA9972@pox.localdomain>
References: <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <57022A85.6040002@iogearbox.net>
 <20160404150700.1456ae80@redhat.com>
 <57026DFA.3090201@iogearbox.net>
 <CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
 <20160404171227.1f862cb1@redhat.com>
 <20160404152948.GA495@gmail.com>
 <57029127.3040303@gmail.com>
 <20160404161720.GB495@gmail.com>
 <20160404200032.GA69842@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36081 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbcDDWEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 18:04:43 -0400
Received: by mail-lb0-f180.google.com with SMTP id qe11so181521360lbc.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 15:04:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160404200032.GA69842@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/16 at 01:00pm, Alexei Starovoitov wrote:
> Exactly. That the most important part of this rfc.
> Right now redirect to different queue, batching, prefetch and tons of
> other code are mising. We have to plan the whole project, so we can
> incrementally add features without breaking abi.
> So new IFLA, xdp_metadata struct and enum for bpf return codes are
> the main things to agree on.

+1
This is the most important statement in this thread so far. A plan
that gets us from this RFC series to a functional forwarding engine
with redirect and load/write is essential. [...]

> Another reason for going with 'pseudo skb' structure was to reuse
> load_byte/half/word instructions in bpf interpreter as-is.
> Right now these instructions have to see in-kernel
> 'struct sk_buff' as context (note we have mirror __sk_buff
> for user space), so to use load_byte for bpf_prog_type_phys_dev
> we have to give real 'struct sk_buff' to interpter with
> data, head, len, data_len fields initialized, so that
> interpreter 'just works'.
> The potential fix would be to add phys_dev specific load_byte/word
> instructions. Then we can drop all the legacy negative offset
> stuff that <1% uses, but it slows down everyone.
> We can also drop byteswap that load_word does (which turned out
> to be confusing and often programs do 2nd byteswap to go
> back to cpu endiannes).

[...] I would really like to see a common set of helpers which
applies to both cls_bpf and phys_dev. Given the existing skb based
helpers cannot be overloaded, at least the phys_dev helpers should
be made to work in cls_bpf context as well to allow for some
portability. Otherwise we'll end up with half a dozen flavours of
BPF which are all incompatible.

> And if we do it smart, we can drop length check as well,
> then new_load_byte will actually be single load byte cpu instruction.
> We can drop length check when offset is constant in the verfier
> and that constant is less than 64, since all packets are larger.
> As seen in 'perf report' from patch 5:
>   3.32%  ksoftirqd/1    [kernel.vmlinux]  [k] sk_load_byte_positive_offset
> this is 14Mpps and 4 assembler instructions in the above function
> are consuming 3% of the cpu. Making new_load_byte to be single
> x86 insn would be really cool.

Neat.
