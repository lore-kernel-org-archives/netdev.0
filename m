From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Mon, 9 Feb 2015 23:08:36 -0500
Message-ID: <20150209230836.7f913c60@grimm.local.home>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
	<1423539961-21792-5-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423539961-21792-5-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  9 Feb 2015 19:45:57 -0800
Alexei Starovoitov <ast@plumgrid.com> wrote:
 
> +int perf_event_mmap(int fd);
> +int perf_event_poll(int fd);
> +typedef void (*print_fn)(void *data, int size);
> +void perf_event_read(print_fn fn);
> +struct trace_entry {
> +	unsigned short          type;
> +	unsigned char           flags;
> +	unsigned char           preempt_count;
> +	int                     pid;
> +};
> +

Please do not hard code any structures. This is not a stable ABI, and
it may not even match if you are running 32 bit userspace on top of a
64 bit kernel.

Please parse the format files. libtraceevent does this for you. If need
be, link to that. But if you look at the event format files you'll see
the offsets and sizes in the binary code:

	field:unsigned short common_type;	offset:0;	size:2;	signed:0;
	field:unsigned char common_flags;	offset:2;	size:1;	signed:0;
	field:unsigned char common_preempt_count;	offset:3;	size:1;	signed:0;
	field:int common_pid;	offset:4;	size:4;	signed:1;

I don't want to get stuck with pinned kernel data structures again. We
had 4 blank bytes of data for every event, because latency top hard
coded the field. Luckily, the 64 bit / 32 bit interface caused latency
top to have to use the event_parse code to work, and we were able to
remove that field after it was converted.

-- Steve
