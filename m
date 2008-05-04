From: David Miller <davem@davemloft.net>
Subject: Re: S/G operation, skb checksums, data copying
Date: Sun, 04 May 2008 15:50:47 -0700 (PDT)
Message-ID: <20080504.155047.56630645.davem@davemloft.net>
References: <1209925725.3655.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751913AbYEDWur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 18:50:47 -0400
In-Reply-To: <1209925725.3655.15.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 04 May 2008 20:28:45 +0200

> Should we do IP checksumming in software within mac80211, announce s/g
> support and hardware checksumming to the rest of the networking layer
> and hope that we only have to copy the header instead of the data for
> many packets then, if the underlying hardware is capable enough?

No, this doesn't work.

There is a correctness reason why we don't allow SG without HW
checksum support.

Those scatter-gather pages could be in the page cache for a sendfile()
or similar operation.

Any process in the system can write into and change the contents of
those pages while the packet is still in flight to the device.

So the only way to always generate correct checksums is to enforce
that the hardware do it once the full packet is in the device FIFO
after being DMA'd.

If you do the checksum in software, we'll generate incorrect checksums
if another process is writing into the page at the same time, so we
must not allow this.
