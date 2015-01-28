From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH v2 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Wed, 28 Jan 2015 13:25:57 -0300
Message-ID: <20150128162557.GP7220@kernel.org>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
 <1422417973-10195-5-git-send-email-ast@plumgrid.com>
 <20150128162415.GO7220@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150128162415.GO7220@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Jan 28, 2015 at 01:24:15PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Tue, Jan 27, 2015 at 08:06:09PM -0800, Alexei Starovoitov escreveu:
> > diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
> > new file mode 100644
> > index 000000000000..7849ceb4bce6
> > --- /dev/null
> > +++ b/samples/bpf/tracex1_kern.c
> > @@ -0,0 +1,28 @@
> > +#include <linux/skbuff.h>
> > +#include <linux/netdevice.h>
> > +#include <uapi/linux/bpf.h>
> > +#include <trace/bpf_trace.h>
> > +#include "bpf_helpers.h"
> > +
> > +SEC("events/net/netif_receive_skb")
> > +int bpf_prog1(struct bpf_context *ctx)
> > +{
> > +	/*
> > +	 * attaches to /sys/kernel/debug/tracing/events/net/netif_receive_skb
> > +	 * prints events for loobpack device only
> > +	 */
> > +	char devname[] = "lo";
> > +	struct net_device *dev;
> > +	struct sk_buff *skb = 0;
> > +
> > +	skb = (struct sk_buff *) ctx->arg1;
> > +	dev = bpf_fetch_ptr(&skb->dev);
> > +	if (bpf_memcmp(dev->name, devname, 2) == 0)
> 
> I'm only starting to look at all this, so bear with me... But why do we
> need to have it as "bpf_memcmp"? Can't we simply use it as "memcmp" and
> have it use the right function?
> 
> Less typing, perhaps we would need to have a:
> 
> #define memcmp bpf_memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)

Argh, like this:

#define memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)
 
> in bpf_helpers.h to have it work?
> 
> - Arnaldo
> 
> > +		/* print event using default tracepoint format */
> > +		return 1;
> > +
> > +	/* drop event */
> > +	return 0;
> > +}
