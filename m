From: DESBRUS Maxime <maxime.desbrus@thalesgroup.com>
Subject: Question about packet_mmap & huge pages
Date: Fri, 5 May 2017 18:00:17 +0200
Message-ID: <6C26BDBD2FD19B418E20F4A951DDC74A17CDD18778@THSONEA01CMS08P.one.grp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thsbbfxrt02p.thalesgroup.com ([192.93.158.29]:56002 "EHLO
        thsbbfxrt02p.thalesgroup.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752142AbdEEQFi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:05:38 -0400
Received: from thsbbfxrt02p.thalesgroup.com (localhost [127.0.0.1])
        by localhost (Postfix) with SMTP id 3wKGnb4d8Yz8Lf
        for <netdev@vger.kernel.org>; Fri,  5 May 2017 18:00:19 +0200 (CEST)
Content-Language: fr-FR
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am currently evaluating various 0-copy packet capture frameworks on Linux.
One of them is packet mmap, provided by the mainline Linux kernel.

I want to capture on one network interface with several raw sockets, each being used in a dedicated thread (to spread the processing load on several cores).
My first test program works well, however I am now trying to gain even more performance by mapping RX rings inside 1GB huge pages (other 0-copy network frameworks like DPDK do this).

My first question is: is it possible to map the rx ring of packet_mmap using huge pages, with the current Linux kernel?
If it is possible, what specific flags must be passed to mmap?

Here is what I tried so far:
* Calling mmap on the socket file descriptor (to set the rx ring address) with MAP_SHARED | MAP_HUGETLB | MAP_HUGE_1GB
=> mmap returns error EINVAL
* Calling mmap on the socket file descriptor (to set the rx ring address) with MAP_SHARED | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB
=> mmap succeeds and a huge page is allocated, but the memory area is all zero and does not contain the expected ring structures. I suspect the MAP_ANONYMOUS flag makes it ignore the socket file descriptor, and the mapping is thus unrelated to the ring.
* Calling mmap first to map a huge page area by opening a file on a hugetlbfs mount, and then calling mmap on the socket file descriptor (to set the ring address) with an address inside the previously mapped area
=> the address hint is ignored, and thus the ring is not mapped inside a huge page

I am using "tpacket_v3" packet_mmap version and my kernel version is based on 4.8 (on Ubuntu 16.04). 
I reserve huge pages with the kernel boot command line, as recommended in Documentation/vm/hugetlbpage.txt.

Thank you in advance for your guidance
