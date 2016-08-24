From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 10:37:51 -0600
Message-ID: <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
 <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: pravin shelar <pshelar@ovn.org>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33652 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755751AbcHXQqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:46:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id ti13so8076170pac.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:46:03 -0700 (PDT)
In-Reply-To: <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 10:28 AM, pravin shelar wrote:
>> How do you feel about implementing the do_output() idea I suggested above?
>> I'm happy to provide testing and review.
> 
> I am not sure about changing do_output(). why not just use same scheme
> to track mpls header in OVS datapath as done in mpls device?
> 

was just replying with the same. 

Something like this should be able to handle multiple labels. The inner network header is set once and the outer one pointing to MPLS is adjusted each time a label is pushed:

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1ecbd7715f6d..0f37b17e3a73 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -162,10 +162,16 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
        if (skb_cow_head(skb, MPLS_HLEN) < 0)
                return -ENOMEM;

+       if (!skb->inner_protocol) {
+               skb_set_inner_network_header(skb, skb->mac_len);
+               skb_set_inner_protocol(skb, skb->protocol);
+       }
+
        skb_push(skb, MPLS_HLEN);
        memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
                skb->mac_len);
        skb_reset_mac_header(skb);
+       skb_set_network_header(skb, skb->mac_len);

        new_mpls_lse = (__be32 *)skb_mpls_header(skb);
        *new_mpls_lse = mpls->mpls_lse;
@@ -173,8 +179,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
        skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);

        update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
-       if (!skb->inner_protocol)
-               skb_set_inner_protocol(skb, skb->protocol);
+
        skb->protocol = mpls->mpls_ethertype;

        invalidate_flow_key(key);




If it does, what else needs to be changed in OVS to handle the network layer now pointing to the MPLS labels?
