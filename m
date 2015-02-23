From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 17:34:29 -0500 (EST)
Message-ID: <20150223.173429.1474472311581340033.davem@davemloft.net>
References: <CAADnVQKQWsRv-NrT4YWiG1sD-o2vMQTWKrbCt_u-LMusveG+bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, tgraf@suug.ch, josh@joshtriplett.org,
	herbert@gondor.apana.org.au, kaber@trash.net,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQKQWsRv-NrT4YWiG1sD-o2vMQTWKrbCt_u-LMusveG+bA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 23 Feb 2015 14:17:06 -0800

> I'm not sure all of these counting optimizations will help at the end.
> Say we have a small table. A lot of inserts are coming in at the same
> time. rhashtable_expand kicks in and all new inserts are going
> into future table, while expansion is happening.
> Since expand will kick in quickly the old table will not have long
> chains per bucket, so few unzips and corresponding
> synchronize_rcu and we're done with expand.
> Now future table becomes the only table, but it still has a lot
> of entries, since insertions were happening and this table has
> long per bucket chains, so next expand will have a lot of
> synchronize_rcu and will take very long time.
> So whether we count while inserting or not and whether
> we grow by 2x or grow by 8x we still have an underlying
> problem of very large number of synchronize_rcu.
> Malicious user that knows this can stall the whole system.
> Please tell me I'm missing something.

This is why I have just suggested that we make inserts block,
and the expander looks at the count of pending inserts in an
effort to keep expanding the table further if necessary before
releasing the blocked insertion threads.
