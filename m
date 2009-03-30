From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Mon, 30 Mar 2009 14:32:23 -0500
Message-ID: <49D11E47.8080106@freescale.com>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com> <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se> <49CCD3E8.9040007@freescale.com> <OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se> <49D0FFBB.7000009@freescale.com> <OF3127420C.081D4097-ONC1257589.00603E3D-C1257589.006093B3@transmode.se> <49D1052D.2050609@freescale.com> <OF70832E04.3DC53F05-ONC1257589.00663AFF-C1257589.0066C397@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43468 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758685AbZC3TdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 15:33:07 -0400
In-Reply-To: <OF70832E04.3DC53F05-ONC1257589.00663AFF-C1257589.0066C397@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
>> different since descriptors are in MURAM which is ioremap()ed -- though 
>> switching to a cacheable mapping with barriers should be a performance 
>> improvement.
> 
> I always thought that MURAM was very fast. The whole reason to have BDs in
> MURAM is that it is faster than normal RAM, at least that is what I 
> thought.

Yeah, on second thought it probably wouldn't be worth it.  There's also 
the question of under what circumstances the QE's MURAM accesses will be 
cache-coherent.

As for the CPU not reordering guarded+cache inhibited accesses, that 
initially seemed to be true for the new arch stuff (book3e/book3s, but 
not really, see below), but the classic arch documentation only 
guarantees stores to such regions to be in-order (and the 
explicitly-specified operation of eieio on I+G accesses wouldn't make 
much sense if they were already guaranteed to be in-order).

Then I looked at the EREF to see what older book E documents had to say 
on the issue, and it suggests that when the architecture document says 
"out of order", it really means "speculative" (and reading the arch 
doc's definition of "out of order" seems to confirm this -- redefining 
terms is bad, m'kay?).  So it seems that the simple answer is no, 
guarded storage is not guaranteed to be in order, unless the only thing 
that can cause an out-of-order access is speculative execution.

-Scott
