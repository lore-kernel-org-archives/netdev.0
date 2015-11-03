From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 3 Nov 2015 07:59:36 +0000
Message-ID: <BY2PR0301MB16547E3AA4FB1F1AC8DE28ECA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151101.155859.1206189858863918018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0117.outbound.protection.outlook.com ([157.56.111.117]:54176
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752288AbbKCH7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 02:59:39 -0500
In-Reply-To: <20151101.155859.1206189858863918018.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, November 1, 2015 12:59 PM
> To: eric.dumazet@gmail.com
> Cc: Haiyang Zhang <haiyangz@microsoft.com>; edumazet@google.com;
> netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>
> Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET
> is enabled
> 
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 01 Nov 2015 09:20:59 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> >
> > My recent commit, attaching SYNACK messages to request sockets
> > exposed a too small LL_MAX_HEADER when netvsc_drv.c is in use,
> > because this driver sets a needed_headroom of 220 bytes.
> >
> > Increase LL_MAX_HEADER in this case, to avoid a realloc of all
> > TCP frames.
> >
> > In another patch, I'll make skb_set_owner_w() more robust.
> >
> > Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets
> instead of listener")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Bisected-by: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Using a value of 256 just because HYPER-V is crazy imposes a huge
> unnecessary burdon upon the rest of the stack.
> 
> I rejected a previous attempt to use such a huge value for
> LL_MAX_HEADER, and I will do so again here.  We need a different fix
> for this issue, one that doesn't hurt everyone.
> 
> Every distribution is going to turn all the options on, so you might
> as well consider the largest LL_MAX_HEADER value the one %99.999
> users end up paying the price for.

David,

I have implemented the scheme we had discussed a few weeks ago. In this new implementation
our driver is NOT requesting addition headroom - rndis header and the per packet state is being
maintained outside of the skb. What I am seeing is that when I have LL_MAX_HEADER set to 220 bytes,
even though our driver is not using the additional head room, I see about a 10% boost in the peak performance
(about 34 Gbps on a 40Gbps interface). However, when I set the LL_MAX_HEADER value to the current default,
the peak performance drops back to what we currently have (around 31 Gbps). In both these cases,
there is no reallocation of skb since no additional headroom is being requested and yet there is a significant
difference in performance.  I trying to figure out why this is the case, your insights will be greatly
appreciated.

Regards,

K. Y
