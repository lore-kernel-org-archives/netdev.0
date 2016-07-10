From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 10 Jul 2016 08:40:31 -0700
Message-ID: <20160710154029.GA6657@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
 <CAJ3xEMjjG2ZZe=qBsRaFuk-j8Akj38Uk6+Nw1xuZya=R7FOJ7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33476 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbcGJPkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 11:40:35 -0400
Received: by mail-pf0-f169.google.com with SMTP id i123so27485648pfg.0
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 08:40:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjjG2ZZe=qBsRaFuk-j8Akj38Uk6+Nw1xuZya=R7FOJ7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2016 at 05:07:36PM +0300, Or Gerlitz wrote:
> On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
> >
> > In tc/socket bpf programs, helpers linearize skb fragments as needed
> > when the program touchs the packet data. However, in the pursuit of
> 
> nit, for the next version touchs --> touches
Will fix.
> 
[...]
> > +                       switch (act) {
> > +                       case XDP_PASS:
> > +                               break;
> > +                       default:
> > +                               bpf_warn_invalid_xdp_action(act);
> > +                       case XDP_DROP:
> > +                               goto next;
> > +                       }
> > +               }
> 
> 
> (probably a nit too, but wanted to make sure we don't miss something
> here) is the default case preceding the DROP one in purpose? any
> special reason to do that?
This is intentional, and legal though unconventional C. Without this
order, the later patches end up with a bit too much copy/paste for my
liking, as in:

case XDP_DROP:
        if (mlx4_en_rx_recycle(ring, frags))
                goto consumed;
        goto next;
default:
        bpf_warn_invalid_xdp_action(act);
        if (mlx4_en_rx_recycle(ring, frags))
                goto consumed;
        goto next;
