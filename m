From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] ixgbe: Limit lowest interrupt rate for
 adaptive interrupt moderation to 12K
Date: Tue, 1 Sep 2015 18:49:23 -0700
Message-ID: <55E655A3.9010304@gmail.com>
References: <20150730221927.984.91700.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35007 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbIBBtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 21:49:31 -0400
Received: by pacfv12 with SMTP id fv12so14455415pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 18:49:30 -0700 (PDT)
In-Reply-To: <20150730221927.984.91700.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2015 03:19 PM, Alexander Duyck wrote:
> This patch updates the lowest limit for adaptive interrupt interrupt
> moderation to roughly 12K interrupts per second.
>
> The way I came about reaching 12K as the desired interrupt rate is by
> testing with UDP flows.  Specifically I had a simple test that ran a
> netperf UDP_STREAM test at varying sizes.  What I found was as the packet
> sizes increased the performance fell steadily behind until we were only
> able to receive at ~4Gb/s with a message size of 65507.  A bit of digging
> found that we were dropping packets for the socket in the network stack,
> and looking at things further what I found was I could solve it by increasing
> the interrupt rate, or increasing the rmem_default/rmem_max.  What I found was
> that when the interrupt coalescing resulted in more data being processed
> per interrupt than could be stored in the socket buffer we started losing
> packets and the performance dropped.  So I reached 12K based on the
> following math.
>
> rmem_default = 212992
> skb->truesize = 2994
> 212992 / 2994 = 71.14 packets to fill the buffer
>
> packet rate at 1514 packet size is 812744pps
> 71.14 / 812744 = 87.9us to fill socket buffer
>
> >From there it was just a matter of choosing the interrupt rate and
> providing a bit of wiggle room which is why I decided to go with 12K
> interrupts per second as that uses a value of 84us.
>
> The data below is based on VM to VM over a direct assigned ixgbe interface.
> The test run was:
> 	netperf -H <ip> -t UDP_STREAM"
>
> Socket  Message  Elapsed      Messages                   CPU      Service
> Size    Size     Time         Okay Errors   Throughput   Util     Demand
> bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB
> Before:
> 212992   65507   60.00     1100662      0     9613.4     10.89    0.557
> 212992           60.00      473474            4135.4     11.27    0.576
>
> After:
> 212992   65507   60.00     1100413      0     9611.2     10.73    0.549
> 212992           60.00      974132            8508.3     11.69    0.598
>
> Using bare metal the data is similar but not as dramatic as the throughput
> increases from about 8.5Gb/s to 9.5Gb/s.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Has there been any update on this patch?  I submitted it just over a 
month ago now and it hasn't received any feedback.  I was hoping this 
could be submitted before the merge window closes for net-next.

Thanks.

- Alex
