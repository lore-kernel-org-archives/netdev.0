From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCHv4 next 3/3] ipvlan: Introduce l3s mode
Date: Sun, 18 Sep 2016 10:57:35 -0600
Message-ID: <b8002d08-ff4a-b53e-6dff-2cf969db3189@cumulusnetworks.com>
References: <1474055959-12565-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36074 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754653AbcIRQ6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 12:58:21 -0400
Received: by mail-pf0-f174.google.com with SMTP id q2so22608136pfj.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 09:57:37 -0700 (PDT)
In-Reply-To: <1474055959-12565-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/16 1:59 PM, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> In a typical IPvlan L3 setup where master is in default-ns and
> each slave is into different (slave) ns. In this setup egress
> packet processing for traffic originating from slave-ns will
> hit all NF_HOOKs in slave-ns as well as default-ns. However same
> is not true for ingress processing. All these NF_HOOKs are
> hit only in the slave-ns skipping them in the default-ns.
> IPvlan in L3 mode is restrictive and if admins want to deploy
> iptables rules in default-ns, this asymmetric data path makes it
> impossible to do so.
> 
> This patch makes use of the l3_rcv() (added as part of l3mdev
> enhancements) to perform input route lookup on RX packets without
> changing the skb->dev and then uses nf_hook at NF_INET_LOCAL_IN
> to change the skb->dev just before handing over skb to L4.

Today's l3 mode only allows netfilter Rx rules on ipvlan devices in slave-ns since skb->dev is changed to ipvlan device and the namespace crossing happens in rx-handler.

This new l3s mode only allows Rx rules on the parent devices (eg., eth1) in the default-ns since skb->dev stays as parent device until the NF_HOOK is run. Specifically, you can't put rules on eth1 and ipvl0 since the packet never goes through L3 with the ipvlan device set?

So the 'symmetric' is wrt to the parent device in the default-ns.

Also, there is no longer an explicit namespace crossing; that happens via the route lookup and setting dst on the skb. I guess for this use case it is ok.

> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> CC: David Ahern <dsa@cumulusnetworks.com>
> ---
>  Documentation/networking/ipvlan.txt |  7 ++-
>  drivers/net/Kconfig                 |  1 +
>  drivers/net/ipvlan/ipvlan.h         |  6 +++
>  drivers/net/ipvlan/ipvlan_core.c    | 94 +++++++++++++++++++++++++++++++++++++
>  drivers/net/ipvlan/ipvlan_main.c    | 87 +++++++++++++++++++++++++++++++---
>  include/uapi/linux/if_link.h        |  1 +
>  6 files changed, 188 insertions(+), 8 deletions(-)


Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
