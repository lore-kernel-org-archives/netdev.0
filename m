From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] bpf, array: fix heap out-of-bounds access when
 updating elements
Date: Tue, 1 Dec 2015 10:38:07 +0100
Message-ID: <CACT4Y+av=tbWXWRdvtpVE0NJKb+Uki=OZmYLqoET6+O_jvXt7A@mail.gmail.com>
References: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
 <20151130182946.GB30762@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33391 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553AbbLAJi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 04:38:27 -0500
Received: by wmec201 with SMTP id c201so196032359wme.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 01:38:26 -0800 (PST)
In-Reply-To: <20151130182946.GB30762@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 7:29 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Nov 30, 2015 at 01:02:55PM +0100, Daniel Borkmann wrote:
>> During own review but also reported by Dmitry's syzkaller [1] it has been
>> noticed that we trigger a heap out-of-bounds access on eBPF array maps
>> when updating elements. This happens with each map whose map->value_size
>> (specified during map creation time) is not multiple of 8 bytes.
> ...
>> In case of array_map_lookup_elem(), the verifier prevents eBPF programs
>> from accessing beyond map->value_size through check_map_access(). Also
>> from syscall side map_lookup_elem() only copies map->value_size back to
>> user, so nothing could leak.
>>
>>   [1] http://github.com/google/syzkaller
>>
>> Fixes: 28fbcfa08d8e ("bpf: add array type of eBPF maps")
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Dmitry, thanks a lot for applying syzkaller to bpf. The issues
> got cought much sooner than they would have been discovered otherwise.
> Looks like the fuzzing has limited dependency chains described
> in sys/sys.txt. Can they be improved into doing something like:
> single call to map_create followed by many calls to update to
> stress oom ? I did it manually so far without kasan.

Hi Alexei,

Please elaborate.
sys.txt describes signatures of syscalls. Based on that syzkaller
generates programs that can contain a map_create call followed by
multiple map update calls. Though, it won't generate millions of
update calls on a single map, because it directly conflicts with the
idea of coverage guided fuzzing. For OOMs I guess you want to try
kmalloc fault injection.
