From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] samples/bpf: fix a build issue
Date: Mon, 10 Jul 2017 22:27:26 +0200
Message-ID: <5963E32E.2020105@iogearbox.net>
References: <20170710201224.1071186-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, Yonghong Song <yhs@localhost.localdomain>
To: Yonghong Song <yhs@fb.com>, ast@fb.com, brakmo@fb.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59511 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753981AbdGJU1a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 16:27:30 -0400
In-Reply-To: <20170710201224.1071186-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2017 10:12 PM, Yonghong Song wrote:
> From: Yonghong Song <yhs@localhost.localdomain>
>
> With latest net-next:
> ====
> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
> 	-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> 	-Wno-compare-distinct-pointer-types \
> 	-Wno-gnu-variable-sized-type-not-at-end \
> 	-Wno-address-of-packed-member -Wno-tautological-compare \
> 	-Wno-unknown-warning-option \
> 	-O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>           ^~~~~~~~~~~~~~
> 1 error generated.
> ====
>
> net has the same issue.
>
> Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h
> and move it to samples/bpf/ directory so that it can used by
> both selftests/bpf and samples/bpf. The existing samples/bpf/bpf_helpers.h
> is already used by both.
>
> Signed-off-by: Yonghong Song <yhs@fb.com>
> ---
>   {tools/testing/selftests => samples}/bpf/bpf_endian.h | 14 ++++++++++++++

samples/bpf/Makefile already does:

   HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/

If needed we should rather extend the sample's Makefile to pull in
bpf_endian.h also for clang generated files, but not the other way
round. It's both kind of messy, but kernel selftests should not need
to include or depend upon some sample code.

Other than that looks good to me.

>   tools/testing/selftests/bpf/Makefile                  |  3 ++-
>   2 files changed, 16 insertions(+), 1 deletion(-)
>   rename {tools/testing/selftests => samples}/bpf/bpf_endian.h (73%)
>
> diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/samples/bpf/bpf_endian.h
> similarity index 73%
> rename from tools/testing/selftests/bpf/bpf_endian.h
> rename to samples/bpf/bpf_endian.h
> index 487cbfb..74af266 100644
> --- a/tools/testing/selftests/bpf/bpf_endian.h
> +++ b/samples/bpf/bpf_endian.h
> @@ -23,11 +23,19 @@
>   # define __bpf_htons(x)			__builtin_bswap16(x)
>   # define __bpf_constant_ntohs(x)	___constant_swab16(x)
>   # define __bpf_constant_htons(x)	___constant_swab16(x)
> +# define __bpf_ntohl(x)			__builtin_bswap32(x)
> +# define __bpf_htonl(x)			__builtin_bswap32(x)
> +# define __bpf_constant_ntohl(x)	___constant_swab32(x)
> +# define __bpf_constant_htonl(x)	___constant_swab32(x)
>   #elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
>   # define __bpf_ntohs(x)			(x)
>   # define __bpf_htons(x)			(x)
>   # define __bpf_constant_ntohs(x)	(x)
>   # define __bpf_constant_htons(x)	(x)
> +# define __bpf_ntohl(x)			(x)
> +# define __bpf_htonl(x)			(x)
> +# define __bpf_constant_ntohl(x)	(x)
> +# define __bpf_constant_htonl(x)	(x)
>   #else
>   # error "Fix your compiler's __BYTE_ORDER__?!"
>   #endif
> @@ -38,5 +46,11 @@
>   #define bpf_ntohs(x)				\
>   	(__builtin_constant_p(x) ?		\
>   	 __bpf_constant_ntohs(x) : __bpf_ntohs(x))
> +#define bpf_htonl(x)				\
> +	(__builtin_constant_p(x) ?		\
> +	 __bpf_constant_htonl(x) : __bpf_htonl(x))
> +#define bpf_ntohl(x)				\
> +	(__builtin_constant_p(x) ?		\
> +	 __bpf_constant_ntohl(x) : __bpf_ntohl(x))
>
>   #endif /* __BPF_ENDIAN__ */
> diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
> index 2ca51a8..f263c6b 100644
> --- a/tools/testing/selftests/bpf/Makefile
> +++ b/tools/testing/selftests/bpf/Makefile
> @@ -8,7 +8,8 @@ ifneq ($(wildcard $(GENHDR)),)
>     GENFLAGS := -DHAVE_GENHDR
>   endif
>
> -CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include
> +CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include \
> +	-I../../../../samples/bpf
>   LDLIBS += -lcap -lelf
>
>   TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs \
>
