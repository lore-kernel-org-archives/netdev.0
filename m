From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: Receive offloads, small RCVBUF and zero TCP window
Date: Mon, 28 Nov 2016 15:49:26 -0500
Message-ID: <2080597.A38JFJZ1AD@zbook>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:29701 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752677AbcK1Uta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:49:30 -0500
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com [15.241.48.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 5296061146
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:49:29 +0000 (UTC)
Received: from g9t2301.houston.hpecorp.net (g9t2301.houston.hpecorp.net [16.220.97.129])
        by g9t5009.houston.hpe.com (Postfix) with ESMTP id 4615554
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:49:28 +0000 (UTC)
Received: from zbook.localnet (ospra0.fc.hp.com [16.79.38.117])
        by g9t2301.houston.hpecorp.net (Postfix) with ESMTP id 1B4C44F
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:49:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of our customers has met a problem: TCP window closes and stays closed forever even though receive buffer is empty. This problem has been reported for RHEL6.8 and I think that the issue is in __tcp_select_window() subroutine. Comparing sources of RHEL6.8 kernel and the latest upstream kernel (pulled from GIT today), it looks that it should still be present in the latest kernels.

The problem is triggered by the following conditions:

(a) small RCVBUF (24576 in our case), as a result WS=0
(b) mss = icsk->icsk_ack.rcv_mss > MTU

I asked customer to trigger vmcore when the problem occurs to find why window stays closed forever. I can see in vmcore (doing calculations following __tcp_select_window sources):

        windows: rcv=0, snd=65535  advmss=1460 rcv_ws=0 snd_ws=0
        --- Emulating __tcp_select_window ---
          rcv_mss=7300 free_space=18432 allowed_space=18432 full_space=16972
          rcv_ssthresh=5840, so free_space->5840 

So when we reach the test

		if (window <= free_space - mss || window > free_space)
			window = (free_space / mss) * mss;
		else if (mss == full_space &&
			 free_space > window + (full_space >> 1))
			window = free_space;

we have  negative value of (free_space - mss) = -1460

As a result, we do not update the window and it stays zero forever - even though application has read all available data and we have sufficient free_space.


This occurs only due to the fact that we have interface with MTU=1500 (so that mss=1460 is expected), but icsk->icsk_ack.rcv_mss is 5*1460 = 7300.

As a result, "Get the largest window that is a nice multiple of mss" means a multiple of 7300, and this never happens!

All other mss-related values look reasonable:

crash64> struct tcp_sock 0xffff8801bcb8c840  | grep mss
    icsk_sync_mss = 0xffffffff814ce620 , 
      rcv_mss = 7300
  mss_cache = 1460, 
  advmss = 1460, 
    user_mss = 0, 
    mss_clamp = 1460


Now the question is whether is is OK to have icsk->icsk_ack.rcv_mss larger than MTU. I suspect the most important factor is that this host is running under VMWare. VMWare probably optimizes receive offloading dramatically, pushing to us merged SKBs larger than MTU. I have written a tool to print warnings when we have mss > advmss and ran it on my collection of vmcores. Almost in all cases where vmcore was taken on VMWare guest, we have some connections with mss > advmss. I have not found any vmcores showing this high mss value for any non-VMWare vmcore.

Obviously, this is a corner-case problem - it can happen only if we have a small RCVBUF. But I think this needs to be fixed anyway. I am not sure whether having 
icsk->icsk_ack.rcv_mss > MTU is expected. If not, this should be fixed in receiving offload subroutines (LRO?) or maybe VMWare NIC driver.

But if it is OK for NICs to merge received SKBs and present to TCP supersegments (similar to TSO), this needs to be fixed in __tcp_select_window - e.g. if we see a small RCVBUF and large icsk->icsk_ack.rcv_mss, switch to mss_clamp, as it was done in older versions. From __tcp_select_window() comment 

	/* MSS for the peer's data.  Previous versions used mss_clamp
	 * here.  I don't know if the value based on our guesses
	 * of peer's MSS is better for the performance.  It's more correct
	 * but may be worse for the performance because of rcv_mss
	 * fluctuations.  --SAW  1998/11/1
	 */

Regards,
Alex

-- 

------------------------------------------------------------------
Alex Sidorenko	email: asid@hpe.com
ERT  Linux 	Hewlett-Packard Enterprise (Canada)
------------------------------------------------------------------
