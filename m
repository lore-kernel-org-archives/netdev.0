From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] bonding: fix two race conditions in bond_store_updelay/downdelay
Date: Thu, 14 Nov 2013 09:50:20 +0800
Message-ID: <52842C5C.6080505@huawei.com>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com> <1384362214.28458.117.camel@edumazet-glaptop2.roam.corp.google.com> <5283B19A.9050302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:6706 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab3KNBvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 20:51:03 -0500
In-Reply-To: <5283B19A.9050302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/14 1:06, Nikolay Aleksandrov wrote:
> On 11/13/2013 06:03 PM, Eric Dumazet wrote:
>> On Wed, 2013-11-13 at 17:07 +0100, Nikolay Aleksandrov wrote:
>>> This patch fixes two race conditions between bond_store_updelay/downdelay
>>> and bond_store_miimon which could lead to division by zero as miimon can
>>> be set to 0 while either updelay/downdelay are being set and thus miss the
>>> zero check in the beginning, the zero div happens because updelay/downdelay
>>> are stored as new_value / bond->params.miimon. Use rtnl to synchronize with
>>> miimon setting.
>>
>> It seems a bit heavy duty to take rtnl for this.
>>
>> Using ACCESS_ONCE() in bonding_store_updelay()/bonding_store_downdelay()
>> should be enough ?
>>
>> int miimon = ACCESS_ONCE(bond->params.miimon);
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> Hi Eric,
> I thought about this version too, but downdelay/updelay can be changed in other
> places (e.g., store_miimon) and the resulting downdelay/updelay value might not
> be the right one.
> Correct me if I'm wrong, but this is what I have in mind (miimon = 100, updelay
> = 200):
> set miimon to 300 and concurrently set updelay to 400, we might endup leaving
> updelay to 400 because the old value of miimon is used in the calculation in
> store_updelay even though when changing miimon updelay/downdelay get adjusted,
> they might get adjusted by store_updelay/downdelay to a wrong value afterwards.
> 
>  Nik
> 
> 
agree, set miimon and set updelay may conflict.

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
