From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Subject: Re: [PATCH] ethtool: Zero memory allocated for statistics
Date: Sat, 15 Oct 2016 17:13:09 +0200
Message-ID: <CAH0z3hPgebpUF_PCf0LCRDdJpH_JH3ASRhONjr2j4NYJDXCzuA@mail.gmail.com>
References: <1476439158-66060-1-git-send-email-vlad@tsyrklevich.net>
 <20161014.212128.1303887902157786593.davem@davemloft.net> <CAH0z3hMSTAWQK550gTpZ3jv1BnEpjHKoCC6wz182YYHLVcesQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38493 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbcJOPNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 11:13:11 -0400
Received: by mail-wm0-f42.google.com with SMTP id d128so32296582wmf.1
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 08:13:11 -0700 (PDT)
In-Reply-To: <CAH0z3hMSTAWQK550gTpZ3jv1BnEpjHKoCC6wz182YYHLVcesQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree that we should propagate those errors and I'll prepare a new
change to do so for phy_driver.get_stats(), ethtool_ops.self_test(),
and ethtool_ops.get_ethtool_stats(). However, I still think this
change should be adopted. 3/5 of the cases here are reachable without
any special capabilities and programming defensively at the ethtool
interface can eliminate an entire class of potential driver bugs
instead of fixing them one by one. For example, get_eeprom()
propagates errors but with a brief grep I found that
qlcnic_get_eeprom() will return 0 incorrectly even though it read
nothing for some NICs. Deeper bugs are undoubtedly laying around.

On Sat, Oct 15, 2016 at 5:11 PM, Vlad Tsyrklevich <vlad@tsyrklevich.net> wrote:
> I agree that we should propagate those errors and I'll prepare a new change
> to do so for phy_driver.get_stats(), ethtool_ops.self_test(), and
> ethtool_ops.get_ethtool_stats(). However, I still think this change should
> be adopted. 3/5 of the cases here are reachable without any special
> capabilities and programming defensively at the ethtool interface can
> eliminate an entire class of potential driver bugs instead of fixing them
> one by one. For example, get_eeprom() propagates errors but with a brief
> grep I found that qlcnic_get_eeprom() will return 0 incorrectly even though
> it read nothing for some NICs. Deeper bugs are undoubtedly laying around.
>
> On Sat, Oct 15, 2016 at 3:21 AM David Miller <davem@davemloft.net> wrote:
>>
>> From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
>> Date: Fri, 14 Oct 2016 11:59:18 +0200
>>
>> > enic_get_ethtool_stats()
>>
>> Looknig merely at this shows the real problem.
>>
>> We don't propagate and handle errors for this method.
>>
>> And that's what we should fix, making the get_ethtool_stats() method
>> return an integer error.
>>
>> Then ethtool_get_stats() should return any non-zero value provided by
>> ops->get_ethtool_stats() and not attempt to copy any bytes of 'data'
>> to userspace in that case.
