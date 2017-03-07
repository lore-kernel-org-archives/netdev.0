From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Added the auth and enc update support in "state
 update"
Date: Tue, 7 Mar 2017 13:56:13 +0100
Message-ID: <20170307125613.GL694@gauss.secunet.com>
References: <1488888193-4071-1-git-send-email-trajaraman@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <trajaraman@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:55230 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752842AbdCGNPL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 08:15:11 -0500
Content-Disposition: inline
In-Reply-To: <1488888193-4071-1-git-send-email-trajaraman@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 07, 2017 at 05:33:13PM +0530, trajaraman@mvista.com wrote:
> From: Thiruvadi rajaraman <trajaraman@mvista.com>
> 
> The "ip xfrm state update" process doesn't update the new authendication
> and encryption keys as well as it doesn't return an error.
> 
> Test logs: (Default)
> ==========
> ~# ip xfrm state list
> ~# ip xfrm state add src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0010 enc des 0xAABBCCDDEEFF0010
> ~# ip xfrm state list
> src fe80:: dst ff02::3
>         proto esp spi 0x000004d3 reqid 0 mode transport
>         replay-window 0
>         auth-trunc hmac(sha1) 0xaabbccddeeff0010 96
>         enc cbc(des) 0xaabbccddeeff0010
>         sel src ::/0 dst ::/0
> ~#
> 
> ~# ip xfrm state update src fe80::/10 dst ff02::3 proto esp spi 1235 mode transport auth sha1 0xAABBCCDDEEFF0015 enc des 0xAABBCCDDEEFF0020
> src fe80:: dst ff02::3
>         proto esp spi 0x000004d3 reqid 0 mode transport
>         replay-window 0
>         auth-trunc hmac(sha1) 0xaabbccddeeff0010 96   ----> [ Auth key doesn't changed and remains same ]
>         enc cbc(des) 0xaabbccddeeff0010               ----> [  Enc key doesn't changed and remains same ]

This is intentional, the original state is not XFRM_STATE_ACQ,
so you are not allowed to update keys without requesting for
a new SPI. The original code was written 15 years ago, based
on RFC 2367 (PF_KEY) which says we must return -EINVAL in this
case. So if we change this, we should return an error.
