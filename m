From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH v3 5/7] via-velocity: Re-enable transmit scatter-gather
 support
Date: Thu, 26 Nov 2009 08:36:41 +0100
Message-ID: <20091126083641.4f961ce5@marrow.netinsight.se>
References: <20091123152724.2871cf4d@marrow.netinsight.se>
	<20091123153133.2237b04c@marrow.netinsight.se>
	<20091125092213.423d0dd7@marrow.netinsight.se>
	<20091125.153735.28806618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:15919 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758096AbZKZHgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 02:36:41 -0500
In-Reply-To: <20091125.153735.28806618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Nov 2009 15:37:35 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> The case where you aren't getting this right:
> 
> +	/* If it's still above 6 we can't do anything */
> +	if (skb_shinfo(skb)->nr_frags > 6) {
> +		dev_err(&vptr->pdev->dev,
> +				"via-velocity: more than 6 frags, can't send.\n");
> +		return NETDEV_TX_OK;
> +	}
> 
> is bogus because you just did __skb_linearize() and it returned zero, therefore
> it would be illegal to see ->nr_frags with a > 6 value here.

Thanks for the explanation, I'll submit an updated patch. I put the
check there because I was a bit unsure about what __skb_linearize()
could do to the number of fragments. In particular, __pskb_pull_tail()
ends with

  pull_pages:
	eat = delta;
	k = 0;
	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
		if (skb_shinfo(skb)->frags[i].size <= eat) {
			put_page(skb_shinfo(skb)->frags[i].page);
			eat -= skb_shinfo(skb)->frags[i].size;
		} else {
			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
			if (eat) {
				skb_shinfo(skb)->frags[k].page_offset += eat;
				skb_shinfo(skb)->frags[k].size -= eat;
				eat = 0;
			}
			k++;
		}
	}
	skb_shinfo(skb)->nr_frags = k;

	skb->tail     += delta;
	skb->data_len -= delta;

	return skb_tail_pointer(skb);
  }

and after having crunched this in my head for a while, I couldn't
convince myself that nr_frags would always come out as less than 7 from
here. I don't claim to have done a thorough examination though.


Anyway, patch coming up.

// Simon
