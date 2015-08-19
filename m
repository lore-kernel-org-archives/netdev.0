From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Wed, 19 Aug 2015 13:39:22 -0700
Message-ID: <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35706 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbbHSUjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:39:24 -0400
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 19:17 +0000, Grumbach, Emmanuel wrote:

> Hm.. how would net/core/tso.c avoid this?

Because a driver using these helpers keep around the original LSO packet
and frees it normally at TX completion time.

> I can't see anything related to truesize there.
> Note that this work since it is guaranteed that we release the skbs in
> order.
> 
> > 
> > (BTW TCP packets do not have sock_wfree as destructor but tcp_wfree(),
> > yet we want backpressure mostly for TCP stack (TCP Small Queues))
> > 
> > 
> 
> I am not sure I follow here.
> You want me to test:
> if (skb_gso->destructor == tcp_wfree) ?


Yes.

Look for example at tcp_gso_segment() (called from skb_gso_segment())

copy_destructor = gso_skb->destructor == tcp_wfree;
...
        /* Following permits TCP Small Queues to work well with GSO :
         * The callback to TCP stack will be called at the time last frag
         * is freed at TX completion, and not right now when gso_skb
         * is freed by GSO engine
         */
        if (copy_destructor) {
                swap(gso_skb->sk, skb->sk);
                swap(gso_skb->destructor, skb->destructor);
                sum_truesize += skb->truesize;
                atomic_add(sum_truesize - gso_skb->truesize,
                           &skb->sk->sk_wmem_alloc);
        }


> 
> I checked that code using iperf and saw that I don't get into this if,
> but I (probably wrongly) assumed that other applications would set a
> flag on the socket (forgive my ignorance) that would make this if be taken.

If you do not see skb->destructor == tcp_wfree, then something is
definitely wrong on your setup.
