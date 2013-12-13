From: Francesco Fusco <ffusco@redhat.com>
Subject: Re: [PATCH net-next v2 2/2] net: ovs: use CRC32 accelerated flow
 hash if available
Date: Fri, 13 Dec 2013 15:53:48 +0100
Message-ID: <52AB1F7C.1050606@redhat.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com> <1386860946-1621-3-git-send-email-ffusco@redhat.com> <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7487@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	dev@openvswitch.org, Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825Ab3LMOyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 09:54:01 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7487@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2013 11:01 AM, David Laight wrote:
> My thoughts exactly.
> Given this is a hash it could crc alternate words into separate
> accumulators and the combine the values at the end.
> That way you are still doing sequential accesses to the data.
> (The crc instruction might be better than an xor for the combine.)
> If the cpu has 3 execution units that can do crc, use them all.
>
> It might be that the hash function is now an insignificant cost.
> Looking at how much hashing the data twice (discarding the first
> result - assign to global volatile data) slows things down can
> help determine this.

On i7 CPUs the crc32/crc64 instructions have a throughput
of 1 cycle and a latency of 3 cycles [1], which means that 1) with this 
code we pay 3 clocks per crc32 instruction, and 2) we could compute 
three CRCs in parallel, each processing 1/3 of the data during the same 
clock. This could in theory provide 3x the performance.

For short keys (~100 bytes and less) there is chance that the 3x 
theoretical speedup will be destroyed by the additional code required
to compute boundaries, xor the results, etc. But as I already mentioned, 
this is something to try.

[1] 
http://www.intel.com/content/dam/www/public/us/en/documents/white-papers/fast-crc-computation-paper.pdf
