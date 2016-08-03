From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and rewrite
Date: Wed, 3 Aug 2016 12:06:55 -0700
Message-ID: <CALx6S36k=kfrvY+aFD4rfq+nUJfd5-=8+26uk-=8dCFye_c-Ow@mail.gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-13-git-send-email-bblanco@plumgrid.com> <CALx6S34b1O6iiFn6M2=xX3iduGWDQm=G+jweYVvGqY-xa4E2sg@mail.gmail.com>
 <20160803171118.GA37742@ast-mbp.thefacebook.com> <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
 <20160803182950.GA10130@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
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
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34485 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758012AbcHCTG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 15:06:57 -0400
Received: by mail-io0-f169.google.com with SMTP id q83so252822399iod.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 12:06:56 -0700 (PDT)
In-Reply-To: <20160803182950.GA10130@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2016 at 11:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> On Wed, Aug 03, 2016 at 10:29:58AM -0700, Tom Herbert wrote:
>> On Wed, Aug 3, 2016 at 10:11 AM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Wed, Aug 03, 2016 at 10:01:54AM -0700, Tom Herbert wrote:
>> >> On Tue, Jul 19, 2016 at 12:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> [...]
>> >> > +SEC("xdp1")
>> >> > +int xdp_prog1(struct xdp_md *ctx)
>> >> > +{
>> >> > +       void *data_end = (void *)(long)ctx->data_end;
>> >> > +       void *data = (void *)(long)ctx->data;
>> >>
>> >> Brendan,
>> >>
>> >> It seems that the cast to long here is done because data_end and data
>> >> are u32s in xdp_md. So the effect is that we are upcasting a
>> >> thirty-bit integer into a sixty-four bit pointer (in fact without the
>> >> cast we see compiler warnings). I don't understand how this can be
>> >> correct. Can you shed some light on this?
>> >
>> > please see:
>> > http://lists.iovisor.org/pipermail/iovisor-dev/2016-August/000355.html
>> >
>> That doesn't explain it. The only thing I can figure is that there is
>> an implicit assumption somewhere that even though the pointer size may
>> be 64 bits, only the low order thirty-two bits are relevant in this
>> environment (i.e. upper bit are always zero for any pointers)-- so
>> then it would safe store pointers as u32 and to upcast them to void *.
> No, the actual pointer storage is always void* sized (see struct
> xdp_buff). The mangling is cosmetic. The verifier converts the
> underlying bpf load instruction to the right sized operation.

This is not at all obvious to XDP programmer. The type of ctx
structure is xdp_md and the definition of that structure in
uapi/linux/bpf.h says that the fields in the that structure are __u32.
So when I, as a user naive the inner workings of the verifier, read
this code it sure looks like we are upcasting a 32 bit value to a 64
bit value-- that does not seem right at all and the compiler
apparently concurs my point of view. If the code ends up being correct
anyway, then the obvious answer to have an explicit cast that points
out the special nature of this cast. Blindly casting to u32 to long
for the purposes of assigning to a pointer is only going to confuse
more people as it has me.

Tom
