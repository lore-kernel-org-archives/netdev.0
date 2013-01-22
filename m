From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 14:15:24 -0800
Message-ID: <1358892924.12374.157.camel@edumazet-glaptop>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
	 <1358892199.12374.139.camel@edumazet-glaptop>
	 <20130122.170826.1481012610894653735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55142 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354Ab3AVWP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:15:28 -0500
Received: by mail-pa0-f41.google.com with SMTP id bj3so4318021pad.14
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:15:28 -0800 (PST)
In-Reply-To: <20130122.170826.1481012610894653735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 17:08 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Jan 2013 14:03:19 -0800
> 
> > An application changing data provided on a sendfile() or vmsplice() cant
> > really expect data integrity being respected, even if checksum are done
> > by the NIC (TSO)
> > 
> > So if data integrity is not respected, just send a bogus TX checksum.
> 
> I disagree.
> 
> As a quality of implementation decision, we should always compute
> correct checksums, ragardless of whether the page contents can be
> modified asynchronously during the packet transmit.

The retransmits will compute the correct checksums.

For a very unlikely operation from the user, we want to disable GSO on
GRE.

If so, just revert my GSO patch.

This is plain stupid to cook GSO packets and then linearize them, adding
an extra copy and a point of failure, as allocating a 128K skb->head
will probably fail very easily.

Now, tcp_sendmsg() cooked skb are fine, and this patch assumes they are
not.

This patch is absolutely wrong.
