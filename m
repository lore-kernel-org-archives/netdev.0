From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Sun, 7 Sep 2014 17:17:04 -0700
Message-ID: <CAMEtUuzO5HyWhnx7Ns+z25WE8uFi9Wz5PH4o8R6RN1F3UezAfA@mail.gmail.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
	<1409996567-2170-2-git-send-email-dborkman@redhat.com>
	<20140907.161543.2206530539028176158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36419 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbaIHARG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 20:17:06 -0400
Received: by mail-wg0-f45.google.com with SMTP id z12so369192wgg.28
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 17:17:04 -0700 (PDT)
In-Reply-To: <20140907.161543.2206530539028176158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 7, 2014 at 4:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Sat,  6 Sep 2014 11:42:45 +0200
>
>> While reviewing the code, I think on s390, the alignment masking
>> seems not to be correct in it's current form, that is, we make sure
>> the first instruction starts at an even address as stated by commit
>> aa2d2c73c21f but masks the start with '& -2' while 2 byte-alignment
>> should rather be '& ~1'.
>
> Both -2 and ~1 are the same value.

oops. you're right. commit log is incorrect.

The new code makes the logic more clear:
in s390:
- *image_ptr = &header->image[(prandom_u32() % hole) & -2];
+ header = bpf_jit_binary_alloc(size, &jit.start, 2, bpf_jit_fill_hole);

and in bpf/core.c:
+struct bpf_binary_header *
+bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
+                    unsigned int alignment,
+                    bpf_jit_fill_hole_t bpf_fill_ill_insns)
+{
...
+       start = (prandom_u32() % hole) & ~(alignment - 1);

we'll fix the commit log and resubmit.
Thx
