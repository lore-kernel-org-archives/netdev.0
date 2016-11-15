From: Jann Horn <jannh@google.com>
Subject: Re: [PATCH net][v2] bpf: fix range arithmetic for bpf map access
Date: Tue, 15 Nov 2016 14:47:13 +0100
Message-ID: <CAG48ez1z8wJstz84-ekY5Ed8oNgpT73Xc18Or7RboOoBnTE03w@mail.gmail.com>
References: <1479156336-6211-1-git-send-email-jbacik@fb.com> <20161115031016.GA10323@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josef Bacik <jbacik@fb.com>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:33008 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbcKONrf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 08:47:35 -0500
Received: by mail-it0-f48.google.com with SMTP id c20so25581662itb.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 05:47:34 -0800 (PST)
In-Reply-To: <20161115031016.GA10323@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 4:10 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Nov 14, 2016 at 03:45:36PM -0500, Josef Bacik wrote:
>> I made some invalid assumptions with BPF_AND and BPF_MOD that could result in
>> invalid accesses to bpf map entries.  Fix this up by doing a few things
>>
>> 1) Kill BPF_MOD support.  This doesn't actually get used by the compiler in real
>> life and just adds extra complexity.
>>
>> 2) Fix the logic for BPF_AND, don't allow AND of negative numbers and set the
>> minimum value to 0 for positive AND's.
>>
>> 3) Don't do operations on the ranges if they are set to the limits, as they are
>> by definition undefined, and allowing arithmetic operations on those values
>> could make them appear valid when they really aren't.
>>
>> This fixes the testcase provided by Jann as well as a few other theoretical
>> problems.
>>
>> Reported-by: Jann Horn <jannh@google.com>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>
> lgtm.
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
> Jann, could you please double check the logic.
> Thanks!

I found some more potential issues, maybe Josef and you can tell me whether I
understood these correctly.


/* If the source register is a random pointer then the
* min_value/max_value values represent the range of the known
* accesses into that value, not the actual min/max value of the
* register itself.  In this case we have to reset the reg range
* values so we know it is not safe to look at.
*/
if (regs[insn->src_reg].type != CONST_IMM &&
   regs[insn->src_reg].type != UNKNOWN_VALUE) {
min_val = BPF_REGISTER_MIN_RANGE;
max_val = BPF_REGISTER_MAX_RANGE;
}

Why only the source register? Why not the destination register?


/* We don't know anything about what was done to this register, mark it
* as unknown.
*/
if (min_val == BPF_REGISTER_MIN_RANGE &&
   max_val == BPF_REGISTER_MAX_RANGE) {
reset_reg_range_values(regs, insn->dst_reg);
return;
}

Why have this special case at all? Since min_val and max_val are
basically independent, this code shouldn't be necessary, right?


static void check_reg_overflow(struct bpf_reg_state *reg)
{
if (reg->max_value > BPF_REGISTER_MAX_RANGE)
reg->max_value = BPF_REGISTER_MAX_RANGE;
if (reg->min_value < BPF_REGISTER_MIN_RANGE ||
   reg->min_value > BPF_REGISTER_MAX_RANGE)
reg->min_value = BPF_REGISTER_MIN_RANGE;
}

Why is this asymmetric? Why is `reg->max_value <
BPF_REGISTER_MIN_RANGE` not important, but `reg->min_value >
BPF_REGISTER_MAX_RANGE` is?


In states_equal():
if (rold->type == NOT_INIT ||
   (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))   <------------
continue;

I think this is broken in code like the following:

int value;
if (condition) {
  value = 1; // visited first by verifier
} else {
  value = 1000000; // visited second by verifier
}
int dummy = 1; // states seem to converge here, but actually don't
map[value] = 1234;

`value` would be an UNKNOWN_VALUE for both paths, right? So
states_equal() would decide that the states converge after the
conditionally executed code?
