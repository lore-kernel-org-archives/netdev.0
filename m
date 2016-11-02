From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 3/3] tools lib bpf: Sync bpf_map_def with tc
Date: Tue, 1 Nov 2016 21:09:28 -0700
Message-ID: <CAPWQB7GxA+imikeJEJ-JZVm+qWONM1Ronj7ucf0=QRBbrPM06g@mail.gmail.com>
References: <20161031183917.9938-1-joe@ovn.org> <20161031183917.9938-4-joe@ovn.org>
 <581958D1.3010209@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53450 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbcKBEJz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 00:09:55 -0400
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 3935C1720A9
        for <netdev@vger.kernel.org>; Wed,  2 Nov 2016 05:09:53 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 97zTf_y0iYeu for <netdev@vger.kernel.org>;
        Wed,  2 Nov 2016 05:09:51 +0100 (CET)
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 7ABB2172094
        for <netdev@vger.kernel.org>; Wed,  2 Nov 2016 05:09:50 +0100 (CET)
Received: by mail-oi0-f42.google.com with SMTP id v84so4271463oie.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 21:09:50 -0700 (PDT)
In-Reply-To: <581958D1.3010209@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 20:09, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/31/2016 07:39 PM, Joe Stringer wrote:
>>
>> TC uses a slightly different map layout in its ELFs. Update libbpf to
>> use the same definition so that ELFs may be built using libbpf and
>> loaded using tc.
>>
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> ---
>>   tools/lib/bpf/libbpf.h | 11 +++++++----
>>   1 file changed, 7 insertions(+), 4 deletions(-)
>>
>> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
>> index dd7a513efb10..ea70c2744f8c 100644
>> --- a/tools/lib/bpf/libbpf.h
>> +++ b/tools/lib/bpf/libbpf.h
>> @@ -181,10 +181,13 @@ bool bpf_program__is_kprobe(struct bpf_program
>> *prog);
>>    * and will be treated as an error due to -Werror.
>>    */
>>   struct bpf_map_def {
>> -       unsigned int type;
>> -       unsigned int key_size;
>> -       unsigned int value_size;
>> -       unsigned int max_entries;
>> +       uint32_t type;
>> +       uint32_t key_size;
>> +       uint32_t value_size;
>> +       uint32_t max_entries;
>> +       uint32_t flags;
>> +       uint32_t id;
>> +       uint32_t pinning;
>>   };
>>
>>   /*
>
>
> I think the problem is that this would break existing obj files that have
> been compiled with the current struct bpf_map_def (besides libbpf not having
> a use for the last two members right now).

Right, this is a problem. I wasn't sure whether libbpf was yet at a
stage where it tries to retain compatibility with binaries compiled
against older kernels.

> For tc, we have a refactoring of the tc_bpf.c bits that generalizes them so
> we can move these bits into iproute2 lib part and add new BPF types really
> easily. What I did along with that is to implement a map compat mode, where
> it detects the size of struct bpf_elf_map (or however you want to name it)
> from the obj file and fixes up the missing members with some reasonable
> default,
> so these programs can still be loaded. Thus, the sample code using the
> current
> struct bpf_map_def will then work with tc as well. (I'll post the iproute2
> patch early next week.)

Are you encoding the number of maps into the start of the maps section
in the ELF then using that to divide out and determine the size?

I look forward to your patches. Maybe if TC is more tolerant of other
map definition sizes then this patch is less relevant.
