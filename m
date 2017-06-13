From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Tue, 13 Jun 2017 12:26:47 +0530
Message-ID: <CAHgaXdJrvKdzr3fJ1TMkC4foeVsZJDSVEwhDOeZGxQVsmoK2cQ@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com>
 <593E6B0F.8070901@iogearbox.net> <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel, Kees, David, Russel,

>> Any plans to implement above especially BPF_JMP | BPF_CALL in near future?
>> Reason why I'm asking is that i) currently the arm32 cBPF JIT implements
>> all of the cBPF extensions (except SKF_AD_RANDOM and SKF_AD_VLAN_TPID).
>> Some of the programs that were JITed before e.g. using SKF_AD_CPU would now
>> fall back to the eBPF interpreter due to lack of translation in JIT, but
>> also ii) that probably most (if not all) of eBPF programs use BPF helper
>> calls heavily, which will still redirect them to the interpreter right now
>> due to lack of BPF_JMP | BPF_CALL support, so it's really quite essential
>> to have it implemented.
>
> I can try for BPF_JMP | BPF_CALL. I didn't do it last time because I
> thought, it would make the code look messy and become pain to get it
> through the review.
> For this, I have to map eBPF arguments with arm ABI arguments and move
> ebpf arguments to corresponding arm ABI arguments, as eBPF arguments
> doesn't match with arm ABI arguments.
> Let me try that if its possible.

Okay. I looked at it, tried few different solutions also. There is a
problem with implementing BPF_JMP | BPF_CALL.
Problem is transition between 4 byte and 8 byte arguments. Lets take a
look a the following example to get a more clear look at the problem.

Lets consider this function :
CASE 1:                            foo(int a, int b, long long c, int d)
For calling this function in arm 32 arch, I have to pass the arguments
as following:
                                         a -> r0
                                         b -> r1
                                         c -> r2, r3
                                         d -> stack_top

Now consider an another example function :
CASE 2:                           bar(int a, int b, int c, int d)
For calling this function in arm32 arch, I have to pass the arguments
as following:
                                       a -> r0
                                       b -> r1
                                       c -> r2
                                       d -> r3

So, you can clearly see the problem with it. There is no way of
knowing which of the above way to pass the arguments. There are
solutions possible:

1. One thing I can do is look at the address of the function to call
and pass the argument accordingly but thats not really a robust
solution as we have to change the arm32 JIT each time we add any new
BPF helper function.

2. Another solution is, if any of you guys can assure/confirm me that
there will be only 4 byte argument passed to BPF helper functions in
arm32 as of now and in future including the pointer as well, then I
can just assume that each argument is passed as 4 byte value and my
trimming the 8byte arguments to 4 bytes arguments wouldn't be a
problem. In that case, arguments for CASE 1 and CASE 2 will be passed
in the same way, i.e.
                                       a -> r0
                                       b -> r1
                                       c -> r2
                                       d -> r3

Let me know what you think. I don't think I can find the solution to
this problem other than those mentioned above. Would love to here any
ideas from you guys.

>> Did you also manage to get the BPF selftest suite running in the meantime
>> (tools/testing/selftests/bpf/)? There are a couple of programs that clang
>> will compile (test_pkt_access.o, test_xdp.o, test_l4lb.o, test_tcp_estats.o)
>> and then test run.
I will run these tests tonight. Hopefully I will be able to run them.

Any comments are welcome. Would love to here what you think about my
solutions above.

Thanks.
Shubham
