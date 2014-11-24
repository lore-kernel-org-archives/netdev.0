From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRE with GRO very slow when forwarding starting with 3.14.24
Date: Mon, 24 Nov 2014 08:48:16 -0800
Message-ID: <1416847696.17888.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2340533.MickblD7NF@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:62681 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbaKXQsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 11:48:19 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so3691098iga.8
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 08:48:18 -0800 (PST)
In-Reply-To: <2340533.MickblD7NF@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-24 at 17:13 +0100, Wolfgang Walter wrote:
> Hello,
> 
> starting with 3.14.24 GRE with GRO on is very slow. To be more specific:
> 
> yyyy <--> GRO_endpoint <-_> .... <--> |eth0<->GRO-endpoint | eth1 |<-> xxxx
> 
> routing (IPv4) between xxxx and yyyy is very slow when GRO is enabled on eth0 
> and/or eth1 starting with stable kernel 3.14.24
> 
> Regards,


tcpdump might help, but I presume GSO is no longer working properly on
egress.

Can you try to revert :

commit abe640984aa492652232b65d3579361cf6d461f5
Author: Tom Herbert <therbert@google.com>
Date:   Thu Oct 30 08:40:56 2014 -0700

    gre: Use inner mac length when computing tunnel length
    
    [ Upstream commit 14051f0452a2c26a3f4791e6ad6a435e8f1945ff ]
    
    Currently, skb_inner_network_header is used but this does not account
    for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header which
    handles TEB and also should work with IP encapsulation in which case
    inner mac and inner network headers are the same.
    
    Tested: Ran TCP_STREAM over GRE, worked as expected.
    
    Signed-off-by: Tom Herbert <therbert@google.com>
    Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 2d24f293f977..8c8493ea6b1c 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -50,7 +50,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
        greh = (struct gre_base_hdr *)skb_transport_header(skb);
 
-       ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
+       ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
        if (unlikely(ghl < sizeof(*greh)))
                goto out;
