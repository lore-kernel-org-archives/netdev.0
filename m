From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: [1/3] PPP MPPE module
Date: Fri, 18 Jun 2004 11:03:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618110350.3983354f@dell_ss3.pdx.osdl.net>
References: <20040618161001.GE19269@lists.us.dell.com>
	<20040618161052.GF19269@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
In-Reply-To: <20040618161052.GF19269@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor stuff.

> +/*
> + * State for an MPPE (de)compressor.
> + */
> +typedef struct ppp_mppe_state {
> +	struct crypto_tfm *arc4;
> +	struct crypto_tfm *sha1;
> +	unsigned char *sha1_digest;
> +	unsigned char master_key[MPPE_MAX_KEY_LEN];
> +	unsigned char session_key[MPPE_MAX_KEY_LEN];
> +	unsigned keylen;	/* key length in bytes             */
> +	/* NB: 128-bit == 16, 40-bit == 8! */
> +	/* If we want to support 56-bit,   */
> +	/* the unit has to change to bits  */
> +	unsigned char bits;	/* MPPE control bits */
> +	unsigned ccount;	/* 12-bit coherency count (seqno)  */
> +	unsigned stateful;	/* stateful mode flag */
> +	int discard;		/* stateful mode packet loss flag */
> +	int sanity_errors;	/* take down LCP if too many */
> +	int unit;
> +	int debug;
> +	struct compstat stats;
> +} ppp_mppe_state;

Is the typedef really making things clearer? no.


> +/* ppp_mppe_state.bits definitions */
> +#define MPPE_BIT_A	0x80	/* Encryption table were (re)inititalized */
> +#define MPPE_BIT_B	0x40	/* MPPC only (not implemented) */
> +#define MPPE_BIT_C	0x20	/* MPPC only (not implemented) */
> +#define MPPE_BIT_D	0x10	/* This is an encrypted frame */
> +
> +#define MPPE_BIT_FLUSHED	MPPE_BIT_A
> +#define MPPE_BIT_ENCRYPTED	MPPE_BIT_D
> +
> +#define MPPE_BITS(p) ((p)[4] & 0xf0)
> +#define MPPE_CCOUNT(p) ((((p)[4] & 0x0f) << 8) + (p)[5])
> +#define MPPE_CCOUNT_SPACE 0x1000	/* The size of the ccount space */
> +
> +#define MPPE_OVHD	2	/* MPPE overhead/packet */
> +#define SANITY_MAX	1600	/* Max bogon factor we will tolerate */
> +
> +#define SHA1_PAD_SIZE 40
> +/*
> + * Key Derivation, from RFC 3078, RFC 3079.
> + * Equivalent to Get_Key() for MS-CHAP as described in RFC 3079.
> + */
> +static void GetNewKeyFromSHA(ppp_mppe_state * state, unsigned char *InterimKey)

annoying RandomCaptialization

> 
> +/*
> + * Compress (encrypt) a packet.
> + * It's strange to call this a compressor, since the output is always
> + * MPPE_OVHD + 2 bytes larger than the input.
> + */
> +int
> +mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
> +	      int isize, int osize)
> +{

This can be static since only call should be through table.

> +
> +/*
> + * Decompress (decrypt) an MPPE packet.
> + */
> +int
> +mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
> +		int osize)
> +{

Also can be static.

> +
> +/*************************************************************
> + * Module interface table
> + *************************************************************/
> +
> +/*
> + * Procedures exported to if_ppp.c.
> + */
> +struct compressor ppp_mppe = {
> +	CI_MPPE,		/* compress_proto */
> +	mppe_alloc,		/* comp_alloc */
> +	mppe_free,		/* comp_free */
> +	mppe_comp_init,		/* comp_init */
> +	mppe_comp_reset,	/* comp_reset */
> +	mppe_compress,		/* compress */
> +	mppe_comp_stats,	/* comp_stat */
> +	mppe_alloc,		/* decomp_alloc */
> +	mppe_free,		/* decomp_free */
> +	mppe_decomp_init,	/* decomp_init */
> +	mppe_decomp_reset,	/* decomp_reset */
> +	mppe_decompress,	/* decompress */
> +	mppe_incomp,		/* incomp */
> +	mppe_comp_stats,	/* decomp_stat */
> +};

Table can be static since it is hooked in with register call.
