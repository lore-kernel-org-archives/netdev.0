From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf program
Date: Mon, 18 Jul 2016 13:39:02 +0200
Message-ID: <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com> <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com> <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com> <CALx6S37hihFayCBJcrr61WjER11=fDk_S_sGXaRSoC3Ukw93eA@mail.gmail.com>
 <20160718091023.GA29198@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:38352 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbcGRLjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:39:04 -0400
Received: by mail-it0-f42.google.com with SMTP id j124so28951160ith.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:39:03 -0700 (PDT)
In-Reply-To: <20160718091023.GA29198@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 11:10 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/15/16 at 10:49am, Tom Herbert wrote:
>> I'm really missing why having a program pointer per ring could be so
>> complicated. This should just a matter of maintaining a pointer to the
>> BPF program program in each RX queue. If we want to latch together all
>> the rings to run the same program then just have an API that does
>> that-- walk all the queues and set the pointer to the program.  if
>> necessary this can be done atomically by taking the device down for
>> the operation.
>
> I think two different use cases are being discussed here. Running
> individual programs on different rings vs providing guarantees for the
> straight forward solo program use case.
>
> Implementing the program per ring doesn't sound complicated and it
> looks like we are only debating on whether to add it now or as a second
> step.
>
> For the solo program use case: an excellent property of BPF with cls_bpf
> right now is that it is possible to atomically replace a BPF program
> without disruption or dropping any packets (thanks to the properties of
> tc). This makes updating BPF programs simple and reliable. Even map
> layout updates can be managed relatively easily right now.
>
> It should be a goal to preserve that property in XDP. As a user, I
> will not expect the same guarantees when I add different programs to
> different rings whereas when I add a program on net_device level I will
> expect an atomic update without taking down the device.
>
>> To me, an XDP program is just another attribute of an RX queue, it's
>> really not special!. We already have a very good infrastructure for
>> managing multiqueue and pretty much everything in the receive path
>> operates at the queue level not the device level-- we should follow
>> that model.
>
> I agree with that but I would like to keep the current per net_device
> atomic properties.

I don't see that see that there is any synchronization guarantees
using xchg. For instance, if the pointer is set right after being read
by a thread for one queue and right before being read by a thread for
another queue, this could result in the old and new program running
concurrently or old one running after new. If we need to synchronize
the operation across all queues then sequence
ifdown,modify-config,ifup will work.

Tom
