From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Wed, 25 Jun 2014 17:22:32 -0700
Message-ID: <CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
	<87d2dwsfh6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:46975 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbaFZAWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:22:33 -0400
Received: by mail-oa0-f42.google.com with SMTP id eb12so3060637oac.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 17:22:32 -0700 (PDT)
In-Reply-To: <87d2dwsfh6.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 5:04 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> Different net namespaces have different devices, routes, neighbours,
>> so their neigh table should be separated as well.
>
> This justification doesn't work.  Neighbour entries are per network
> device which are already per network device.

I knew, this is why I never say I am fixing a bug. I just don't see the
point of holding all such entries in one big table. Routing tables
are already separated.

>
> The only thing I see that you can gain by this work is getting around
> global limits on neighbor table size.  Something that I think is most
> unwise.

Yes, this is one the benefits.

>
> We may want a smarter limits infrastructure as it is possible to DOS one
> interface by hitting the global neigh table limit on other interfaces.
> That problem really isn't a network namespace problem except that with
> network namespaces you typically have more interfaces and can see the
> problem more easily.
>
>> This patch makes
>> gloable arp_tbl and nd_tbl etc. be per netns.
>
>> Also, as we don't support multiple tables per family, there is no
>> point to make tables chained by linked list, they can just be
>> statically compiled. This will eliminate the global neigh_tbl_lock.
>
> There might to this lock removal, but mixing the lock removal in with
> everything else winds up with extra noise, and code that looks
> suspiciously messy.
>
> At the very least neigh_tbl_lock today protects against rmmod decnet
> and rmmod ipv6, which while unlikely can oops they kernel if they aren't
> handled carefully.  So it definitely feels inappropriate to mush these
> all together.

At module exit, we should call unregister_pernet_subsys(), where
each ->exit() will called.

>
> If your goal is to deal with the issue of the limited set of neighbour
> limits say so and let's look at that problem.
>
> If your goal is just to kill neigh_tbl_lock please take that to a
> separate patch where the pros and cons can be weighed, and people can
> focus on the issue.
>

Neither.

> As it stands this patch does too much, and seems to do nothing except
> bypass controls on global kernel memory consumption.
>

I agree it's too big, I can split it into two if you want. One for removing
neigh_tbl_lock, one for making it per netns.

Thanks.
