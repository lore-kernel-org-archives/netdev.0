From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Tue, 12 Jan 2016 13:33:28 +0800
Message-ID: <56949028.2070208@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-28-git-send-email-wangnan0@huawei.com> <20160111180913.GA25950@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <acme@kernel.org>, <linux-kernel@vger.kernel.org>,
	<pi3orama@163.com>, <lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Yunlong Song <yunlong.song@huawei.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111180913.GA25950@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/12 2:09, Alexei Starovoitov wrote:
> On Mon, Jan 11, 2016 at 01:48:18PM +0000, Wang Nan wrote:
>> This patch introduces a PERF_SAMPLE_TAILSIZE flag which allows a size
>> field attached at the end of a sample. The idea comes from [1] that,
>> with tie size at tail of an event, it is possible for user program who
>> read from the ring buffer parse events backward.
>>
>> For example:
>>
>>     head
>>      |
>>      V
>>   +--+---+-------+----------+------+---+
>>   |E6|...|   B  8|   C    11|  D  7|E..|
>>   +--+---+-------+----------+------+---+
>>
>> In this case, from the 'head' pointer provided by kernel, user program
>> can first see '6' by (*(head - sizeof(u64))), then it can get the start
>> pointer of record 'E', then it can read size and find start position
>> of record D, C, B in similar way.
> adding extra 8 bytes for every sample is quite unfortunate.
> How about another idea:
> . update data_tail pointer when head is about to overwrite it
>
> Ex:
>     head   data_tail
>      |       |
>      V       V
>   +--+-------+-------+---+----+---+
>   |E |  ...  |   B   | C |  D | E |
>   +--+-------+-------+---+----+---+
>
> if new sample F is about to overwrite B, the kernel would need
> to read the size of B from B's header and update data_tail to point C.
> Or even further.
> Comparing to TAILSIZE approach, now kernel will be doing both reads
> and writes into ring-buffer and there is a concern that reads may
> be hitting cold data, but if the records are small they may be
> actually on the same cache line brought by the previous
> read A's header, write E record cycle. So I think we shouldn't see
> cache misses.

After ring buffer rewind, we need a read before nearly
every write operations. The performance penalty depends on
configuration of write allocate. In addition, another data
dependency is required: we must wait for the size of
event B is retrived before overwrite it.

Even in the very first try at 2013 in [1], reading from the ring
buffer is avoided. I don't think Peter changes his mind now.

> Another concern is validity of records stored. If user space messes
> with ring-buffer, kernel won't be able to move data_tail properly
> and would need to indicate that to userspace somehow.
> But memory saving of 8 bytes per record could be sizable

Yes. But I have already discussed with Peter on this in [2].
Last month I suggested:

<quote>

  1. If PERF_SAMPLE_SIZE is selected, we can avoid outputting the event
     size in header. Which eliminate extra space cost;
</quote>

However:

<quote>

That would mandate you always parse the stream backwards. Which seems
rather unfortunate. Also, no you cannot recoup the extra space, see the
alignment and size requirement.

</quote>

>   and
> user space wouldn't need to walk the whole buffer backwards and
> can just start from valid data_tail, so the dumps of overwrite
> ring-buffer will be faster too.
> Thoughts?
>
Please also refer to [3]. In that patch we introduced a userspace
ring buffer in perf and make it continously collect data from
normal ring buffers. Since we have to wake up perf to read data,
the cost is even higher.

[1] 
http://lkml.kernel.org/r/20130708121557.GA17211@twins.programming.kicks-ass.net
[2] 
http://lkml.kernel.org/r/20151203100801.GV3816@twins.programming.kicks-ass.net
[3] 
http://lkml.kernel.org/r/1448373632-8806-1-git-send-email-yunlong.song@huawei.com
