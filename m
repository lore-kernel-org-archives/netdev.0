From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Generic TSO
Date: Mon, 14 Mar 2016 08:59:19 -0700
Message-ID: <CAKgT0UfMp6c89dyAavWO5J0E+2ZvF7EMbq4znJmWY+y5YyY+6w@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
	<CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
	<CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
	<CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
	<CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
	<56E31A89.9020602@solarflare.com>
	<CALx6S37G5N-3GxXYf8uF9p8QNC+U_d6-Vf+8Jg6bFqEv_FpULg@mail.gmail.com>
	<56E3239B.7080009@solarflare.com>
	<CALx6S37P+gVA_O7vxBjGMxHpY69Cx2aL3E79ptvGkRW4L2x5Ug@mail.gmail.com>
	<56E32966.7090409@solarflare.com>
	<CAKgT0Ud0bj=1Baty7O_8Bi5dEU67-036EeZxLpXjvovANem=6Q@mail.gmail.com>
	<56E338A3.5070909@solarflare.com>
	<CAKgT0UeBx8NepNM2oGkYOnPV2Niy9GPd7RDZdgDMY3EcRMxNmw@mail.gmail.com>
	<CALx6S36wJdFnq=2ZkTfijqro1TM1GTqap=aLQ0+NszgWC6Sznw@mail.gmail.com>
	<CAKgT0UfffHvVZPNbfQseOSTXFXAhjtscdoaVKzYxL1t4rooNEw@mail.gmail.com>
	<56E691F1.2020605@solarflare.com>
	<56E6933E.3050407@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36158 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965348AbcCNP7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 11:59:20 -0400
Received: by mail-io0-f171.google.com with SMTP id z76so227797885iof.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 08:59:20 -0700 (PDT)
In-Reply-To: <56E6933E.3050407@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 3:32 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 14/03/16 10:26, Edward Cree wrote:
>> On 12/03/16 05:40, Alexander Duyck wrote:
>>> Well that is the thing.  Before we can actually start tinkering with
>>> the outer header we probably need to make sure we set the DF bit and
>>> that it would be honored on the outer headers for IPv4.  I don't
>>> believe any of the tunnels are currently doing that so repeating the
>>> IP ID would be the worst possible scenario until that is resolved
>>> since VXLAN tunneled frames can be fragmented while TCP frames cannot
>>> so we really shouldn't be repeating IP IDs for the outer headers.
>> So how do we progress with that?  I'm presuming it's not as simple as
>> just patching the tunnel drivers to set DF if the inner packet has it,
>> as that could break existing setups.  (I've heard that "but they're
>> already broken anyway" is not usually an acceptable argument.)  Some
>> sort of configuration option on the tunnel (like we do with udpcsum)?
> ...and immediately I find out it already exists.  (I guess I should have
> looked there first!)
> From drivers/net/vxlan.c:2001:
>> else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
>>             df = htons(IP_DF);

I'm still not a fan of trying to freeze the outer IP header.  I think
it should be the one that should have the IP ID increment while the
inner IP header be the one that is frozen.  Maybe that is where we can
differ per device.  I would be okay with the outer tunnel headers and
inner IP header being frozen on ixgbe which will be needed in order to
compute outer UDP checksum anyway.  Then we could leave it up to the
driver's discretion as to if the outer header has the IP ID that
increments or the inner header.

- Alex
