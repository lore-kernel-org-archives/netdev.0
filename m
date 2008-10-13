From: David Miller <davem@davemloft.net>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Mon, 13 Oct 2008 00:42:26 -0700 (PDT)
Message-ID: <20081013.004226.171259546.davem@davemloft.net>
References: <20081011172002.GA12659@pest>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: berni@birkenwald.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754577AbYJMHmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:42:50 -0400
In-Reply-To: <20081011172002.GA12659@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Schmidt <berni@birkenwald.de>
Date: Sat, 11 Oct 2008 19:20:03 +0200

> [  289.588669] ------------[ cut here ]------------
> [  289.588673] WARNING: at net/core/dev.c:1505 skb_gso_segment+0x82/0x1a7()
> 
>         if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {

So this is via tg3_tso_bug()

 ...
> [  289.588760]  [<ffffffff803d14ab>] dev_queue_xmit+0x3aa/0x462
> [  289.588778]  [<ffffffffa024ca8c>] ip6_output+0xce7/0xcff [ipv6]
> [  289.588785]  [<ffffffffa023ade0>] br_dev_queue_push_xmit+0x75/0x79 [bridge]
> [  289.588792]  [<ffffffffa023a2fe>] br_dev_xmit+0x66/0x7c [bridge]
> [  289.588795]  [<ffffffff803d1535>] dev_queue_xmit+0x434/0x462
> [  289.588811]  [<ffffffffa024ca8c>] ip6_output+0xce7/0xcff [ipv6]
> [  289.588827]  [<ffffffffa024b8b4>] ip6_xmit+0x35c/0x439 [ipv6]
> [  289.588848]  [<ffffffffa026d303>] inet6_csk_xmit+0x223/0x236 [ipv6]
> [  289.588850]  [<ffffffff80443e8e>] _spin_lock_irqsave+0x21/0x29
> [  289.588853]  [<ffffffff804059ff>] tcp_transmit_skb+0x60f/0x64e

And it seems we have a TCP TSO frame that went through bridging
netfilter.

Herbert, is there something about checksum state changing done
by bridging netfilter that we have to be mindful of in
skb_gso_segment() and therefore not consider "!= CHECKSUM_PARTIAL"
a warn-worthy case?
