From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf program
Date: Fri, 15 Jul 2016 10:49:52 -0700
Message-ID: <CALx6S37hihFayCBJcrr61WjER11=fDk_S_sGXaRSoC3Ukw93eA@mail.gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com> <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com> <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37391 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbcGORtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 13:49:53 -0400
Received: by mail-it0-f54.google.com with SMTP id f6so25245371ith.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 10:49:53 -0700 (PDT)
In-Reply-To: <20160715164744.GA3693@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 9:47 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Jul 15, 2016 at 09:18:13AM -0700, Tom Herbert wrote:
>> > attaching program to all rings at once is a fundamental part for correct
>> > operation. As was pointed out in the past the bpf_prog pointer
>> > in the ring design loses atomicity of the update. While the new program is
>> > being attached the old program is still running on other rings.
>> > That is not something user space can compensate for.
>> > So for current 'one prog for all rings' we cannot do what you're suggesting,
>> > yet it doesn't mean we won't do prog per ring tomorrow. To do that the other
>> > aspects need to be agreed upon before we jump into implementation:
>> > - what is the way for the program to know which ring it's running on?
>> >   if there is no such way, then attaching the same prog to multiple
>> >   ring is meaningless.
>>
>> Why would it need to know? If the user can say run this program on
>> this ring that should be sufficient.
>
> and the program would have to be recompiled with #define for every ring?

Why would we need to recompile? We should be able to run the same
program on different rings, this just a matter of associating each
ring with a program.

>> We already have this problem with other per ring configuration.
>
> not really. without atomicity of the program change, the user space
> daemon that controls it will struggle to adjust. Consider the case
> where we're pushing new update for loadbalancer. In such case we
> want to reuse the established bpf map, since we cannot atomically
> move it from old to new, but we want to swap the program that uses
> in one go, otherwise two different programs will be accessing
> the same map. Technically it's valid, but difference in the programs
> may cause issues. Lack of atomicity is not intractable problem,
> it just makes user space quite a bit more complex for no reason.
>

I'm really missing why having a program pointer per ring could be so
complicated. This should just a matter of maintaining a pointer to the
BPF program program in each RX queue. If we want to latch together all
the rings to run the same program then just have an API that does
that-- walk all the queues and set the pointer to the program.  if
necessary this can be done atomically by taking the device down for
the operation.

To me, an XDP program is just another attribute of an RX queue, it's
really not special!. We already have a very good infrastructure for
managing multiqueue and pretty much everything in the receive path
operates at the queue level not the device level-- we should follow
that model.

Tom
