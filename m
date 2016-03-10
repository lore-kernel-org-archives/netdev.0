From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Thu, 10 Mar 2016 13:29:05 -0800
Message-ID: <CAM_iQpUFB4TO=nByzT-8ZESKL8ecLJKYRdCcYRPWBqQ10_Dtnw@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
	<56E14296.5010103@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33400 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbcCJV3H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 16:29:07 -0500
Received: by mail-yw0-f177.google.com with SMTP id d65so78822196ywb.0
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 13:29:06 -0800 (PST)
In-Reply-To: <56E14296.5010103@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 1:47 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 09/03/2016 22:49, Mahesh Bandewar a =C3=A9crit :
>>
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> One of the major request (for enhancement) that I have received
>> from various users of IPvlan in L3 mode is its inability to handle
>> IPtables.
>>
>> While looking at the code and how we handle ingress, the problem
>> can be attributed to the asymmetry in the way packets get processed
>> for IPvlan devices configured in L3 mode. L3 mode is supposed to
>> be restrictive and all the L3 decisions need to be taken for the
>> traffic in master's ns. This does happen as expected for egress
>> traffic however on ingress traffic, the IPvlan packet-handler
>> changes the skb->dev and this forces packet to be processed with
>> the IPvlan slave and it's associated ns. This causes above mentioned
>> problem and few other which are not yet reported / attempted. e.g.
>> IPsec with L3 mode or even ingress routing.
>>
>> This could have been solved if we had a way to handover packet to
>> slave and associated ns after completing the L3 phase. This is a
>> non-trivial issue to fix especially looking at IPsec code.
>>
>> This patch series attempts to solve this problem by introducing the
>> device pointer l3_dev which resides in net_device structure in the
>> RX cache line. We initialize the l3_dev to self. This would mean
>> there is no complex logic to when-and-how-to initialize it. Now
>> the stack will use this dev pointer during the L3 phase. This should
>> not alter any existing properties / behavior and also there should
>> not be any additional penalties since it resides in the same RX
>> cache line.
>
> If I understand correctly (and as Cong already said), information are
> leaking
> between netns during the input phase. On the tx side, skb_scrub_packe=
t() is
> called, but not on the rx side. I think it's wrong. There should be a=
n
> explicit
> boundary.

That is not what I am complaining about.

I dislike the trick of switching skb->dev pointer with skb->dev->l3_dev=
=2E
This is not how we switch netns, nor the way how netns works.

Look at veth pair or dev_change_net_namespace(), each time when we
switch netns, we need to do a full reregistration or a full reentrance,=
 we
never just switch some pointers to switch netns. This is why I said it =
breaks
isolation.

Also, it is ugly to hide such a ipvlan-specific pointer for half of the=
 RX code
path.
