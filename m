From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/4] net/sched: Use TC skip flags to reflect HW
 offload status
Date: Mon, 13 Feb 2017 20:10:36 +0200
Message-ID: <CAJ3xEMg=33E+W0n25wnWdgcc7=nqv_8NpjTw6Ema7_9fJt=+Og@mail.gmail.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com> <20170210.143636.253114480501653886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:36687 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752048AbdBMSKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 13:10:38 -0500
Received: by mail-ot0-f194.google.com with SMTP id 36so12795795otx.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 10:10:37 -0800 (PST)
In-Reply-To: <20170210.143636.253114480501653886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 9:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  9 Feb 2017 16:18:04 +0200
>
>> Currently there is no way of querying whether a filter is
>> offloaded to HW or not when using both policy (no flag).
>>
>> Reuse the skip flags to show the insertion status by setting
>> the skip_hw flag in case the filter wasn't offloaded.
>>
>> The bpf patch is compile tested only, Daniel/Jakub, will
>> appreciate your review/ack.

> I'm learning towards suggesting that you use new flags, this way it
> will be unambiguous whether we are running an old kernel.

> If you just use the skip flag, it's impossible to tell the difference.

Dave, all

SB Jakub detailed proposal, will be good to know if you're happy with
that so I can have backwind for implementing it... basically I was
thinking to add into the UAPI @
 http://lxr.free-electrons.com/source/include/uapi/linux/pkt_cls.h#L157

which has the following flags

/* tca flags definitions */
#define TCA_CLS_FLAGS_SKIP_HW   (1 << 0)
#define TCA_CLS_FLAGS_SKIP_SW   (1 << 1)

#define TCA_CLS_FLAGS_OFFLOADED  (1 << 2)
#define TCA_CLS_FLAGS_NOT_OFFLOADED (1 << 3)

we need two new flags and not only one for user space to
be able and identify if they run over older kernel

And set these flags in each of the offloading classifiers

This is along the proposal of Jakub below

thoughts?

Or.

On Fri, Feb 10, 2017 at 7:42 PM, Jakub Kicinski <kubakici@wp.pl> wrote:

> Restating my proposal was to leave the SKIP_* flags
> with all their existing semantics and complexity and for reporting to
> user space whether something got offloaded add new ones.  My opinion
> is that it would make things simpler, but I'm happy with your version
> if none else thinks this way.
>
> To spell it out with this patchset we would get the following semantics
> of flags in dumps:
>  - no flags - offloaded || old kernel;
>  - skip_hw - not offloaded (either on user request || no flag
>    was set but offload could not happen);
>  - skip_sw - offload only on explicit request.
>
> What we could do if we want to add flags would be:
>  - no flags - old kernel;
>  - no_offload - not offloaded;
>  - skip_hw | no_offload - not offloaded on explicit user request;
>  - offload - offloaded opportunistically;
>  - skip_sw | offload - offloaded on explicit request.
>
> Because of dealing with distributor's kernels and various other
> backports checking if kernel is old is a pain in practice :|
