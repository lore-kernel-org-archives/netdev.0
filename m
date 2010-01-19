From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2] tcp: input header length, prediction, and timestamp
 bugs
Date: Tue, 19 Jan 2010 12:35:02 -0500
Message-ID: <4B55ED46.40909@gmail.com>
References: <4B49C2D0.1070704@gmail.com> <4B50BFFC.8010108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:38483 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105Ab0ASRfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 12:35:07 -0500
In-Reply-To: <4B50BFFC.8010108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Over the weekend, I've been reviewing the .lst output that Andi
explained, and I've found a few interesting things.

1) The 4.4 compiler isn't very smart about shifts:

static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
{
	return th->doff * 4;
c04ea93e:	0f b6 47 0c          	movzbl 0xc(%edi),%eax
c04ea942:	c0 e8 04             	shr    $0x4,%al
c04ea945:	0f b6 c0             	movzbl %al,%eax
c04ea948:	c1 e0 02             	shl    $0x2,%eax

That could easily be done as shr $0x2 instead.

2) This "fast path" code is under quite a bit of register pressure on
the 32-bit i386.  There's a lot of saving and re-loading.

3) Particularly, the seldom used *th and len parameters are saved and
reloaded in the very beginning of the fast path, really wasting time.

4) Since both *th and len are actually indexed loads from *skb (which
the compiler keeps in a register most of the time), doing indexed loads
from the stack (%ebp) is the same, so they shouldn't be sent as
parameters at all!

5) There's already code, added back in 2006 for DMA, that directly
references skb->len instead of the len parameter.  Probably lack of
header documentation, so the coder failed to notice:

				if (copied_early)
					tcp_cleanup_rbuf(sk, skb->len);
c04ead5d:	8b 56 50             	mov    0x50(%esi),%edx
c04ead60:	89 d8                	mov    %ebx,%eax
c04ead62:	e8 fc ff ff ff       	call   c04ead63 <tcp_rcv_established+0x633>

Therefore, I'll resubmit this patch, removing the existing len parameter.
And maybe *th, too....
