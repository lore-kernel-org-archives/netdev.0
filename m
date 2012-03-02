From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: memory leak in udp_table_init
Date: Thu, 01 Mar 2012 16:12:12 -0800
Message-ID: <m1fwdr509v.fsf@fess.ebiederm.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E85@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	<paul.gortmaker@windriver.com>, <tim.bird@am.sony.com>,
	<kuznet@ms2.inr.ac.ru>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E85@saturn3.aculab.com>
	(David Laight's message of "Thu, 1 Mar 2012 08:55:01 -0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David Laight" <David.Laight@ACULAB.COM> writes:

>  
>> > The pid table is a good example of something where a hash
>> > table is unnecessary.
>> > Linux should steal the code I put into NetBSD :-)
>> 
>> On this unrelated topic.  What algorithm did you use on NetBSD for
>> dealing with pids?
>
> Basically I forced the hash chain length to one by allocating
> a pid that hit an empty entry in the table.
>
> So you start off with (say) 64 entries and use the low 6
> bits to index the table. The higher bits are incremented
> each time a 'slot' is reused.
> Free entries are kept in a FIFO list.
> So each entry either contains a pointer to the process,
> or the high bits and the index of the next free slot.
> (and the PGID pointer).
> When there are only (say) 2 free entries, then the table
> size is doubled, the pointers moved to the correct places,
> the free ist fixed up, and the minimum number of free entries
> doubled.
>
> The overall effect:
> - lookup is only ever a mask and index + compare.
> - Allocate is always fast and fixed cost (except when
>   the table size has to be doubled).
> - A pid value will never be reused within (about) 2000
>   allocates (for 16bit pids, much larger for 32bit ones).
> - Allocated pid numbers tend to be random, certainly
>   very difficult to predict.
> - Small memory footprint for small systems.
> For pids we normally avoid issuing large values, but
> will do so to avoid immediate re-use on systems that
> have 1000s of active processes.

That is a very nice technique.  Unfortunately doubling a hash table size
when you need large amounts of contiguous memory is difficult, and worse
does not support user space selectable pid numbers which is needed to
support process migration.  So I don't think we can adapt this case for
the linux pid hash table.

I will keep the technique in mind in case I run into a situation where
it is applicable.

Eric
