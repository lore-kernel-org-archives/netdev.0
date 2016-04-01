From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] net: skbuff: don't use union for napi_id
 and sender_cpu
Date: Fri, 01 Apr 2016 06:04:19 -0700
Message-ID: <1459515859.6473.277.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
	 <1459403439-6011-2-git-send-email-jasowang@redhat.com>
	 <1459420341.6473.225.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDD94E.8090908@redhat.com>
	 <1459479325.6473.260.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDFDDB.7090606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34310 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536AbcDANEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 09:04:22 -0400
In-Reply-To: <56FDFDDB.7090606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 12:49 +0800, Jason Wang wrote:
> 
> On 04/01/2016 10:55 AM, Eric Dumazet wrote:
> > On Fri, 2016-04-01 at 10:13 +0800, Jason Wang wrote:
> >
> >
> >> The problem is we want to support busy polling for tun. This needs
> >> napi_id to be passed to tun socket by sk_mark_napi_id() during
> >> tun_net_xmit(). But before reaching this, XPS will set sender_cpu will
> >> make us can't see correct napi_id.
> >>
> > Looks like napi_id should have precedence then ?
> 
> But then when busy polling is enabled, we may still hit the issue before
> commit 2bd82484bb4c5db1d5dc983ac7c409b2782e0154? So looks like sometimes
> (e.g for tun), we need both two fields.

You did not clearly show me the path you take where both fields would be
needed. If you expect me to do that, it wont happen.

> 
> >
> > Only forwarding should allow the field to be cleared to allow XPS to do
> > its job.
> >
> > Maybe skb_sender_cpu_clear() was removed too early (commit
> > 64d4e3431e686dc37ce388ba531c4c4e866fb141)
> 
> Not sure I get you, but this will clear napi_id too.

Only when allowed. In your case it would not be called.

Some people do not use tun, and want to forward or cook millions of
packets per second. sk_buff size is critical. 

If busy polling gives you 5 % of performance improvement, but cost
everyone else a performance decrease, this is a serious problem.

XPS is a sender problem, NAPI is a receiver problem. Fields should be
shared.
