From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Tue, 11 Oct 2016 08:58:57 +0800
Message-ID: <CAML_gOeNcgH-26iL6W5GDf0Ke0Sbpe9MTSULTvTnuiR9Cj_ZLA@mail.gmail.com>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
 <Pine.LNX.4.64.1610100627230.28174@nacho.alt.net> <CAML_gOeUOrt=-D3VHS2B3B_Q1F2-DAYK95Oxu4FEvfE43hjb3g@mail.gmail.com>
 <Pine.LNX.4.64.1610101818110.28174@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vishwanath Pai <vpai@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chris Caputo <ccaputo@alt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1610101818110.28174@nacho.alt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-11 2:33 GMT+08:00 Chris Caputo <ccaputo@alt.net>:
>>
>> What numbers did you specify after --nflog-size option?
>> --nflog-size 0 or ...? If you want log the whole packet to
>> the ulogd, please do not specify this nflog-size option.
>
> Not specifying nflog-size does not appear to log the whole packet...
>
> If "--nflog-size" is unspecified, and the iptables config is left
> unchanged when the kernel is upgraded to 4.8, ulogd-2.0.5 crashes.
>
> If "--nflog-size 0" is used, ulogd-2.0.5 crashes.
>
> If "--nflog-size" is used with size 1 or greater, ulogd-2.0.5 is fine.
>
>> > I'm surprised to see a kernel change cause unexpected userspace segfaults,
>> > so further investigation into a kernel fix would seem a good idea.
>>
>> According to the original user's manual, nflog-range option was
>> designed to be the number of bytes copied to userspace, but
>> unfortunately there's a bug from the beginning and it never works,
>> i.e. in kernel, it just ignored this option.
>>
>> Try to change the current nflog-range option's semantics may
>> cause unexpected results(maybe like this ulogd crash) ...
>>
>> In order to keep compatibility, Vishwanath introduce a new
>> nflog-size option and keep nflog-range unchanged. If you just
>> upgrade the kernel, and do not change iptables rules, this
>> problem will not happen.
>
> I am reporting that the problem does happen simply with an upgrade to
> kernel 4.8 and no other changes.  When "--nflog-size" is unspecified or
> set to 0, the bug in ulogd-2.0.5 gets triggered.
>
> I agree there is a bug in ulogd-2.0.5 that this kernel change exposed, but
> I am trying to explain that all ulogd users risk this segfault if they
> upgrade to kernel 4.8 and don't either update to a fixed ulogd (possibly
> using your patch below) or an unreleased iptables with iptables config
> changes to implement nflog-size on each NFLOG target.

Yes, thanks for clarifying this. There's a bug in kernel, can you try
this patch:

diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 018eed7..8c069b4 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -32,6 +32,7 @@ nflog_tg(struct sk_buff *skb, const struct
xt_action_param *par)
        li.u.ulog.copy_len   = info->len;
        li.u.ulog.group      = info->group;
        li.u.ulog.qthreshold = info->threshold;
+       li.u.ulog.flags      = 0;

        if (info->flags & XT_NFLOG_F_COPY_LEN)
                li.u.ulog.flags |= NF_LOG_F_COPY_LEN;

Thanks
