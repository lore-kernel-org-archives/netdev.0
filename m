From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFCv2 07/16] bpf: enable non-core use of the verfier
Date: Sat, 27 Aug 2016 12:40:04 +0100
Message-ID: <20160827124004.43728202@jkicinski-Precision-T1700>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
        <1472234775-29453-8-git-send-email-jakub.kicinski@netronome.com>
        <20160826232904.GA28873@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38416 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbcH0LkJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 07:40:09 -0400
Received: by mail-wm0-f53.google.com with SMTP id o80so26172839wme.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 04:40:08 -0700 (PDT)
In-Reply-To: <20160826232904.GA28873@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2016 16:29:05 -0700, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 07:06:06PM +0100, Jakub Kicinski wrote:
> > Advanced JIT compilers and translators may want to use
> > eBPF verifier as a base for parsers or to perform custom
> > checks and validations.
> > 
> > Add ability for external users to invoke the verifier
> > and provide callbacks to be invoked for every intruction
> > checked.  For now only add most basic callback for
> > per-instruction pre-interpretation checks is added.  More
> > advanced users may also like to have per-instruction post
> > callback and state comparison callback.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>  
> 
> I like the apporach. Making verifier into 'bytecode parser'
> that JITs can reuse is a good design choice.
> The only thing I would suggest is to tweak the verifier to
> avoid in-place state recording. Then I think patch 8 for
> clone/unclone of the program won't be needed, since verifier
> will be read-only from bytecode point of view and patch 9
> also will be slightly cleaner.
> I think there are very few places in verifier that do this
> state keeping inside insn. It was bugging me for some time.
> Good time to clean that up.
> Unless I misunderstand the patches 7,8,9...

Agreed, I think the verifier only modifies the program to
store pointer types in imm field.  I will try to come up
a way around this, any suggestions?  Perhaps state_equal()
logic could be modified to downgrade pointers to UNKONWNs
when it detects other state had incompatible pointer type.

> There is also small concern for patches 5 and 6 that add
> more register state information. Potentially that extra
> state can prevent states_equal() to recognize equivalent
> states. Only patch 9 uses that info, right?

5 and 6 recognize more constant loads, those can only
upgrade some UNKNOWN_VALUEs to CONST_IMMs.  So yes, if the
verifier hits the CONST first and then tries with UNKNOWN
it will have to reverify the path.  

> Another question is do you need all state walking that
> verifier does or single linear pass through insns
> would have worked?
> Looks like you're only using CONST_IMM and PTR_TO_CTX
> state, right?

I think I need all the parsing.  Right now I mostly need
the verification to check that exit codes are specific
CONST_IMMs.  Clang quite happily does this:

r0 <- 0
if (...)
	r0 <- 1
exit

> The rest looks very good. Thanks a lot!

Thanks for the review!  FWIW my use of parsing is isolated
to the nfp_bpf_verifier.c file, at the very end of patch 9.
