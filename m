From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bridge: faster compare for link local addresses
Date: Tue, 13 Mar 2007 14:38:32 +0100
Message-ID: <200703131438.32570.dada1@cosmosbay.com>
References: <20070312162015.5d22cd68@dxpl.pdx.osdl.net> <20070312.171029.85409273.davem@davemloft.net> <p731wjt9r9k.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39323 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933318AbXCMNi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 09:38:26 -0400
In-Reply-To: <p731wjt9r9k.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 March 2007 15:01, Andi Kleen wrote:
> David Miller <davem@davemloft.net> writes:
> > From: Rick Jones <rick.jones2@hp.com>
> > Date: Mon, 12 Mar 2007 17:05:39 -0700
> >
> > > Being paranoid - are there no worries about the alignment of dest?
> >
> > If it's an issue, it's an issue elsewhere too, as the places
> > where Stephen took this idiomatic code from is the code
> > ethernet handling and that runs on every input packet via
> > eth_type_trans().
>
> As a quick note -- when you tell gcc the expected alignment
> by using correct types then moderm gcc should generate fast inline code
> for memcpy/memcmp/etc. by itself. It only falls back to a slow generic
> function when it cannot figure out the alignment or the size.
>
> So I expect just using u32 * instead of char * should have the same
> effect and would be somewhat cleaner and the memcmp could be kept.

For memcpy() yes you can have some optimizations.

But memcmp() has a strong semantic (in libc). memcmp(a, b, 6) should do 6 byte 
compares and conditional branches, regardless of a/b alignment.
Or use the x86 "rep cmpsb" instruction that basically has the same cost.

The trick we use in compare_ether_addr() reduces to one some arithmetic and 
one test.

return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | (a[2] ^ b[2])) != 0;

I found this line as clean as memcmp(a, b, 6)

(On x86_64, were alignment is not mandatory, we could do :

((*(long *)a ^ *(long*)b) << 16) != 0)

(only if we can always read two extra bytes without faulting, of course :) )

