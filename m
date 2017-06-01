From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Thu, 01 Jun 2017 22:35:46 +0200
Message-ID: <1496349346.2798.1.camel@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
         <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1496313592.4872.14.camel@redhat.com>
         <1496332699.27480.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <1496334113.9312.8.camel@redhat.com>
         <CANn89iKznSPH9VogQEPSw4bLL8F_L_qj2ZY2M==VZ-O1u0xqiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44902 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751024AbdFAUft (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 16:35:49 -0400
In-Reply-To: <CANn89iKznSPH9VogQEPSw4bLL8F_L_qj2ZY2M==VZ-O1u0xqiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-01 at 09:40 -0700, Eric Dumazet wrote:
> On Thu, Jun 1, 2017 at 9:21 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> 
> > I'm sorry, I do not follow. I'm concerned about the secpath field (skb-
> > > sp), which is the only one that can be not NULL in
> > 
> > __udp_queue_rcv_skb().
> > 
> > If the secpath is not NULL, calling there secpath_reset() (or the to-
> > be-introduced skb_reset_head_state()), we will properly release it and
> > we will clear the field, too.
> > 
> > Calling skb_release_head_state() in the same scenario, we release the
> > secpath, but we don't clear it. So if the packet is later dropped we
> > will get a double free, unless we add and use a specialized a
> > free_stateless_skb(), too.
> 
> Then simply use secpath_reset() instead of secpath_put() from
> skb_release_head_state()
> 
> Clearly having these subtle differences bring confusion, for very little gain.
> 
> secpath_put() should be removed. Most of its callers simply set
> skb->sp back to NULL anyway.

To make the code robust we would have to NULL all the other fields
(nfct, nf_bridge, destructor, sk) that are currently not cleared in
skb_release_head_state(), elsewhere if one day, after some change, any
that fields become non-NULL in this code path we risk a double-free
after skb_release_head_state(), even if the code looks safe.

Will that be a little too invasive for this small use-case? Can't we
prefer a new helper or simply a secpath_reset() plus some appropriate
comments?

Thanks,

Paolo
