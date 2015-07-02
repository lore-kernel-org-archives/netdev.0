From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Thu, 2 Jul 2015 11:44:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com> <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com> <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com> <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40469 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752899AbbGBIpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 04:45:13 -0400
In-Reply-To: <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 1 Jul 2015, Alex Gartrell wrote:

> On Wed, Jul 1, 2015 at 4:26 PM, Eric Dumazet <edumazet@google.com> wrote:
> > I think you are mistaken Alex.
> 
> Indeed, I was!  Should be unsurpising.
> 
> >
> > socket early demux cannot possibly set skb->destructor to sock_rfree()
> 
> Yeah I will admit adding the code to sock_rfree reflexively out of paranoia.
> 
> > If skb->destructor is set by early demux, it correctly points to sock_edemux()
> >
> > And this one correctly handles all socket variants.
> 
> Yes, the problem appears to be in ip_vs_prepare_tunneled_skb
> (ip_vs_xmit.c:859 in 4.0)
> 
>         if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
>                 new_skb = skb_realloc_headroom(skb, max_headroom);
>                 if (!new_skb)
>                         goto error;
>                 if (skb->sk)
>                         skb_set_owner_w(new_skb, skb->sk);
>                 consume_skb(skb);
>                 skb = new_skb;
>         }
> 
> skb_set_owner_w sets sock_wfree.
> 
> I'll figure out how to ensure that we're using an appropriate destructor here.

	Alex, in our discussion on January I thought
we can skip calling skb_orphan for some cases but as
input and output path use different skb->destructor
we should call skb_orphan for every method, in every
case when skb->dev != NULL, even when we do not call
LOCAL_OUT, i.e. when NF_ACCEPT is returned for traffic
to local real server. We should not call it only for
local socket (skb->dev == NULL).

	I think, your patch from January is almost
good:

http://archive.linuxvirtualserver.org/html/lvs-devel/2015-01/msg00014.html

	Just add skb->dev check and we should be fine.
And the patch from Eric for IPVS looks good too.

Regards

--
Julian Anastasov <ja@ssi.bg>
