From: Alexander Wetzel <alexander.wetzel@web.de>
Subject: ipip6 - integer underrun when handlince icmpv4 unreachable messages
Date: Mon, 17 Nov 2014 22:52:04 +0100
Message-ID: <546A6E04.30603@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: roque@di.fc.ul.p, kuznet@ms2.inr.ac.ru, r.venning@telstra.com,
	nate@thebog.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.182]:51144 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaKQV6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 16:58:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

the current code to translate icmpv4 "destination unreachable" packets
to icmpv6 is later generating an integer underrun when calling
icmpv6_send, by later calling skb_network_header_len and subtracting a
bigger number from a lower one.

The issue is not visible for vanilla kernels and works correctly from
a user perspective, but a kernel with the PAX patches and enabled
"size overflow protection" will panic immediately when it's getting an
icmpv4 destination unreachable packet back for an encapsulated ipv6
packet. (Remote tunnel endpoint not reachable.)

I think I've tracked the issue down and can show you the problem with
the code... as I understand it as non-programmer greping the sources
and googeling functions. I was even able to find a fix which passes
the functionality test, but I'm unqualified to rate the correctness of
it and so are reaching out to you for that.

What happens (output of printk's) with transport_header and
network_header around "skb_reset_network_header" is described below
the function.

Near the end of the mail there are two links to the gentoo bug tracker
and pax forum, suggesting to put this forward to the lkml/netdev for
review, also including more details on the panics.

So here the function "ipip6_err_gen_icmpv6_unreach" from
net/ipv6/sit.c with some remarks and one new line which seems to fix
the problem:

************************************************************************
static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
{
        int ihl = ((const struct iphdr *)skb->data)->ihl*4;
        struct rt6_info *rt;
        struct sk_buff *skb2;

        if (!pskb_may_pull(skb, ihl + sizeof(struct ipv6hdr) + 8))
                return 1;

// we clone the ipv4 skb in skb2 to prepare the icmpv6 packet
        skb2 = skb_clone(skb, GFP_ATOMIC);

        if (!skb2)
                return 1;

// we clean up the cloned skb2
        skb_dst_drop(skb2);
        skb_pull(skb2, ihl);
// The network header is reset
        skb_reset_network_header(skb2);

//THE PROPOSED FIX: The following line is NOT in the current code
        skb_reset_transport_header(skb2);

        rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr,
NULL, 0, 0);

        if (rt && rt->dst.dev)
                skb2->dev = rt->dst.dev;

        icmpv6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);

        if (rt)
                ip6_rt_put(rt);

        kfree_skb(skb2);

        return 0;

************************************************************************

With debug printk's prior to "skb_reset_network_header(skb2);" I get
the following values when the code is used:
	sk2b->transport_header: 62
	skb2->network_header  : 4e

After "skb_reset_network_header(skb2);" it reads:
	sk2b->transport_header: 62
	skb2->network_header  : 7e

That are the same values which are later causing the integer underrun
(and with PAX a kernel panic) in "skb_network_header_len"

Adding "skb_reset_network_header(skb2);" prevents that, the transport
header size is extended:
	sk2b->transport_header: 7e
	skb2->network_header  : 7e


Some more details on the error, a clean diff for the proposed patch
(without the comments) and  the full debugging can be fond here:

https://forums.grsecurity.net/viewtopic.php?t=4083
https://bugs.gentoo.org/show_bug.cgi?id=529352

Can you please verify if this is the correct way to fix it and include
the correct fix - if any - in future kernel releases?
Or do you think that the PAX patch is wrong and an integer underrun is
acceptable here?

I'll check the mailing list archives from time to time for replies,
but I'm not subscribed and if you need me for more information or
tests please add me on CC.

Cheers,

Alexander Wetzel
