From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Thu, 7 Apr 2016 11:37:10 -0700
Message-ID: <CAM_iQpXbOj_zuQqHUie_yBOXqBEehHhF2FU8FA+tr7hgYY4QZg@mail.gmail.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
	<1459551391-69969-4-git-send-email-kafai@fb.com>
	<CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
	<20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
	<CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
	<20160406001141.GA97608@kafai-mba.local>
	<CAM_iQpUrcXwBH0BuCh-cjo0st6ykpUgdjRo3Cn-ViO40vtbHKA@mail.gmail.com>
	<20160406184851.GA14894@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:33760 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbcDGShL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:37:11 -0400
Received: by mail-yw0-f176.google.com with SMTP id t10so107726593ywa.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:37:10 -0700 (PDT)
In-Reply-To: <20160406184851.GA14894@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 11:49 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Wed, Apr 06, 2016 at 10:58:23AM -0700, Cong Wang wrote:
>> On Tue, Apr 5, 2016 at 5:11 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>> > On Mon, Apr 04, 2016 at 01:45:02PM -0700, Cong Wang wrote:
>> >> I see your point, but calling __ip6_datagram_connect() seems overkill
>> >> here, we don't need to update so many things in the pmtu update context,
>> >> at least IPv4 doesn't do that either. I don't think you have to do that.
>> >>
>> >> So why just updating the dst cache (also some addr cache) here is not
>> >> enough?
>> > I am not sure I understand.  I could be missing something.
>> >
>> > This patch uses ip6_datagram_dst_update() to do the route lookup and
>> > sk->sk_dst_cache update.  ip6_datagram_dst_update() is
>> > created in the first two refactoring patches and is also used by
>> > __ip6_datagram_connect().
>> >
>> > Which operations in ip6_datagram_dst_update() could be saved
>> > during the pmtu update?
>>
>> I thought you call the same ip6_datagram_dst_update() for both
>> pmtu update and __ip6_datagram_connect(), but you actually skip
>> some sk operations for pmtu case, which means you don't need
>> to worry about parallel ip6_datagram_connect().
>>
>> IPv6 UDP sendmsg() path stores the dst without sock lock anyway,
>> we don't cope with a concurrent connect() on another cpu.
> A parallel sendmsg and connect could be an issue.  The user is connecting
> to a new dest while another parallel sendmsg is sending to (could be the old
> dest, new dest or somewhere between old and new dest?)
>
> However, it is the userland making and it will be another patch if we want
> to protect this case too.

Yeah, it is a different problem, but no one complains about it yet.

>
> In pmtu update, the kernel is doing the lookup and update without the
> userland conscious.
>
>> But still, I don't see this is a problem here, because even if we store
>> an obsolete address in cache, it would be corrected later.
> The sendmsg() path will correct it (relookup and update sk_dst_cache) but not
> the getsockopt(IPV6_MTU) path which is what this patch is trying to fix: Update
> a _valid_ dst to sk->sk_dst_cache.

You are lost in discussion, I never object to update sk_dst_cache, what
we disagree here is merely if we need to lock the sock in pmtu update
context.

I still think it is okay without the lock, because even if you take the lock,
the pmtu update could still happen after you release it, so there is no
essential difference here. The only reason I can think of for taking
the sock lock is protecting parallel pmtu update, but it looks safe for
this case too.

So which case do you want to protect by taking the sock lock?
