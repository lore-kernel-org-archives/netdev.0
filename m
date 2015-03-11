From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 15:12:19 -0700
Message-ID: <CAHA+R7N88DFPpfPeN5cqru7oODfew1ZUdT80R0fj1QkQsx-siw@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	<1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
	<1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35863 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbCKWMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:12:20 -0400
Received: by obcva2 with SMTP id va2so12204224obc.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 15:12:19 -0700 (PDT)
In-Reply-To: <1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 2:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-11 at 13:46 -0700, Cong Wang wrote:
>
>> That is just a permission check when val > 6, given the fact most
>> daemons have root permission, I doubt your argument makes a difference
>> for discussion. At least with userns having root permission is more common.
>
> Some setups use ip[6]tables rules to mangle skb->priority to select a
> HTB class.
>
> Google definitely uses this model, as netfilter code runs on multiple
> cpus, while HTB classifier runs under qdisc spinlock, so far.

I knew we can modify skb->priority in a few ways, for example skbedit.

That is not my concern, all what I am thinking is there is some
way in application layer to bypass our tc filters, which is not expected
to happen for me. Given our specific case, I want to propose to clear
skb->priority after moving out of a netns:

diff --git a/net/core/dev.c b/net/core/dev.c
index 962ee9d..2301f01 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1694,6 +1694,7 @@ int __dev_forward_skb(struct net_device *dev,
struct sk_buff *skb)
        }

        skb_scrub_packet(skb, true);
+       skb->priority = 0;
        skb->protocol = eth_type_trans(skb, dev);
        skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
