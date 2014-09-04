From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Wed, 03 Sep 2014 18:08:13 -0700
Message-ID: <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	 <54078FBC.5050402@redhat.com>
	 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:53155 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932912AbaIDBIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 21:08:16 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so18806959pac.39
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 18:08:15 -0700 (PDT)
In-Reply-To: <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 16:14 -0700, Alexei Starovoitov wrote:
> On Wed, Sep 3, 2014 at 3:01 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> > On 09/03/2014 11:08 PM, Denis Kirjanov wrote:
> >>
> >
> >> +static int __init init_pkt_type_offset(void)
> >>   {
> >>         struct sk_buff skb_probe = { .pkt_type = ~0, };
> >>         u8 *ct = (u8 *) &skb_probe;
> >>         unsigned int off;
> >>
> >> +       pkt_type_offset = -1;
> >>         for (off = 0; off < sizeof(struct sk_buff); off++) {
> >> -               if (ct[off] == PKT_TYPE_MAX)
> >> +               if (ct[off] == PKT_TYPE_MAX) {
> >> +                       pkt_type_offset = off;
> >>                         return off;
> >> +               }
> >>         }
> >
> >
> > Why not BUG_ON() when pkt_type_offset could not be found?
> >
> > That way we would know that something is broken and you can
> > spare the checks for negative offsets everywhere ...
> 
> also such BUG_ON will be right in the face, since the kernel
> won't even boot :)
> I guess we can only hit it if compiler changes and starts
> doing crazing things with bitfields.
> Eric, you're the original author of this function, thoughts?

At the time it was written, BPF JIT would have failed and we would
revert to interpreter, thus BUG() was not needed : I used one
pr_err_once()

Note that pkt_type could be moved easily in sk_buff definition, so a
BUG() would be OK after this patch, since the check is done as a
pure_initcall() at boot time.
