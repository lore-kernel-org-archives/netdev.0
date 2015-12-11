From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Fri, 11 Dec 2015 15:50:43 -0800
Message-ID: <CALx6S35UUmt+f4c_5Dh=8qvKBqtO7F5j_RqhXs01ONhj4HChKw@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
	<CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
	<566864C0.6020204@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36031 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbbLKXuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 18:50:44 -0500
Received: by mail-ig0-f182.google.com with SMTP id ph11so49401970igc.1
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 15:50:43 -0800 (PST)
In-Reply-To: <566864C0.6020204@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> If your device is trying do offload more than one checksum on its own > accord without being asked to do so by the stack it is doing the > wrong thing!
> From the stack's perspective: yes, it is doing the wrong thing.  (I've
> been discussing with colleagues today how we could change that, and I
> think we can, but it involves having _three_ hardware TXQs per kernel
> queue, instead of the two we have now...)
> But from the outside perspective, the system as a whole isn't doing
> anything bad - the packet going on the network is valid and just
> happens to have both inner and outer checksums filled in.  Is there a
> good reason _why_ the stack forbids a device to do this?  (Sure, it's
> not necessary, and makes the hardware more complex.  But the hardware's
> already been made, and it's not a *completely* useless thing to do...)
>
By the way, I am pretty sure that any driver that supports checksum
offload of encapsulation is going to break at some point with multiple
layers of encapsulation. For example, suppose send a UDP packet in
VXLAN in VXLAN, where packet looks like:
IP|UDP|VXLAN|Eth|IP|UDP|VXLAN|Eth|IP|UDP. I believe the kernel can set
up checksum offload for any of the three UDP checksums. If the outer
checksum is offloaded, then skb->encapsulation is not set so the
driver will know that a plain UDP/IP checksum is being offload-- no
problem. For the other two, skb->encapsulation will be set so driver
will know that one of the encapsulated checksums is being offloaded,
but it cannot tell which one without comparing against csum_start.
Inner headers don't help here since they would likely point to the
outermost encapsulation headers even when checksum being offloaded is
the innermost one. If the driver guesses about which checksum is being
offloaded and its wrong then packet is sent with a bad checksum
(possibly two bad checksums).

Unless I'm reading this incorrectly, it is a real bug. I hope to the
send base helper functions for this next week (the NETIF_F_IP[V6]_CSUM
sunsetting patches). Any drivers that are offloading encapsulated
checksums and don't check csum_start really should be subsequently
fixed.

Tom
