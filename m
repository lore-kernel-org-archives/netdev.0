From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: fixing sk_stream_rfree()
Date: Tue, 18 Apr 2006 13:49:36 +0200
Message-ID: <200604181349.36949.netdev@axxeo.de>
References: <20060414.205927.13626300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a81-14-224-183.net-htp.de ([81.14.224.183]:56513 "EHLO
	mail.axxeo.de") by vger.kernel.org with ESMTP id S932214AbWDRLty
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 07:49:54 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.205927.13626300.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

You wrote:
> 2) We can't turn sk_forward_alloc easily into an atomic_t.  The
>    masking operation in __sk_stream_mem_reclaim() does not translate
>    readily into an atomic_t op:
> 
> 		sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
> 
>    That line has always driven me nuts, but I know that it is there
>    to handle partial page allocations existing when that function
>    is called.
> 
> I guess for #2 we could change those two lines into:
> 
> 		int n = atomic_read(&sk->sk_forward_alloc) /
> 				SK_STREAM_MEM_QUANTUM;
> 
> 		atomic_sub(n, sk->sk_prot->memory_allocated);
> 		sk->sk_forward_alloc -= n * SK_STREAM_MEM_QUANTUM;
> 
> in order to make it "atomic_t op" translatable.

It is possible. Just view this as an register with size SK_STREAM_MEM_QUANTUM.

Mask on every read and always after the read.
Always add/subtract the intended value.
Wraparound happens within the modulo/mask value.

This works without problems as long as SK_STREAM_MEM_QUANTUM 
is a power of two. If not, just use modulo arithmetics.


The non-atomic wrapround doesn't change the atomic nature of
read, add, sub. Only problem is atomic_dec_and_test() or similiar ops.


Regards

Ingo Oeser
