From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fast_hash: avoid indirect function calls
Date: Wed, 05 Nov 2014 22:03:06 -0500 (EST)
Message-ID: <20141105.220306.359839190322444593.davem@davemloft.net>
References: <8214a3fdc8b7f97bb782c8722e9f1e65037553fe.1415142006.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	dborkman@redhat.com, tgraf@suug.ch
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaKFDDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:03:10 -0500
In-Reply-To: <8214a3fdc8b7f97bb782c8722e9f1e65037553fe.1415142006.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  5 Nov 2014 00:23:04 +0100

> By default the arch_fast_hash hashing function pointers are initialized
> to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
> updated to the CRC32 ones. This dispatching scheme incurs a function
> pointer lookup and indirect call for every hashing operation.
> 
> rhashtable as a user of arch_fast_hash e.g. stores pointers to hashing
> functions in its structure, too, causing two indirect branches per
> hashing operation.
> 
> Using alternative_call we can get away with one of those indirect branches.
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.

> Would it make sense to start suppressing the generation of local
> functions for static inline functions which address is taken?
> 
> E.g. we could use extern inline in a few cases (dst_output is often used
> as a function pointer but marked static inline).  We could mark it as
> extern inline and copy&paste the code to a .c file to prevent multiple
> copies of machine code for this function. But because of the copy&paste I
> did not in this case.

I'd say that perhaps dst_output() can be handled in the "traditional"
way, by not inlining it ever.

If we have indirect function invocations and non-direct inlines, maybe
in the end it's better to have it in a single hot cache location, no?
