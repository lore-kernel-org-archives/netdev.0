From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Mon, 11 Sep 2017 08:22:28 -0700
Message-ID: <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
         <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        edumazet@google.com, ycheng@google.com, hkchu@google.com,
        netdev@vger.kernel.org, weiyongjun1@huawei.com
To: liujian56@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34294 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750810AbdIKPWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 11:22:31 -0400
Received: by mail-pf0-f182.google.com with SMTP id e1so14439934pfk.1
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 08:22:31 -0700 (PDT)
In-Reply-To: <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-11 at 08:13 -0700, Eric Dumazet wrote:

> You can see we got only 3 probes, not 4.

Here is complete packetdrill test showing that code behaves as expected.

    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>

// Client advertises a zero receive window, so we can't send.
  +.1 < . 1:1(0) ack 1 win 0
   +0 accept(3, ..., ...) = 4

   +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
   +0 write(4, ..., 2920) = 2920

// Window probes are scheduled just like RTOs.
  +.3~+.31 > . 0:0(0) ack 1
  +.6~+.62 > . 0:0(0) ack 1
 +1.2~+1.24 > . 0:0(0) ack 1

// Peer opens its window too late !
   +3 < . 1:1(0) ack 1 win 1000
   +0 > R 1:1(0)
