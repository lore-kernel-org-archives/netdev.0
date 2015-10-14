From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 11:34:01 +0200
Message-ID: <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
References: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
 <20151013.184539.1401344867685512636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com,
	nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39293 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751478AbbJNJeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 05:34:02 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C8EB4207BE
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 05:34:01 -0400 (EDT)
In-Reply-To: <20151013.184539.1401344867685512636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Oct 14, 2015, at 03:45, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 12 Oct 2015 09:33:07 -0700
> 
> > Currently, all ipv6 addresses are flushed when the interface is configured
> > down, including global, static addresses:
>  ...
> > Add a new sysctl to make this behavior optional. The new setting defaults to
> > flush all addresses to maintain backwards compatibility. When the setting is
> > reset global addresses with no expire times are not flushed:
>  ...
> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Here is what I really don't like about these changes: the failure
> semantics are terrible.
> 
> If I add an address or a route, and some memory allocation fails, I get
> a notification and see that my operation did not succeed.
> 
> But here, my routes can fail to be added during an ifup and all I will
> get, at best, is a kernel log message.
> 
> This places a serious disconnect between what the user asked for and
> making sure he finds out directly that his operation did not really
> fully succeed.
> 
> In fact, this failure handling here during ifup leaves the interface in
> a partially configured state.

Agreed, it would be better.

> There are really two ways to deal with this properly:
> 
> 1) Propagate the failure back through the notifiers and fail the ifup
>    completely when the addrconf_dst_alloc() fails.
> 
> 2) On ifdown, stash the objects away somewhere so that memory allocation
>    is not necessary on ifup.

In regard to error propagation I think 2) is the only viable option. I
don't think why you shouldn't be able to simply remove the ip6_rt_put
after the ip6_del_rt and keep the dst_entry hanging there and later
reinsert.

> Neither are really smooth approaches, but they have the attribute that
> they give the user clean behavior and semantics.

On another node:

This sysctl is on my list to be enabled soon by default by any systemd
based distribution. For that reason, could you maybe remove all the
unlikely annotations from your code. It really doesn't matter in
configuration code, because it is not performance critical and in my
opinion just distracts.

Thanks,
Hannes
