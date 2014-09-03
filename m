From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 3 Sep 2014 14:54:38 -0400
Message-ID: <CA+FuTSdsrAAd0iti0oF3MDvXTtQWnBByuo_UMGCW2Dd+WnWeLg@mail.gmail.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com> <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:34519 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaICSzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:55:10 -0400
Received: by mail-qc0-f181.google.com with SMTP id i17so9143133qcy.26
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 11:55:09 -0700 (PDT)
In-Reply-To: <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 11:53 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> The phy timestamping takes a different path than the regular timestamping
> does in that it will create a clone first so that the packets needing to be
> timestamped can be placed in a queue, or the context block could be used.
>
> In order to support these use cases I am pulling the core of the code out
> so it can be used in other drivers beyond just phy devices.

Do you already have additional such use cases?

> +struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb)
> +{
> +       struct sock *sk = skb->sk;
> +       struct sk_buff *clone;
> +
> +       if (!sk || !atomic_inc_not_zero(&sk->sk_refcnt))
> +               return NULL;
> +
> +       clone = skb_clone(skb, GFP_ATOMIC);
> +       if (!clone) {
> +               sock_put(sk);
> +               return NULL;
> +       }
> +
> +       clone->sk = sk;
> +
> +       return clone;
> +}
> +EXPORT_SYMBOL(__skb_clone_tx_timestamp);
> +

Code looks great. Again, this can be verified to be a functional noop.
One minor comment is that this really is not a timestamping function,
but an skb_clone variant. skb_clone_sk?
