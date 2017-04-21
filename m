From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when
 intersecting features
Date: Fri, 21 Apr 2017 11:53:17 -0700
Message-ID: <CAKgT0UemA58zY3x=ahkhN6dO91uHvxPL-OT+O4Xv37AZz1BqrQ@mail.gmail.com>
References: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
 <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
 <b34063e7-e0c2-583d-f809-02386fc175de@redhat.com> <20170421053325.GH13789@unicorn.suse.cz>
 <CAGCdqXFM-+OeQFznZ9kcjpnyeBU=1gcdjv1v7RR3KEGPyiZ_GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35464 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424007AbdDUSxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:53:21 -0400
Received: by mail-io0-f170.google.com with SMTP id r16so124988877ioi.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:53:20 -0700 (PDT)
In-Reply-To: <CAGCdqXFM-+OeQFznZ9kcjpnyeBU=1gcdjv1v7RR3KEGPyiZ_GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 10:33 AM, Vladislav Yasevich
<vyasevich@gmail.com> wrote:
> On Fri, Apr 21, 2017 at 1:33 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>> On Thu, Apr 20, 2017 at 07:19:55PM -0400, Vlad Yasevich wrote:
>>>
>>> Having said that, the other alternative is to inherit hw_features from
>>> lower devices.  BTW, bonding I think has a similar "issue" you are
>>> describing since it prefers HW_CSUM if any of the slaves have it set.
>>
>> It does but bonding uses netdev_increment_features() to combine slave
>> features and this function handles checksumming like "or", not "and"
>> (not only checksumming, also flags in NETIF_F_ONE_FOR_ALL).
>>
>
> I am not saying that it doesn't.  What I am saying is that if you
> form a bond with two devices: one with only NETIF_F_IP_CSUM and the
> other with NETIF_F_HW_CSUM, then the bonding device will have NETIF_F_HW_CSUM
> set.  This is similar to what is being proposed in the patch.
>
> Alex's objection, at least as I understand it, is that we never want to
> allow the above condition.  However, it looks like we already allow it
> and correctly handle it.

My objection is that the change as you have proposed it doesn't work
that way. It is one thing to advertise NETIF_F_HW_CSUM on an upper
device, the problem is netdev_intersect_features isn't used on just
the upper device. It is used to perform what is essentially a logical
AND of the features. What you are doing changes that logic. That is
why I suggested fixing this in the VLAN driver code instead.

>> That said, it's legitimate to ask if we want some of the features to be
>> handled differently when computing features for a vlan device. My point
>> before was that if the helper is called netdev_intersect_features(), it
>> shouldn't return any features that are not supported by both argument
>> sets, even if all its current users would benefit from slightly
>> different behaviour. If it does, it's a trap that someone might one day
>> fall in.
>
> Ok.  I think I understand, but we've always handled the checksum intersection
> stangely.  I'll see what I can figure out.
>

I'm okay with us setting NETIF_F_HW_CSUM if the lower device supports
any checksum offload. I just don't want the change to impact
netif_skb_features() in any way that could cause us to advertise
offload support that isn't there. That was why I suggested updating
vlan_dev_fix_features so that it would zero out the IP_CSUM and
IP6_CSUM flags and set the HW_CSUM if any offload was supported.
Basically it would just consist of adding the following lines after
the calls to netdev_intersect_features:

if (features & NETIF_F_CSUM_MASK) {
        features &= ~NETIF_F_CSUM_MASK;
        features |= NETIF_F_HW_CSUM;
}

Just that should be enough to resolve the issues you were seeing and
make it so that you always advertise NETIF_F_HW_CSUM instead of
IP_CSUM or IPV6_CSUM.

- Alex
