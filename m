From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v3 8/9] net: filter: rework/optimize internal BPF
 interpreter's instruction set
Date: Thu, 27 Mar 2014 13:30:47 -0700
Message-ID: <CAMEtUuz0SxSoSeJk7_C7Qt1t_27wqkp__Hk1CT13TgzhJGUUcg@mail.gmail.com>
References: <1395867970-1338-1-git-send-email-dborkman@redhat.com>
	<1395867970-1338-9-git-send-email-dborkman@redhat.com>
	<20140327.152319.1469721259196062415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Kees Cook <keescook@chromium.org>, pmoore@redhat.com,
	Ingo Molnar <mingo@kernel.org>, hpa@linux.intel.com,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140327.152319.1469721259196062415.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 12:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 26 Mar 2014 22:06:09 +0100
>
>>   - Adds swab insns for 32/64-bit
>
> I don't like this.
>
> You don't want a swab instruction, you want "endian X to endian Y".  Just
> like we have "cpu_to_le32()", "le32_to_cpu()" et al. in the kernel.
>
> That way the user can be completely oblivious as to the endianness of
> the cpu it's running on.

Agreed.
If we want to expose ebpf instruction set to the userspace as-is then
it completely makes sense.

The reason we picked swab style is two fold:
1. swab32/64 maps as-is to native cpu instructions during jit.
2. assumption was that new_socket_filters/tracing_filters/ovs_filters
   will be written in C and will use standard macro ntohl() that
   will be expanded to __builtin_swap or nop by gcc/llvm,
  so users don't need to worry about underlying endianness while
  writing filters in C.

> So if you ask for a "to little endian" swab, if the chip is
> little-endian then no code needs to be emitted at all, it's a nop.
>
> There is zero reason for the BPF program emitted by userspace to be
> dependant upon the cpu endianness.

Agree.
with cpu_to_le and cpu_to_be instructions the programs written in C
and written directly in ebpf won't need to worry about endianness.
Best of both.

We'll fix and resend.

Thanks
Alexei
