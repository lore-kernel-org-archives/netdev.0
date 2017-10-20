From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/8] tools: bpftool: print all relevant byte
 opcodes for "load double word"
Date: Fri, 20 Oct 2017 09:59:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009D515@AcuExch.aculab.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
 <20171019224626.31608-7-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        Quentin Monnet <quentin.monnet@netronome.com>
To: 'Jakub Kicinski' <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:64258 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752727AbdJTJ7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 05:59:10 -0400
In-Reply-To: <20171019224626.31608-7-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 19 October 2017 23:46
> The eBPF instruction permitting to load double words (8 bytes) into a
> register need 8-byte long "immediate" field, and thus occupy twice the
> space of other instructions. bpftool was aware of this and would
> increment the instruction counter only once on meeting such instruction,
> but it would only print the first four bytes of the immediate value to
> load. Make it able to dump the whole 16 byte-long double instruction
> instead (as would `llvm-objdump -d <program>`).

Guess why most modern instruction sets use a 'load high' instruction
to generate big constants...

Interestingly, is there anything special in the rest of the
second instruction in order to make it an identifiable no-op?

...
> diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
> index 355c14325622..57edbea2fbe8 100644
> --- a/tools/bpf/bpftool/prog.c
> +++ b/tools/bpf/bpftool/prog.c
> @@ -313,20 +313,29 @@ static void print_insn(struct bpf_verifier_env *env, const char *fmt, ...)
>  static void dump_xlated(void *buf, unsigned int len, bool opcodes)
>  {
>  	struct bpf_insn *insn = buf;
> +	bool double_insn = false;
>  	unsigned int i;
> 
>  	for (i = 0; i < len / sizeof(*insn); i++) {
> +		if (double_insn) {
> +			double_insn = false;
> +			continue;
> +		}

Why not just:
	for (i = 0; i < len / sizeof(*insn); i += 1 + double_insn) {

...

	David
