From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 05/17] MIPS: bpf: Return error code if the offset is a
 negative number
Date: Mon, 23 Jun 2014 15:09:01 -0700
Message-ID: <CAMEtUuyL8EV3UxS7yaD_ufiAywr7hkgPSC-3etMEYfbAZ_rRew@mail.gmail.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
	<1403516340-22997-6-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:49231 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaFWWJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 18:09:03 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so7087513wgh.35
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 15:09:01 -0700 (PDT)
In-Reply-To: <1403516340-22997-6-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2014 at 2:38 AM, Markos Chandras
<markos.chandras@imgtec.com> wrote:
> Previously, the negative offset was not checked leading to failures
> due to trying to load data beyond the skb struct boundaries. Until we
> have proper asm helpers in place, it's best if we return ENOSUPP if K
> is negative when trying to JIT the filter or 0 during runtime if we
> do an indirect load where the value of X is unknown during build time.
>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>

Hi Markos,

thank you for addressing all of my earlier comments.
Looks like test_bpf was quite useful in finding all of these bugs :)
For the patches that reached netdev:

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

One minor nit below:

> ---
>  arch/mips/net/bpf_jit.c | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)
>
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> index 5cc92c4590cb..95728ea6cb74 100644
> --- a/arch/mips/net/bpf_jit.c
> +++ b/arch/mips/net/bpf_jit.c
> @@ -331,6 +331,12 @@ static inline void emit_srl(unsigned int dst, unsigned int src,
>         emit_instr(ctx, srl, dst, src, sa);
>  }
>
> +static inline void emit_slt(unsigned int dst, unsigned int src1,
> +                           unsigned int src2, struct jit_ctx *ctx)
> +{
> +       emit_instr(ctx, slt, dst, src1, src2);
> +}
> +
>  static inline void emit_sltu(unsigned int dst, unsigned int src1,
>                              unsigned int src2, struct jit_ctx *ctx)
>  {
> @@ -816,8 +822,21 @@ static int build_body(struct jit_ctx *ctx)
>                         /* A <- P[k:1] */
>                         load_order = 0;
>  load:
> +                       /* the interpreter will deal with the negative K */
> +                       if ((int)k < 0)

should be a space after cast.
