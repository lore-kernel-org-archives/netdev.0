From: "Anand H. Krishnan" <anandhkrishnan@gmail.com>
Subject: Bug in skb_gro_receive - possible bad page state problems?
Date: Fri, 5 May 2017 08:57:35 +0530
Message-ID: <CACeb84vFNfPcC=FJ3HEjraZ02Zi2igbK0Q=M3=pUw7AKG=u3PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:36170 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbdEED1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 23:27:36 -0400
Received: by mail-qt0-f170.google.com with SMTP id m91so24936430qte.3
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 20:27:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is skb_gro_receive doing the right thing for cloned packets?

When we are merging fragments, we do not seem to be taking a reference
to the underlying page. To me, it looks like it should work fine for non-cloned
packets. However, for cloned packets, when the gro-ed packet is eventually
freed (because the original skb was not cloned and hence reference was 1),
the merged skb's frags also get freed (put_page-ed) without taking into account
the other references that were held for the fragments (dataref).

We saw crashes because of this behavior. Our setup had a third party kernel
forwarding module which uses GRO (napi_gro_receive). Doing iperf3 with small
packets and doing tcpdump on the receiving tap interface results in the problem.
With DEBUG_VM enabled, put page crashes. Without DEBUG_VM, bad page
state results.

Your thoughts (please CC me, since I am not part of this list).

Thanks,
Anand
