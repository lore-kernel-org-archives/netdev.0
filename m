From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net] ipv6: xfrm: Handle errors reported by xfrm6_find_1stfragopt()
Date: Wed, 31 May 2017 10:01:09 -0400
Message-ID: <CAEfhGixMRc6sEWBhYFggENXBrAnMNWfMx1OcJ84o5ERNo8Hd+w@mail.gmail.com>
References: <20170531121541.GA16923@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35317 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdEaOBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 10:01:13 -0400
Received: by mail-qt0-f194.google.com with SMTP id r58so1968930qtb.2
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 07:01:12 -0700 (PDT)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by smtp.gmail.com with ESMTPSA id c15sm10788491qte.25.2017.05.31.07.01.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 07:01:10 -0700 (PDT)
Received: by mail-qk0-f178.google.com with SMTP id y201so12300685qka.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 07:01:10 -0700 (PDT)
In-Reply-To: <20170531121541.GA16923@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 8:15 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> xfrm6_find_1stfragopt() may now return an error code and we must
> not treat it as a length.
>
> Fixes: 2423496af35d ("ipv6: Prevent overrun when parsing v6 header options")
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> Commits 2423496af35d "ipv6: Prevent overrun when parsing v6 header
> options" and 7dd7eb9513bd "ipv6: Check ip6_find_1stfragopt() return
> value properly." changed ip6_find_1stfragopt() to return negative
> error codes and changed some of its callers to handle this.
>
> However, there is also xfrm6_find_1stfragopt() which is a wrapper for
> ip6_find_1stfragopt() and is called indirectly by xfrm6_ro_output()
> and xfrm6_transport_output().  Neither of them check for errors.
>
> This is totally untested.  I think xfrm_type::hdr_offset deserves a
> comment about its semantics, but I don't understand it well enogugh to
> write that.
Thank you for finding this, it's a good lesson to not rely solely on cscope :\

I believe this fix is correct and sufficient.  I only found 2 up-stack
callers of this (pktgen_output_ipsec and xfrm_output_one) and they
both ultimately call kfree_skb on error.

However, the fact that this function is used as a function pointer
through xfrm_type.hdr_offset made me look at a couple other functions
that can be stored in this structure.  mip6_destopt_offset and
mip6_rthdr_offset have very similar implementations to the original
ip6_find_1stfragopt and may very well suffer from the same bug I was
trying to fix.  Maybe it doesn't matter since that bug relied on the
user changing the v6 nexthdr field.  I need to understand the mip6
code first...

In any event, I think this patch applies on its own.  Thanks again.

Acked-by: Craig Gallek <kraig@google.com>
