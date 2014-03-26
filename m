From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 8/9] net: filter: rework/optimize internal BPF
 interpreter's instruction set
Date: Tue, 25 Mar 2014 18:58:14 -0700
Message-ID: <CAMEtUuyQs4Jk+zi9_DxFRnoTFGQ8WXn4aPPJ+yp5XxWb6pkmbQ@mail.gmail.com>
References: <1395749457-16178-9-git-send-email-dborkman@redhat.com>
	<20140325.201712.1651156258234145348.davem@davemloft.net>
	<53321E3B.8080709@linux.intel.com>
	<20140325.204628.1622839093852736075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hpa@linux.intel.com, Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Kees Cook <keescook@chromium.org>, pmoore@redhat.com,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140325.204628.1622839093852736075.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 25, 2014 at 5:46 PM, David Miller <davem@davemloft.net> wrote:
> From: "H. Peter Anvin" <hpa@linux.intel.com>
> Date: Tue, 25 Mar 2014 17:24:27 -0700
>
>> If you allow loops, it greatly increases the expressibility of the
>> language, but we would really need another control to limit CPU usage.
>
> We don't want super expressibility.
>
> We want an extremely simple, trivial to validate, filtering language.

Filtering language is unchanged. It's still the same classic BPF
and in this patch set all jumps are forward only.
We didn't touch sk_chk_filter(), so it's allowing forward only jumps.
Classic bpf and ebpf instruction sets can accommodate both.
It's bpf verifier (sk_chk_filter) that allows one or the other.

So I think we can debate backward jumps later when they actually
will be up for review.

I think we can allow backward jumps in the future, since it helps
llvm/gcc to generate more efficient code, reduce code duplication, etc
Extended bpf verifier is still simple enough and it detects loops
by doing DAG check.
See check_cfg() that was part of V1 series.
The DAG check is from the wikipedia. It's looking for a back-edge.
If back-edge is present, it means loop is possible, so whole ebpf
program is thrown out.
I think even classic BPF requires DAG check,
since today sk_chk_filter() allows unreachable instructions,
so attacker can write a bpf program that jumps over junk instructions.
I cannot imagine how this little hole can be exploited, but I think
it's safer to close it.
So we're planning to send patches to close this 10 year old
hole in the future series.

After extended verifier is reviewed and it still feels wrong, we can
make it more restrictive and disallow backward jumps, but that
will complicate llvm/gcc.

Thanks
Alexei
