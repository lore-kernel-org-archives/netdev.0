From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Mon, 11 Jan 2016 10:09:14 -0800
Message-ID: <20160111180913.GA25950@ast-mbp.thefacebook.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@kernel.org, linux-kernel@vger.kernel.org, pi3orama@163.com,
	lizefan@huawei.com, netdev@vger.kernel.org, davem@davemloft.net,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Yunlong Song <yunlong.song@huawei.com>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 01:48:18PM +0000, Wang Nan wrote:
> This patch introduces a PERF_SAMPLE_TAILSIZE flag which allows a size
> field attached at the end of a sample. The idea comes from [1] that,
> with tie size at tail of an event, it is possible for user program who
> read from the ring buffer parse events backward.
> 
> For example:
> 
>    head
>     |
>     V
>  +--+---+-------+----------+------+---+
>  |E6|...|   B  8|   C    11|  D  7|E..|
>  +--+---+-------+----------+------+---+
> 
> In this case, from the 'head' pointer provided by kernel, user program
> can first see '6' by (*(head - sizeof(u64))), then it can get the start
> pointer of record 'E', then it can read size and find start position
> of record D, C, B in similar way.

adding extra 8 bytes for every sample is quite unfortunate.
How about another idea:
. update data_tail pointer when head is about to overwrite it

Ex:
   head   data_tail
    |       |
    V       V
 +--+-------+-------+---+----+---+
 |E |  ...  |   B   | C |  D | E |
 +--+-------+-------+---+----+---+

if new sample F is about to overwrite B, the kernel would need
to read the size of B from B's header and update data_tail to point C.
Or even further.
Comparing to TAILSIZE approach, now kernel will be doing both reads
and writes into ring-buffer and there is a concern that reads may
be hitting cold data, but if the records are small they may be
actually on the same cache line brought by the previous
read A's header, write E record cycle. So I think we shouldn't see
cache misses.
Another concern is validity of records stored. If user space messes
with ring-buffer, kernel won't be able to move data_tail properly
and would need to indicate that to userspace somehow.
But memory saving of 8 bytes per record could be sizable and
user space wouldn't need to walk the whole buffer backwards and
can just start from valid data_tail, so the dumps of overwrite
ring-buffer will be faster too.
Thoughts?
