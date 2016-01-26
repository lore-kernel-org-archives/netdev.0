From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] inet: frag: Always orphan skbs inside ip_defrag()
Date: Mon, 25 Jan 2016 17:11:17 -0800
Message-ID: <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
References: <1453506552-10373-1-git-send-email-joe@ovn.org> <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, fw@strlen.de,
	hannes@stressinduktion.org, pravin shelar <pshelar@ovn.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:38733 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcAZBLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 20:11:40 -0500
Received: from mfilter49-d.gandi.net (mfilter49-d.gandi.net [217.70.178.180])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id C9A41A80D3
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 02:11:38 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter49-d.gandi.net (mfilter49-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id N7BUFGI_cwX1 for <netdev@vger.kernel.org>;
	Tue, 26 Jan 2016 02:11:37 +0100 (CET)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	(Authenticated sender: joe@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 5E14EA809B
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 02:11:37 +0100 (CET)
Received: by mail-wm0-f50.google.com with SMTP id b14so107217514wmb.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 17:11:37 -0800 (PST)
In-Reply-To: <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 January 2016 at 17:22, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-22 at 15:49 -0800, Joe Stringer wrote:
>> Later parts of the stack (including fragmentation) expect that there is
>> never a socket attached to frag in a frag_list, however this invariant
>> was not enforced on all defrag paths. This could lead to the
>> BUG_ON(skb->sk) during ip_do_fragment(), as per the call stack at the
>> end of this commit message.
>>
>> While the call could be added to openvswitch to fix this particular
>> error, the head and tail of the frags list are already orphaned
>> indirectly inside ip_defrag(), so it seems like the remaining fragments
>> should all be orphaned in all circumstances.
>
>
> Yes, it looks we have a problem, and even IP early demux apparently does
> not check if incoming packet is a fragment.
>
> Your patch could also remove some socket leaks in this respect.
>
> I guess we also could add a safety check (ipv4 only, but ipv6 needs care
> as well)
>
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index b1209b63381f..99513c829213 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -316,7 +316,9 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>         const struct iphdr *iph = ip_hdr(skb);
>         struct rtable *rt;
>
> -       if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
> +       if (sysctl_ip_early_demux &&
> +           !skb_dst(skb) && !skb->sk &&
> +           !ip_is_fragment(iph)) {
>                 const struct net_protocol *ipprot;
>                 int protocol = iph->protocol;

Thanks, I can roll this into a v2 (or keep as a separate patch?). I
got sidetracked on the IPv6 side, some other issues are blocking me on
that but I intend to continue following up there as well.
