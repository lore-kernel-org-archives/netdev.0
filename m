From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Mon, 4 Jan 2016 11:22:39 -0500
Message-ID: <CAEfhGixs3a326n5wk6BJ2hQEZvZQX7A06tg57oFvdrn4vwmCUw@mail.gmail.com>
References: <1451410150-15466-1-git-send-email-kraigatgoog@gmail.com>
	<1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
	<568840FE.6000001@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35873 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbcADQWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:22:42 -0500
Received: by mail-lf0-f68.google.com with SMTP id p203so28627957lfa.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:22:41 -0800 (PST)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com. [209.85.217.172])
        by smtp.gmail.com with ESMTPSA id th4sm5159987lbb.46.2016.01.04.08.22.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 08:22:40 -0800 (PST)
Received: by mail-lb0-f172.google.com with SMTP id oh2so161144555lbb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:22:39 -0800 (PST)
In-Reply-To: <568840FE.6000001@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 2, 2016 at 4:28 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 12/29/2015 06:29 PM, Craig Gallek wrote:
>>
>> From: Craig Gallek <kraig@google.com>
>>
>> Expose socket options for setting a classic or extended BPF program
>> for use when selecting sockets in an SO_REUSEPORT group.  These options
>> can be used on the first socket to belong to a group before bind or
>> on any socket in the group after bind.
>>
>> This change includes refactoring of the existing sk_filter code to
>> allow reuse of the existing BPF filter validation checks.
>>
>> Signed-off-by: Craig Gallek <kraig@google.com>
>
> [...]
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index 4165e9a..3561d3a 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -447,6 +447,8 @@ void bpf_prog_destroy(struct bpf_prog *fp);
>>
>>   int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>>   int sk_attach_bpf(u32 ufd, struct sock *sk);
>> +int reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>> +int reuseport_attach_bpf(u32 ufd, struct sock *sk);
>
>
> Maybe for consistency this should be sk_* prefixed as well due to its
> relation to sockets?)
ACK -> v3

> You currently don't charge the BPF program against the optmem limits, but
> just
> test if the size of a given program would surpass the current
> sysctl_optmem_max.
> Ok, after all, this would block anything beyond 2560 insns by default. Is
> there
> a reason it's not charged for real? Due to the sysctl_optmem_max default
> being
> too small?
>
> Btw, in case of an eBPF fd, we already charged it to the user's
> RLIMIT_MEMLOCK,
> not sure if blocking it here after program already got an fd makes much
> sense.
> I'm fine if you want to leave it for now and refine this later, though.
I considered a couple options, but I wasn't able to come up with a
straight forward policy.  Which socket should the filter memory be
charged to?  If it's only one of them, you run the risk of under
accounting when that socket leaves the group.  If you charge all of
them you end up over-accounting and introduce all kinds of partial
failure paths.  Another alternative would be to mirror one of the sk
memory properties (omem?) in the sock_reuseport structure.  That is,
have an accounting variable similar to sk_omem_alloc (with a max of
sysctl_optmem_max) which is changed each time the reuseport bpf
program is manipulated.  I'd definitely be interested in ideas for a
follow-on patch if you have any.

> Nit: return bpf_prepare_filter(prog, NULL);
ACK -> v3

> Rest of BPF bits look good to me.
Thank you!
