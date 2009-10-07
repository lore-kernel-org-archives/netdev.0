From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: skb_shinfo(skb)->nr_frags > 0 while skb_is_gso(skb) == 0?
Date: Tue, 6 Oct 2009 18:37:11 -0700
Message-ID: <1254879431.9111.13.camel@HP1>
References: <20091007010315.GA26498@neptune.jswright>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Bob Montgomery" <bob.montgomery@hp.com>
To: "John Wright" <john.wright@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933870AbZJGBqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 21:46:49 -0400
In-Reply-To: <20091007010315.GA26498@neptune.jswright>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2009-10-06 at 18:03 -0700, John Wright wrote:
> So, first, a question for someone who knows more about sk_buff's than
> I:
> is it reasonable/legal for an skb for which skb_is_gso(skb) == 0 to
> also
> have skb_shinfo(skb)->nr_frags > 0?
> 

As Stephen pointed out, yes.

> If yes, then for Michael, or someone familiar with bnx2 hardware: are
> "partial BD completions" (where the hw_tx_cons value is on a ring
> index
> that, on the tx_buf_ring, would have a NULL skb value, and on the
> tx_desc_ring, the tx_bd would not have the TX_BD_FLAGS_START flag set)
> possible only for gso skb's, or is it possible any time nr_frags > 0?
> 

Partial BD completions are only possible on TSO/GSO packets, unless
there is a hardware bug that we haven't found during all these years.

Several years ago, the same crash in bnx2 was found to be caused by HTB
corrupting nr_frags while the skb was queued by the driver.  That issue
has been fixed.  I wonder if skb->gso_size can change on us while the
skb is queued or we still have another case of changing nr_frags.

I think it will be good if you can run the same test on 2.6.31 where
is_gso and nr_frags are cached.  If the chip really does partial BD
completions on TX, you should still see the same issue whether we cache
these values or not.  If it doesn't crash on 2.6.31, then it may be
something else.

Thanks for the detailed debugging information.


