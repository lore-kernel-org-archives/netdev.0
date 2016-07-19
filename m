From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Mon, 18 Jul 2016 19:45:10 -0700
Message-ID: <20160719024509.GB49474@ast-mbp.thefacebook.com>
References: <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com>
 <CALx6S37hihFayCBJcrr61WjER11=fDk_S_sGXaRSoC3Ukw93eA@mail.gmail.com>
 <20160718091023.GA29198@pox.localdomain>
 <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
 <20160718124811.GB2979@pox.localdomain>
 <CALx6S36eGy59CK6OASZk9KSXL1zLbhK1YNXn6vQdpRb6ik6xng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
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
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35717 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbcGSCpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 22:45:16 -0400
Received: by mail-pf0-f180.google.com with SMTP id x72so2135625pfd.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 19:45:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36eGy59CK6OASZk9KSXL1zLbhK1YNXn6vQdpRb6ik6xng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 03:07:01PM +0200, Tom Herbert wrote:
> On Mon, Jul 18, 2016 at 2:48 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 07/18/16 at 01:39pm, Tom Herbert wrote:
> >> On Mon, Jul 18, 2016 at 11:10 AM, Thomas Graf <tgraf@suug.ch> wrote:
> >> > I agree with that but I would like to keep the current per net_device
> >> > atomic properties.
> >>
> >> I don't see that see that there is any synchronization guarantees
> >> using xchg. For instance, if the pointer is set right after being read
> >> by a thread for one queue and right before being read by a thread for
> >> another queue, this could result in the old and new program running
> >> concurrently or old one running after new. If we need to synchronize
> >> the operation across all queues then sequence
> >> ifdown,modify-config,ifup will work.
> >
> > Right, there are no synchronization guarantees between threads and I
> > don't think that's needed. The guarantee that is provided is that if
> > I replace a BPF program, the replace either succeeds in which case
> > all packets have been either processed by the old or new program. Or
> > the replace failed in which case the old program was left intact and
> > all packets are still going through the old program.
> >
> > This is a nice atomic replacement principle which would be nice to
> > preserve.
> 
> Sure, if replace operation fails then old program should remain in
> place. But xchg can't fail, so it seems like part is just giving a
> false sense of security that program replacement is somehow
> synchronized across queues.

good point. we do read_once at the beginning of napi, so we can
process a bunch of packets in other cpus even after xchg is all done.
Then I guess we can have a prog pointers in rings and it only marginally
increases the race. Why not if it doesn't increase the patch complexity...
btw we definitely want to avoid drain/start/stop or any slow operation
during prog xchg. When xdp is used for dos, the prog swap needs to be fast.
