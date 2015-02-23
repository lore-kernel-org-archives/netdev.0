From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 15:07:20 -0800
Message-ID: <CAADnVQ+kJu=Hb5oUMeQuchWe67nLo7AMnPUK0VJecRqYM0GHCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Josh Triplett <josh@joshtriplett.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	"ying.xue" <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:36832 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbBWXHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 18:07:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 2:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Mon, 23 Feb 2015 14:17:06 -0800
>
>> I'm not sure all of these counting optimizations will help at the end.
>> Say we have a small table. A lot of inserts are coming in at the same
>> time. rhashtable_expand kicks in and all new inserts are going
>> into future table, while expansion is happening.
>> Since expand will kick in quickly the old table will not have long
>> chains per bucket, so few unzips and corresponding
>> synchronize_rcu and we're done with expand.
>> Now future table becomes the only table, but it still has a lot
>> of entries, since insertions were happening and this table has
>> long per bucket chains, so next expand will have a lot of
>> synchronize_rcu and will take very long time.
>> So whether we count while inserting or not and whether
>> we grow by 2x or grow by 8x we still have an underlying
>> problem of very large number of synchronize_rcu.
>> Malicious user that knows this can stall the whole system.
>> Please tell me I'm missing something.
>
> This is why I have just suggested that we make inserts block,
> and the expander looks at the count of pending inserts in an
> effort to keep expanding the table further if necessary before
> releasing the blocked insertion threads.

yes. blocking inserts would solve the problem, but it will make
rhashtable applicability to be limited.
Also 'count of pending inserts' is going to be very small and
meaningless, since it will count the number of threads that
are sleeping on insert and not very useful to predict future
expansions.
As an alternative we can store two chains of pointers
per element (one chain for old table and another chain
for future table). That will avoid all unzipping logic at the cost
of extra memory. May be there are other solutions.
I think as a minimum something like 'blocking inserts' are
needed for stable. imo the current situation with nft_hash
is not just annoying, it's a bug.
