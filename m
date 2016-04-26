From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V2 5/5] samples/bpf: like LLC also verify and
 allow redefining CLANG command
Date: Tue, 26 Apr 2016 10:36:10 -0700
Message-ID: <20160426173608.GF42777@ast-mbp.thefacebook.com>
References: <20160426162650.22962.20516.stgit@firesoul>
 <20160426162732.22962.73140.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	bblanco@plumgrid.com, naveen.n.rao@linux.vnet.ibm.com,
	borkmann@iogearbox.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35353 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbcDZRgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:36:15 -0400
Content-Disposition: inline
In-Reply-To: <20160426162732.22962.73140.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 06:27:32PM +0200, Jesper Dangaard Brouer wrote:
> Users are likely to manually compile both LLVM 'llc' and 'clang'
> tools.  Thus, also allow redefining CLANG and verify command exist.
> 
> Makefile implementation wise, the target that verify the command have
> been generalized.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  samples/bpf/Makefile   |   23 +++++++++++++----------
>  samples/bpf/README.rst |    6 +++---
>  2 files changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index dd63521832d8..c02ea9d2a248 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -81,9 +81,10 @@ HOSTLOADLIBES_spintest += -lelf
>  HOSTLOADLIBES_map_perf_test += -lelf -lrt
>  HOSTLOADLIBES_test_overhead += -lelf -lrt
>  
> -# Allows pointing LLC to a LLVM backend with bpf support, redefine on cmdline:
> -#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> +# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
> +#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
>  LLC ?= llc
> +CLANG ?= clang
>  
>  # Trick to allow make to be run from this directory
>  all:
> @@ -94,15 +95,17 @@ clean:
>  	@rm -f *~
>  
>  # Verify LLVM compiler is available and bpf target is supported
> -.PHONY: verify_cmd_llc verify_target_bpf
> +.PHONY: verify_cmd_llc verify_target_bpf $(CLANG) $(LLC)
>  
> -verify_cmd_llc:
> -	@if ! (which "${LLC}" > /dev/null 2>&1); then \
> -		echo "*** ERROR: Cannot find LLVM tool 'llc' (${LLC})" ;\
> -		exit 1; \
> -	else true; fi
> +verify_cmds: $(CLANG) $(LLC)
> +	@for TOOL in $^ ; do \
> +		if ! (which "$${TOOL}" > /dev/null 2>&1); then \
> +			echo "*** ERROR: Cannot find LLVM tool $${TOOL}" ;\
> +			exit 1; \
> +		else true; fi; \
> +	done
>  
> -verify_target_bpf: verify_cmd_llc
> +verify_target_bpf: verify_cmds
>  	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
>  		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
>  		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\

If I read the patch correctly, it only checks that any version
of clang is available and llc supports -march=bpf.
That's correct.
There is no need to build the latest clang most of the time.
clang 3.4 and 3.5 are fine to compile samples/bpf/
since llvm ir is mostly compatible with llc from 3.7 or 3.8

Acked-by: Alexei Starovoitov <ast@kernel.org>
