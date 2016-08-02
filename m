From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix method of PTR_TO_PACKET reg id generation
Date: Tue, 02 Aug 2016 22:38:36 +0200
Message-ID: <57A104CC.6080806@iogearbox.net>
References: <1470150734-24022-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48094 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcHBUkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 16:40:13 -0400
In-Reply-To: <1470150734-24022-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2016 05:12 PM, Jakub Kicinski wrote:
> Using per-register incrementing ID can lead to
> find_good_pkt_pointers() confusing registers which
> have completely different values.  Consider example:
>
> 0: (bf) r6 = r1
> 1: (61) r8 = *(u32 *)(r6 +76)
> 2: (61) r0 = *(u32 *)(r6 +80)
> 3: (bf) r7 = r8
> 4: (07) r8 += 32
> 5: (2d) if r8 > r0 goto pc+9
>   R0=pkt_end R1=ctx R6=ctx R7=pkt(id=0,off=0,r=32) R8=pkt(id=0,off=32,r=32) R10=fp
> 6: (bf) r8 = r7
> 7: (bf) r9 = r7
> 8: (71) r1 = *(u8 *)(r7 +0)
> 9: (0f) r8 += r1
> 10: (71) r1 = *(u8 *)(r7 +1)
> 11: (0f) r9 += r1
> 12: (07) r8 += 32
> 13: (2d) if r8 > r0 goto pc+1
>   R0=pkt_end R1=inv56 R6=ctx R7=pkt(id=0,off=0,r=32) R8=pkt(id=1,off=32,r=32) R9=pkt(id=1,off=0,r=32) R10=fp
> 14: (71) r1 = *(u8 *)(r9 +16)
> 15: (b7) r7 = 0
> 16: (bf) r0 = r7
> 17: (95) exit
>
> We need to get a UNKNOWN_VALUE with imm to force id
> generation so lines 0-5 make r7 a valid packet pointer.
> We then read two different bytes from the packet and
> add them to copies of the constructed packet pointer.
> r8 (line 9) and r9 (line 11) will get the same id of 1,
> independently.  When either of them is validated (line
> 13) - find_good_pkt_pointers() will also mark the other
> as safe.  This leads to access on line 14 being mistakenly
> considered safe.
>
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
