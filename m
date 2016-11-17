From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCHv2 perf/core 2/2] tools lib bpf: Sync with samples/bpf/libbpf
Date: Wed, 16 Nov 2016 18:46:25 -0800
Message-ID: <CAOftzPhXk0LKCt8wQKuqeBnDrj6a4p0YL7P80jhK78eFSAz8WQ@mail.gmail.com>
References: <20161116174324.29675-1-joe@ovn.org> <20161116174324.29675-3-joe@ovn.org>
 <582D11B0.80208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joe@ovn.org>, LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <582D11B0.80208@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 November 2016 at 18:10, Wangnan (F) <wangnan0@huawei.com> wrote:
> I'm also working on improving bpf.c. Please have a look at:
>
> https://lkml.org/lkml/2016/11/14/1078
>
> Since bpf.c is simple, I think we can add more functions and fixes
> gradually, instead of a full copy.
>
> See my inline comment below.

Ah, I missed this, my apologies. It looks like it will provide much of
what I need, I can reassess this patch with your series in mind.

One comment though for your patch (I don't have the original thread to
respond to unfortunately): The map_pin and map_get functions in your
patch series can be used to pin progs too, so maybe there is a better
name? You'll see that this patch uses bpf_obj_{pin,get}() - although I
wouldn't want those to be confused with the libbpf.c objects so maybe
there's a clearer name that could be used.

I also have some patches to rework the samples/bpf/* code to use
libbpf instead of the sample code that is there, is it worth me
submitting that? It will need to wait for your patch to go in, plus a
merge with davem's tree.

>
> On 2016/11/17 1:43, Joe Stringer wrote:
>>
>> Extend the tools/ version of libbpf to include all of the functionality
>> provided in the samples/bpf version.
>>
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> ---
>> v2: Don't shift non-bpf changes across.
>>      Various type cleanups, removal of extraneous declarations
>> ---
>>   tools/lib/bpf/bpf.c    | 107 ++++++++++++++++++++------
>>   tools/lib/bpf/bpf.h    | 202
>> +++++++++++++++++++++++++++++++++++++++++++++++--
>>   tools/lib/bpf/libbpf.c |   3 +-
>>   3 files changed, 279 insertions(+), 33 deletions(-)
>>
>> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
>> index 4212ed62235b..5e061851ac00 100644
>> --- a/tools/lib/bpf/bpf.c
>> +++ b/tools/lib/bpf/bpf.c
>> @@ -20,10 +20,17 @@
>>    */
>>     #include <stdlib.h>
>> -#include <memory.h>
>> +#include <stdio.h>
>>   #include <unistd.h>
>>   #include <asm/unistd.h>
>> +#include <string.h>
>> +#include <linux/netlink.h>
>>   #include <linux/bpf.h>
>> +#include <errno.h>
>> +#include <net/ethernet.h>
>> +#include <net/if.h>
>> +#include <linux/if_packet.h>
>> +#include <arpa/inet.h>
>>   #include "bpf.h"
>>
>
>
> Why we need these network related headers?

I started with a copy/paste, assuming that the headers were all in use
but I guess that assumption was wrong.

>>   /*
>> @@ -53,24 +60,71 @@ static int sys_bpf(enum bpf_cmd cmd, union bpf_attr
>> *attr,
>>         return syscall(__NR_bpf, cmd, attr, size);
>>   }
>>   -int bpf_create_map(enum bpf_map_type map_type, int key_size,
>> -                  int value_size, int max_entries)
>> +int bpf_create_map(enum bpf_map_type map_type, int key_size, int
>> value_size,
>> +                  int max_entries, int map_flags)
>>   {
>> -       union bpf_attr attr;
>> +       union bpf_attr attr = {
>> +               .map_type = map_type,
>> +               .key_size = key_size,
>> +               .value_size = value_size,
>> +               .max_entries = max_entries,
>> +               .map_flags = map_flags,
>> +       };
>>   -     memset(&attr, '\0', sizeof(attr));
>> +       return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
>> +}
>>
>
>
> I lost map_flags in original bpf.c. Thanks to your patch. map_flags is
> useful
> when creating BPF_MAP_TYPE_PERCPU_HASH: BPF_F_NO_PREALLOC is meanful in this
> case.

Do you want me to resubmit this piece as a separate patch or will you
address this?

> Although it is okay in samples, I still prefer a explicit bzero() or
> memset(),
> because kernel checks if unused field in this union is zero. However I'll
> check
> c standard to see how unused field would be initialized.

OK.

>> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
>> index e8ba54087497..4dba36995771 100644
>> --- a/tools/lib/bpf/bpf.h
>> +++ b/tools/lib/bpf/bpf.h
>> @@ -23,16 +23,202 @@
>>     #include <linux/bpf.h>
>>   +struct bpf_insn;
>> +
>>   int bpf_create_map(enum bpf_map_type map_type, int key_size, int
>> value_size,
>> -                  int max_entries);
>> +                  int max_entries, int map_flags);
>> +int bpf_update_elem(int fd, void *key, void *value, unsigned long long
>> flags);
>> +int bpf_lookup_elem(int fd, void *key, void *value);
>> +int bpf_delete_elem(int fd, void *key);
>> +int bpf_get_next_key(int fd, void *key, void *next_key);
>> +
>> +int bpf_load_program(enum bpf_prog_type prog_type,
>> +                    const struct bpf_insn *insns, int insn_len,
>> +                    const char *license, int kern_version,
>> +                    char *log_buf, size_t log_buf_sz);
>> +
>> +int bpf_obj_pin(int fd, const char *pathname);
>> +int bpf_obj_get(const char *pathname);
>>   -/* Recommend log buffer size */
>>   #define BPF_LOG_BUF_SIZE 65536
>> -int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
>> -                    size_t insns_cnt, char *license,
>> -                    u32 kern_version, char *log_buf,
>> -                    size_t log_buf_sz);
>>   -int bpf_map_update_elem(int fd, void *key, void *value,
>> -                       u64 flags);
>> +/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
>> +
>> +#define BPF_ALU64_REG(OP, DST, SRC)                            \
>> +       ((struct bpf_insn) {                                    \
>> +               .code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,        \
>> +               .dst_reg = DST,                                 \
>> +               .src_reg = SRC,                                 \
>> +               .off   = 0,                                     \
>> +               .imm   = 0 })
>> +
>
>
> Should we define these macros here? They are in include/linux/filter.h
> and duplicated in tools/include/linux/filter.h. Redefining them here
> would cause conflict.

Probably not; including the correct header file would be sufficient.
