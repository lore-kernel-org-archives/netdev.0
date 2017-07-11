From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net v2] samples/bpf: fix a build issue
Date: Tue, 11 Jul 2017 21:51:14 +0200
Message-ID: <20170711215114.4726d1da@redhat.com>
References: <20170710210428.1292358-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, <ast@fb.com>, <daniel@iogearbox.net>,
        <brakmo@fb.com>, <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46032 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932645AbdGKTvT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 15:51:19 -0400
In-Reply-To: <20170710210428.1292358-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 10 Jul 2017 14:04:28 -0700 Yonghong Song <yhs@fb.com> wrote:

> With latest net-next:
> ====
> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
>     -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>     -Wno-compare-distinct-pointer-types \
>     -Wno-gnu-variable-sized-type-not-at-end \
>     -Wno-address-of-packed-member -Wno-tautological-compare \
>     -Wno-unknown-warning-option \
>     -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>           ^~~~~~~~~~~~~~
> 1 error generated.
> ====
> 
> net has the same issue.
> 
> Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h.

I think this patch should have been split up in two patches. One where
you fix the compile issue, and one where you add support for ntohl and
htonl.  And you are also moving the file... I'm getting confused
reading this patch.

> Also move bpf_helpers.h from samples/bpf to selftests/bpf and change
> compiler include logic so that programs in samples/bpf can access the headers
> in selftests/bpf, but not the other way around.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>
> ---
>  samples/bpf/Makefile                                   |  1 +
>  tools/testing/selftests/bpf/Makefile                   |  1 -
>  tools/testing/selftests/bpf/bpf_endian.h               | 14 ++++++++++++++
>  {samples => tools/testing/selftests}/bpf/bpf_helpers.h |  0
>  4 files changed, 15 insertions(+), 1 deletion(-)
>  rename {samples => tools/testing/selftests}/bpf/bpf_helpers.h (100%)
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 9c65058..87246be 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -207,6 +207,7 @@ $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
>  # useless for BPF samples.
>  $(obj)/%.o: $(src)/%.c
>  	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
> +		-I$(srctree)/tools/testing/selftests/bpf/ \
>  		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>  		-Wno-compare-distinct-pointer-types \
>  		-Wno-gnu-variable-sized-type-not-at-end \
> diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
> index 2ca51a8..153c3a1 100644
> --- a/tools/testing/selftests/bpf/Makefile
> +++ b/tools/testing/selftests/bpf/Makefile
> @@ -37,6 +37,5 @@ CLANG ?= clang
>  
>  %.o: %.c
>  	$(CLANG) -I. -I./include/uapi -I../../../include/uapi \
> -		-I../../../../samples/bpf/ \
>  		-Wno-compare-distinct-pointer-types \
>  		-O2 -target bpf -c $< -o $@
> diff --git a/tools/testing/selftests/bpf/bpf_endian.h b/tools/testing/selftests/bpf/bpf_endian.h
> index 487cbfb..74af266 100644
> --- a/tools/testing/selftests/bpf/bpf_endian.h
> +++ b/tools/testing/selftests/bpf/bpf_endian.h
> @@ -23,11 +23,19 @@
>  # define __bpf_htons(x)			__builtin_bswap16(x)
>  # define __bpf_constant_ntohs(x)	___constant_swab16(x)
>  # define __bpf_constant_htons(x)	___constant_swab16(x)
> +# define __bpf_ntohl(x)			__builtin_bswap32(x)
> +# define __bpf_htonl(x)			__builtin_bswap32(x)
> +# define __bpf_constant_ntohl(x)	___constant_swab32(x)
> +# define __bpf_constant_htonl(x)	___constant_swab32(x)
>  #elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
>  # define __bpf_ntohs(x)			(x)
>  # define __bpf_htons(x)			(x)
>  # define __bpf_constant_ntohs(x)	(x)
>  # define __bpf_constant_htons(x)	(x)
> +# define __bpf_ntohl(x)			(x)
> +# define __bpf_htonl(x)			(x)
> +# define __bpf_constant_ntohl(x)	(x)
> +# define __bpf_constant_htonl(x)	(x)
>  #else
>  # error "Fix your compiler's __BYTE_ORDER__?!"
>  #endif
> @@ -38,5 +46,11 @@
>  #define bpf_ntohs(x)				\
>  	(__builtin_constant_p(x) ?		\
>  	 __bpf_constant_ntohs(x) : __bpf_ntohs(x))
> +#define bpf_htonl(x)				\
> +	(__builtin_constant_p(x) ?		\
> +	 __bpf_constant_htonl(x) : __bpf_htonl(x))
> +#define bpf_ntohl(x)				\
> +	(__builtin_constant_p(x) ?		\
> +	 __bpf_constant_ntohl(x) : __bpf_ntohl(x))
>  
>  #endif /* __BPF_ENDIAN__ */
> diff --git a/samples/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
> similarity index 100%
> rename from samples/bpf/bpf_helpers.h
> rename to tools/testing/selftests/bpf/bpf_helpers.h



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
