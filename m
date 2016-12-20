From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 20:44:41 -0800
Message-ID: <20161220044440.GB86803@ast-mbp.thefacebook.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <80574175-3692-0278-a74e-23b752d44f73@gmail.com>
 <CALCETrVKu63BFVQFAJcLcd6ovPtq-WDdTh-BwyAPSprw8UarNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVKu63BFVQFAJcLcd6ovPtq-WDdTh-BwyAPSprw8UarNQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 07:12:48PM -0800, Andy Lutomirski wrote:
> 
> struct cgroup_bpf {
>         /*
>          * Store two sets of bpf_prog pointers, one for programs that are
>          * pinned directly to this cgroup, and one for those that are effective
>          * when this cgroup is accessed.
>          */
>         struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
>         struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
> };
> 
> in struct cgroup, there's a 'struct cgroup_bpf bpf;'.
> 
> This would change to something like:
> 
> struct cgroup_filter_slot {
>   struct bpf_prog *effective;
>   struct cgroup_filter_slot *next;
>   struct bpf_prog *local;
> }
> 
> local is NULL unless *this* cgroup has a filter.  effective points to
> the bpf_prog that's active in this cgroup or the nearest ancestor that
> has a filter.  next is NULL if there are no filters higher in the
> chain or points to the next slot that has a filter.  struct cgroup
> has:
> 
> struct cgroup_filter_slot filters[MAX_BPF_ATTACH_TYPE];
> 
> To evaluate it, you do:
> 
> struct cgroup_filter_slot *slot = &cgroup->slot[the index];
> 
> if (!slot->effective)
>   return;
> 
> do {
>   evaluate(slot->effective);
>   slot = slot->next;
> } while (unlikely(slot));

yes. something like this can work as a future extension
to support multiple programs for security use case.
Please propose a patch.
Again, it's not needed today and there is no rush to implement it.
