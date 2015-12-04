From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 04 Dec 2015 22:21:09 +0100
Message-ID: <1449264069.22539.458413297.29D20E0D@webmail.messagingengine.com>
References: <20151204184333.GA42737@ast-mbp.thefacebook.com>
 <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
 <20151204191013.GB45508@ast-mbp.thefacebook.com>
 <20151204.142651.968075964630586979.davem@davemloft.net>
 <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Dec 4, 2015, at 20:48, Dmitry Vyukov wrote:
> On Fri, Dec 4, 2015 at 8:26 PM, David Miller <davem@davemloft.net> wrote:
> > From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> > Date: Fri, 4 Dec 2015 11:10:15 -0800
> >
> >> just don't generate random bpf programs with such shifts.
> >
> > Agreed, it is exactly the same as if the compiler emitted real cpu
> > shift instructions with undefined behavior.
> >
> > The creator of the BPF code in question is what should be fixed.
> 
> 
> There is another magical gcc flag enabled in kernel that alleviates
> this undefined behavior? Or we are just assuming that C compilers are
> still dump translators to machine code without analysis and
> optimizations?
> 
> C standard per-se is pretty clear on this code:
> 
> 6.5.7/3
> The integer promotions are performed on each of the operands. The type
> of the result is that of the promoted left operand. If the value of
> the right operand is negative or is greater than or equal to the width
> of the promoted left operand, the behavior is undefined.
> 
> 3.4.3
> undefined behavior
> 1 behavior, upon use of a nonportable or erroneous program construct
> or of erroneous data, for which this International Standard imposes no
> requirements
> 2 NOTE Possible undefined behavior ranges from ignoring the situation
> completely with unpredictable results, to behaving during translation
> or program execution in a documented manner characteristic of the
> environment (with or without the issuance of a diagnostic message), to
> terminating a translation or execution
> 
> 
> For example, a compiler can assume that result of left shift is larger
> or equal to first operand, which in turn can allow it to elide some
> bounds check in code, which in turn can lead to an exploit. I am not
> saying that this particular pattern is present in the code, what I
> want to say is that such undefined behaviors can lead to very
> unpredictable and unexpected consequences.

I agree with Alexei and David that this should not be an issue. The
paragraphs you quoted define undefined behavior within one compilation
unit. The compiler itself can do undefined behavior within this but it
will not affect the rest of the kernel as the verifier should already
have done enough reasonable checks that you are not able to escape its
sandbox or be able to access random memory.

At the point of execution of the bytecode the interpreter or in case of
jitting, the semantics of the machine code on a particular CPU, are
crucial.

Bye,
Hannes
