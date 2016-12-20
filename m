From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 19:12:48 -0800
Message-ID: <CALCETrVKu63BFVQFAJcLcd6ovPtq-WDdTh-BwyAPSprw8UarNQ@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com> <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <80574175-3692-0278-a74e-23b752d44f73@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:35191 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754890AbcLTDNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 22:13:10 -0500
Received: by mail-ua0-f180.google.com with SMTP id 2so36434723uax.2
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 19:13:09 -0800 (PST)
In-Reply-To: <80574175-3692-0278-a74e-23b752d44f73@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 6:52 PM, David Ahern <dsahern@gmail.com> wrote:
> On 12/19/16 6:56 PM, Andy Lutomirski wrote:
>> On Mon, Dec 19, 2016 at 5:44 PM, David Ahern <dsahern@gmail.com> wrote:
>>> On 12/19/16 5:25 PM, Andy Lutomirski wrote:
>>>> net.socket_create_filter =3D "none": no filter
>>>> net.socket_create_filter =3D "bpf:baadf00d": bpf filter
>>>> net.socket_create_filter =3D "disallow": no sockets created period
>>>> net.socket_create_filter =3D "iptables:foobar": some iptables thingy
>>>> net.socket_create_filter =3D "nft:blahblahblah": some nft thingy
>>>> net.socket_create_filter =3D "address_family_list:1,2,3": allow AF 1, =
2, and 3
>>>
>>> Such a scheme works for the socket create filter b/c it is a very simpl=
e use case. It does not work for the ingress and egress which allow generic=
 bpf filters.
>>
>> Can you elaborate on what goes wrong?  (Obviously the
>> "address_family_list" example makes no sense in that context.)
>
> Being able to dump a filter or see that one exists would be a great add-o=
n, but I don't see how 'net.socket_create_filter =3D "bpf:baadf00d"' is a v=
iable API for loading generic BPF filters. Simple cases like "disallow" are=
 easy -- just return 0 in the filter, no complicated BPF code needed. The r=
est are specific cases of the moment which goes against the intent of ebpf =
and generic programmability.

Oh -- I'm not proposing that at all.  Let me clarify.  For the bpf
case, if you *read* the file, you'd see "bpf:baadf00d".  But writing
"bpf:baadf00d" is nonsense and would give you -EINVAL.  Instead you
install a bpf filter by opening the file for write (O_RDWR or
O_WRONLY) and doing ioctl(cgroup_socket_create_file_fd,
CGROUP_IOCTL_SET_BPF_FILTER, bpf_fd);  It's kind of like
BPF_PROG_ATTACH except that it respects filesystem permissions, it
isn't in the bpf() multiplexer, the filter being set is implied (by
the fd in use), and everything is nicely seccompable.

To remove the filter, you write "none" or "none\n" to the file.

As a future extension, if someone wanted more than one filter to be
able to coexist in the cgroup socket_create_filter slot, you could
plausibly do 'echo disallow >>net.socket_create_filter' or use a new
ioctl CGROUP_IOCTL_APPEND_BPF_FILTER, and then you'd read the file and
see more than one line.  But this would be a future extension and may
never be needed.

>>
>> a) sub-cgroups cannot have a filter at all of the parent has a filter.
>> (This is the "punt" approach -- it lets different semantics be
>> assigned later without breaking userspace.)
>>
>> b) sub-cgroups can have a filter if a parent does, too.  The semantics
>> are that the sub-cgroup filter runs first and all side-effects occur.
>> If that filter says "reject" then ancestor filters are skipped.  If
>> that filter says "accept", then the ancestor filter is run and its
>> side-effects happen as well.  (And so on, all the way up to the root.)
>
> That comes with a big performance hit for skb / data path cases.
>
> I'm riding my use case on Daniel's work, and as I understand it the nesti=
ng case has been discussed. I'll defer to Daniel and Alexei on this part.

I'm not sure I buy the performance hit.  If you do it naively, then
performance will indeed suck.  But there's already a bunch of code in
there to pre-populate a filter list for faster use.  Currently, we
have:

struct cgroup_bpf {
        /*
         * Store two sets of bpf_prog pointers, one for programs that are
         * pinned directly to this cgroup, and one for those that are effec=
tive
         * when this cgroup is accessed.
         */
        struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
        struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
};

in struct cgroup, there's a 'struct cgroup_bpf bpf;'.

This would change to something like:

struct cgroup_filter_slot {
  struct bpf_prog *effective;
  struct cgroup_filter_slot *next;
  struct bpf_prog *local;
}

local is NULL unless *this* cgroup has a filter.  effective points to
the bpf_prog that's active in this cgroup or the nearest ancestor that
has a filter.  next is NULL if there are no filters higher in the
chain or points to the next slot that has a filter.  struct cgroup
has:

struct cgroup_filter_slot filters[MAX_BPF_ATTACH_TYPE];

To evaluate it, you do:

struct cgroup_filter_slot *slot =3D &cgroup->slot[the index];

if (!slot->effective)
  return;

do {
  evaluate(slot->effective);
  slot =3D slot->next;
} while (unlikely(slot));

The old code was one branch per evaluation.  The new code is n+1
branches where n is the number of filters, so it's one extra branch in
the worst case.  But the extra branch is cache-hot (the variable is
right next to slot->effective, which is needed regardless) and highly
predictable (in the case where nesting isn't used, the branch is not
taken, and it's a backward branch which most CPUs will predict as not
taken).

I expect that, on x86, this adds at most a cycle or two and quite
possibly adds no measurable overhead at all.
