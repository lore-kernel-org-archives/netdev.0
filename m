From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf: improve htab inlining for future 32
 bit jits
Date: Sat, 19 Aug 2017 02:21:28 +0200
Message-ID: <59978488.9010802@iogearbox.net>
References: <cover.1503100047.git.daniel@iogearbox.net> <a2a1360af1df20e5a11269441656b5daffabdd77.1503100047.git.daniel@iogearbox.net> <43a2b95f-db1d-8c33-a7d6-42f8299ddcb3@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52044 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdHSAVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:21:32 -0400
In-Reply-To: <43a2b95f-db1d-8c33-a7d6-42f8299ddcb3@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2017 02:00 AM, Alexei Starovoitov wrote:
> On 8/18/17 4:51 PM, Daniel Borkmann wrote:
>> Lets future proof htab lookup inlining, commit 9015d2f59535 ("bpf:
>> inline htab_map_lookup_elem()") was making the assumption that a
>> direct call emission to __htab_map_lookup_elem() will always work
>> out for JITs. This is currently true since all JITs we have are
>> for 64 bit archs, but in case of 32 bit JITs like upcoming arm32,
>> we get a NULL pointer dereference when executing the call to
>> __htab_map_lookup_elem() since passed arguments are of a different
>> size (unsigned long vs. u64 for pointers) than what we do out of
>> BPF. Thus, lets do a proper BPF_CALL_2() declaration such that we
>> don't need to make any such assumptions.
>>
>> Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> assuming on 64-bit archs the should be no perf difference
> and only increase in .text, since __htab_map_lookup_elem
> is now force inlined into a bunch of places?
> I guess that's ok, but kinda sux for 64-bit archs to pay
> such penalty because of 32-bit archs.

Yeah true, text bumps from 11k to 13k, doesn't pay off.

> May be drop always_inline and do such thing conditionally
> on 32-bit archs only?

I will guard with this instead:

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4f6e7eb..e42c096 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -4160,7 +4160,11 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
                         continue;
                 }

-               if (ebpf_jit_enabled() && insn->imm == BPF_FUNC_map_lookup_elem) {
+               /* BPF_EMIT_CALL() assumptions in some of the map_gen_lookup
+                * handlers are currently limited to 64 bit only.
+                */
+               if (ebpf_jit_enabled() && BITS_PER_LONG == 64 &&
+                   insn->imm == BPF_FUNC_map_lookup_elem) {
                         map_ptr = env->insn_aux_data[i + delta].map_ptr;
                         if (map_ptr == BPF_MAP_PTR_POISON ||
                             !map_ptr->ops->map_gen_lookup)
