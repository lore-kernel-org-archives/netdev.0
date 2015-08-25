From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Tue, 25 Aug 2015 15:41:36 -0700
Message-ID: <55DCEF20.5080908@cumulusnetworks.com>
References: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>	<20150824001514.GD21926@pox.localdomain>	<55DA7AFE.5040301@cumulusnetworks.com> <20150825.134759.1592811364914291771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36129 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbHYWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:41:38 -0400
Received: by pacgr6 with SMTP id gr6so4553643pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:41:38 -0700 (PDT)
In-Reply-To: <20150825.134759.1592811364914291771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 1:47 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 23 Aug 2015 20:01:34 -0600
>
>> On 8/23/15 6:15 PM, Thomas Graf wrote:
>>> On 08/23/15 at 08:26am, David Ahern wrote:
>>>> inetpeer caches based on address only, so duplicate IP addresses
>>>> within
>>>> a namespace return the same cached entry. Similar to IP fragments
>>>> handle
>>>> duplicate addresses across VRFs by adding the VRF master device index
>>>> to
>>>> the lookup.
>>>
>>> We have a lot of other places which use the address only. Are you
>>> going to add the VRF id to all these places as well?
>>>
>>
>> If appropriate, yes. I have fixed IP fragments and this patch fixes
>> inetpeer cache. In both cases (L3 artifacts) the vrf device index
>> provides the means to uniquely identify duplicate IP addresses within
>> a namespace. If you know of other code that might be impacted I will
>> investigate and fix as needed.
>
> Anyways, what this inetpeer patch is doing is the wrong abstraction.
>
> The key is really "daddr + netdev" so make a helper that works using
> those arguments.

That's what I have here:

struct inetpeer_addr {
         struct inetpeer_addr_base       addr;
         __u16                           family;
#if IS_ENABLED(CONFIG_NET_VRF)
         int vif;
#endif
};

the addr_compare then checks the vif (VRF device index) after the N-word 
address compare.

>
> Then it is clear as we propagate this around that addresses need to
> be coupled with the device in question in order to be keyed properly.
>

Meaning rename struct inetpeer_addr to struct inetpeer_key and 
addr_compare to entry_compare or key_compare? Everything else still 
treats the address + VRF device as the key.

David
