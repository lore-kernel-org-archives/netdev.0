From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH v2 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Fri, 3 Feb 2017 13:10:46 -0800
Message-ID: <CALDO+SYvAVbXCmMRca0jq7XxMYvQ0VJ0joNGpPLWRTEg=H4a6Q@mail.gmail.com>
References: <1486142565-2794-1-git-send-email-u9012063@gmail.com> <20170203205513.GA24959@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Mihai Budiu <mbudiu@vmware.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33507 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbdBCVL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:11:27 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so2820222itc.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:11:27 -0800 (PST)
In-Reply-To: <20170203205513.GA24959@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

why it is bogus? on my system, it fails without the patch applied.

--William

On Fri, Feb 3, 2017 at 12:55 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Feb 03, 2017 at 09:22:45AM -0800, William Tu wrote:
>> The patch fixes the case when adding a zero value to the packet
>> pointer.  The verifer reports the following error:
>>   [...]
>>     R0=imm0,min_value=0,max_value=0
>>     R1=pkt(id=0,off=0,r=4)
>>     R2=pkt_end R3=fp-12
>>     R4=imm4,min_value=4,max_value=4
>>     R5=pkt(id=0,off=4,r=4)
>>   269: (bf) r2 = r0   // r2 becomes imm0
>>   270: (77) r2 >>= 3
>>   271: (bf) r4 = r1   // r4 becomes pkt ptr
>>   272: (0f) r4 += r2  // r4 += 0
>>   addition of negative constant to packet pointer is not allowed
>>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Signed-off-by: Mihai Budiu <mbudiu@vmware.com>
>> ---
>>  kernel/bpf/verifier.c                       |  2 +-
>>  tools/testing/selftests/bpf/test_verifier.c | 15 +++++++++++++++
>>  2 files changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> index fb3513b..1a754e5 100644
>> --- a/kernel/bpf/verifier.c
>> +++ b/kernel/bpf/verifier.c
>> @@ -1397,7 +1397,7 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
>>               imm = insn->imm;
>>
>>  add_imm:
>> -             if (imm <= 0) {
>> +             if (imm < 0) {
>>                       verbose("addition of negative constant to packet pointer is not allowed\n");
>>                       return -EACCES;
>>               }
>> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
>> index 0d0912c..a2b5c7e 100644
>> --- a/tools/testing/selftests/bpf/test_verifier.c
>> +++ b/tools/testing/selftests/bpf/test_verifier.c
>> @@ -2404,6 +2404,21 @@ static struct bpf_test tests[] = {
>>               .prog_type = BPF_PROG_TYPE_SCHED_CLS,
>>       },
>>       {
>> +             "direct packet access: test14 (pkt_ptr += 0, good access)",
>> +             .insns = {
>> +                     BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
>> +                                 offsetof(struct __sk_buff, data)),
>> +                     BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
>> +                                 offsetof(struct __sk_buff, data_end)),
>> +                     BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
>> +                     BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0),
>
> wait. the test is bogus.
> please write the proper test for the feature
> and check that it fails before the patch and passes afterwards.
>
>> +                     BPF_MOV64_IMM(BPF_REG_0, 1),
>> +                     BPF_EXIT_INSN(),
>> +             },
>> +             .result = ACCEPT,
>> +             .prog_type = BPF_PROG_TYPE_SCHED_CLS,
>> +     },
>> +     {
>>               "helper access to packet: test1, valid packet_ptr range",
>>               .insns = {
>>                       BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
>> --
>> 2.7.4
>>
