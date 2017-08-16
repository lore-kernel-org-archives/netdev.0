From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] xfrm: Clear sk_dst_cache when applying per-socket
 policy.
Date: Wed, 16 Aug 2017 03:43:54 -0700
Message-ID: <1502880234.4936.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170815222510.21711-1-misterikkit@google.com>
         <20170816110341.5e899c23@beetle>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Basseri <misterikkit@google.com>, netdev@vger.kernel.org,
        davem@davemloft.net, steffen.klassert@secunet.com,
        lorenzo@google.com
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32967 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdHPKn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 06:43:57 -0400
Received: by mail-it0-f65.google.com with SMTP id m34so2174518iti.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 03:43:57 -0700 (PDT)
In-Reply-To: <20170816110341.5e899c23@beetle>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 11:03 +0200, Jakub Sitnicki wrote:
> On Tue, 15 Aug 2017 15:25:10 -0700
> Jonathan Basseri <misterikkit@google.com> wrote:
> 
> > If an IPv6 socket has a valid dst cache, then xfrm_lookup_route will get
> > skipped. However, the cache is not invalidated when applying policy to a
> > socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
> > sometimes ignored on those sockets.
> > 
> > This can be demonstrated like so,
> > 1. Create UDPv6 socket.
> > 2. connect() the socket.
> > 3. Apply an outbound XFRM policy to the socket.
> > 4. send() data on the socket.
> > 
> > Packets will continue to be sent in the clear instead of matching an
> > xfrm or returning a no-match error (EAGAIN). This affects calls to
> > send() and not sendto().
> > 
> > Note: Creating normal XFRM policies should have a similar effect on
> > sk_dst_cache entries that match the policy, but that is not fixed in
> > this patch.
> > 
> > Fixes: 00bc0ef5880d ("ipv6: Skip XFRM lookup if dst_entry in socket cache is valid")
> > Tested: https://android-review.googlesource.com/418659
> > Signed-off-by: Jonathan Basseri <misterikkit@google.com>
> > ---
> 
> Thank you for the fix.
> 
> Acked-by: Jakub Sitnicki <jkbs@redhat.com>

I do not believe this fix is correct.

What happens if the socket is TCP ?

sk_dst_reset(sk) is not safe for them.

This might add use-after-free, and eventually crash.
