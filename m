From: Cong Wang <cwang@twopensource.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 13:46:55 -0700
Message-ID: <CAHA+R7M5+1gbfx7pv=bPdNempL1eeXRu-J79c29z1k6Mr-aXfA@mail.gmail.com>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
	<CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
	<20140917190626.GA11354@breakpoint.cc>
	<5419F17D.2090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:61482 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416AbaIQUq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:46:57 -0400
Received: by mail-lb0-f175.google.com with SMTP id n15so2599143lbi.20
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 13:46:55 -0700 (PDT)
In-Reply-To: <5419F17D.2090409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 1:39 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 09/17/2014 03:06 PM, Florian Westphal wrote:
>> Cong Wang <cwang@twopensource.com> wrote:
>>> On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
>>>> This used to work in older releases.
>>>> The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
>>>> on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
>>>> to inherit its features from the lower device.
>>>>
>>>> Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
>>>> lower device
>>>> by macvlan interfaces?
>>>
>>> commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
>>> so just clear this flag. Please submit a patch.
>>
>> Under which conditions would NETIF_F_NETNS_LOCAL have to be inherited?
>> (i.e., why is it inheritable in the first place?)
>
> macvlan code calls
>         features = netdev_increment_features(vlan->lowerdev->features,
>                                              features,
>                                              mask);
>
> where lowerdev->features contains the NETIF_F_NETNS_LOCAL bit.  That
> bit is not set in features or in mask.  It is also not one of the ALL_FOR_ALL
> bits so it's not turned off.
>
> As an example, here are the values from a quit test I ran:
>
> bond features = 0x400f3888
> features = 0x3b5a09  (mask is the same).
> incremented features = 0x41bf389
>
> NETIF_F_NETNS_LOCAL is still on.

I think the comment on netdev_increment_features() is clear:

 *      Computes a new feature set after adding a device with feature set
 *      @one to the master device with current feature set @all.  Will not
 *      enable anything that is off in @mask. Returns the new feature set.

And NETIF_F_NETNS_LOCAL is on in mask.

>
> May be a better solution is:
>
>         features = netdev_increment_features(vlan->lowerdev->features & MACVLAN_FEATURS,
>                                              features,
>                                              mask);
>
> This way we start with only the feature MACVLAN is interested in.
>

Or clear it in mask?
