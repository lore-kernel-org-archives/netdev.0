From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT] fib_trie: macro cleanup
Date: Thu, 26 Jul 2007 03:54:33 -0700
Message-ID: <20070726035433.69146262.akpm@linux-foundation.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
	<20070726114334.1e3e446c@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34251 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754439AbXGZKzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 06:55:09 -0400
In-Reply-To: <20070726114334.1e3e446c@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Jul 2007 11:43:34 +0100 Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> This patch converts the messy macro for MASK_PFX to inline function
> and expands TKEY_GET_MASK in the one place it is used.
> 
> 
> --- a/net/ipv4/fib_trie.c	2007-07-26 09:26:19.000000000 +0100
> +++ b/net/ipv4/fib_trie.c	2007-07-26 10:17:21.000000000 +0100
> @@ -85,8 +85,6 @@
>  #define MAX_STAT_DEPTH 32
>  
>  #define KEYLENGTH (8*sizeof(t_key))
> -#define MASK_PFX(k, l) (((l)==0)?0:(k >> (KEYLENGTH-l)) << (KEYLENGTH-l))
> -#define TKEY_GET_MASK(offset, bits) (((bits)==0)?0:((t_key)(-1) << (KEYLENGTH - bits) >> offset))
>  
>  typedef unsigned int t_key;
>  
> @@ -192,6 +190,11 @@ static inline int tnode_child_length(con
>  	return 1 << tn->bits;
>  }
>  
> +static inline t_key mask_pfx(t_key k, unsigned short l)
> +{
> +	return (l == 0) ? 0 : k >> (KEYLENGTH-l) << (KEYLENGTH-l);
> +}

that's a funy way of doing the masking, isn't it?  I suppose gcc will turn
it into the single and-immediate.

>  static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
>  {
>  	if (offset < KEYLENGTH)
> @@ -676,7 +679,7 @@ static struct tnode *inflate(struct trie
>  		    inode->pos == oldtnode->pos + oldtnode->bits &&
>  		    inode->bits > 1) {
>  			struct tnode *left, *right;
> -			t_key m = TKEY_GET_MASK(inode->pos, 1);
> +			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;

hm, so we "know" that t_key is an unsigned int.  It makes the typedef a bit
pointless.

<wonders what an inode is doing in there>

<oh>


