From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] samples: bpf: example of stateful socket filtering
Date: Sat, 29 Nov 2014 22:24:28 -0800
Message-ID: <CAMEtUuw+z61FL81-_aZ0=D5XKm-_gh+Cs1uGL2th+0A+hcYPGQ@mail.gmail.com>
References: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
	<1417066951-1999-4-git-send-email-ast@plumgrid.com>
	<20141129.210158.2021042941461629799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141129.210158.2021042941461629799.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 29, 2014 at 9:01 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> Date: Wed, 26 Nov 2014 21:42:28 -0800
>
>> this socket filter example does:
>> - creates arraymap in kernel with key 4 bytes and value 8 bytes
>>
>> - loads eBPF program:
>>   r0 = skb[14 + 9]; // load one byte of ip->proto
>  ...
>> +             BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
>
> I do not want anything having to do with fixed offsets from
> the skb.
>
> Nothing should know where things are in the SKB structure,
> especially user facing things.
>
> That's why we have explicit BPF operations for fetching
> specific SKB members, so that the layout is completely
> transparent to the entity generating BPF programs.
>
> Besides retaining the flexibility of changing the SKB
> layout arbitrarily without breaking bpf programs, there
> are also security considerations from allowing bpf
> programs to load arbitrary offsets.
>
> Sorry, I do not like this patch series at all.

sigh.
You misunderstood one wrong comment in the whole series.
r0 = skb[14 + 9]; // load one byte of ip->proto
is saying
r0 = skb->data[14 + 9]; // load one byte of ip->proto
it's loading one byte of packet payload and
not one byte of skb structure.

There are plenty of other comments where I mentioned that.
Including cover letter:
"Though native eBPF programs are way more powerful than classic filters
(attachable through similar setsockopt() call), they don't have skb field
accessors yet. Like skb->pkt_type, skb->dev->ifindex are not accessible.
There are sevaral ways to achieve that. That will be in the next set of patches.
So in this set native eBPF programs can only read data from packet and
access maps"

and in patch #2:
+static bool sock_filter_is_valid_access(int off, int size, enum
bpf_access_type type)
+{
+       /* skb fields cannot be accessed yet */
+       return false;
+}

In other words, there is no way to access skb fields yet.
There are several different ways I've implemented to
access skb fields, but they all had their cons and pros, so I
dropped them all to focus on basic things first.
Which is: read packet data and access maps.

Please let me know if you want me to fix this comment
in this patch of sample code.
