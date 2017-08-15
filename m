From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Tue, 15 Aug 2017 20:17:17 +0200
Message-ID: <1502821037.3475.16.camel@redhat.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
         <1502702846.8411.25.camel@redhat.com> <1846443.VTclhqQinN@ring00>
         <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
         <1502724662.8411.53.camel@redhat.com>
         <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
         <1502811641.3475.7.camel@redhat.com>
         <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753266AbdHOSRU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 14:17:20 -0400
In-Reply-To: <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 12:45 -0400, Willem de Bruijn wrote:
> On Tue, Aug 15, 2017 at 11:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > For the record, I thought something like the following (uncomplete,
> > does not even compile):
> > ---
> > diff --git a/include/linux/socket.h b/include/linux/socket.h
> > index 8b13db5163cc..5085cf003b88 100644
> > --- a/include/linux/socket.h
> > +++ b/include/linux/socket.h
> > @@ -286,6 +286,7 @@ struct ucred {
> >  #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
> >  #define MSG_BATCH      0x40000 /* sendmmsg(): more messages coming */
> >  #define MSG_EOF         MSG_FIN
> > +#define MSG_PEEK_OFF   0x80000
> 
> Yes, that also works well.
> 
> I'm afraid about exhausting the MSG_* flag space here for a
> feature that is not exposed to userspace. We don't have many flags
> left. We could shadow an existing flag that is unused in this context.

That was my concern, too. Fortunately there are a bunch of flags
defined but apparently unused (MSG_FIN, MSG_SYN, MSG_RST) since long
time (if I'm not too low on coffee).

We can shadow one of them (and ev. drop the above define, if really
unused).

I think that the MSG_PEEK_OFF should be explicitly cleared in
sk_peek_offset() when the 'sk_peek_off' is negative, to avoid beeing
fooled by stray bits into the 'flags' argument.

I'll try to scatch-up something tomorrow.

Thanks,

Paolo
