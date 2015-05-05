From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 04 May 2015 22:32:04 -0400
Message-ID: <55482BA4.9070607@gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>	<20150504133943.GA17043@x131e>	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com> <20150504132714.55dca5b0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35346 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbbEECcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 22:32:09 -0400
Received: by qgej70 with SMTP id j70so75156426qge.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 19:32:06 -0700 (PDT)
In-Reply-To: <20150504132714.55dca5b0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 04:27 PM, Stephen Hemminger wrote:
> On Mon, 4 May 2015 11:45:41 -0700
> Cong Wang <cwang@twopensource.com> wrote:
> 
>> On Mon, May 4, 2015 at 6:39 AM, Dominick Grift <dac.override@gmail.com> wrote:
>>> On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
>>>> Hi All,
>>>>
>>>> We've had a user report the following backtrace from the bridge module
>>>> with a recent Linus' tree.  Has anything like this been reported yet?
>>>> If you have any questions on setup, the user is CC'd.
>>>>
>>>> josh
>>>>
>>>> [   29.382235] br0: port 1(tap0) entered forwarding state
>>>>
>>>> [   29.382286] ===============================
>>>> [   29.382315] [ INFO: suspicious RCU usage. ]
>>>> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
>>>> [   29.382380] -------------------------------
>>>> [   29.382409] net/bridge/br_private.h:626 suspicious
>>>> rcu_dereference_check() usage!
>>>
>>> <snip>
>>>
>>> With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly changed:
>>>
>>
>> Should be the same issue. Please give the attached patch a try,
>> it is compile-tested only.
>>
>> Thanks!
> 
> Good analysis in identifying the issue. But the proposed patch
> doesn't seem right.
> 
> The br->lock protects against changes to the bridge port state.
> vlan_info should be treated as part of the bridge state.
> 
> The correct fix is to get vlan_info out of depending on RTNL
> and use br->lock to control modifications.
> 

Changing the write side protection to be dependent on br->lock would
then require rcu or lock to be held in br_getlink().  It all
boils down to the same thing.  br_fill_info() needs to be either
in rcu or locked context.  It's already in rtnl context, so Eric's
proposal is the simplest one.

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
