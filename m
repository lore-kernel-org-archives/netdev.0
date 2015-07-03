From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Fri, 03 Jul 2015 06:45:01 +0200
Message-ID: <1435898701.11970.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
	 <20150701.141402.587634025761326092.davem@davemloft.net>
	 <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
	 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
	 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
	 <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
	 <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
	 <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38495 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbbGCEpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 00:45:06 -0400
Received: by wibdq8 with SMTP id dq8so89898802wib.1
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 21:45:04 -0700 (PDT)
In-Reply-To: <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 14:18 -0700, Alex Gartrell wrote:
> On Thu, Jul 2, 2015 at 1:44 AM, Julian Anastasov <ja@ssi.bg> wrote:
> >         I think, your patch from January is almost
> > good:
> 
> I'll rebase it, add your other suggestions, test it, and send it in.
> 
> > And the patch from Eric for IPVS looks good too.
> 
> Are we sure that we want to change the semantics of set_owner_w to
> orphan it?  It works for us but that's not the behavior I'd expect
> from that function and might burn someone later?

I do not understand the concern.

skb_set_owner_w() callers are attempting to :

1) Remove association of a previous socket (skb_orphan()), if it was
there (while most skb at this point are not associated with a previous
socket)

2) Attach skb to a socket.

My fix makes sure this new socket is not a timewait or request sock.

This could happen when routes are changed in a malicious way,
because in early demux, socket dst cache is not valid anymore,
but we keep skb->sk set.

(This could happen without ipvs being in the picture I think)

Bug could happen for example if 
A) GRO cooks a GRO packet
B) we find a timewait socket and attach it to skb (and soon we also
might find a syn_recv socket)
C) Route decides to forward packet
D) output interface needs to add some headroom, check for example
net/ipv6/ip6_gre.c around lines 699
