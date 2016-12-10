From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 net-next 1/8] lib bpf: Add support for BPF_PROG_ATTACH
 and BPF_PROG_DETACH
Date: Sat, 10 Dec 2016 22:21:52 +0100
Message-ID: <584C71F0.3000203@iogearbox.net>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com> <1481401934-4026-2-git-send-email-dsa@cumulusnetworks.com> <584C70C0.8040506@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34558 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbcLJVVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 16:21:54 -0500
In-Reply-To: <584C70C0.8040506@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2016 10:16 PM, Daniel Borkmann wrote:
> On 12/10/2016 09:32 PM, David Ahern wrote:
>> For consistency with other bpf commands, the functions are named
>> bpf_prog_attach and bpf_prog_detach. The existing bpf_prog_attach is
>> renamed to bpf_prog_load_and_report since it calls bpf_prog_load and
>> bpf_prog_report.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>   include/bpf_util.h |  3 +++
>>   lib/bpf.c          | 31 ++++++++++++++++++++++++++-----
>>   2 files changed, 29 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/bpf_util.h b/include/bpf_util.h
>> index 05baeecda57f..49b96bbc208f 100644
>> --- a/include/bpf_util.h
>> +++ b/include/bpf_util.h
>> @@ -75,6 +75,9 @@ int bpf_trace_pipe(void);
>>
>>   void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
>>
>> +int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type);
>> +int bpf_prog_detach(int target_fd, enum bpf_attach_type type);
>> +
>>   #ifdef HAVE_ELF
>>   int bpf_send_map_fds(const char *path, const char *obj);
>>   int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
>> diff --git a/lib/bpf.c b/lib/bpf.c
>> index 2a8cd51d4dae..103fc1ef0593 100644
>> --- a/lib/bpf.c
>> +++ b/lib/bpf.c
>> @@ -850,6 +850,27 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
>>       return ret;
>>   }
>>
>> +int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
>> +{
>> +    union bpf_attr attr = {
>> +        .target_fd = target_fd,
>> +        .attach_bpf_fd = prog_fd,
>> +        .attach_type = type,
>> +    };
>
> Please make this consistent with the other bpf(2) cmds we
> have in the current lib code. There were some gcc issues in
> the past, see:
>
> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=67584e3ab289a22eb9a2e51f90d23e2ced2e76b0
>
> F.e. bpf_map_create() currently looks like:
>
>      union bpf_attr attr = {};
>
>      attr.map_type = type;
>      attr.key_size = size_key;
>      attr.value_size = size_value;
>      attr.max_entries = max_elem;
>      attr.map_flags = flags;
>
>> +    return bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
>> +}
>> +
>> +int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
>> +{
>> +    union bpf_attr attr = {
>> +        .target_fd = target_fd,
>> +        .attach_type = type,
>> +    };
>
> Ditto.
>
>> +    return bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
>> +}
>> +
>>   #ifdef HAVE_ELF
>>   struct bpf_elf_prog {
>>       enum bpf_prog_type    type;
>> @@ -1262,9 +1283,9 @@ static void bpf_prog_report(int fd, const char *section,
>>       bpf_dump_error(ctx, "Verifier analysis:\n\n");
>>   }
>>
>> -static int bpf_prog_attach(const char *section,
>> -               const struct bpf_elf_prog *prog,
>> -               struct bpf_elf_ctx *ctx)
>> +static int bpf_prog_load_and_report(const char *section,
>> +                    const struct bpf_elf_prog *prog,
>> +                    struct bpf_elf_ctx *ctx)
>>   {
>
> Please name it bpf_prog_create() then, it would be consistent to
> bpf_map_create() and shorter as well.

Sorry, lack of coffee, scratch that.

Can't the current bpf_prog_attach() stay as is, and you name the above new
functions bpf_prog_attach_fd() and bpf_prog_detach_fd()? I think that would
be better.

>>       int tries = 0, fd;
>>   retry:
>> @@ -1656,7 +1677,7 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section,
>>           prog.size    = data.sec_data->d_size;
>>           prog.license = ctx->license;
>>
>> -        fd = bpf_prog_attach(section, &prog, ctx);
>> +        fd = bpf_prog_load_and_report(section, &prog, ctx);
>>           if (fd < 0)
>>               return fd;
>>
>> @@ -1755,7 +1776,7 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
>>           prog.size    = data_insn.sec_data->d_size;
>>           prog.license = ctx->license;
>>
>> -        fd = bpf_prog_attach(section, &prog, ctx);
>> +        fd = bpf_prog_load_and_report(section, &prog, ctx);
>>           if (fd < 0) {
>>               *lderr = true;
>>               return fd;
>>
>
