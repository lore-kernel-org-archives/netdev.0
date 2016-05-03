From: John Stultz <john.stultz@linaro.org>
Subject: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Mon, 2 May 2016 21:55:49 -0700
Message-ID: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dean Jenkins <Dean_Jenkins@mentor.com>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35681 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbcECEzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 00:55:50 -0400
Received: by mail-io0-f182.google.com with SMTP id d62so12199697iof.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 21:55:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In testing with HiKey, we found that since commit 3f30b158eba5c60
(asix: On RX avoid creating bad Ethernet frames), we're seeing lots of
noise during network transfers:

[  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  239.037310] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0x54ebb5ec, offset 4
[  239.045519] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0xcdffe7a2, offset 4
[  239.275044] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  239.284355] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0x1d36f59d, offset 4
[  239.292541] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0xaef3c1e9, offset 4
[  239.518996] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[  239.528300] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0x2881912, offset 4
[  239.536413] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
0x5638f7e2, offset 4


And network throughput ends up being pretty bursty and slow with a
overall throughput of at best ~30kB/s.

Looking through the commits since the v4.1 kernel where we didn't see
this, I narrowed the regression down, and reverting the following two
commits seems to avoid the problem:

6a570814cd430fa5ef4f278e8046dcf12ee63f13 asix: Continue processing URB
if no RX netdev buffer
3f30b158eba5c604b6e0870027eef5d19fc9271d asix: On RX avoid creating
bad Ethernet frames

With these reverted, we don't see all the error messages, and we see
better ~1.1MB/s throughput (I've got a mouse plugged in, so I think
the usb host is only running at "full-speed" mode here).

This worries me some, as the patches seem to describe trying to fix
the issue they seem to cause, so I suspect a revert isn't the correct
solution, but am not sure why we're having such trouble and the patch
authors did not.  I'd be happy to do further testing of patches if
folks have any ideas.

Originally Reported-by: Yongqin Liu <yongqin.liu@linaro.org>

thanks
-john
