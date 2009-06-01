From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Mon, 01 Jun 2009 21:47:22 +0200
Message-ID: <1243885642.22917.35.camel@pohly-MOBL>
References: <200905292344.56814.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Divy Le Ray <divy@chelsio.com>,
	Roland Dreier <rolandd@cisco.com>,
	Pavel Emelianov <xemul@openvz.org>,
	Dan Williams <dcbw@redhat.com>,
	libertas-dev@lists.infradead.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46982 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753575AbZFATr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2009 15:47:28 -0400
In-Reply-To: <200905292344.56814.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 23:44 +0930, Rusty Russell wrote:
> This patch adds skb_orphan to the start of dev_hard_start_xmit(): it
> can be premature in the NETDEV_TX_BUSY case, but that's uncommon.

Would it be possible to make the new skb_orphan() at the start of
dev_hard_start_xmit() conditionally so that it is not executed for
packets that are to be time stamped?

As discussed before
(http://article.gmane.org/gmane.linux.network/121378/), the skb->sk
socket pointer is required for sending back the send time stamp from
inside the device driver. Calling skb_orphan() unconditionally as in
this patch would break the hardware time stamping of outgoing packets.

This should work without much overhead (skb_tx() expands to a lookup of
the skb_shared_info):
if (!skb_tx(skb)->flags)
    skb_orphan(skb);

Instead of looking at the individual skb_shared_tx "hardware" and
"software" bits I'm just checking the whole byte here because it is
shorter and perhaps faster. Semantically the result is the same.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


