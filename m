From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 20:35:32 -0800
Message-ID: <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
         <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
         <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
         <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@nicira.com>
To: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36470 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdAREfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 23:35:34 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so266481pgf.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 20:35:34 -0800 (PST)
In-Reply-To: <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-17 at 20:21 -0800, Eric Dumazet wrote:
> On Wed, 2017-01-18 at 03:12 +0000, Ashizuka, Yuusuke wrote:
> 
> > indeed.
> > 
> > In the case of TSO with i.MX6 system (highmem enabled) with 2GB memory,
> > "this_frag->page.p" did not become highmem area.
> > (We confirmed by transferring about 100MB of files)
> > 
> > However, in the case of non-tso on an i.MX6 system with 2GB of memory,
> > "this_frag->page.p" may become a highmem area.
> > (Occurred with approximately 2MB of file transfer)
> > 
> > For non-tso only, I do not know the reason why "this_frag-> page.p" 
> > in this driver shows highmem area.
> 
> This worries me, since this driver does not set NETIF_F_HIGHDMA in its
> features.
> 
> No packet should be given to this driver with a highmem fragment
> 
> Check is done in illegal_highdma() in net/core/dev.c

This used to work.

I suspect commit ec5f061564238892005257c83565a0b58ec79295
("net: Kill link between CSUM and SG features.")

added this bug.

Can you try this hot fix :

diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e561166f445bdd9d7260652a338f74cfea..073b832b945257dba9ed47f4bf875605225effc9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2773,9 +2773,9 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, type)) {
 		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
-	} else if (illegal_highdma(skb->dev, skb)) {
-		features &= ~NETIF_F_SG;
 	}
+	if (illegal_highdma(skb->dev, skb))
+		features &= ~NETIF_F_SG;
 
 	return features;
 }
