From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH v2 1/2] ethtool: changes of emac_regs structure
 accordingly within driver emac_regs structure.
Date: Thu, 27 Aug 2015 14:39:46 +0400
Message-ID: <20150827143946.4cd947c9@fr-ThinkPad-W520>
References: <20150805150153.10f054ed@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805150153.10f054ed@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Aug 2015 15:01:53 +0400
Ivan Mikhaylov <ivan@ru.ibm.com> wrote:

ping

> * do the redefinition of emac_regs struct from driver structure
> perspective and passing size from actual struct size, not from memory
> area variable which set in dts file.
> 
> * passing variable from dts option may cause a problem with output
> below MII's section which we're fixing with this and 5369c71 commit
> in kernel.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
> ---
>  ibm_emac.c |  101
> +++++++++++++++++++++++++++++++++++++++++++----------------- 1 file
> changed, 73 insertions(+), 28 deletions(-)
> 
> diff --git a/ibm_emac.c b/ibm_emac.c
> index e128e48..da6c28e 100644
> --- a/ibm_emac.c
> +++ b/ibm_emac.c
> @@ -32,35 +32,78 @@ struct emac_ethtool_regs_subhdr {
>  };
>  
>  struct emac_regs {
> -	u32 mr0;
> -	u32 mr1;
> -	u32 tmr0;
> -	u32 tmr1;
> -	u32 rmr;
> -	u32 isr;
> -	u32 iser;
> -	u32 iahr;
> -	u32 ialr;
> -	u32 vtpid;
> -	u32 vtci;
> -	u32 ptr;
> -	u32 iaht1;
> -	u32 iaht2;
> -	u32 iaht3;
> -	u32 iaht4;
> -	u32 gaht1;
> -	u32 gaht2;
> -	u32 gaht3;
> -	u32 gaht4;
> +	/* Common registers across all EMAC implementations. */
> +	u32 mr0;			/* Special 	*/
> +	u32 mr1;			/* Reset 	*/
> +	u32 tmr0;			/* Special 	*/
> +	u32 tmr1;			/* Special 	*/
> +	u32 rmr;			/* Reset 	*/
> +	u32 isr;			/* Always 	*/
> +	u32 iser;			/* Reset 	*/
> +	u32 iahr;			/* Reset, R, T 	*/
> +	u32 ialr;			/* Reset, R, T 	*/
> +	u32 vtpid;			/* Reset, R, T 	*/
> +	u32 vtci;			/* Reset, R, T 	*/
> +	u32 ptr;			/* Reset,    T 	*/
> +	union {
> +		/* Registers unique to EMAC4 implementations */
> +		struct {
> +			u32 iaht1;	/* Reset, R	*/
> +			u32 iaht2;	/* Reset, R	*/
> +			u32 iaht3;	/* Reset, R	*/
> +			u32 iaht4;	/* Reset, R	*/
> +			u32 gaht1;	/* Reset, R	*/
> +			u32 gaht2;	/* Reset, R	*/
> +			u32 gaht3;	/* Reset, R	*/
> +			u32 gaht4;	/* Reset, R	*/
> +		} emac4;
> +		/* Registers unique to EMAC4SYNC implementations */
> +		struct {
> +			u32 mahr;	/* Reset, R, T  */
> +			u32 malr;	/* Reset, R, T  */
> +			u32 mmahr;	/* Reset, R, T  */
> +			u32 mmalr;	/* Reset, R, T  */
> +			u32 rsvd0[4];
> +		} emac4sync;
> +	} u0;
> +	/* Common registers across all EMAC implementations. */
>  	u32 lsah;
>  	u32 lsal;
> -	u32 ipgvr;
> -	u32 stacr;
> -	u32 trtr;
> -	u32 rwmr;
> +	u32 ipgvr;			/* Reset,    T 	*/
> +	u32 stacr;			/* Special 	*/
> +	u32 trtr;			/* Special 	*/
> +	u32 rwmr;			/* Reset 	*/
>  	u32 octx;
>  	u32 ocrx;
> -	u32 ipcr;
> +	union {
> +		/* Registers unique to EMAC4 implementations */
> +		struct {
> +			u32 ipcr;
> +		} emac4;
> +		/* Registers unique to EMAC4SYNC implementations */
> +		struct {
> +			u32 rsvd1;
> +			u32 revid;
> +			u32 rsvd2[2];
> +			u32 iaht1;	/* Reset, R     */
> +			u32 iaht2;	/* Reset, R     */
> +			u32 iaht3;	/* Reset, R     */
> +			u32 iaht4;	/* Reset, R     */
> +			u32 iaht5;	/* Reset, R     */
> +			u32 iaht6;	/* Reset, R     */
> +			u32 iaht7;	/* Reset, R     */
> +			u32 iaht8;	/* Reset, R     */
> +			u32 gaht1;	/* Reset, R     */
> +			u32 gaht2;	/* Reset, R     */
> +			u32 gaht3;	/* Reset, R     */
> +			u32 gaht4;	/* Reset, R     */
> +			u32 gaht5;	/* Reset, R     */
> +			u32 gaht6;	/* Reset, R     */
> +			u32 gaht7;	/* Reset, R     */
> +			u32 gaht8;	/* Reset, R     */
> +			u32 tpc;	/* Reset, T     */
> +		} emac4sync;
> +	} u1;
>  };
>  
>  struct mal_regs {
> @@ -132,12 +175,14 @@ static void *print_emac_regs(void *buf)
>  	       p->trtr, p->rwmr,
>  	       p->iahr, p->ialr,
>  	       p->lsah, p->lsal,
> -	       p->iaht1, p->iaht2, p->iaht3, p->iaht4,
> -	       p->gaht1, p->gaht2, p->gaht3, p->gaht4,
> +	       p->u0.emac4.iaht1, p->u0.emac4.iaht2,
> p->u0.emac4.iaht3,
> +	       p->u0.emac4.iaht4,
> +	       p->u0.emac4.gaht1, p->u0.emac4.gaht2,
> p->u0.emac4.gaht3,
> +	       p->u0.emac4.gaht4,
>  	       p->vtpid, p->vtci, p->ipgvr, p->stacr, p->octx,
> p->ocrx); 
>  	if (hdr->version)
> -		printf(" IPCR = 0x%08x\n\n", p->ipcr);
> +		printf(" IPCR = 0x%08x\n\n", p->u1.emac4.ipcr);
>  	else {
>  		printf("\n\n");
>  		res -= sizeof(u32);
