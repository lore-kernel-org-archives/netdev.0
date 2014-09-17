From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 16:39:25 -0400
Message-ID: <5419F17D.2090409@gmail.com>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com> <CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com> <20140917190626.GA11354@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Florian Westphal <fw@strlen.de>, Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:62641 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556AbaIQUj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:39:28 -0400
Received: by mail-qc0-f179.google.com with SMTP id x13so281295qcv.38
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 13:39:28 -0700 (PDT)
In-Reply-To: <20140917190626.GA11354@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2014 03:06 PM, Florian Westphal wrote:
> Cong Wang <cwang@twopensource.com> wrote:
>> On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
>>> This used to work in older releases.
>>> The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
>>> on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
>>> to inherit its features from the lower device.
>>>
>>> Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
>>> lower device
>>> by macvlan interfaces?
>>
>> commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
>> so just clear this flag. Please submit a patch.
> 
> Under which conditions would NETIF_F_NETNS_LOCAL have to be inherited?
> (i.e., why is it inheritable in the first place?)

macvlan code calls
        features = netdev_increment_features(vlan->lowerdev->features,
                                             features,
                                             mask);

where lowerdev->features contains the NETIF_F_NETNS_LOCAL bit.  That
bit is not set in features or in mask.  It is also not one of the ALL_FOR_ALL
bits so it's not turned off.

As an example, here are the values from a quit test I ran:

bond features = 0x400f3888
features = 0x3b5a09  (mask is the same).
incremented features = 0x41bf389

NETIF_F_NETNS_LOCAL is still on.

May be a better solution is:

        features = netdev_increment_features(vlan->lowerdev->features & MACVLAN_FEATURS,
                                             features,
                                             mask);

This way we start with only the feature MACVLAN is interested in.

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
