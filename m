From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 17:43:43 -0800
Message-ID: <CALCETrUhJbc90xnNJJyWEMTdah4_C4qaf+tFu5-OJSvJgwZtMA@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 4:25 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Dec 19, 2016 at 4:02 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> you're ignoring use cases I described earlier.
>> In vrf case there is only one ifindex it needs to bind to.
>
> I'm totally lost.  Can you explain what this has to do with the cgroup
> hierarchy?
>

Okay, I figured out what you mean, I think.  You have a handful of vrf
devices.  Let's say they have ifindexes 1 and 2 (and maybe more).

The interesting case happens when you set up /cgroup/a with a bpf
program that binds new sockets to ifindex 1 and /cgroup/a/b with a bpf
program that binds new sockets to ifindex 2.  The question is: what
should happen if you're in /cgroup/a/b?  Presumably, if you do this,
you wanted to end up with ifindex 2.

I think the way it should actually work is that the kernel evaluates
/cgroup/a/b's hook and then /cgroup/a's hook.  Then /cgroup/a (which
is the more privileged hook) gets to make the choice.  If it wants
ifindex 2 to win, it can do (pseudocode):

if (!sk->sk_bound_if)
  sk->sk_bound_if = 1;
