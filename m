From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Wed, 13 Jan 2016 12:34:19 +0800
Message-ID: <5695D3CB.3030604@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com> <1452520124-2073-28-git-send-email-wangnan0@huawei.com> <20160111180913.GA25950@ast-mbp.thefacebook.com> <56949028.2070208@huawei.com> <20160112061145.GA31444@ast-mbp.thefacebook.com> <5694F347.5010700@huawei.com> <20160112195641.GA34601@ast-mbp.thefacebook.com>
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
In-Reply-To: <20160112195641.GA34601@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/13 3:56, Alexei Starovoitov wrote:
> On Tue, Jan 12, 2016 at 08:36:23PM +0800, Wangnan (F) wrote:
>>> hmm, in this kernel patch I see that you're adding 8 bytes for
>>> every record via this extra TAILSISZE flag and in perf you're
>>> walking the ring buffer backwards by reading this 8 byte
>>> sizes, comparing header sizes and so on until reaching beginning,
>>> where you start dumping it as normal.
>>> So for this 'signal to perf' approach to work the ring buffer
>>> will contain tailsizes everywhere just so that user space can
>>> find the beginning. That's not very pretty. imo if kernel
>>> can do header read to adjust data_tail it would make user
>>> space side clean. May be there are other solutions.
>>> Adding tailsize seems like brute force hack.
>>> There must be some nicer way.
>> Hi Peter,
>>
>>   What's your opinion? Should we reconsider moving size field from header the
>> end?
>> Or moving whole header to the end of a record?
> I think moving the whole header under new TAILHEADER flag is
> actually very good idea. The ring buffer will be fully utilized
> and no extra bytes necessary. User space would need to parse it
> backwards, but for this use case it fits well.

I have another crazy suggestion: can we make kernel writing to
the ring buffer from the end to the beginning? For example:

This is the initial state of the ring buffer, head pointer
pointes to the end of it:

       -------------> Address increase

                                     head
                                       |
                                       V
  +--+---+-------+----------+------+---+
  |                                    |
  +--+---+-------+----------+------+---+


Write the first event at the end of the ring buffer, and *decrease*
the head pointer:

                                 head
                                   |
                                   V
  +--+---+-------+----------+------+---+
  |                                | A |
  +--+---+-------+----------+------+---+


Another record:
                           head
                            |
                            V
  +--+---+-------+----------+------+---+
  |                         |   B  | A |
  +--+---+-------+----------+------+---+


Ring buffer rewind, A is fully overwritten and B is broken:

                                head
                                  |
                                  V
  +--+---+-------+----------+-----+----+
  |F | E |   D   | C        | ... | F  |
  +--+---+-------+----------+-----+----+

At this time user can parse the ring buffer normally from
F to C. From timestamp in it he know which one is the
oldest.

By this perf don't need too much extra work to do. There's no
performance penalty at all, and the 8 bytes are saved.

Thought?

Thank you.
