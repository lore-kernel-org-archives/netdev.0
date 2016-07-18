From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Mon, 18 Jul 2016 12:03:25 -0700
Message-ID: <20160718190323.GB9198@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com>
 <CALx6S37hihFayCBJcrr61WjER11=fDk_S_sGXaRSoC3Ukw93eA@mail.gmail.com>
 <20160718091023.GA29198@pox.localdomain>
 <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
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
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33568 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbcGRTD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 15:03:29 -0400
Received: by mail-pf0-f177.google.com with SMTP id y134so42445288pfg.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 12:03:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 01:39:02PM +0200, Tom Herbert wrote:
> On Mon, Jul 18, 2016 at 11:10 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 07/15/16 at 10:49am, Tom Herbert wrote:
[...]
> >> To me, an XDP program is just another attribute of an RX queue, it's
> >> really not special!. We already have a very good infrastructure for
> >> managing multiqueue and pretty much everything in the receive path
> >> operates at the queue level not the device level-- we should follow
> >> that model.
> >
> > I agree with that but I would like to keep the current per net_device
> > atomic properties.
> 
> I don't see that see that there is any synchronization guarantees
> using xchg. For instance, if the pointer is set right after being read
> by a thread for one queue and right before being read by a thread for
> another queue, this could result in the old and new program running
> concurrently or old one running after new. If we need to synchronize
> the operation across all queues then sequence
> ifdown,modify-config,ifup will work.
The case you mentioned is a valid criticism. The reason I wanted to keep this
fast xchg around is because the full stop/start operation on mlx4 is a second
or longer of downtime. I think something like the following should suffice to
have a clean cut between programs without bringing the whole port down, buffers
and all:

{
        struct bpf_prog *old_prog;
        bool port_up;
        int i;

        mutex_lock(&mdev->state_lock);
        port_up = priv->port_up;
        priv->port_up = false;
        for (i = 0; i < priv->rx_ring_num; i++)
                napi_synchronize(&priv->rx_cq[i]->napi);

        old_prog = xchg(&priv->prog, prog);
        if (old_prog)
                bpf_prog_put(old_prog);

        priv->port_up = port_up;
        mutex_unlock(&mdev->state_lock);
}

Thoughts?

> 
> Tom
