From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 2/3] tools lib bpf: Sync with samples/bpf/libbpf
Date: Tue, 1 Nov 2016 20:50:10 -0700
Message-ID: <CAPWQB7H_O_L2_Jfewb4UuBoh+fst64cmJqdh2KtjHYoZeC4t+A@mail.gmail.com>
References: <20161031183917.9938-1-joe@ovn.org> <20161031183917.9938-3-joe@ovn.org>
 <58195506.8040205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:52496 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbcKBDuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 23:50:35 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 5EAF317209F
        for <netdev@vger.kernel.org>; Wed,  2 Nov 2016 04:50:33 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id lbmfi4Kkx44u for <netdev@vger.kernel.org>;
        Wed,  2 Nov 2016 04:50:31 +0100 (CET)
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id B2D7C172095
        for <netdev@vger.kernel.org>; Wed,  2 Nov 2016 04:50:31 +0100 (CET)
Received: by mail-oi0-f50.google.com with SMTP id 62so3981085oif.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 20:50:31 -0700 (PDT)
In-Reply-To: <58195506.8040205@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 19:52, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/31/2016 07:39 PM, Joe Stringer wrote:
>>
>> Extend the tools/ version of libbpf to include all of the functionality
>> provided in the samples/bpf version.
>>
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> ---
>>   tools/lib/bpf/bpf.c    | 139 +++++++++++++++++++++++++++------
>>   tools/lib/bpf/bpf.h    | 208
>> +++++++++++++++++++++++++++++++++++++++++++++++--
>>   tools/lib/bpf/libbpf.c |   3 +-
>>   3 files changed, 317 insertions(+), 33 deletions(-)
>>
> [...]
>
>> +int open_raw_sock(const char *name)
>> +{
>> +       struct sockaddr_ll sll;
>> +       int sock;
>> +
>> +       sock = socket(PF_PACKET, SOCK_RAW | SOCK_NONBLOCK | SOCK_CLOEXEC,
>> +                     htons(ETH_P_ALL));
>> +       if (sock < 0) {
>> +               printf("cannot create raw socket\n");
>> +               return -1;
>> +       }
>> +
>> +       memset(&sll, 0, sizeof(sll));
>> +       sll.sll_family = AF_PACKET;
>> +       sll.sll_ifindex = if_nametoindex(name);
>> +       sll.sll_protocol = htons(ETH_P_ALL);
>> +       if (bind(sock, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
>> +               printf("bind to %s: %s\n", name, strerror(errno));
>> +               close(sock);
>> +               return -1;
>> +       }
>> +
>> +       return sock;
>> +}
>> +
>> +int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
>> +                   int group_fd, unsigned long flags)
>> +{
>> +       return syscall(__NR_perf_event_open, attr, pid, cpu,
>> +                      group_fd, flags);
>>   }
>
>
> I'm actually wondering, above bits are not really libbpf related. Maybe
> these should go elsewhere into some other misc header file just for the
> samples to use?

True, I started this patch by just copying the whole file over to
tools/lib/bpf so this came with it. I can bring it back to the samples
directory in v2.

>> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
>> index e8ba54087497..227edb23c022 100644
>> --- a/tools/lib/bpf/bpf.h
>> +++ b/tools/lib/bpf/bpf.h
>> @@ -23,16 +23,208 @@
>>
>>   #include <linux/bpf.h>
>>
>> +struct bpf_insn;
>> +
>
>
> Isn't that already defined in the above uapi bpf.h anyway?

Yup, I'll drop this bit.
