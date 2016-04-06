From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Wed, 6 Apr 2016 10:58:23 -0700
Message-ID: <CAM_iQpUrcXwBH0BuCh-cjo0st6ykpUgdjRo3Cn-ViO40vtbHKA@mail.gmail.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
	<1459551391-69969-4-git-send-email-kafai@fb.com>
	<CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
	<20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
	<CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
	<20160406001141.GA97608@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:35105 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbcDFR6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 13:58:24 -0400
Received: by mail-yw0-f177.google.com with SMTP id i84so60383527ywc.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 10:58:23 -0700 (PDT)
In-Reply-To: <20160406001141.GA97608@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 5, 2016 at 5:11 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Mon, Apr 04, 2016 at 01:45:02PM -0700, Cong Wang wrote:
>> I see your point, but calling __ip6_datagram_connect() seems overkill
>> here, we don't need to update so many things in the pmtu update context,
>> at least IPv4 doesn't do that either. I don't think you have to do that.
>>
>> So why just updating the dst cache (also some addr cache) here is not
>> enough?
> I am not sure I understand.  I could be missing something.
>
> This patch uses ip6_datagram_dst_update() to do the route lookup and
> sk->sk_dst_cache update.  ip6_datagram_dst_update() is
> created in the first two refactoring patches and is also used by
> __ip6_datagram_connect().
>
> Which operations in ip6_datagram_dst_update() could be saved
> during the pmtu update?

I thought you call the same ip6_datagram_dst_update() for both
pmtu update and __ip6_datagram_connect(), but you actually skip
some sk operations for pmtu case, which means you don't need
to worry about parallel ip6_datagram_connect().

IPv6 UDP sendmsg() path stores the dst without sock lock anyway,
we don't cope with a concurrent connect() on another cpu. But
still, I don't see this is a problem here, because even if we store
an obsolete address in cache, it would be corrected later.
