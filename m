From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: Re: [PATCH 2.6.18-rc4] aoe [04/13]: zero copy write 1 of 2
Date: Thu, 14 Sep 2006 15:50:54 -0400
Message-ID: <20060914195054.GL697__38769.1412623555$1158268651$gmane$org@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Greg K-H <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.coraid.com ([65.14.39.133]:27732 "EHLO coraid.com")
	by vger.kernel.org with ESMTP id S1751167AbWINVQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 17:16:53 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

f5d@coraid.com> <1155982692.4051.9.camel@localhost.localdomain> <20060822212150.
GQ6196@coraid.com> <1156345386.3007.24.camel@localhost.localdomain>
In-Reply-To: <1156345386.3007.24.camel@localhost.localdomain>
User-Agent: Mutt/1.5.11+cvs20060126

Hi.  Back in August I sent out some patches for the aoe driver, and
Alan objected to the direct setting of skb->len in one of them.  I
asked whether he was suggesting that we use something like this
instead of setting skb->len:

	skb->data_len = 0;
	skb_trim(skb, 0);
	skb_put(skb, sizeof *h + sizeof *ah + DEFAULTBCNT);

... and Alan said that was acceptible because it takes care of
skb->tail, checks for overflow, and is more future proof.

So I took some time to implement the necessary changes, but then it
became apparent that there was a problem.

The skb_trim and skb_put macros are only for non-linear skbuffs, but
we are only using the area inside the skbuff itself for packet
headers, not data.

When we do something like this:

	if (bio_data_dir(buf->bio) == WRITE) {
		skb_fill_page_desc(skb, 0, bv->bv_page, buf->bv_off, bcnt);
		ah.aflags |= AOEAFL_WRITE;
		skb->len += bcnt;
		skb->data_len = bcnt;
		t->wpkts++;

... skb->tail isn't really relevant, because we are only using the
pre-allocated part of the skbuff for headers, and the headers aren't
expanding here.  Other parts of the kernel that aren't putting data in
the skbuff itself set the skb->len directly.

  e1000_main.c
  ip_output.c
  tcp.c
  ip6_output.c

So is it correct for the callers of skb_fill_page_desc to set skb->len
or is another interface needed besides skb_put/skb_trim?  Such a new
interface would be able to maintain the consistency of the skbuff
fields without assuming that the data is in the skbuff itself.

If a new interface is needed, then it seems like we should set
skb->len in this patch until the new interface is ready.

-- 
  Ed L Cashin <ecashin@coraid.com>
