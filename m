From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 07/12] nfp: add skb mark support to the bpf offload
Date: Wed, 1 Jun 2016 23:19:36 +0100
Message-ID: <20160601231936.63c53f69@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-8-git-send-email-jakub.kicinski@netronome.com>
	<20160601215624.GB24671@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35152 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcFAWTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 18:19:41 -0400
Received: by mail-wm0-f41.google.com with SMTP id a136so203345829wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 15:19:40 -0700 (PDT)
In-Reply-To: <20160601215624.GB24671@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jun 2016 14:56:26 -0700, Alexei Starovoitov wrote:
> On Wed, Jun 01, 2016 at 05:50:09PM +0100, Jakub Kicinski wrote:
> > Skb marking should be set in designated register, FW will
> > prepend it to the packet for us.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> > Reviewed-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c    | 20 ++++++++++++++++++++
> >  drivers/net/ethernet/netronome/nfp/nfp_net.h        |  2 +-
> >  drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  8 +++++++-
> >  3 files changed, 28 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
> > index d7eecfceba5c..b31e673a6fe8 100644
> > --- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
> > +++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
> > @@ -46,6 +46,8 @@
> >  
> >  #define REG_IMM0_N	30 /* Bank AB */
> >  #define REG_QNUM	29 /* Bank AB */
> > +#define REG_MARK	28 /* Bank A */
> > +#define REG_MARK_STS	28 /* Bank B */
> >  
> >  /* --- NFP prog --- */
> >  /* Foreach "multiple" entries macros provide pos and next<n> pointers.
> > @@ -416,6 +418,15 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
> >  	return construct_data_ind_ld(nfp_prog, offset, 0, false, size);
> >  }
> >  
> > +static int wrp_skb_mark(struct nfp_prog *nfp_prog, u16 src)
> > +{
> > +	__emit_alu(nfp_prog, REG_MARK, ALU_DST_A, REG_NONE, ALU_OP_NONE, src,
> > +		   false, false);
> > +	__emit_immed(nfp_prog, REG_MARK_STS, ALU_DST_B, 1, false);
> > +
> > +	return 0;
> > +}
> > +
> >  static int
> >  construct_br_imm(struct nfp_prog *nfp_prog, u32 imm, u16 dst, u8 br, u16 off,
> >  		 enum alu_op alu_op, bool sw)
> > @@ -538,6 +549,14 @@ static int imm_ld8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
> >  	return 0;
> >  }
> >  
> > +static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
> > +{
> > +	if (meta->insn.off == offsetof(struct sk_buff, mark))
> > +		return wrp_skb_mark(nfp_prog, meta->insn.src_reg * 2);  
> 
> couldn't figure out from the diff or commit log...
> what is the meaning of 'skb->mark' for nfp?
> Looks like it's writing into magic register and fw will do something
> with that register?
> 'mark' is packet metadata. Could you explain how it's passing
> this metadata? Is it on the wire as well or somehow in the wire
> only between two nfps?
> Looks like interesting feature.

Oh, it's not a magic register, it just an "API" I have between the BPF
and the datapath firmware.  Whatever is put in that register will be
prepended to the packet (if the mark status register is set).

I was actually pondering making the prepend TC IFE-compatible. Not sure
if it's worth the overhead but definitely something that can be done if
there is interest.
