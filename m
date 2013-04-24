From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 17:09:56 -0700
Message-ID: <1366762196.8964.46.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	 <1366749094-5982-1-git-send-email-willemb@google.com>
	 <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	 <1366753063.8964.14.camel@edumazet-glaptop>
	 <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36831 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab3DXAJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 20:09:58 -0400
Received: by mail-pa0-f42.google.com with SMTP id kl13so808823pab.1
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 17:09:58 -0700 (PDT)
In-Reply-To: <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 14:52 -0700, Stephen Hemminger wrote:

> I just don't want to get tied down to one hard coded policy.
> User seem have different ideas about what constitutes a flow and what policy for drop should be.
> Existing ingress qdisc is inflexible and ifb is a pain to setup and adds
> another queue transistion.

qdisc code has a hardcoded dev_hard_start_xmit() call, thats why ifb
hack is used. Not mentioning device flow control.

It might be possible to use a q->xmit() method instead, so that it can
be used on ingress without ifb.

Then we would have to allow one qdisc per RX queue, and not use qdisc
lock (assuming NAPI protects us from reentrancy).

So napi device handler would queue skbs in qdisc (q->enqueue()),
(allowing a standing queue to build so that some clever qdisc can drop
some selected packets)

Not really clear how we would allow packets being delivered to another
queue (RPS/RFS), and not clear how/when doing the qdisc_run() to dequeue
packets and deliver them to stack.

I don't know, this looks like a lot of changes.
