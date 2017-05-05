From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_gro_receive - possible bad page state problems?
Date: Thu, 04 May 2017 21:14:45 -0700
Message-ID: <1493957685.7796.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACeb84vFNfPcC=FJ3HEjraZ02Zi2igbK0Q=M3=pUw7AKG=u3PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Anand H. Krishnan" <anandhkrishnan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35229 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbdEEEOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 00:14:49 -0400
Received: by mail-pf0-f172.google.com with SMTP id v14so16862541pfd.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 21:14:48 -0700 (PDT)
In-Reply-To: <CACeb84vFNfPcC=FJ3HEjraZ02Zi2igbK0Q=M3=pUw7AKG=u3PQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-05 at 08:57 +0530, Anand H. Krishnan wrote:
> Hello,
> 
> Is skb_gro_receive doing the right thing for cloned packets?
> 
> When we are merging fragments, we do not seem to be taking a reference
> to the underlying page. To me, it looks like it should work fine for non-cloned
> packets. However, for cloned packets, when the gro-ed packet is eventually
> freed (because the original skb was not cloned and hence reference was 1),
> the merged skb's frags also get freed (put_page-ed) without taking into account
> the other references that were held for the fragments (dataref).
> 
> We saw crashes because of this behavior. Our setup had a third party kernel
> forwarding module which uses GRO (napi_gro_receive). Doing iperf3 with small
> packets and doing tcpdump on the receiving tap interface results in the problem.
> With DEBUG_VM enabled, put page crashes. Without DEBUG_VM, bad page
> state results.

Yep, GRO must not be used with cloned skb.

This is why gro_cells_receive() has this check :

if (!gcells->cells || skb_cloned(skb) || netif_elide_gro(dev))
        return netif_rx(skb);

(But not the main napi_gro_receive() that is supposed to be used by
driver before any tap)
