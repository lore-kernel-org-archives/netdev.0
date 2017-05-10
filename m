From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf pointer alignment validation
Date: Wed, 10 May 2017 17:51:50 +0200
Message-ID: <59133716.7060800@iogearbox.net>
References: <59104D35.8080108@iogearbox.net>    <20170509.143234.1785658771452710730.davem@davemloft.net>       <20170510055735.hfkoh4w3xaka5yl5@ast-mbp> <20170510.113357.362211347006868605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39048 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753771AbdEJPv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 11:51:56 -0400
In-Reply-To: <20170510.113357.362211347006868605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 05:33 PM, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 9 May 2017 22:57:37 -0700
>
>> On Tue, May 09, 2017 at 02:32:34PM -0400, David Miller wrote:
>>>
>>> +static u32 calc_align(u32 imm)
>>> +{
>>> +	u32 align = 1;
>>> +
>>> +	if (!imm)
>>> +		return 1U << 31;
>>> +
>>> +	while (!(imm & 1)) {
>>> +		imm >>= 1;
>>> +		align <<= 1;
>>> +	}
>>> +	return align;
>>> +}
>>
>> same question as in previous reply.
>> Why not to use something like:
>> static u32 calc_align(u32 n)
>> {
>>          if (!n)
>>                  return 1U << 31;
>>          return n - ((n - 1) & n);
>> }
>
> Ok.
>
> I did a cursory search and we don't have a generic kernel helper for
> this kind of calculation.  I was actually quite surprised, as we
> have one for everything else :-)
>
>> this needs to be tweaked like
>> if (log_level > 1)
>>          verbose("%d:", insn_idx);
>> else
>> 	verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
>>
>> otherwise it prints prev_insn_idx which is meaningful
>> only with processing exit and search pruning.
>
> Agreed.
>
>> Nice to see all these comments.
>> I wonder how we can make them automatic in the verifier.
>> Like if verifier can somehow hint the user in such human friendly way
>> about what is happening with the program.
>> Today that's the #1 problem. Most folks complaining
>> that verifier error messages are too hard to understand.
>
> We can put whatever text strings we want into that verifier buffer.
> It is as flexible as netlink extended acks.
>
>> would it make sense to bpf_prog_test_run() it here as well?
>
> We could.
>
>> On x86 not much value, but on sparc we can somehow look for traps?
>> Is there some counter of unaligned traps that we can read and report
>> as error to user space after prog_test_run ?
>
> Unfortunately, no.
>
>> These tests we cannot really run, since they don't do any load/store.
>> I mean more for some future tests. Or some sort of debug warn
>> that there were traps while bpf prog was executed, so the user
>> is alarmed and reports to us, since that would be a bug in verifier
>> align logic?
>
> One thing I could definitely do is add logic to the unaligned trap
> handler to print something special in the logs if we find that we
> are executing BPF code.
>
> The basic structure of the log message can be codified in a generic
> bpf_xxx() helper, which architectures call with the PC and unaligned
> address as arguments.
>
> I was thinking more last night about strict alignment mode for the
> verifier, so that bugs can be spotted on all architectures.  But
> it stupidly will not work.
>
> The problem is that x86 and powerpc define NET_IP_ALIGN as 0, so all
> bets are off.
>
> One thing we could do in "strict alignment" verifier mode is pretend
> that NET_IP_ALIGN is 2 in the alignment checks.

Would probably be good nevertheless to have this as a flag for
program loads, which gets then passed through to the verifier to
explicitly enable strict alignment checks.

Might certainly aide developing & testing programs on archs with
efficient unaligned access and later actually running them on archs
that don't have it. (And at minimum, it also helps for checking
the test suite against the verifier.)
