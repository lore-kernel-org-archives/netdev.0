From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Tue, 13 Oct 2015 18:45:39 -0700 (PDT)
Message-ID: <20151013.184539.1401344867685512636.davem@davemloft.net>
References: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com,
	nicolas.dichtel@6wind.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbbJNB3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 21:29:37 -0400
In-Reply-To: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 12 Oct 2015 09:33:07 -0700

> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
 ...
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the setting is
> reset global addresses with no expire times are not flushed:
 ...
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Here is what I really don't like about these changes: the failure
semantics are terrible.

If I add an address or a route, and some memory allocation fails, I get
a notification and see that my operation did not succeed.

But here, my routes can fail to be added during an ifup and all I will
get, at best, is a kernel log message.

This places a serious disconnect between what the user asked for and
making sure he finds out directly that his operation did not really
fully succeed.

In fact, this failure handling here during ifup leaves the interface in
a partially configured state.

There are really two ways to deal with this properly:

1) Propagate the failure back through the notifiers and fail the ifup
   completely when the addrconf_dst_alloc() fails.

2) On ifdown, stash the objects away somewhere so that memory allocation
   is not necessary on ifup.

Neither are really smooth approaches, but they have the attribute that
they give the user clean behavior and semantics.
