From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 08/16] bpf: add hashtable type of BPF maps
Date: Wed, 23 Jul 2014 13:33:29 -0700
Message-ID: <CAGXu5jLbcrR76=omiqRNERhjZS8bsR1-jG+Ctra97uCrpHLPUA@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-9-git-send-email-ast@plumgrid.com>
	<CAGXu5jK1hrwvPs7f+mSOer+81J9SBxwMrqb=6fFeZQ7hd-FMzA@mail.gmail.com>
	<CAMEtUuyRUG6ZdRvL0JuakD0zPdYo3WoqQepK7_b_MW+r2aVzVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuyRUG6ZdRvL0JuakD0zPdYo3WoqQepK7_b_MW+r2aVzVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 12:57 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Wed, Jul 23, 2014 at 11:36 AM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>> +static struct bpf_map *htab_map_alloc(struct nlattr *attr[BPF_MAP_ATTR_MAX + 1])
>>> +{
>>> +       struct bpf_htab *htab;
>>> +       int err, i;
>>> +
>>> +       htab = kmalloc(sizeof(*htab), GFP_USER);
>>
>> I'd prefer kzalloc here.
>
> in this case I agree. will change, since it's not in critical path and we
> can waste few cycles zeroing memory.
>
>>> +       err = -ENOMEM;
>>> +       htab->buckets = kmalloc(htab->n_buckets * sizeof(struct hlist_head),
>>> +                               GFP_USER);
>>
>> I'd prefer kcalloc here, even though n_buckets can't currently trigger
>> an integer overflow.
>
> hmm, I would argue that kmalloc_array is a preferred way, but kcalloc ?
> Few lines below the whole array is inited with INIT_HLIST_HEAD...

Ah! I didn't realize kmalloc_array existed! Perfect. Yes, that would
be great to use. The zeroing is not needed, due to the init below, as
you say.

>
>>> +       for (i = 0; i < htab->n_buckets; i++)
>>> +               INIT_HLIST_HEAD(&htab->buckets[i]);
>
>>> +       htab->slab_name = kasprintf(GFP_USER, "bpf_htab_%p", htab);
>>
>> This leaks a kernel heap memory pointer to userspace. If a unique name
>> needed, I think map_id should be used instead.
>
> it leaks, how? slabinfo is only available to root.
> The same code exists in conntrack:
> net/netfilter/nf_conntrack_core.c:1767

Right, in extreme cases, there are system configurations where leaking
addresses even to root can be considered a bug. There are a lot of
these situations in the kernel still, that's true. However, if we can
at all avoid it, I'd really like to avoid adding new ones. Nearly all
the cases of using a memory pointer is for uniqueness concerns, but I
think can already get that from the map_id.

-Kees

-- 
Kees Cook
Chrome OS Security
