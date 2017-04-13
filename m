From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH linux 0/2] net sched actions: access to uninitialized
 data and error handling
Date: Wed, 12 Apr 2017 18:22:10 -0700
Message-ID: <CAM_iQpUvt9G+kqHUN9keuXeQ2HEtwTgBrpb3Bkzk6nxzhvdAhA@mail.gmail.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412142140.26649-1-w.bumiller@proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 7:21 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
> Commit 1045ba77a ("net sched actions: Add support for user cookies")
> added code to net/sched/act_api.c's tcf_action_init_1 using the `tb`
> nlattr array unconditionally, while it was otherwise used as well as
> initialized only when `name == NULL`:
>
>         if (name == NULL) {
>                 err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
>
> In the other case `nla` is instead passed over to ->init to be parsed
> there (using a different set of TCA_ enum values, iow. TCA_ACT_COOKIE
> then "clashes" with some other value). This lead to the following three
> example commands resulting in errors (sometimes followed by more traces
> and hangups some time later (although the hangups happened seconds or
> sometimes minutes later, sometimes not at all - results differed between
> different kernel versions (linux git-master vs ubuntu's mainline 4.11
> rc6 vs. pve 4.10.5 (based off ubuntu's zesty kernel where the commit is
> cherry-picked)...))):


Makes sense.

>
>  # ip link add ve0 type veth peer name ve0b
>  # tc qdisc add dev ve0 handle ffff: ingress
>  # tc filter add dev ve0 parent ffff: prio 50 basic police rate 1000bps burst 1000b drop
>
> The 3rd command would sometimes succeed, sometimes error with:
>
>  RTNETLINK answers: Invalid argument
>  We have an error talking to the kernel
>
> and sometimes error with:
>
>  RTNETLINK answers: Cannot allocate memory
>  We have an error talking to the kernel
>
> In the latter case I assume `cklen` became negative, which passes the
> TC_COOKIE_MAX_SIZE check since it is signed but becomes unsigned later
> in kmemdup() (see the crash dump below)


Yeah because tb[] contains some random pointers when not initialized.

>
> When the `tc filter add` command fails a backtrace shows up in dmesg,
> added below.
>
> I'm not sure why the TC_ACT_COOKIE code was added to tcf_action_init_1
> where it is now. It makes me think that it's supposed to be available
> universally, but the `name == NULL` check for how nla is used or passed
> to ->init() shows that the there are various different TC_ACT_* enums in
> use at this point, hence the 'RFC' part of the patches, I'm not that
> familiar with the code yet.
>

According to commit 1045ba77a5962a22bce777767, it is generic,
but if we need it for act_police too, we should add it to TCA_POLICE*.

Thanks.
