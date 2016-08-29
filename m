From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Mon, 29 Aug 2016 22:13:32 +0200
Message-ID: <57C4976C.4010501@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com> <20160826232904.GA28873@ast-mbp.thefacebook.com> <20160827124004.43728202@jkicinski-Precision-T1700> <20160827173250.GA38477@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44964 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbcH2UNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 16:13:37 -0400
In-Reply-To: <20160827173250.GA38477@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2016 07:32 PM, Alexei Starovoitov wrote:
> On Sat, Aug 27, 2016 at 12:40:04PM +0100, Jakub Kicinski wrote:
>> On Fri, 26 Aug 2016 16:29:05 -0700, Alexei Starovoitov wrote:
>>> On Fri, Aug 26, 2016 at 07:06:06PM +0100, Jakub Kicinski wrote:
>>>> Advanced JIT compilers and translators may want to use
>>>> eBPF verifier as a base for parsers or to perform custom
>>>> checks and validations.
>>>>
>>>> Add ability for external users to invoke the verifier
>>>> and provide callbacks to be invoked for every intruction
>>>> checked.  For now only add most basic callback for
>>>> per-instruction pre-interpretation checks is added.  More
>>>> advanced users may also like to have per-instruction post
>>>> callback and state comparison callback.
>>>>
>>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>>
>>> I like the apporach. Making verifier into 'bytecode parser'
>>> that JITs can reuse is a good design choice.

+1

>>> The only thing I would suggest is to tweak the verifier to
>>> avoid in-place state recording. Then I think patch 8 for
>>> clone/unclone of the program won't be needed, since verifier
>>> will be read-only from bytecode point of view and patch 9
>>> also will be slightly cleaner.
>>> I think there are very few places in verifier that do this
>>> state keeping inside insn. It was bugging me for some time.
>>> Good time to clean that up.
>>> Unless I misunderstand the patches 7,8,9...
>>
>> Agreed, I think the verifier only modifies the program to
>> store pointer types in imm field.  I will try to come up
>> a way around this, any suggestions?  Perhaps state_equal()
>
> probably array_of_insn_aux_data[num_insns] should do it.
> Unlike reg_state that is forked on branches, this array
> is only one.

This would be for struct nfp_insn_meta, right? So, struct
bpf_ext_parser_ops could become:

static const struct bpf_ext_parser_ops nfp_bpf_pops = {
	.insn_hook = nfp_verify_insn,
	.insn_size = sizeof(struct nfp_insn_meta),
};

... where bpf_parse() would prealloc that f.e. in env->insn_meta[].

>> logic could be modified to downgrade pointers to UNKONWNs
>> when it detects other state had incompatible pointer type.
>>
>>> There is also small concern for patches 5 and 6 that add
>>> more register state information. Potentially that extra
>>> state can prevent states_equal() to recognize equivalent
>>> states. Only patch 9 uses that info, right?
>>
>> 5 and 6 recognize more constant loads, those can only
>> upgrade some UNKNOWN_VALUEs to CONST_IMMs.  So yes, if the
>> verifier hits the CONST first and then tries with UNKNOWN
>> it will have to reverify the path.

Agree, was also my concern when I read patch 5 and 6. It would
not only be related to types, but also different imm values,
where the memcmp() could fail on. Potentially the latter can be
avoided by only checking types which should be sufficient. Hmm,
maybe only bpf_parse() should go through this stricter mode since
only relevant for drivers (otoh downside would be that bugs
would end up less likely to be found).

>>> Another question is do you need all state walking that
>>> verifier does or single linear pass through insns
>>> would have worked?
>>> Looks like you're only using CONST_IMM and PTR_TO_CTX
>>> state, right?
>>
>> I think I need all the parsing.  Right now I mostly need
>> the verification to check that exit codes are specific
>> CONST_IMMs.  Clang quite happily does this:
>>
>> r0 <- 0
>> if (...)
>> 	r0 <- 1
>> exit
>
> I see. Indeed then you'd need the verifier to walk all paths
> to make sure constant return values.

I think this would still not cover the cases where you'd fetch
a return value/verdict from a map, but this should be ignored/
rejected for now, also since majority of programs are not written
in such a way.

> If you only need yes/no check then such info can probably be
> collected unconditionally during initial program load.
> Like prog->cb_access flag.

One other comment wrt the header, when you move these things
there, would be good to prefix with bpf_* so that this doesn't
clash in future with other header files.
