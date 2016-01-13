From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 27/53] perf/core: Put size of a sample at the end of it
 by PERF_SAMPLE_TAILSIZE
Date: Tue, 12 Jan 2016 21:14:00 -0800
Message-ID: <20160113051358.GA37858@ast-mbp.thefacebook.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-28-git-send-email-wangnan0@huawei.com>
 <20160111180913.GA25950@ast-mbp.thefacebook.com>
 <56949028.2070208@huawei.com>
 <20160112061145.GA31444@ast-mbp.thefacebook.com>
 <5694F347.5010700@huawei.com>
 <20160112195641.GA34601@ast-mbp.thefacebook.com>
 <5695D3CB.3030604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, acme@kernel.org,
	linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Adrian Hunter <adrian.hunter@intel.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Ahern <dsahern@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Yunlong Song <yunlong.song@huawei.com>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5695D3CB.3030604@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 12:34:19PM +0800, Wangnan (F) wrote:
> 
> >>Or moving whole header to the end of a record?
> >I think moving the whole header under new TAILHEADER flag is
> >actually very good idea. The ring buffer will be fully utilized
> >and no extra bytes necessary. User space would need to parse it
> >backwards, but for this use case it fits well.
> 
> I have another crazy suggestion: can we make kernel writing to
> the ring buffer from the end to the beginning? For example:
> 
> This is the initial state of the ring buffer, head pointer
> pointes to the end of it:
> 
>       -------------> Address increase
> 
>                                     head
>                                       |
>                                       V
>  +--+---+-------+----------+------+---+
>  |                                    |
>  +--+---+-------+----------+------+---+
> 
> 
> Write the first event at the end of the ring buffer, and *decrease*
> the head pointer:
> 
>                                 head
>                                   |
>                                   V
>  +--+---+-------+----------+------+---+
>  |                                | A |
>  +--+---+-------+----------+------+---+
> 
> 
> Another record:
>                           head
>                            |
>                            V
>  +--+---+-------+----------+------+---+
>  |                         |   B  | A |
>  +--+---+-------+----------+------+---+
> 
> 
> Ring buffer rewind, A is fully overwritten and B is broken:
> 
>                                head
>                                  |
>                                  V
>  +--+---+-------+----------+-----+----+
>  |F | E |   D   | C        | ... | F  |
>  +--+---+-------+----------+-----+----+
> 
> At this time user can parse the ring buffer normally from
> F to C. From timestamp in it he know which one is the
> oldest.
> 
> By this perf don't need too much extra work to do. There's no
> performance penalty at all, and the 8 bytes are saved.
> 
> Thought?

I like it.
I think from algorithmic stand point it's very pretty, but real
cpus may not like to stream the data backwards. x86 can detect
the stride and prefetch the next cache line when stride is
positive. I don't think there is such hw logic for negative strides.
So if it's not too hard, I would suggest to implement both of
your ideas. I negative stride is just as fast as normal, then
let's use that, since it doesn't change the header and nothing
needs to change on perf side or any other tools that read
ring-buffer manually.
