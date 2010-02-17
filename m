From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [PATCH net-2.6] net: bug fix for vlan + gro issue
Date: Wed, 17 Feb 2010 11:55:43 +0530
Message-ID: <20100217062541.GA10350@serverengines.com>
References: <20100212053451.GA23351@serverengines.com>
 <20100216114015.GB31642@gondor.apana.org.au>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f200.google.com ([209.85.210.200]:61118 "EHLO
	mail-yx0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab0BQGZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:25:49 -0500
Received: by yxe38 with SMTP id 38so5005819yxe.4
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 22:25:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100216114015.GB31642@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/10 19:40 +0800, Herbert Xu wrote:
> On Fri, Feb 12, 2010 at 11:04:53AM +0530, Ajit Khaparde wrote:
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index be9924f..16aac06 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2761,7 +2761,10 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
> >  	switch (ret) {
> >  	case GRO_NORMAL:
> >  	case GRO_HELD:
> > -		skb->protocol = eth_type_trans(skb, napi->dev);
> > +		if (skb->vlan_tci)
> > +			skb->protocol = eth_type_trans(skb, skb->dev);
> > +		else
> > +			skb->protocol = eth_type_trans(skb, napi->dev);
> 
> We should be able to just use skb->dev here.

Thanks Herbert. I think you meant something like this:
+		skb->protocol = eth_type_trans(skb, skb->dev);

Here is the patch:-

Traffic (tcp) doesnot start on a vlan interface when gro is enabled.
Even the tcp handshake was not taking place.
This is because, the eth_type_trans call before the netif_receive_skb
in napi_gro_finish() resets the skb->dev to napi->dev from the previously
set vlan netdev interface. This causes the ip_route_input to drop the
incoming packet considering it as a packet coming from a martian source.

I could repro this on 2.6.32.7 (stable) and 2.6.33-rc7.
With this fix, the traffic starts and the test runs fine on both vlan
and non-vlan interfaces.

CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index be9924f..ec87421 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2761,7 +2761,7 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:
-		skb->protocol = eth_type_trans(skb, napi->dev);
+		skb->protocol = eth_type_trans(skb, skb->dev);
 
 		if (ret == GRO_HELD)
 			skb_gro_pull(skb, -ETH_HLEN);
-- 
1.6.3.3

