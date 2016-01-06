From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 05 Jan 2016 16:08:04 -0800
Message-ID: <1452038884.8255.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
	 <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452033208.8255.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGiwB6=oPm7uMMazkCZ5G+tijkq1PLCSgm1G4ES-7Hodp6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35989 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbcAFAIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 19:08:07 -0500
Received: by mail-pa0-f53.google.com with SMTP id yy13so130538303pab.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 16:08:06 -0800 (PST)
In-Reply-To: <CAEfhGiwB6=oPm7uMMazkCZ5G+tijkq1PLCSgm1G4ES-7Hodp6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 17:56 -0500, Craig Gallek wrote:
> On Tue, Jan 5, 2016 at 5:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > +       unsigned short hnum = ntohs(req->id.idiag_dport);
> > +       unsigned int slot = udp_hashfn(net, hnum, tbl->mask);
> > +       struct udp_hslot *hslot = &tbl->hash[slot];
> > +       struct hlist_nulls_node *node;
> > +       int err = -ENOENT;
> > +
> > +       spin_lock_bh(&hslot->lock);
> > +       sk_nulls_for_each(aux, node, &hslot->head) {
> > +               if (net_eq(sock_net(aux), net) &&
> > +                   !sock_diag_check_cookie(aux, req->id.idiag_cookie) &&
> > +                   (req->sdiag_family == AF_UNSPEC ||
> > +                    req->sdiag_family == aux->sk_family)) {
> > +                       sk = aux;
> > +                       sock_hold(sk);
> > +                       break;
> > +               }
> > +       }
> > +       spin_unlock_bh(&hslot->lock);
> >         if (!sk)
> >                 goto out_nosk;
> >
> > -       err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
> > -       if (err)
> > -               goto out;
> > -
> sock_diag_check_cookie will return successfully if the cookie in the
> request is INET_DIAG_NOCOOKIE before even considering the socket.  I
> think this could cause this loop to prematurely terminate.

Hmmm...

I never considered passing a INET_DIAG_NOCOOKIE there.

(Actually I am not sure if this interface is used. It is not in
iproute2)


> 
> Also, previously this would return ESTALE on a cookie error, now it
> returns ENOENT.  Not sure if this is a big deal or not, though...

Probably not a big deal.

I'll send a V3, thanks.
