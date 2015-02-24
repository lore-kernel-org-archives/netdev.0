From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 10:38:51 +0100
Message-ID: <54EC46AB.3030302@iogearbox.net>
References: <20150223184904.GA24955@linux.vnet.ibm.com> <20150224085909.GC17306@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	kaber@trash.net, ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, josh@joshtriplett.org,
	johunt@akamai.com
To: Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48904 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbbBXJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 04:39:13 -0500
In-Reply-To: <20150224085909.GC17306@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 09:59 AM, Thomas Graf wrote:
> On 02/23/15 at 10:49am, Paul E. McKenney wrote:
>> Hello!
>>
>> Alexei mentioned that there was some excitement a couple of weeks ago in
>> Ottawa, something about the resizing taking forever when there were large
>> numbers of concurrent additions.  One approach comes to mind:
>
> @Dave et al,
> Just want to make sure we have the same level of understanding of
> urgency for this. The only practical problem experienced so far is
> loading n*1M entries into an nft_hash set which takes 3s for 4M
> entries upon restore. A regular add is actually fine as it provides
> a hint and sizes the table accordingly.

Btw, there is one remaining bug in nft that Josh Hunt found which
should go into 3.20/4.0, it's not in -net tree, so it could have
affected testing with nft. We're currently missing max_shift
parameter in nft's rhashtable initialization.

This means that there will be _no_ expansions as rht_grow_above_75()
will end up always returning false. It's not that dramatic when you
have a proper hint provided, but when you start out small
(NFT_HASH_ELEMENT_HINT = 3) and try to squeeze 1M entries into it,
it might take a while.

Simplest fix would be, similarly as in other users:

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 61e6c40..47abdca 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -192,6 +192,7 @@ static int nft_hash_init(const struct nft_set *set,
  		.key_offset = offsetof(struct nft_hash_elem, key),
  		.key_len = set->klen,
  		.hashfn = jhash,
+		.max_shift = 20, /* 1M */
  		.grow_decision = rht_grow_above_75,
  		.shrink_decision = rht_shrink_below_30,
  	};

But I presume Josh wanted to resend his code ... or wait for nft
folks to further review?

> I agree that rhashtable should be improved to better handle many
> inserts on small tables but wanted to make sure whether anyone thinks
> this needs urgent fixing in 3.20 or whether we can take some time to
> fully understand all scenarios and experiment with ideas and then
> propose solutions for the next merge window. I also have the TCP hash
> tables on my radar while improving this.
