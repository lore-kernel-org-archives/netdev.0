From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 13:17:45 -0700
Message-ID: <55A41CE9.8050907@plumgrid.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>	<20150711.212917.1463596559900301434.davem@davemloft.net>	<55A415DE.8020806@plumgrid.com> <20150713.130438.1857789246357119116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34341 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbbGMUYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:24:48 -0400
Received: by pacan13 with SMTP id an13so21248836pac.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 13:24:40 -0700 (PDT)
In-Reply-To: <20150713.130438.1857789246357119116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/15 1:04 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Mon, 13 Jul 2015 12:47:42 -0700
>
>> In all normal cases skb->users == 1, but pktgen is using trick:
>> atomic_add(burst, &skb->users);
>> so when testing something like:
>
> You can want pktgen rx (which is the only buggy case as far as I can
> see, TX is fine) to run fast, but you must do so by abiding by the
> appropriate SKB sharing rules.
>
> You can't do an optimization in pktgen for RX processing that works
> "some of the time".  We have shared SKB rules for a reason.
>
> And I don't want to have to explain to someone in the future why that
> drop check is there, and have to tell them "because pktgen is broken
> and we decided to add a hack here rather than make pktgen send
> properly formed SKBs into the RX path"
>
> Ok?

in general all makes sense, but it is both RX and TX.
Without burst hack we cannot achieve line rate TX.
         atomic_add(burst, &pkt_dev->skb->users);
xmit_more:
         ret = netdev_start_xmit(pkt_dev->skb, odev, txq, --burst > 0);

in pktgen we check that driver can work with users > 1 via:
pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING

so real hw driver are mostly ready for users > 1, it's only
few tc actions struggle a bit.
We cannot check tc actions from pktgen, since they can be added
dynamically.
So I see three options:
1 get rid of burst hack for both RX and TX in pktgen (kills performance)
2 add unlikely(skb_shread) check to few tc actions
3 do nothing

I think 2 isn't that bad after all if properly documented with
"because pktgen is doing this hack for performance" ?

I'm fine with 3 too, since the whole pktgen business is for root
and for kernel hackers who suppose to know what they're doing.
