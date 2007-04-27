From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:08:09 -0700 (PDT)
Message-ID: <20070426.200809.04441500.davem@davemloft.net>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
	<20070426.161522.76328746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41739
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755148AbXD0DIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 23:08:01 -0400
In-Reply-To: <20070426.161522.76328746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 16:15:22 -0700 (PDT)

> Ok, I applied it all and added a compiler warning fix for 64-bit
> at the end.

I just found a problem in your work, you cannot use cmpxchg() in
generic code, it is not available on all processors:

davem@sunset:~/src/GIT/net-2.6$ egrep cmpxchg fs/afs/*.c
fs/afs/vlocation.c:			if (cmpxchg(&vl->state, state, AFS_VL_CREATING) ==
davem@sunset:~/src/GIT/net-2.6$ 

Also, cmpxchg() implementations typically only support 32-bit and
64-bit atomic operations, so even if this were allowed you'll get
linking errors on sparc64 (and I think powerpc):

WARNING: "__cmpxchg_called_with_bad_pointer" [fs/afs/kafs.ko] undefined!
make[1]: *** [__modpost] Error 1

Anyways, please get me a patch to fix this, use a spinlock or
the existing vl->lock rwlock.  Something like that.

Thanks.
