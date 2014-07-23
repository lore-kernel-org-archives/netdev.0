From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 07/16] bpf: add lookup/update/delete/iterate
 methods to BPF maps
Date: Wed, 23 Jul 2014 12:49:17 -0700
Message-ID: <CAMEtUuwE1oLUZb2QM243uKGSAfT_ahozducakpi9uvADzsj5XA@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-8-git-send-email-ast@plumgrid.com>
	<CAGXu5j+cvG5BhNSA=UrcbYs3LPSZUZyj4_ey8=9O0KgbUYUd9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+cvG5BhNSA=UrcbYs3LPSZUZyj4_ey8=9O0KgbUYUd9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 11:25 AM, Kees Cook <keescook@chromium.org> wrote:
>> +
>> +       /* lookup key in a given map referenced by map_id
>> +        * err = bpf_map_lookup_elem(int map_id, void *key, void *value)
>
> This needs map_id documentation updates too?

yes. will grep for it just to make sure.

>> +static int get_map_id(struct fd f)
>> +{
>> +       struct bpf_map *map;
>> +
>> +       if (!f.file)
>> +               return -EBADF;
>> +
>> +       if (f.file->f_op != &bpf_map_fops) {
>> +               fdput(f);
>
> It feels weird to me to do the fdput inside this function. Instead,
> should map_lookup_elem get a "err_put" label, instead?

I don't think it will work, since I'm not sure that fd.flags will be zero
when fd.file == NULL. It looks so by analyzing return code path
in fs/file.c, but I wasn't sure that I followed all code paths,
so I just picked this style from fs/timerfd.c assuming it was
done this away on purpose and there can be the case where
fd.file == null and fd.flags !=0. In such case we cannot call fdput().

>> +       err = -EFAULT;
>> +       if (copy_to_user(uvalue, value, map->value_size) != 0)
>> +               goto free_key;
>
> I'm made uncomfortable with memory copying where explicit lengths from
> userspace aren't being used. It does look like it would be redundant,
> though. Are there other syscalls where the kernel may stomp on user
> memory based on internal kernel sizes? I think this is fine as-is, but
> it makes me want to think harder about it. :)

good question :)
key_size and value_size are passed initially from user space.
Kernel only verifies and allocates internal map elements with given
sizes. Then it copies the value back with the size it remembered.
If user space said at map creation time that value_size is 100,
it should be using it consistently in user space program.

>> +       err = -ENOMEM;
>> +       next_key = kmalloc(map->key_size, GFP_ATOMIC);
>
> In the interests of defensiveness, I'd use kzalloc here.

I think it would be an overkill. Map implementation must consume
all bytes of incoming 'key' and return exactly the same number
of bytes in 'next_key'. Otherwise the whole iteration over map
with 'get_next_key' won't work. So if map implementation is
broken, it will be seen right away. No security leak here :)

>> +       case BPF_MAP_GET_NEXT_KEY:
>> +               return map_get_next_key((int) arg2, (void __user *) arg3,
>> +                                       (void __user *) arg4);
>
> Same observation as the other syscall cmd: perhaps arg5 == 0 should be
> checked? Also, since each of these functions looks up the fd and

yes. will do.

> builds the key, maybe those should be added to a common helper instead
> of copy/pasting into each demuxed function?

well, get_map_id() is a common helper. I didn't move fdget() all
the way to switch statement, since it looks less readable.
