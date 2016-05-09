From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] ip6_gre: Fix MTU setting
Date: Mon, 9 May 2016 16:14:11 -0700
Message-ID: <CAKgT0UdUVvd7eBbYsJ4E-SkUV6hXL04S=xYXkQMnLitrJkpH0g@mail.gmail.com>
References: <1462832909-553684-1-git-send-email-tom@herbertland.com>
	<CAKgT0UdyJyALd6DHA4GeUQtS08MusBTU880A5fNtMbMu_r55Sg@mail.gmail.com>
	<CALx6S35FbaG9jiM4diNmKC+=cSCi+3t7WM1AXxi_c3iigsUu-A@mail.gmail.com>
	<CAKgT0UcHky39E9Sxo7L_ZtOOx9uUNy5NdLa78C+oLeB2q21o+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35589 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbcEIXOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 19:14:12 -0400
Received: by mail-io0-f181.google.com with SMTP id d62so187936431iof.2
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 16:14:11 -0700 (PDT)
In-Reply-To: <CAKgT0UcHky39E9Sxo7L_ZtOOx9uUNy5NdLa78C+oLeB2q21o+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 4:10 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, May 9, 2016 at 3:49 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, May 9, 2016 at 3:44 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Mon, May 9, 2016 at 3:28 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> In ip6gre_tnl_link_config set t->tun_len and t->hlen correctly for the
>>>> configuration. For hard_header_len and mtu calculation include
>>>> IPv6 header and encapsulation overhead.
>>>>
>>>> In ip6gre_tunnel_init_common set t->tun_len and t->hlen correctly for
>>>> the configuration. Revert to setting hard_header_len instead of
>>>> needed_headroom.
>>>>
>>>> Tested:
>>>>
>>>> ./ip link add name tun8 type ip6gretap remote \
>>>> 2401:db00:20:911a:face:0:27:0 local \
>>>> 2401:db00:20:911a:face:0:25:0 ttl 225
>>>>
>>>> Gives MTU of 1434. That is equal to 1500 - 40 - 14 - 4 - 8.
>>>>
>>>> ./ip link add name tun8 type ip6gretap remote \
>>>> 2401:db00:20:911a:face:0:27:0 local \
>>>> 2401:db00:20:911a:face:0:25:0 ttl 225 okey 123
>>>>
>>>> Gives MTU of 1430. That is equal to 1500 - 40 - 14 - 4 - 8 - 4.
>>>>
>>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>>
>>> So this gives me the correct result now.  However we still need patch
>>> 3 / 11 from the set you submitted next week in order to be able to
>>> even transmit because the flags are otherwise mangled.
>>>
>>> Tested-by: Alexander Duyck <aduyck@mirantis.com>
>>
>> Okay, I'll repost the flags patch as a standalone. Do you have any
>> other issues then in this path?
>
> This piece no.

Actually I just realized there are two other bits that need to be updated.

I just copied/pasted the below out of a text console so I am sure the
white-space formatting is wrong.  These two spots should be fixed as
well as they are using the wrong flag type.

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index ec209f4d3312..ee62ec469ab3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -343,7 +343,7 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
                goto failed_free;

        /* Can use a lockless transmit, unless we generate output sequences */
-       if (!(nt->parms.o_flags & GRE_SEQ))
+       if (!(nt->parms.o_flags & TUNNEL_SEQ))
                dev->features |= NETIF_F_LLTX;

        dev_hold(dev);
@@ -1314,7 +1314,7 @@ static int ip6gre_newlink(struct net *src_net,
struct net_device *dev,
        dev->features           |= GRE6_FEATURES;
        dev->hw_features        |= GRE6_FEATURES;

-       if (!(nt->parms.o_flags & GRE_SEQ)) {
+       if (!(nt->parms.o_flags & TUNNEL_SEQ)) {
                /* TCP segmentation offload is not supported when we
                 * generate output sequences.
                 */
