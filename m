From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 14:17:06 -0800
Message-ID: <CAADnVQKQWsRv-NrT4YWiG1sD-o2vMQTWKrbCt_u-LMusveG+bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Josh Triplett <josh@joshtriplett.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2015 at 1:52 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Feb 23, 2015 at 09:03:58PM +0000, Thomas Graf wrote:
>> On 02/23/15 at 11:12am, josh@joshtriplett.org wrote:
>> > In theory, resizes should only take the locks for the buckets they're
>> > currently unzipping, and adds should take those same locks.  Neither one
>> > should take a whole-table lock, other than resize excluding concurrent
>> > resizes.  Is that still insufficient?
>>
>> Correct, this is what happens. The problem is basically that
>> if we insert from atomic context we cannot slow down inserts
>> and the table may not grow quickly enough.
>>
>> > Yeah, the add/remove statistics used for tracking would need some
>> > special handling to avoid being a table-wide bottleneck.
>>
>> Daniel is working on a patch to do per-cpu element counting
>> with a batched update cycle.
>
> One approach is simply to count only when a resize operation is in
> flight.  Another is to keep a per-bucket count, which can be summed
> at the beginning of the next resize operation.

I'm not sure all of these counting optimizations will help at the end.
Say we have a small table. A lot of inserts are coming in at the same
time. rhashtable_expand kicks in and all new inserts are going
into future table, while expansion is happening.
Since expand will kick in quickly the old table will not have long
chains per bucket, so few unzips and corresponding
synchronize_rcu and we're done with expand.
Now future table becomes the only table, but it still has a lot
of entries, since insertions were happening and this table has
long per bucket chains, so next expand will have a lot of
synchronize_rcu and will take very long time.
So whether we count while inserting or not and whether
we grow by 2x or grow by 8x we still have an underlying
problem of very large number of synchronize_rcu.
Malicious user that knows this can stall the whole system.
Please tell me I'm missing something.
