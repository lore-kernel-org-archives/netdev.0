From: David Miller <davem@davemloft.net>
Subject: Re: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 02:09:03 -0700 (PDT)
Message-ID: <20090915.020903.93643290.davem@davemloft.net>
References: <1253003420.7549.51.camel@debian>
	<20090915.013321.07006714.davem@davemloft.net>
	<1253005050.7549.58.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mel@csn.ul.ie, reinette.chatre@intel.com, elendil@planet.nl,
	Larry.Finger@lwfinger.net, linville@tuxdriver.com,
	penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, akpm@linux-foundation.org,
	cl@linux-foundation.org, assaf.krauss@intel.com,
	johannes@sipsolutions.net, mohamed.abbas@intel.com,
	netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751864AbZIOJI5@vger.kernel.org>
In-Reply-To: <1253005050.7549.58.camel@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhu Yi <yi.zhu@intel.com>
Date: Tue, 15 Sep 2009 16:57:29 +0800

> Thanks. So we can put the 8K buffer into 2 skb_shinfo()->frags[] slots
> and set nr_frags to 2, right? Is this supported allover the network code
> already? At a first glance, I didn't find any frags handling in mac80211
> stack.

You have to pre-pull the link level protocol headers into the
linear area, but that's it.

Again, see niu.c for details, it does:

static void niu_rx_skb_append(struct sk_buff *skb, struct page *page,
			      u32 offset, u32 size)
{
	int i = skb_shinfo(skb)->nr_frags;
	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];

	frag->page = page;
	frag->page_offset = offset;
	frag->size = size;

	skb->len += size;
	skb->data_len += size;
	skb->truesize += size;

	skb_shinfo(skb)->nr_frags = i + 1;
}

to add pages to SKBs and then at the end it goes:

	skb_reserve(skb, NET_IP_ALIGN);
	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));

Right before giving the SKB to the networking stack.  NIU_RXPULL_MAX
should be a value that will be large enough to cover the largest
possible link level header.
