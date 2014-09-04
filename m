From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 03:25:59 +0200
Message-ID: <1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
 <54078FBC.5050402@redhat.com>
 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
 <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58174 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750796AbaIDB0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 21:26:00 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 6272D20A21
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2014 21:25:59 -0400 (EDT)
In-Reply-To: <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014, at 03:08, Eric Dumazet wrote:
> On Wed, 2014-09-03 at 16:14 -0700, Alexei Starovoitov wrote:
> > On Wed, Sep 3, 2014 at 3:01 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> > > On 09/03/2014 11:08 PM, Denis Kirjanov wrote:
> > >>
> > >
> > >> +static int __init init_pkt_type_offset(void)
> > >>   {
> > >>         struct sk_buff skb_probe = { .pkt_type = ~0, };
> > >>         u8 *ct = (u8 *) &skb_probe;
> > >>         unsigned int off;
> > >>
> > >> +       pkt_type_offset = -1;
> > >>         for (off = 0; off < sizeof(struct sk_buff); off++) {
> > >> -               if (ct[off] == PKT_TYPE_MAX)
> > >> +               if (ct[off] == PKT_TYPE_MAX) {
> > >> +                       pkt_type_offset = off;
> > >>                         return off;
> > >> +               }
> > >>         }
> > >
> > >
> > > Why not BUG_ON() when pkt_type_offset could not be found?
> > >
> > > That way we would know that something is broken and you can
> > > spare the checks for negative offsets everywhere ...
> > 
> > also such BUG_ON will be right in the face, since the kernel
> > won't even boot :)
> > I guess we can only hit it if compiler changes and starts
> > doing crazing things with bitfields.
> > Eric, you're the original author of this function, thoughts?
> 
> At the time it was written, BPF JIT would have failed and we would
> revert to interpreter, thus BUG() was not needed : I used one
> pr_err_once()
> 
> Note that pkt_type could be moved easily in sk_buff definition, so a
> BUG() would be OK after this patch, since the check is done as a
> pure_initcall() at boot time.

Can't we add an address marker to struct sk_buff?

Several possibilities are available:

ptrdiff_t pkt_type_offset[0]  before the pkt_type flags field

If one wants to make it more expressive:
typedef struct {} mark_struct_offset;
and add
mark_struct_offset pkt_type_offset;
at appropriate places

Or maybe an anonymous union?

pkt_type_offset would become a simple offsetof(struct sk_buff,
pkt_type_offset) then and there is no need for BUG_ON then.

Bye,
Hannes
