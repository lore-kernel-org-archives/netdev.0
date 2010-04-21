From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 19:01:27 -0700 (PDT)
Message-ID: <20100420.190127.66303903.davem@davemloft.net>
References: <20100420.181648.183008607.davem@davemloft.net>
	<Pine.LNX.4.64.1004202120180.29631@hs20-bc2-1.build.redhat.com>
	<20100420.182407.174368203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638Ab0DUCBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:01:23 -0400
In-Reply-To: <20100420.182407.174368203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I looked more at your crash report.

You shouldn't even be in this code path for other reasons, namely
skb->next should be NULL.  But it's not in your case.  skb->next would
only be non-NULL for GSO frames, which we've established we should not
be seeing here.

Given that skb->next is non-NULL and the fraglists of this SKB are
corrupted (next pointer is 0x18), I think we're getting memory
corruption from somewhere else.  This also jives with the fact that
this is not readily reproducable.

The whole ->ndo_start_xmit() return value stuff is unrelated to this
issue, we shouldn't even be in this code path.  In fact, if reverting
that TX flags handling commit makes your crashes go away it would be a
huge surprise.
