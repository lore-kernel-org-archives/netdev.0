From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 09/16] bpf: expand BPF syscall with
 program load/unload
Date: Wed, 23 Jul 2014 13:22:21 -0700
Message-ID: <CAMEtUuw9paQJXEzg=dJw6z--3UqFp-pWq4uyxV-oT4_0_+7Gxg@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-10-git-send-email-ast@plumgrid.com>
	<CAGXu5j+gMepR-euMhBjYqMVHsdJM-Do5yc0rLw5dMK-C9BBieA@mail.gmail.com>
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
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5j+gMepR-euMhBjYqMVHsdJM-Do5yc0rLw5dMK-C9BBieA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 12:00 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Thu, Jul 17, 2014 at 9:19 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> eBPF programs are safe run-to-completion functions with load/unload
>> methods from userspace similar to kernel modules.
>>
>> User space API:
>>
>> - load eBPF program
>>   fd = bpf_prog_load(bpf_prog_type, struct nlattr *prog, int len)
>>
>>   where 'prog' is a sequence of sections (TEXT, LICENSE, MAP_ASSOC)
>>   TEXT - array of eBPF instructions
>>   LICENSE - must be GPL compatible to call helper functions marked gpl_only
>>   MAP_FIXUP - array of {insn idx, map fd} used by kernel to adjust
>>   imm constants in 'mov' instructions used to access maps
>
> Nit: naming mismatch between MAP_ASSOC vs MAP_FIXUP.

ohh yes, I used map_assoc name initially and forgot to rename it
in commit log. will fix.

>> + */
>> +static int fixup_bpf_map_id(struct sk_filter *prog, struct nlattr *map_fixup)
>> +{
>> +       struct {
>> +               u32 insn_idx;
>> +               u32 ufd;
>> +       } *fixup = nla_data(map_fixup);
>> +       int fixup_len = nla_len(map_fixup) / sizeof(*fixup);
>> +       struct bpf_insn *insn;
>> +       struct fd f;
>> +       u32 idx;
>> +       int i, map_id;
>> +
>> +       if (fixup_len <= 0)
>> +               return -EINVAL;
>> +
>> +       for (i = 0; i < fixup_len; i++) {
>> +               idx = fixup[i].insn_idx;
>> +               if (idx >= prog->len)
>> +                       return -EINVAL;
>> +
>> +               insn = &prog->insnsi[idx];
>> +               if (insn->code != (BPF_ALU64 | BPF_MOV | BPF_K) &&
>> +                   insn->code != (BPF_ALU | BPF_MOV | BPF_K))
>> +                       return -EINVAL;
>> +
>> +               f = fdget(fixup[i].ufd);
>> +
>> +               map_id = get_map_id(f);
>> +
>> +               if (map_id < 0)
>> +                       return map_id;
>> +
>> +               insn->imm = map_id;
>> +               fdput(f);
>
> It looks like there a potentially race risk of a map_id changing out
> from under a running program? Between the call to fixup_bpf_map_id()
> and the bpf_map_get() calls during bpf_prog_load() below...

Excellent question!
If user space created a bunch of maps and has another thread
that closes fds (and may be creating new maps) while main thread is
doing syscall(prog_load,...) then map_ids stored inside instructions
can become stale by the time bpf_check() is called. In such case
bpf_check() will reject the program. Either it will find unknown map_id
or map will have invalid key/value ranges for the program to access.
So this is not an issue, but I agree the code is not obviously correct.
My bad to allow such subtle races.
I'll increase mutex_lock() range.

>> +       if (tb[BPF_PROG_MAP_FIXUP]) {
>> +               /* if program is using maps, fixup map_ids */
>> +               err = fixup_bpf_map_id(prog, tb[BPF_PROG_MAP_FIXUP]);
>> +               if (err < 0)
>> +                       goto free_prog;
>> +       }
>> +
>> +       /* allocate eBPF related auxilary data */
>> +       prog->info = kzalloc(sizeof(struct bpf_prog_info), GFP_USER);
>> +       if (!prog->info)
>> +               goto free_prog;
>> +       prog->ebpf = 1;
>> +       prog->info->is_gpl_compatible = is_gpl;
>> +
>> +       /* find program type: socket_filter vs tracing_filter */
>> +       err = find_prog_type(type, prog);
>> +       if (err < 0)
>> +               goto free_prog;
>> +
>> +       /* lock maps to prevent any changes to maps, since eBPF program may
>> +        * use them. In such case bpf_check() will populate prog->used_maps
>> +        */
>> +       mutex_lock(&bpf_map_lock);
>> +
>> +       /* run eBPF verifier */
>> +       /* err = bpf_check(prog); */
>> +
>> +       if (err == 0 && prog->info->used_maps) {
>> +               /* program passed verifier and it's using some maps,
>> +                * hold them
>> +                */
>> +               for (i = 0; i < prog->info->used_map_cnt; i++) {
>> +                       map = bpf_map_get(prog->info->used_maps[i]);
>> +                       BUG_ON(!map);
>> +                       atomic_inc(&map->refcnt);
>> +               }
>> +       }
>> +       mutex_unlock(&bpf_map_lock);
>
> As mentioned above, I think fixup_bpf_map_id needs to be done under
> the map_lock mutex, unless I'm misunderstanding something in the
> object lifetime.

yes. Excellent point. Will increase the range.

Thank you so much for the review!
