From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Date: Wed, 25 Jan 2017 21:16:42 +0100
Message-ID: <588907AA.1020704@iogearbox.net>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        linux-mm <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Michal Hocko <mhocko@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2017 07:14 PM, Alexei Starovoitov wrote:
> On Wed, Jan 25, 2017 at 5:21 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Wed 25-01-17 14:10:06, Michal Hocko wrote:
>>> On Tue 24-01-17 11:17:21, Alexei Starovoitov wrote:
[...]
>>>>> Are there any more comments? I would really appreciate to hear from
>>>>> networking folks before I resubmit the series.
>>>>
>>>> while this patchset was baking the bpf side switched to use bpf_map_area_alloc()
>>>> which fixes the issue with missing __GFP_NORETRY that we had to fix quickly.
>>>> See commit d407bd25a204 ("bpf: don't trigger OOM killer under pressure with map alloc")
>>>> it covers all kmalloc/vmalloc pairs instead of just one place as in this set.
>>>> So please rebase and switch bpf_map_area_alloc() to use kvmalloc().
>>>
>>> OK, will do. Thanks for the heads up.
>>
>> Just for the record, I will fold the following into the patch 1
>> ---
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index 19b6129eab23..8697f43cf93c 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -53,21 +53,7 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
>>
>>   void *bpf_map_area_alloc(size_t size)
>>   {
>> -       /* We definitely need __GFP_NORETRY, so OOM killer doesn't
>> -        * trigger under memory pressure as we really just want to
>> -        * fail instead.
>> -        */
>> -       const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
>> -       void *area;
>> -
>> -       if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
>> -               area = kmalloc(size, GFP_USER | flags);
>> -               if (area != NULL)
>> -                       return area;
>> -       }
>> -
>> -       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
>> -                        PAGE_KERNEL);
>> +       return kvzalloc(size, GFP_USER);
>>   }
>>
>>   void bpf_map_area_free(void *area)
>
> Looks fine by me.
> Daniel, thoughts?

I assume that kvzalloc() is still the same from [1], right? If so, then
it would unfortunately (partially) reintroduce the issue that was fixed.
If you look above at flags, they're also passed to __vmalloc() to not
trigger OOM in these situations I've experienced. This is effectively the
same requirement as in other networking areas f.e. that 5bad87348c70
("netfilter: x_tables: avoid warn and OOM killer on vmalloc call") has.
In your comment in kvzalloc() you eventually say that some of the above
modifiers are not supported. So there would be two options, i) just leave
out the kvzalloc() chunk for BPF area to avoid the merge conflict and tackle
it later (along with similar code from 5bad87348c70), or ii) implement
support for these modifiers as well to your original set. I guess it's not
too urgent, so we could also proceed with i) if that is easier for you to
proceed (I don't mind either way).

Thanks a lot,
Daniel

   [1] https://lkml.org/lkml/2017/1/12/442
