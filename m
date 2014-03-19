From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Wed, 19 Mar 2014 15:59:30 -0400 (EDT)
Message-ID: <20140319.155930.1805664690676428310.davem@davemloft.net>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbaCST7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 15:59:32 -0400
In-Reply-To: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Mon, 17 Mar 2014 18:01:33 +0530

> NIC drivers that support RSS use either a hard-coded value or a random value for
> the RSS hash key. Irrespective of the type of the key used, the user would want
> to change the hash key if he/she is not satisfied with the effectiveness of the
> default hash-key in spreading the incoming flows evenly across the RSS queues.
> 
> This patch set adds support for configuring the RSS hash-key via the ethtool
> interface using -X option.

I apologize, but I really dislike this.  For several reasons.

First, why aren't we adding _just_ a RSS hash changing interface?

We already have an interface for changing the indirection table,
there is absolutely not need to add a second interface that supports
both indirection table _plus_ hash modifications.

And combining these two is what leads to this hard to audit, ugly,
data structure layout.

There's the indirection table at some offset, then the key at some
other offset.  This makes it impossible to impose type checking
of any kind on both objects.

And the data structure is furthermore named in a way that suggests
it's just for doing things with the RSS hash.

Just add:

struct ethtool_rxfh {
	__u32	cmd;
	__u32	key_size;
	__u32	key[0];
};

And that's it.

To change the indirection table, call "ETHTOOL_SRXFH".  To set the
RSS flow hash, call "ETHTOOL_SRSSH".
