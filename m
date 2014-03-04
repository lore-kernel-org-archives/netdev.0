From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Tue, 04 Mar 2014 13:41:41 -0500 (EST)
Message-ID: <20140304.134141.1732220919806520941.davem@davemloft.net>
References: <20140304210104.42ef3dd8@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbaCDSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:41:44 -0500
In-Reply-To: <20140304210104.42ef3dd8@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Tue, 4 Mar 2014 21:01:04 +1100

> The unix socket code is using the result of csum_partial to
> hash into a lookup table:
> 
> 	unix_hash_fold(csum_partial(sunaddr, len, 0));
> 
> csum_partial is only guaranteed to produce something that can be
> folded into a checksum, as its prototype explains:
> 
>  * returns a 32-bit number suitable for feeding into itself
>  * or csum_tcpudp_magic
> 
> The 32bit value should not be used directly.
> 
> Depending on the alignment the ppc64 csum_partial will return
> different 32bit values that will fold into the same checksum.
> 
> This difference causes the following testcase (courtesy of
> Gustavo) to sometimes fail:

Alternatively you could just make unix_hash_fold() use csum_fold(),
right?

static inline unsigned int unix_hash_fold(__wsum n)
{
	unsigned int hash = (__force unsigned int) csum_fold(n);

	hash ^= hash>>8;
	return hash&(UNIX_HASH_SIZE-1);
}
