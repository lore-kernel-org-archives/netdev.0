From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 12:04:23 +0200
Message-ID: <1350036263.21172.11438.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	 <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de>
	 <20121012090321.GA21164@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34319 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757937Ab2JLKE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 06:04:27 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1449951bkc.19
        for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 03:04:26 -0700 (PDT)
In-Reply-To: <20121012090321.GA21164@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 10:03 +0100, Russell King - ARM Linux wrote:

> No.  It is my understanding that various IP option processing can also
> cause the alignment fault handler to be invoked, even when the packet is
> properly aligned, and then there's jffs2/mtd which also relies upon
> alignment faults being fixed up.

Oh well.

We normally make sure we dont have alignment faults on arches that dont
have CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS (or a non null NET_IP_ALIGN)

So if you find an offender, please report a bug, because I can guarantee
you we will _fix_ it.

One example of a fix was the following subtle one.

commit 117632e64d2a5f464e491fe221d7169a3814a77b
tcp: take care of misalignments
    
We discovered that TCP stack could retransmit misaligned skbs if a
malicious peer acknowledged sub MSS frame. This currently can happen
only if output interface is non SG enabled : If SG is enabled, tcp
builds headless skbs (all payload is included in fragments), so the tcp
trimming process only removes parts of skb fragments, header stay
aligned.
    
Some arches cant handle misalignments, so force a head reallocation and
shrink headroom to MAX_TCP_HEADER.

Dont care about misaligments on x86 and PPC (or other arches setting
NET_IP_ALIGN to 0)

This patch introduces __pskb_copy() which can specify the headroom of
new head, and pskb_copy() becomes a wrapper on top of __pskb_copy()
