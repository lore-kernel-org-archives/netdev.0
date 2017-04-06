From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH 20/24] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Thu, 6 Apr 2017 13:40:20 +0100
Message-ID: <CAKv+Gu_mWJ2LwPqokWmCG4nmKJHrdQ1qHdM8xTvUziJh3GP+JA@mail.gmail.com>
References: <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk>
 <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk> <20170406122907.GA53880@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Howells <dhowells@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>,
        One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Chun-Yi Lee <jlee@suse.com>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        keyrings@vger.kernel.org,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        Matthew Garrett <matthew.garrett@nebula.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33208 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755203AbdDFMkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:40:21 -0400
Received: by mail-io0-f172.google.com with SMTP id f84so28495878ioj.0
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 05:40:21 -0700 (PDT)
In-Reply-To: <20170406122907.GA53880@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 April 2017 at 13:29, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Apr 05, 2017 at 09:17:25PM +0100, David Howells wrote:
>> From: Chun-Yi Lee <jlee@suse.com>
>>
>> There are some bpf functions can be used to read kernel memory:
>> bpf_probe_read, bpf_probe_write_user and bpf_trace_printk.  These allow
>> private keys in kernel memory (e.g. the hibernation image signing key) to
>> be read by an eBPF program.  Prohibit those functions when the kernel is
>> locked down.
>>
>> Signed-off-by: Chun-Yi Lee <jlee@suse.com>
>> Signed-off-by: David Howells <dhowells@redhat.com>
>> cc: netdev@vger.kernel.org
>> ---
>>
>>  kernel/trace/bpf_trace.c |   11 +++++++++++
>>  1 file changed, 11 insertions(+)
>>
>> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
>> index cee9802cf3e0..7fde851f207b 100644
>> --- a/kernel/trace/bpf_trace.c
>> +++ b/kernel/trace/bpf_trace.c
>> @@ -65,6 +65,11 @@ BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
>>  {
>>       int ret;
>>
>> +     if (kernel_is_locked_down()) {
>> +             memset(dst, 0, size);
>> +             return -EPERM;
>> +     }
>
> this will obviously break the program. How about disabling loading tracing
> programs during the lockdown completely?
>
> Also is there a description of what this lockdown trying to accomplish?
> The cover letter is scarce in details.
>

This is a very good point, and this is actually feedback that was
given (by Alan Cox, iirc) the last time this series was circulated.

This series is a mixed bag of patches that all look like they improve
'security' in one way or the other. But what is lacking is a coherent
view on the threat model, and to what extent all these patches reduce
the vulnerability to such threats. Without that, these patches do very
little beyond giving a false sense of security, imo.
