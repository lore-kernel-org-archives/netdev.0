From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Tue, 15 Jan 2013 06:39:12 -0800
Message-ID: <1358260752.8744.5677.camel@edumazet-glaptop>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
	 <1358176310-31504-10-git-send-email-yuvalmin@broadcom.com>
	 <1358184123.8744.3127.camel@edumazet-glaptop>
	 <1358189075.8744.3320.camel@edumazet-glaptop>
	 <50F50537.3030608@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51308 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751Ab3AOOjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 09:39:16 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so139698pad.2
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 06:39:15 -0800 (PST)
In-Reply-To: <50F50537.3030608@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 09:28 +0200, Yuval Mintz wrote:
> On 01/14/2013 08:44 PM, Eric Dumazet wrote:
> > On Mon, 2013-01-14 at 09:22 -0800, Eric Dumazet wrote:
> > 
> > What is the value of gso_segs ?
> > 
> > The reason I am pointing this out is the recent change in commit
> > 1def9238d4aa2146924994aa4b7dc861f03b9362
> > (net_sched: more precise pkt_len computation)
> > 
> > bnx2x not setting gso_segs means that qdisc accounting on ingress is
> > completely wrong.
> 
> Hi Eric,
> 
> First I just want to state that you're totally correct about the gso_segs -
> bnx2x is not setting it correctly (it's currently totally omitted), and so
> it would incorrectly affect the accounting.
> 
> However, notice this behaviour was not introduced in this patch -
> Since 621b4d6 bnx2x is using FW GRO, overriding the kernel's GRO implementation:
> As the bnx2x driver is supplied with the aggregated packet from its FW,
> the bnx2x passes a value in the `gso_size' field of its skb, causing
> `skb_is_gso' to return `true'.
> This will cause the aggregated skb to override the GRO machinations
> (in `dev_gro_receive'), overriding all calls to `gro_receive' and thus also
> the call to `skb_gro_receive' which whould have incremented `gso_segs'.
> 
> This patch actually tries to correct said behaviour, obviously failing
> with the gso_segs but still improving the current state of bnx2x GRO
> in bridging scenarios.
> 
> >> This looks weird to me. This should be called by GRO stack only.
> 
> I think this is the main question - we could try and implement this
> inside the network-core itself, but as said behaviour is unique to the
> bnx2x driver (correct me if I'm wrong, but I'm unaware of any other
> driver which does GRO without the kernel GRO implementation), the
> solution is specially tailored for the bnx2x driver.
> 
> We could either:
>   1. Continue with this patch, later sending a patch correcting gso_segs,
>      as this is not a new issue.
>   2. Send a V2 patch-series which will also set gso_segs correctly.
>   3. Send a V2 patch-series which omits this patch, and later send an RFC
>      for some kernel implementation which fixes the issue.
> 
> Your thoughts on this matter will be greatly appreciated.

I am fine with any solution, as long as we fix the problem.

If GRO is done by the FW/driver instead of core network stack, we should
make sure :

- transport_header is set correctly (your patch seems to do that)
- gso_segs is computed (this could be done in core network, but this
adds yet another conditional test in th fast path, and it seems only
bnx2x would need this)

Thanks
