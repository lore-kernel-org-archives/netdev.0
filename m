From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/2] act_ife: Fix external mac header on encode
Date: Thu, 22 Sep 2016 19:16:40 -0400
Message-ID: <a5dadd53-788e-c02f-7dab-3d1a30088405@mojatatu.com>
References: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
 <1474548926-22815-2-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotamg@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32839 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754778AbcIVXQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:16:42 -0400
Received: by mail-io0-f196.google.com with SMTP id r145so6104812ior.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:16:42 -0700 (PDT)
In-Reply-To: <1474548926-22815-2-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-22 08:55 AM, Yotam Gigi wrote:
> On ife encode side, external mac header is copied from the original packet
> and may be overridden if the user requests. Before, the mac header copy
> was done from memory region that might not be accessible anymore, as
> skb_cow_head might free it and copy the packet. This led to random values
> in the external mac header once the values were not set by user.
>
> This fix takes the internal mac header from the packet, after the call to
> skb_cow_head.


Since this depends on the previous patch, can you double check for me? I 
will test later, but here's a very simple test case:

sudo $TC qdisc del dev $ETH root handle 1: prio
sudo $TC qdisc add dev $ETH root handle 1: prio

#set mark of decimal 17 and allow sending out
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action skbedit mark 17 \
action ife encode \
type 0xDEAD \
allow mark \
dst 02:15:15:15:15:15

I am not going to comment on your other patch, but i suggest you
test with with this (encoding at least two TLVs):

sudo $TC qdisc del dev $ETH root handle 1: prio
sudo $TC qdisc add dev $ETH root handle 1: prio
#Override mark and send prio of 0x33 (unfortunately
#skbedit is not very consistent 33 means 0x33)
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action skbedit prio 33 \
action ife encode \
type 0xDEAD \
use mark 12 \
allow prio \
dst 02:15:15:15:15:15


cheers,
jamal
