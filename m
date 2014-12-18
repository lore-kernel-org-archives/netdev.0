From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net 2/2] geneve: Fix races between socket add and release.
Date: Thu, 18 Dec 2014 10:34:39 -0800
Message-ID: <CAEP_g=81tz9UhgCde8h44mCa4GoBQy9t3XezOaQnUbJcjYyWLg@mail.gmail.com>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
 <1418783132-99230-2-git-send-email-jesse@nicira.com> <20141217165454.GE28766@casper.infradead.org>
 <CAEP_g=_-hgeosH83FdPZLb9mvi5DSW6mbe+Xe5x0YoR7mKaTPA@mail.gmail.com> <20141217211513.GF28766@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:58751 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751057AbaLRSfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 13:35:00 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so1313809qcy.4
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 10:34:59 -0800 (PST)
In-Reply-To: <20141217211513.GF28766@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 1:15 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/17/14 at 10:48am, Jesse Gross wrote:
>> I generally agree (with the exception of kfree_rcu() - I believe that
>> is still needed since incoming packets reference it using RCU).
>
> I didn't inspect this in full detail but seems like the data path
> should only care about gs->sock which is properly refcnt'ed.

The data path (if you include the consumer in OVS), goes from sk to gs
to gs->rcv_data so it does care about the stuff that is being freed
here.

>> for destroying the socket. This was added by Stephen in "vxlan: listen
>> on multiple ports" but it's not obvious to me what problem it is
>> trying to avoid and I don't see a comment. If possible, it would be
>> nice to simplify this as well if the issue doesn't apply to Geneve.
>
> I don't have an explanation for that either. Each entry on the
> vni_list[] takes a vs->refcnt.

I don't think the workqueue is about refcounting - it looks to me like
the issue that is being avoided is either that RTNL is held and a
lower layer tries to take it again or another lock that nests in the
opposite way with RTNL. However, looking through the code, the problem
wasn't obvious to me.
