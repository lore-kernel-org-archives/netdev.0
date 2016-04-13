From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Tue, 12 Apr 2016 19:42:06 -0700
Message-ID: <1460515326.32504.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
	 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FB6AA7.1080004@huawei.com>
	 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5705F759.9020003@huawei.com>
	 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5707939B.2030907@huawei.com>
	 <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570B9126.9080806@huawei.com>
	 <1460376828.6473.538.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570C6483.5020502@huawei.com> <570CEA9C.1070803@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ding Tianhong <dingtianhong@huawei.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35556 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbcDMCmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 22:42:09 -0400
Received: by mail-pa0-f44.google.com with SMTP id fs9so5879901pac.2
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 19:42:09 -0700 (PDT)
In-Reply-To: <570CEA9C.1070803@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-12 at 20:31 +0800, Yang Yingliang wrote:

> I traced the cost cycles of handling backlog packets in
> __release_sock().
> 16.97 ms to handling about 12MB backlog packets, of which 13.66ms to do
> sk_data_ready.
> The speed of handling packets in TCP is 5.65Gb/s which is smaller than
> the NIC's bandwidth. So the packets will be dropped.
> 
> If the cost of sk_data_read cannot be reduced, do we have other choice
> exclude dropping packets ?

Normally, TCP stack sends ACK packets with appropriate RWIN.

Sender should not send more packets than allowed in RWIN, even if there
are 128 threads using one TCP socket, it does not matter.

Imagine you do not have a backlog problem (nothing does the sendmsg()
while you receive data), and nothing reads the socket. Then the receiver
should eventually send WIN 0 back to the sender and sender should stop,
before any drop can possibly happen.

I have no problem receiving one TCP flow at 34Gbit, so it must be
something related to the huge windows you seem to use.

One possibility could be to tweak in ACK packets a reduced rwin so that
the sender is not allowed to continue the flood while we are painfully
processing a huge backlog.
