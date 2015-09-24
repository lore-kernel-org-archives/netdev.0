From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 RFC] 8139cp: Fix GSO MSS handling
Date: Thu, 24 Sep 2015 05:05:25 -0700
Message-ID: <1443096325.29850.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442996049.36485.32.camel@infradead.org>
	 <20150923.105812.149257816141624869.davem@davemloft.net>
	 <1443037530.74600.29.camel@infradead.org>
	 <20150923.144808.886375927698238398.davem@davemloft.net>
	 <1443045602.74600.33.camel@infradead.org>
	 <20150923232931.GA8365@electric-eye.fr.zoreil.com>
	 <1443085112.74600.53.camel@infradead.org>
	 <1443091102.74600.70.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35283 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbbIXMF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 08:05:27 -0400
Received: by pacfv12 with SMTP id fv12so72803811pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 05:05:27 -0700 (PDT)
In-Reply-To: <1443091102.74600.70.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-24 at 11:38 +0100, David Woodhouse wrote:
> When fixing the TSO support I noticed we just mask ->gso_size with th=
e
> MSSMask value and don't care about the consequences.
>=20
> Provide a .ndo_features_check() method which drops the NETIF_F_TSO
> feature for any skb which would exceed the maximum, and thus forces i=
t
> to be segmented by software.
>=20
> Then we can stop the masking in cp_start_xmit(), and just WARN if the
> maximum is exceeded, which should now never happen.
>=20
> Finally, Francois Romieu noticed that we didn't even have the right
> value for MSSMask anyway; it should be 0x7ff (11 bits) not 0xfff.
>=20
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
> OK, netif_set_gso_max_size() was *not*, as I had na=C3=AFvely assumed=
, a way
> to set the maximum value of ->gso_size. That's an unfortunate set of
> naming decisions.

Right, netif_skb_features() only has the following checks :

if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
    features &=3D ~NETIF_F_GSO_MASK;

But now we have .ndo_features_check() we could remove this generic chec=
k
from fast path.
