From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: [PATCH net-next] ebpf: move CONFIG_BPF_SYSCALL-only function
 declarations
Date: Tue, 03 Mar 2015 12:12:52 +0900
Message-ID: <54F526B4.8060506@hitachi.com>
References: <CAMEtUuw+6j5uNCxV7M7HXm_GUha9Dpk6Y-h6ey0yMQ+7Z_Wa4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:52029 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbbCCDM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 22:12:59 -0500
In-Reply-To: <CAMEtUuw+6j5uNCxV7M7HXm_GUha9Dpk6Y-h6ey0yMQ+7Z_Wa4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2015/03/03 2:35), Alexei Starovoitov wrote:
> On Mon, Mar 2, 2015 at 6:21 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Masami noted that it would be better to hide the remaining CONFIG_BPF_SYSCALL-only
>> function declarations within the BPF header ifdef, w/o else path dummy alternatives
>> since these functions are not supposed to have a user outside of CONFIG_BPF_SYSCALL.
> 
> So far we didn't have anyone trying to add new map types
> outside of kernel/bpf/, so this patch is a defensive move.
> Such potential future abuser will get compile error for
> missing bpf_register_map_type() instead of linker error for the same.
> Not sure that's really needed.
> Also bpf_map_put() and bpf_map_get() are only used
> by bpf syscall and verifier. imo moving them under ifdef is overkill.

No, not overkill. This patch becomes good description about the code to
reader who learns the eBPF. It tells them what functions are provided
when the kconfig is set or not.

And compiler error is better since abuser would get it before
compiling all other object :)

> I think ifdef should only be used for function that have
> real and dummy bodies.
> Today we have three:
> bpf_register_prog_type(), bpf_prog_get() and bpf_prog_put()
> and that makes sense.
> 
> Hiding *map*() functions seems unnecessary.
> I think linker error is good enough.

But, then, why we need to move ONLY bpf_prog* functions?
I just thought it was half-way.

Thank you,

> 
>> Suggested-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
>> Reference: http://article.gmane.org/gmane.linux.kernel.api/8658
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>  include/linux/bpf.h | 18 +++++++++---------
>>  1 file changed, 9 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index a1a7ff2..a884f5a 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -42,10 +42,6 @@ struct bpf_map_type_list {
>>         enum bpf_map_type type;
>>  };
>>
>> -void bpf_register_map_type(struct bpf_map_type_list *tl);
>> -void bpf_map_put(struct bpf_map *map);
>> -struct bpf_map *bpf_map_get(struct fd f);
>> -
>>  /* function argument constraints */
>>  enum bpf_arg_type {
>>         ARG_ANYTHING = 0,       /* any argument is ok */
>> @@ -126,9 +122,16 @@ struct bpf_prog_aux {
>>
>>  #ifdef CONFIG_BPF_SYSCALL
>>  void bpf_register_prog_type(struct bpf_prog_type_list *tl);
>> +void bpf_register_map_type(struct bpf_map_type_list *tl);
>>
>> -void bpf_prog_put(struct bpf_prog *prog);
>>  struct bpf_prog *bpf_prog_get(u32 ufd);
>> +void bpf_prog_put(struct bpf_prog *prog);
>> +
>> +struct bpf_map *bpf_map_get(struct fd f);
>> +void bpf_map_put(struct bpf_map *map);
>> +
>> +/* verify correctness of eBPF program */
>> +int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
>>  #else
>>  static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
>>  {
>> @@ -142,10 +145,7 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
>>  static inline void bpf_prog_put(struct bpf_prog *prog)
>>  {
>>  }
>> -#endif
>> -
>> -/* verify correctness of eBPF program */
>> -int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
>> +#endif /* CONFIG_BPF_SYSCALL */
>>
>>  /* verifier prototypes for helper functions called from eBPF programs */
>>  extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
>> --
>> 1.9.3
>>
> 


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
