From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen
 logic
Date: Thu, 21 Nov 2013 12:57:07 -0500 (EST)
Message-ID: <20131121.125707.653753874005080724.davem@davemloft.net>
References: <20131121003828.GA32587@order.stressinduktion.org>
	<528E1E2E.20905@gmail.com>
	<1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3KUR5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 12:57:09 -0500
In-Reply-To: <1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 07:00:14 -0800

> So a protocol should use BUILD_BUG_ON() to make sure sockaddr_storage is
> big enough.

Hannes mentioned trying to do this, somehow, automatically.  Best I could
come up with is something like:

#define DECLARE_RECVMSG_HANDLER(name, ..., sockaddr_type) \
static ... __name(...); \
static ... name(...)	\
{	\
	BUILD_BUG_ON(sizeof(sockaddr_type) > sizeof(sockaddr_storage); \
	__name(...); \
} \
static ... __name(...)

And then the protocols go:

DECLARE_RECVMSG_HANDLER(udp_recvmsg, ..., struct sockaddr_in)
{
	struct inet_sock *inet = inet_sk(sk);
	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 ...

You get the idea.

Slightly convoluted, and we can do something special with types or the
prot ops member name to enforce usage of the macro.
