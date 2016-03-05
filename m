From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Sat, 5 Mar 2016 20:43:07 +0100
Message-ID: <56DB36CB.2010407@cumulusnetworks.com>
References: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
 <56D82E42.4060401@cumulusnetworks.com>
 <CADvbK_eiSQFT9uKfJZf_8omcFyiVuh+XbnywzC2wszxqPuThjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37890 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcCETnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 14:43:10 -0500
Received: by mail-wm0-f44.google.com with SMTP id l68so28158087wml.1
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 11:43:09 -0800 (PST)
In-Reply-To: <CADvbK_eiSQFT9uKfJZf_8omcFyiVuh+XbnywzC2wszxqPuThjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2016 03:44 PM, Xin Long wrote:
> On Thu, Mar 3, 2016 at 8:29 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>>
>> This is incorrect because you don't have rtnl here, bridge device sysfs
>> options take care of rtnl only on per-option basis and they obtain and
>> release it themselves, so you won't have rtnl held when you call
>> netdev_state_change. While I agree that this is needed, a larger change
>> would be necessary for br_sysfs_br.c.
> Sorry, I can't follow you, cause I didn't see any held in dev_ioctl, like:
> ipip6_tunnel_ioctl
>     ipip6_tunnel_update
>         netdev_state_change
> 
> why sysfs have to hold rtnl ?
> 

See the comment above dev_ifsioc:
/*
 *      Perform the SIOCxIFxxx calls, inside rtnl_lock()
 */
static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
{
...
it is usually called like:
                       rtnl_lock();
                       ret = dev_ifsioc(net, &ifr, cmd);
                       rtnl_unlock();
And also you cannot be calling netdevice notifiers without RTNL. So in any
case you do need it here as well, in fact you'll surely hit the ASSERT_RTNL();
in call_netdevice_notifiers_info if you do so, thus I'm not sure how this
patch was actually tested.

>> Off-topic: I've been looking into factoring out the bond option API and reusing
>> it here as it already has all of this handled, but I won't have time to finish
>> it before the next merge window, so if you fix the issue here I'm okay with
>> this as interim solution.
>>
>> Cheers,
>>  Nik
>>
