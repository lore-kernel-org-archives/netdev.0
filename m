From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 22:20:22 +0200
Message-ID: <1502914822.2796.6.camel@redhat.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
         <1502702846.8411.25.camel@redhat.com> <1846443.VTclhqQinN@ring00>
         <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
         <1502724662.8411.53.camel@redhat.com>
         <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
         <1502811641.3475.7.camel@redhat.com>
         <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
         <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
         <1502875722.3548.11.camel@redhat.com>
         <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751847AbdHPUU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 16:20:26 -0400
In-Reply-To: <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 11:18 -0400, Willem de Bruijn wrote:
> > If I read the above correctly, you are arguining in favor of the
> > addittional flag version, right?
> 
> I was. Though if we are going to thread the argument from the caller
> to __skb_try_recv_from_queue to avoid rereading sk->sk_peek_off,
> on second thought it might be simpler to do it through off:
[...]
> This, of course, requires restricting sk_peek_off to protect against overflow.

Ok, even if I'm not 100% sure overall this will be simpler when adding
also the overflow check.

> If I'm not mistaken, the test in udp_recvmsg currently incorrectly sets
> peeking to false when peeking at offset zero:
> 
>         peeking = off = sk_peek_offset(sk, flags);

I think you are right, does not look correct.

> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -2408,9 +2408,7 @@ EXPORT_SYMBOL(__sk_mem_reclaim);
> > 
> >  int sk_set_peek_off(struct sock *sk, int val)
> >  {
> > -       if (val < 0)
> > -               return -EINVAL;
> > -
> > +       /* a negative value will disable peeking with offset */
> >         sk->sk_peek_off = val;
> >         return 0;
> >  }
> 
> Separate patch to net-next?

Agreed.

Paolo
