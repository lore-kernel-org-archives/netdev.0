From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Mon, 13 Sep 2010 20:17:30 -0700 (PDT)
Message-ID: <20100913.201730.27805132.davem@davemloft.net>
References: <1284410580.13351.10.camel@localhost.localdomain>
	<1284410883.13351.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avi@redhat.com, arnd@arndb.de, mst@redhat.com,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1284410883.13351.14.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>
Date: Mon, 13 Sep 2010 13:48:03 -0700

> +		base = (unsigned long)from->iov_base + offset1;
> +		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> +		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
> +		if ((num_pages != size) ||
> +		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
> +			/* put_page is in skb free */
> +			return -EFAULT;

What keeps the user from writing to these pages in it's address space
after the write call returns?

A write() return of success means:

	"I wrote what you gave to me"

not

	"I wrote what you gave to me, oh and BTW don't touch these
         pages for a while."

In fact "a while" isn't even defined in any way, as there is no way
for the write() invoker to know when the networking card is done with
those pages.
