From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Tue, 23 May 2017 09:29:29 -0700
Message-ID: <CAKgT0UfONzqdcaLGbwomhmRuvPvNWUsEszL6u+fGOo7bM5NirA@mail.gmail.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com> <20170522.195921.1033609103219347751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        "vyasevic@redhat.com" <vyasevic@redhat.com>,
        makita.toshiaki@lab.ntt.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35440 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757756AbdEWQ3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:29:31 -0400
Received: by mail-it0-f44.google.com with SMTP id c15so22783520ith.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:29:30 -0700 (PDT)
In-Reply-To: <20170522.195921.1033609103219347751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 4:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Thu, 18 May 2017 09:31:03 -0400
>
>> It appears that since commit 8cb65d000, Q-in-Q vlans have been
>> broken.  The series that commit is part of enabled TSO and checksum
>> offloading on Q-in-Q vlans.  However, most HW we support can't handle
>> it.  To work around the issue, the above commit added a function that
>> turns off offloads on Q-in-Q devices, but it left the checksum offload.
>> That will cause issues with most older devices that supprort very basic
>> checksum offload capabilities as well as some newer devices (we've
>> reproduced te problem with both be2net and bnx).
>>
>> To solve this for everyone, turn off checksum offloading feature
>> by default when sending Q-in-Q traffic.  Devices that are proven to
>> work can provided a corrected ndo_features_check implemetation.
>>
>> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>
> This is a tough one.  I can certainly sympathize with your frustration
> trying to track this down.
>
> Clearing NETIF_F_HW_CSUM completely is the most conservative change.
>
> However, for all the (perhaps many) cards upon which the checksumming
> does work properly in Q-in-Q situations, this change could be
> introducing non-trivial performance regressions.
>
> So I think Toshiaki's suggestion to drop IP_CSUM and IPV6_CSUM is,
> on balance, the best way forward.
>
> Thanks.

I would have to agree. I think we can simplify all this since all we
are essentially looking at doing is dropping the
netdev_features_intersect call and instead just do an AND instead of
fuzzing for the other CSUM bits. That way we don't have to worry about
systems that might only be able to handle frames that are IPv4/v6
with one level of VLAN and should be able to support multiple levels
of mixed headers.

We probably should add a comment about HW_CSUM being the only one we
can support as well so nobody comes back later and tries to revert the
change.

- Alex
