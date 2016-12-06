From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Tue, 6 Dec 2016 09:01:17 -0800
Message-ID: <CALCETrV3Yrq1hRcoGCTU_z-T-6hmq-gY-HytR2HGkvnRK-W1SQ@mail.gmail.com>
References: <1478647728-30357-1-git-send-email-john.stultz@linaro.org>
 <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com> <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com> <20161206165519.GA17648@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kafai-b10kYP2dOMg@public.gmane.org,
        Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
        Harald Hoyer <harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Rom Lemarchand <romlem-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
        Dmitry Shmidt
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161206165519.GA17648-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2016 at 8:55 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> On Mon, Dec 05, 2016 at 04:36:51PM -0800, Andy Lutomirski wrote:
>> I really don't know.  The cgroupfs interface is a bit unfortunate in
>> that it doesn't really express the constraints.  To safely migrate a
>> task, ISTM you ought to have some form of privilege over the task
>> *and* some form of privilege over the cgroup.  cgroupfs only handles
>> the latter.
>>
>> CAP_CGROUP_MIGRATE ought to be okay.  Or maybe cgroupfs needs to gain
>> a concept of "dangerous" cgroups and further restrict them and
>> CAP_SYS_RESOURCE should be fine for non-dangerous cgroups?  I think I
>> favor the latter, but it might be nice to hear from Tejun first.
>
> If we can't do CAP_SYS_RESOURCE due to overlaps, let's go with a
> separate CAP.  While for android and cgroup v1, it's nice to have a
> finer grained CAP for security control, privilege isolation in cgroup
> should also primarily done through hierarchical delegation.  It
> doesn't make sense to have another system in parallel.
>
> We can't do it properly on v1 because some controllers aren't properly
> hierarchical and delegation model isn't well defined.  e.g. nothing
> prevents a process from being pulled across different subtrees with
> the same delegation, but v2 can do it properly.  All that's necessary
> is to make the CAP test OR'd to other perm checks instead of AND'ing
> so that the CAP just allows overriding restrictions expressed through
> delegation but it's normally possible to move processes around in
> one's own delegated subtree.

How would one be granted the right to move processes around in one's
own subtree?

Are you imagining that, if you're in /a/b and you want to move a
process that's currently in /a/b/c to /a/b/d then you're allowed to
because the target process is in your tree?  If so, I doubt this has
the security properties you want -- namely, if you can cooperate with
anyone in /, even if they're unprivileged, you can break it.
