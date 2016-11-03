From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/netlink: global-out-of-bounds in genl_family_rcv_msg/validate_nla
Date: Thu, 3 Nov 2016 16:28:37 +0100
Message-ID: <CAAeHK+xtgjBM6MOy3kmi7D70rkyUY_yZPygRUw12bjt+mBd_XA@mail.gmail.com>
References: <CAAeHK+xm5_n-Ep2d4YEq=Yx=f5M2NpV-So0o7811LUk+pLr+rg@mail.gmail.com>
 <CAM_iQpWBoEhaLfCYPaStZ-U8s-i5h9fmaG9JCW-q7QfjntfEOA@mail.gmail.com> <CAM_iQpXAqgW5LxAXmHbBqppM-eo1spyOJhyCpkkZ_3J7DRUUuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXAqgW5LxAXmHbBqppM-eo1spyOJhyCpkkZ_3J7DRUUuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

Yes, the last patch fixes the issue.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

On Thu, Nov 3, 2016 at 6:29 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Nov 2, 2016 at 10:25 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, Nov 2, 2016 at 5:25 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> Hi,
>>>
>>> I've got the following error report while running the syzkaller fuzzer:
>>>
>>> ==================================================================
>>> BUG: KASAN: global-out-of-bounds in validate_nla+0x49b/0x4e0 at addr
>>> ffffffff8407e3ac
>>> Read of size 2 by task a.out/3877
>>> Address belongs to variable[<        none        >]
>>> cgroupstats_cmd_get_policy+0xc/0x40 ??:?
>>
>> Seems taskstats doesn't use genetlink correctly, CGROUPSTATS_CMD_ATTR_FD
>> is not within 0~TASKSTATS_CMD_ATTR_MAX.
>>
>> I guess we need the following patch, but it certainly breaks user-space... :-/
>
>
> Wait, maybe just this one-line fix is enough:
>
> diff --git a/kernel/taskstats.c b/kernel/taskstats.c
> index b3f05ee..e6b342e 100644
> --- a/kernel/taskstats.c
> +++ b/kernel/taskstats.c
> @@ -54,7 +54,7 @@ static const struct nla_policy
> taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1
>         [TASKSTATS_CMD_ATTR_REGISTER_CPUMASK] = { .type = NLA_STRING },
>         [TASKSTATS_CMD_ATTR_DEREGISTER_CPUMASK] = { .type = NLA_STRING },};
>
> -static const struct nla_policy
> cgroupstats_cmd_get_policy[CGROUPSTATS_CMD_ATTR_MAX+1] = {
> +static const struct nla_policy
> cgroupstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1] = {
>         [CGROUPSTATS_CMD_ATTR_FD] = { .type = NLA_U32 },
>  };
