From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and rewrite
Date: Wed, 3 Aug 2016 15:36:34 -0700
Message-ID: <20160803223632.GA42605@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-13-git-send-email-bblanco@plumgrid.com>
 <CALx6S34b1O6iiFn6M2=xX3iduGWDQm=G+jweYVvGqY-xa4E2sg@mail.gmail.com>
 <20160803171118.GA37742@ast-mbp.thefacebook.com>
 <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
 <20160803182950.GA10130@gmail.com>
 <CALx6S36k=kfrvY+aFD4rfq+nUJfd5-=8+26uk-=8dCFye_c-Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Aaron Yue <haoxuany@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35315 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcHCWgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 18:36:40 -0400
Received: by mail-pa0-f51.google.com with SMTP id iw10so77688765pac.2
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 15:36:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36k=kfrvY+aFD4rfq+nUJfd5-=8+26uk-=8dCFye_c-Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 03, 2016 at 12:06:55PM -0700, Tom Herbert wrote:
> On Wed, Aug 3, 2016 at 11:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > On Wed, Aug 03, 2016 at 10:29:58AM -0700, Tom Herbert wrote:
> >> On Wed, Aug 3, 2016 at 10:11 AM, Alexei Starovoitov
> >> <alexei.starovoitov@gmail.com> wrote:
> >> > On Wed, Aug 03, 2016 at 10:01:54AM -0700, Tom Herbert wrote:
> >> >> On Tue, Jul 19, 2016 at 12:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > [...]
> >> >> > +SEC("xdp1")
> >> >> > +int xdp_prog1(struct xdp_md *ctx)
> >> >> > +{
> >> >> > +       void *data_end = (void *)(long)ctx->data_end;
> >> >> > +       void *data = (void *)(long)ctx->data;
> >> >>
> >> >> Brendan,
> >> >>
> >> >> It seems that the cast to long here is done because data_end and data
> >> >> are u32s in xdp_md. So the effect is that we are upcasting a
> >> >> thirty-bit integer into a sixty-four bit pointer (in fact without the
> >> >> cast we see compiler warnings). I don't understand how this can be
> >> >> correct. Can you shed some light on this?
> >> >
> >> > please see:
> >> > http://lists.iovisor.org/pipermail/iovisor-dev/2016-August/000355.html
> >> >
> >> That doesn't explain it. The only thing I can figure is that there is
> >> an implicit assumption somewhere that even though the pointer size may
> >> be 64 bits, only the low order thirty-two bits are relevant in this
> >> environment (i.e. upper bit are always zero for any pointers)-- so
> >> then it would safe store pointers as u32 and to upcast them to void *.
> > No, the actual pointer storage is always void* sized (see struct
> > xdp_buff). The mangling is cosmetic. The verifier converts the
> > underlying bpf load instruction to the right sized operation.
> 
> This is not at all obvious to XDP programmer. The type of ctx
> structure is xdp_md and the definition of that structure in
> uapi/linux/bpf.h says that the fields in the that structure are __u32.
> So when I, as a user naive the inner workings of the verifier, read
> this code it sure looks like we are upcasting a 32 bit value to a 64
> bit value-- that does not seem right at all and the compiler
> apparently concurs my point of view. If the code ends up being correct
> anyway, then the obvious answer to have an explicit cast that points
> out the special nature of this cast. Blindly casting to u32 to long
> for the purposes of assigning to a pointer is only going to confuse
> more people as it has me.

Agree. Would be nice to have few helpers. The question is whether
they belong in bpf.h. Probably not, since they're not kernel abi.
For the same reasons we didn't include instruction building macros
like BPF_ALU64_REG and instead kept them in samples/bpf/libbpf.h
Here probably four static inline functions are needed. Two for __sk_buff
and two for xpd_md. That should make xdp*_kern.c examples a bit easier
to read.
