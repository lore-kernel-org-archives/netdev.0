From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: (unknown)
Date: Mon, 16 Jan 2017 21:18:36 -0800
Message-ID: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Subject: 
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.



On Sun, Jan 15, 2017 at 5:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> Sorry about the delay.  Some fire fighthing followed the holidays.
>
> On Tue, Jan 03, 2017 at 11:25:59AM +0100, Michal Hocko wrote:
>> > So from what I understand the proposed cgroup is not in fact
>> > hierarchical at all.
>> >
>> > @TJ, I thought you were enforcing all new cgroups to be properly
>> > hierarchical, that would very much include this one.
>>
>> I would be interested in that as well. We have made that mistake in
>> memcg v1 where hierarchy could be disabled for performance reasons and
>> that turned out to be major PITA in the end. Why do we want to repeat
>> the same mistake here?
>
> Across the different threads on this subject, there have been multiple
> explanations but I'll try to sum it up more clearly.
>
> The big issue here is whether this is a cgroup thing or a bpf thing.
> I don't think there's anything inherently wrong with one approach or
> the other.  Forget about the proposed cgroup bpf extentions but thinkg
> about how iptables does cgroups.  Whether it's the netcls/netprio in
> v1 or direct membership matching in v2, it is the network side testing
> for cgroup membership one way or the other.  The only part where
> cgroup is involved in is answering that test.
>

[...]

>
> None of the issues that people have been raising here is actually an
> issue if one thinks of it as a part of bpf.  Its security model is
> exactly the same as any other bpf programs.  Recursive behavior is
> exactly the same as how other external cgroup descendant membership
> testing work.  There is no issue here whatsoever.

After sleeping on this, here are my thoughts:

First, there are three ways to think about this, not just two.  It
could be a BPF feature, a net feature, or a cgroup feature.

I think that calling it a BPF feature is a cop-out.  BPF is an
assembly language and a mechanism for importing little programs into
the kernel.  BPF maps are a BPF feature.  These new hooks are a
feature that actively changes the behavior of other parts of the
kernel.  I don't see how calling this new feature a "BPF" feature
excuses it from playing by the expected rules of the subsystems it
affects or from generally working well with the rest of the kernel.

Perhaps this is a net feature, though, not a cgroup feature.  This
would IMO make a certain amount of sense.  Iptables cgroup matches,
for example, logically are an iptables (i.e., net) feature.  The
problem here is that network configuration (and this explicitly
includes iptables) is done on a per-netns level, whereas these new
hooks entirely ignore network namespaces.  I've pointed out that
trying to enable them in a namespaced world is problematic (e.g.
switching to ns_capable() will cause serious problems), and Alexei
seems to think that this will never happen.  So I don't think we can
really call this a net feature that works the way that other net
features work.

(Suppose that this actually tried to be netns-enabled.  Then you'd
have to map from (netns, cgroup) -> hook, and this would probably be
slow and messy.)

So I think that leaves it being a cgroup feature.  And it definitely
does *not* play by the rules of cgroups right now.

> I'm sure we'll
> eventually get there but from what I hear it isn't something we can
> pull off in a restricted timeframe.

To me, this sounds like "the API isn't that great, we know how to do
better, but we really really want this feature ASAP so we want to ship
it with a sub-par API."  I think that's a bad idea.

> This also holds true for the perf controller.  While it is implemented
> as a controller, it isn't visible to cgroup users in any way and the
> only function it serves is providing the membership test to perf
> subsystem.  perf is the one which decides whether and how it is to be
> used.  cgroup providing membership test to other subsystems is
> completely acceptable and established.

Unless I'm mistaken, "perf_event" is an actual cgroup controller, and
it explicitly respects the cgroup hierarchy.  It shows up in
/proc/cgroups, and I had no problem mounting a cgroupfs instance with
perf_event enabled.  So I'm not sure what you mean.
