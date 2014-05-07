From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Wed, 7 May 2014 10:30:23 +0300
Message-ID: <CAE1zotJXpM+crFYE8-95G6s77BGvWF0LUUNgvCjQPcr-nbmzAA@mail.gmail.com>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
	<20140507.013820.1357850416047414291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:42245 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbaEGHaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 03:30:25 -0400
Received: by mail-we0-f178.google.com with SMTP id u56so552960wes.37
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 00:30:24 -0700 (PDT)
In-Reply-To: <20140507.013820.1357850416047414291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Octavian Purdila <octavian.purdila@intel.com>
> Date: Tue,  6 May 2014 21:05:24 +0300
>
> > Pardon the rough patch, but I hope it is enough to get some feedback
> > on the overall approach.
>
> Sorry I don't like this.
>
> Walking a linked list unnecessary is going to add overhead to every
> single packet transmission.  I think more people want our TCP stack to
> be fast (everyone) than those who want option processing to be
> abstracted enough to be modular (you).
>
> Just make the intrusive changes, they are necessary as they force you
> to think fully about how one option might interact with another.
>

Unfortunately skb_tcp_cb does not have enough space to hold
information for new large options. To work around that, the MPTCP
implementation is pushing the option data in the skb and then
occasionally uses the following when the pskb_copy is used:

-               else
+               if (unlikely(skb_cloned(skb))) {
+                       struct sk_buff *newskb;
+                       if (mptcp_is_data_seq(skb))
+                               skb_push(skb, MPTCP_SUB_LEN_DSS_ALIGN +
+                                             MPTCP_SUB_LEN_ACK_ALIGN +
+                                             MPTCP_SUB_LEN_SEQ_ALIGN);
+
+                       newskb = pskb_copy(skb, gfp_mask);
+
+                       if (mptcp_is_data_seq(skb)) {
+                               skb_pull(skb, MPTCP_SUB_LEN_DSS_ALIGN +
+                                             MPTCP_SUB_LEN_ACK_ALIGN +
+                                             MPTCP_SUB_LEN_SEQ_ALIGN);
+                               if (newskb)
+                                       skb_pull(newskb,
MPTCP_SUB_LEN_DSS_ALIGN +
+
MPTCP_SUB_LEN_ACK_ALIGN +
+
MPTCP_SUB_LEN_SEQ_ALIGN);
+                       }
+                       skb = newskb;
+               } else {
                        skb = skb_clone(skb, gfp_mask);
+               }

MPTCP has many other intrusive changes in the TCP stack. To avoid that
complexity, we could do the bulk of the implementation in a separate
layer, on top of TCP. But we would need a mechanism to pass the
options down to the TCP layer somehow.

> I also disagree with the "if the option doesn't fit, send it in the
> next packet" idea.  Where did that come from?
>
> For SACK for example, that doesn't make any sense, and it's SACK
> that usually can put us past the amount of space available.  For
> SACK the thing to do is send the SACK information for the area
> closest to what we've fully ACKd and just forget about advertising
> the rest of the SACK blocks.

It is useful for MPTCP. A few MPTCP options are 12-20 bytes but if you
already have timestamps and SACK in the packet there is not enough
space to include it. However, MPTCP does not bound you to sent the
options immediately, they can be sent at a later time.

The patch may look like an "abstraction bloat", but it is just a way
of trying to to keep adding more complexity in the TCP stack when
implementing MPTCP. If people have other ideas of how can we
accomplish that, so that we can integrate MPTCP upstream, I am keenly
looking for suggestions.
