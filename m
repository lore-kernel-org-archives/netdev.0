From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: Clear sk_dst_cache when applying per-socket
 policy.
Date: Tue, 24 Oct 2017 09:04:14 +0200
Message-ID: <20171024070414.GJ3323@secunet.com>
References: <20170815222510.21711-1-misterikkit@google.com>
 <20171024011855.8658-1-misterikkit@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jkbs@redhat.com>, <davem@davemloft.net>,
        <lorenzo@google.com>, <eric.dumazet@gmail.com>
To: Jonathan Basseri <misterikkit@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57132 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750868AbdJXHER (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 03:04:17 -0400
Content-Disposition: inline
In-Reply-To: <20171024011855.8658-1-misterikkit@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 06:18:55PM -0700, Jonathan Basseri wrote:
> If a socket has a valid dst cache, then xfrm_lookup_route will get
> skipped. However, the cache is not invalidated when applying policy to a
> socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
> sometimes ignored on those sockets. (Note: This was broken for IPv4 and
> IPv6 at different times.)
> 
> This can be demonstrated like so,
> 1. Create UDP socket.
> 2. connect() the socket.
> 3. Apply an outbound XFRM policy to the socket.
> 4. send() data on the socket.
> 
> Packets will continue to be sent in the clear instead of matching an
> xfrm or returning a no-match error (EAGAIN). This affects calls to
> send() and not sendto().
> 
> Invalidating the sk_dst_cache is necessary to correctly apply xfrm
> policies. Since we do this in xfrm_user_policy(), the sk_lock was
> already acquired in either do_ip_setsockopt() or do_ipv6_setsockopt(),
> and we may call __sk_dst_reset().
> 
> Performance impact should be negligible, since this code is only called
> when changing xfrm policy, and only affects the socket in question.
> 
> Note: Creating normal XFRM policies should have a similar effect on
> sk_dst_cache entries that match the policy, but that is not fixed in
> this patch.

I think we don't have this problem with 'normal' policies. When
inserting such a policy, we bump the IPv4/IPv6 genid. This should
invalidate all cached dst entries, no?
