From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] tipc: convert tipc reference table to use
 generic rhashtable
Date: Sun, 4 Jan 2015 09:53:20 +0000
Message-ID: <20150104095320.GB15305@casper.infradead.org>
References: <1420356862-7523-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39761 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbADJxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 04:53:23 -0500
Content-Disposition: inline
In-Reply-To: <1420356862-7523-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/15 at 03:34pm, Ying Xue wrote:
> As tipc reference table is statically allocated, its memory size
> requested on stack initialization stage is quite big even if the
> maximum port number is just restricted to 8191 currently, however,
> the number already becomes insufficient in practice. But if the
> maximum ports is allowed to its theory value - 2^32, its consumed
> memory size will reach a ridiculously unacceptable value. Apart from
> this, heavy tipc users spend a considerable amount of time in
> tipc_sk_get() due to the read-lock on ref_table_lock.
> 
> If tipc reference table is converted with generic rhashtable, above
> mentioned both disadvantages would be resolved respectively: making
> use of the new resizable hash table can avoid locking on the lookup;
> smaller memory size is required at initial stage, for example, 256
> hash bucket slots are requested at the beginning phase instead of
> allocating the entire 8191 slots in old mode. The hash table will
> grow if entries exceeds 75% of table size up to a total table size
> of 1M, and it will automatically shrink if usage falls below 30%,
> but the minimum table size is allowed down to 256.
> 
> Also converts ref_table_lock to a separate mutex to protect hash table
> mutations on write side. Lastly defers the release of the socket
> reference using call_rcu() to allow using an RCU read-side protected
> call to rhashtable_lookup().

If I read the code correctly, then the only reason for the mutex
to exist is to protect the quest of identifying an unused portid
since the insertion is protected by per bucket locks now.

As a further optimization, you could add a new atomic function
rhashtable_lookup_and_insert() which holds the per bucket lock during
lookup and use that instead. This would allow you to get rid of the
mutex alltogether.
