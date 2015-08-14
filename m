From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Fri, 14 Aug 2015 17:58:07 +0900
Message-ID: <20150814085807.GA30443@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
 <20150812.163819.620222685130362816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35780 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbbHNI6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 04:58:13 -0400
Received: by pdrg1 with SMTP id g1so29279806pdr.2
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 01:58:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812.163819.620222685130362816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

Thank you for taking your time.
Please let me explain these with code samples on gist.
I can not describe and arrange it well, sorry.
 
    normal socket nflog sample:
    https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/nflog.c

set iptables

    iptables -A INPUT -p icmp --icmp-type echo-request \
        -j NFLOG --nflog-group 2 --nflog-threshold 4

monitor nlmon (like netsniff-ng), run this sample and
ping -i 0.2 -c 10 from another hosts. This sample only shows receive
size and nlmsg_type. Same things can be done with rx mmaped socket.

    rx only mmaped nflog sample:
    https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/rxring-nflog.c

This sample gets a panic if monitoring nlmon.

    panic message:
    https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/mmaped_netlink_panic

I think it's because of accessing a skb_shared_info when releasing
skb, although mmaped netlink skb does not have a skb_shared_info. I
tried to fix this at patch 1 and 2 by introducing helper function
which will not access a skb_shared_info.

And I think nm_status should be set to UNUSED when releasing it so
also tried to fix it patch 3.

----

With both tx/rx mmaped,

    both tx/rx mmaped nflog sample:
    https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/2d6da8fff31ef61af77e68713fdb1d71978746a6/ring-nflog.c

This sample will not work, since msg->msg_iter.type in
netlink_sendmsg() is set to 1 (WRITE) when this sample calls
sendto(). patch 4 fix this by accepting it.

----

After applying patch 1 and 2, rx only sample can work but it behaves
differ from normal one. patch 5 may fix this.

And it also works well with my another code which set frame
nm_status to SKIP and passes it to worker threads and the worker
threads set status to UNUSED, even though ring becomes full.

That my another code may set UNUSED status in random, not
sequensially, so that it seems I need to check whole ring.

Thanks,
