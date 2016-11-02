From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] tools lib bpf: Sync bpf_map_def with tc
Date: Wed, 02 Nov 2016 15:12:49 +0100
Message-ID: <5819F461.7050309@iogearbox.net>
References: <20161031183917.9938-1-joe@ovn.org> <20161031183917.9938-4-joe@ovn.org> <581958D1.3010209@iogearbox.net> <CAPWQB7GxA+imikeJEJ-JZVm+qWONM1Ronj7ucf0=QRBbrPM06g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com, ast@fb.com
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54181 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752677AbcKBOM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 10:12:57 -0400
In-Reply-To: <CAPWQB7GxA+imikeJEJ-JZVm+qWONM1Ronj7ucf0=QRBbrPM06g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2016 05:09 AM, Joe Stringer wrote:
> On 1 November 2016 at 20:09, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 10/31/2016 07:39 PM, Joe Stringer wrote:
>>>
>>> TC uses a slightly different map layout in its ELFs. Update libbpf to
>>> use the same definition so that ELFs may be built using libbpf and
>>> loaded using tc.
>>>
>>> Signed-off-by: Joe Stringer <joe@ovn.org>
>>> ---
>>>    tools/lib/bpf/libbpf.h | 11 +++++++----
>>>    1 file changed, 7 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
>>> index dd7a513efb10..ea70c2744f8c 100644
>>> --- a/tools/lib/bpf/libbpf.h
>>> +++ b/tools/lib/bpf/libbpf.h
>>> @@ -181,10 +181,13 @@ bool bpf_program__is_kprobe(struct bpf_program
>>> *prog);
>>>     * and will be treated as an error due to -Werror.
>>>     */
>>>    struct bpf_map_def {
>>> -       unsigned int type;
>>> -       unsigned int key_size;
>>> -       unsigned int value_size;
>>> -       unsigned int max_entries;
>>> +       uint32_t type;
>>> +       uint32_t key_size;
>>> +       uint32_t value_size;
>>> +       uint32_t max_entries;
>>> +       uint32_t flags;
>>> +       uint32_t id;
>>> +       uint32_t pinning;
>>>    };
>>>
>>>    /*
>>
>> I think the problem is that this would break existing obj files that have
>> been compiled with the current struct bpf_map_def (besides libbpf not having
>> a use for the last two members right now).
>
> Right, this is a problem. I wasn't sure whether libbpf was yet at a
> stage where it tries to retain compatibility with binaries compiled
> against older kernels.
>
>> For tc, we have a refactoring of the tc_bpf.c bits that generalizes them so
>> we can move these bits into iproute2 lib part and add new BPF types really
>> easily. What I did along with that is to implement a map compat mode, where
>> it detects the size of struct bpf_elf_map (or however you want to name it)
>> from the obj file and fixes up the missing members with some reasonable
>> default,
>> so these programs can still be loaded. Thus, the sample code using the
>> current
>> struct bpf_map_def will then work with tc as well. (I'll post the iproute2
>> patch early next week.)
>
> Are you encoding the number of maps into the start of the maps section
> in the ELF then using that to divide out and determine the size?

No. It's walking the symbol table and simply counts the number of symbols
that are present in the maps section with correct st_info attribution. It
works because that section name is fixed ABI for all cases and really per
definition only map structs are present there. The minimum attributes which
are allowed to be loaded are type, key_size, value_size and max_entries.

> I look forward to your patches. Maybe if TC is more tolerant of other
> map definition sizes then this patch is less relevant.
