From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/5] stmmac: add CHAINED descriptor mode support (V2)
Date: Fri, 14 Oct 2011 09:10:49 +0200
Message-ID: <4E97E079.8030205@st.com>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com> <1318426688-9419-2-git-send-email-peppe.cavallaro@st.com> <20111013.163946.859494070937160730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:53775 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754196Ab1JNHLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:11:20 -0400
In-Reply-To: <20111013.163946.859494070937160730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 10:39 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 12 Oct 2011 15:38:04 +0200
> 
>> +#if defined(CONFIG_STMMAC_RING)
>> +
>> +static unsigned int stmmac_jumbo_frm(struct stmmac_priv *priv,
>> +				     struct sk_buff *skb, int csum_insertion)
>> +{
> 
> This is not exactly what I meant.
> 
> In your original patch, two or three line snippets of code were conditionalized.
> 
> That's what I wanted you to do here.  Keep as much common code around as possible
> in the driver *.c file, but the small 2 or 3 line conditional parts are implemented
> in very small well contained inline functions implemented in a header file.
> 
> These small, 2 or 3 line, inline functions are where the ifdefs go.
> 
> I didn't mean to replicate all of the functions, in their entirety, into some
> header file.

This is what I wanted to do indeed. :-(

I had added new small functions like where possible (used in the main):

static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
static void stmmac_clean_desc3(struct dma_desc *p)

I guess this is what you actually wanted.

In other cases, I had put two implementation of the same function
specialized for ring and chained mode. This was the case of the enhanced
and normal descriptors. Instead of implementing new inline funtcs I
direcly moved the functions themselves into the header because small enough.

For example

inline void enh_desc_release_tx_desc(struct dma_desc *p)
{
	memset(p, 0, offsetof(struct dma_desc, des2));
	p->des01.etx.second_address_chained = 1;
}

and
inline void enh_desc_release_tx_desc(struct dma_desc *p)
{
	int ter = p->des01.etx.end_ring;

	memset(p, 0, offsetof(struct dma_desc, des2));
	p->des01.etx.end_ring = ter;
}


Unfortunately, jumbo frame function is big :-( and I agree with you that
it's not good to have this in the Header.

At any rate, I'll try to reduce the code in the header as much possible
although this makes more complex the driver's API.

Thanks for your feedback.

Let me know for other advice and comments

Regards
Peppe

> 
> You might was well put the entire driver into a header file, then you can add
> all the ifdefs you want :-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
