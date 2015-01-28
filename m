From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Wed, 28 Jan 2015 08:42:29 -0800
Message-ID: <CAMEtUuxRXEPOaX3rksqQKdz4THMmtLR3=uHymEKaMSNkjMBhxw@mail.gmail.com>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
 <1422417973-10195-5-git-send-email-ast@plumgrid.com> <20150128162415.GO7220@kernel.org>
 <20150128162557.GP7220@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150128162557.GP7220-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 28, 2015 at 8:25 AM, Arnaldo Carvalho de Melo
<acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Em Wed, Jan 28, 2015 at 01:24:15PM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Tue, Jan 27, 2015 at 08:06:09PM -0800, Alexei Starovoitov escreveu:
>> > diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
>> > new file mode 100644
>> > index 000000000000..7849ceb4bce6
>> > --- /dev/null
>> > +++ b/samples/bpf/tracex1_kern.c
>> > @@ -0,0 +1,28 @@
>> > +#include <linux/skbuff.h>
>> > +#include <linux/netdevice.h>
>> > +#include <uapi/linux/bpf.h>
>> > +#include <trace/bpf_trace.h>
>> > +#include "bpf_helpers.h"
>> > +
>> > +SEC("events/net/netif_receive_skb")
>> > +int bpf_prog1(struct bpf_context *ctx)
>> > +{
>> > +   /*
>> > +    * attaches to /sys/kernel/debug/tracing/events/net/netif_receive_skb
>> > +    * prints events for loobpack device only
>> > +    */
>> > +   char devname[] = "lo";
>> > +   struct net_device *dev;
>> > +   struct sk_buff *skb = 0;
>> > +
>> > +   skb = (struct sk_buff *) ctx->arg1;
>> > +   dev = bpf_fetch_ptr(&skb->dev);
>> > +   if (bpf_memcmp(dev->name, devname, 2) == 0)
>>
>> I'm only starting to look at all this, so bear with me... But why do we
>> need to have it as "bpf_memcmp"? Can't we simply use it as "memcmp" and
>> have it use the right function?
>>
>> Less typing, perhaps we would need to have a:
>>
>> #define memcmp bpf_memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)
>
> Argh, like this:
>
> #define memcmp(s1, s2, n) bpf_memcmp(s1, s2, n)
>
>> in bpf_helpers.h to have it work?

yes, that will work just fine.
Since it's an example I made it explicit that bpf_memcmp()
has memcmp() semantics, but little bit different:
int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size)
meaning that one of the pointers can point anywhere and
the function will be doing probe_kernel_read() underneath
similar to bpf_fetch_*() helpers.

If it was plain memcmp() it would give a wrong impression
that vanilla memcmp() can be used.
In general the programs cannot use any library functions
outside of helpers defined in uapi/linux/bpf.h

bpf_fetch_*() helpers are also explicit in examples.
If one need to do a lot of pointer walking, then macro like
#define D(P) ((typeof(P))bpf_fetch_ptr(&P))
would be easier to use: p = D(D(skb->dev)->ifalias)
multiple pointer derefs would look more natural...
