From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: Re: [PATCH] packet: uses kfree_skb() for drop.
Date: Wed, 6 Apr 2016 11:10:11 -0700
Message-ID: <20160406181010.GA17455@jwg>
References: <1459961686-14281-1-git-send-email-weongyo.linux@gmail.com>
 <CAF=yD-JrVXKsJTUcWSmuVmPbdZV=_h8hsVPQVQTPF64R1k684w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36110 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbcDFSKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 14:10:16 -0400
Received: by mail-pf0-f196.google.com with SMTP id q129so4982958pfb.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 11:10:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAF=yD-JrVXKsJTUcWSmuVmPbdZV=_h8hsVPQVQTPF64R1k684w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2016 at 01:27:11PM -0400, Willem de Bruijn wrote:
> On Wed, Apr 6, 2016 at 12:54 PM, Weongyo Jeong <weongyo.linux@gmail.com> wrote:
> > consume_skb() isn't for drop or error cases.  kfree_skb() is more proper
> > one.
> > Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
> > ---
> >  net/packet/af_packet.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 1ecfa71..a75d5bf 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -2141,7 +2141,7 @@ drop_n_restore:
> >                 skb->len = skb_len;
> >         }
> >  drop:
> > -       consume_skb(skb);
> > +       kfree_skb(skb);
> 
> This does show an inconsistency between packet_rcv and tpacket_rcv,
> which calls kfree_skb.
> 
> A comment at consume_skb mentions that kfree_skb is intended for drops
> that signal a failure condition, and indeed, that makes it a useful
> way to track errors (e.g., with perf record -a -g -e skb:kfree_skb).
> 
> This drop path is not always an error path, though. These network taps
> will legitimately drop references to any packets not destined to them.
> To be precise, only the drop_n_acct label cases are delivery errors
> (drops after the filter accepted the packet). Changing unconditionally
> to kfree_skb does pollute that useful counter with false positives. A
> pedantic solution is to change both functions to only call kfree_skb
> on drop_n_acct and consume_skb otherwise.
> 
> This shorthand change does at least makes packet_rcv and tpacket_rcv more alike.

Thank you for comments.  I'll try to submit patch v2 for this case.

Regards,
Weongyo Jeong
