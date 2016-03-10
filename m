From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Thu, 10 Mar 2016 10:47:02 +0100
Message-ID: <56E14296.5010103@6wind.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33629 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbcCJJrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 04:47:06 -0500
Received: by mail-wm0-f49.google.com with SMTP id l68so20839032wml.0
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 01:47:05 -0800 (PST)
In-Reply-To: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/03/2016 22:49, Mahesh Bandewar a =C3=A9crit :
> From: Mahesh Bandewar <maheshb@google.com>
>
> One of the major request (for enhancement) that I have received
> from various users of IPvlan in L3 mode is its inability to handle
> IPtables.
>
> While looking at the code and how we handle ingress, the problem
> can be attributed to the asymmetry in the way packets get processed
> for IPvlan devices configured in L3 mode. L3 mode is supposed to
> be restrictive and all the L3 decisions need to be taken for the
> traffic in master's ns. This does happen as expected for egress
> traffic however on ingress traffic, the IPvlan packet-handler
> changes the skb->dev and this forces packet to be processed with
> the IPvlan slave and it's associated ns. This causes above mentioned
> problem and few other which are not yet reported / attempted. e.g.
> IPsec with L3 mode or even ingress routing.
>
> This could have been solved if we had a way to handover packet to
> slave and associated ns after completing the L3 phase. This is a
> non-trivial issue to fix especially looking at IPsec code.
>
> This patch series attempts to solve this problem by introducing the
> device pointer l3_dev which resides in net_device structure in the
> RX cache line. We initialize the l3_dev to self. This would mean
> there is no complex logic to when-and-how-to initialize it. Now
> the stack will use this dev pointer during the L3 phase. This should
> not alter any existing properties / behavior and also there should
> not be any additional penalties since it resides in the same RX
> cache line.
If I understand correctly (and as Cong already said), information are l=
eaking
between netns during the input phase. On the tx side, skb_scrub_packet(=
) is
called, but not on the rx side. I think it's wrong. There should be an =
explicit
boundary.

Another small comment: maybe finding another name than l3_dev could hel=
p to
avoid confusion with the existing l3mdev.
