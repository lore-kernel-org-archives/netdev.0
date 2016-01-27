From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] inet: frag: Always orphan skbs inside ip_defrag()
Date: Tue, 26 Jan 2016 18:16:10 -0800
Message-ID: <CAPWQB7EAD9CGSW3C-LMO1U1gHOOkeh3sTkS+gtpWVpkwChdBTw@mail.gmail.com>
References: <1453506552-10373-1-git-send-email-joe@ovn.org>
 <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com> <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, fw@strlen.de,
	hannes@stressinduktion.org, pravin shelar <pshelar@ovn.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:38247 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbcA0C2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 21:28:19 -0500
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id CA1D4534FA7
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 03:16:32 +0100 (CET)
Received: from mfilter38-d.gandi.net (mfilter38-d.gandi.net [217.70.178.169])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 57DCCC5A5F
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 03:16:31 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter38-d.gandi.net (mfilter38-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id LCSX6Y-4jpz1 for <netdev@vger.kernel.org>;
	Wed, 27 Jan 2016 03:16:29 +0100 (CET)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	(Authenticated sender: joe@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id E1058C5A50
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 03:16:29 +0100 (CET)
Received: by mail-wm0-f54.google.com with SMTP id p63so5060816wmp.1
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 18:16:29 -0800 (PST)
In-Reply-To: <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 January 2016 at 17:11, Joe Stringer <joe@ovn.org> wrote:
> On 22 January 2016 at 17:22, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2016-01-22 at 15:49 -0800, Joe Stringer wrote:
>>> Later parts of the stack (including fragmentation) expect that there is
>>> never a socket attached to frag in a frag_list, however this invariant
>>> was not enforced on all defrag paths. This could lead to the
>>> BUG_ON(skb->sk) during ip_do_fragment(), as per the call stack at the
>>> end of this commit message.
>>>
>>> While the call could be added to openvswitch to fix this particular
>>> error, the head and tail of the frags list are already orphaned
>>> indirectly inside ip_defrag(), so it seems like the remaining fragments
>>> should all be orphaned in all circumstances.
>>
>>
>> Yes, it looks we have a problem, and even IP early demux apparently does
>> not check if incoming packet is a fragment.
>>
>> Your patch could also remove some socket leaks in this respect.
>>
>> I guess we also could add a safety check (ipv4 only, but ipv6 needs care
>> as well)
>>
>> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
>> index b1209b63381f..99513c829213 100644
>> --- a/net/ipv4/ip_input.c
>> +++ b/net/ipv4/ip_input.c
>> @@ -316,7 +316,9 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>>         const struct iphdr *iph = ip_hdr(skb);
>>         struct rtable *rt;
>>
>> -       if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
>> +       if (sysctl_ip_early_demux &&
>> +           !skb_dst(skb) && !skb->sk &&
>> +           !ip_is_fragment(iph)) {
>>                 const struct net_protocol *ipprot;
>>                 int protocol = iph->protocol;
>
> Thanks, I can roll this into a v2 (or keep as a separate patch?). I
> got sidetracked on the IPv6 side, some other issues are blocking me on
> that but I intend to continue following up there as well.

FWIW I confirmed that all frags in frag list coming back from
nf_ct_frag6_gather() have skb->sk == NULL, so this bug is not present
on that path.
