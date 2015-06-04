From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Thu, 4 Jun 2015 14:29:59 -0700
Message-ID: <CAK6E8=d3cGxABb95wMqkuRBpo=wscvaOA5e467Ar+nG4U4PFMw@mail.gmail.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
 <CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com>
 <5E30A40E-EC6C-4D37-AB49-04BF40EEFBFC@fastly.com> <CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com>
 <904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com> <CADVnQymCSGyyOqdO2HOap+_6zsfy99-3CbgxnQTfGakRYNoteQ@mail.gmail.com>
 <55707E38.4090506@fastly.com> <20150604193838.GA2951343@devbig242.prn2.facebook.com>
 <5570B0B2.5080908@fastly.com> <20150604205629.GB2951343@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Zhang <gzhang@fastly.com>, netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:32992 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbFDVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 17:30:40 -0400
Received: by obbea3 with SMTP id ea3so41867927obb.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 14:30:40 -0700 (PDT)
In-Reply-To: <20150604205629.GB2951343@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 1:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>
> On Thu, Jun 04, 2015 at 01:10:26PM -0700, Grant Zhang wrote:
> > Hi Martin,
> >
> > Thank you! My net.ipv4.tcp_mtu_probing is 1. After turning it off,
> > the WARN_ON stack is gone.
> Thanks for confirming it.
>
> > Could you elaborate a bit on why this setting relates to the WARN_ON
> > trace?
> The WARN_ON is complaining about tcp_fragment() is trying to slice
> a skb which has a too-short skb->len.
>
> When doing mtu probing, it may slice the skb.  In some cases (which
> I also failed to reproduce in packetdrill), it does not
> update some related skb values and then confuse tcp_fragment()
> later on.
>
> > And what are the pros/cons for disabling mtu_probing?
> It depends on your traffic, I guess.  However, turning it off is not the
> right fix.
There might be two bugs. We saw the warning with mtu_probing=0. This
would explain why Neal's fix did not work.


>
> FYI, here is the change I am trying.
>
> Thanks,
> --Martin
>
> diff --git i/net/ipv4/tcp_output.c w/net/ipv4/tcp_output.c
> index acec745..e767e53 100644
> --- i/net/ipv4/tcp_output.c
> +++ w/net/ipv4/tcp_output.c
> @@ -1920,6 +1920,8 @@ static int tcp_mtu_probe(struct sock *sk)
>                                                    ~(TCPHDR_FIN|TCPHDR_PSH);
>                         if (!skb_shinfo(skb)->nr_frags) {
>                                 skb_pull(skb, copy);
> +                               if (tcp_skb_pcount(skb) > 1)
> +                                       tcp_set_skb_tso_segs(sk, skb, mss_now);
>                                 if (skb->ip_summed != CHECKSUM_PARTIAL)
>                                         skb->csum = csum_partial(skb->data,
>                                                                  skb->len, 0);
