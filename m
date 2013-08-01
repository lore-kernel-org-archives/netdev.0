From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Revising locking scheme for MAC
 configuration
Date: Thu, 01 Aug 2013 15:56:59 -0700 (PDT)
Message-ID: <20130801.155659.2230904456508730148.davem@davemloft.net>
References: <1375367459-11832-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab3HAW5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:57:00 -0400
In-Reply-To: <1375367459-11832-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 1 Aug 2013 17:30:59 +0300

> On very rare occasions, repeated load/unload stress test in the presence of
> our storage driver (bnx2i/bnx2fc) causes a kernel panic in bnx2x code
> (NULL pointer dereference). Stack traces indicate the issue happens during MAC
> configuration; thorough code review showed that indeed several races exist
> in which one thread can iterate over the list of configured MACs while another
> deletes entries from the same list.
> 
> This patch adds a varient on the single-writer/Multiple-reader lock mechanism -
> It utilizes an already exsiting bottom-half lock, using it so that Whenever
> a writer is unable to continue due to the existence of another writer/reader,
> it pends its request for future deliverance.
> The writer / last readers will check for the existence of such requests and
> perform them instead of the original initiator.
> This prevents the writer from having to sleep while waiting for the lock
> to be accessible, which might cause deadlocks given the locks already
> held by the writer.
> 
> Another result of this patch is that setting of Rx Mode is now made in
> sleepable context - Setting of Rx Mode is made under a bottom-half lock, which
> was always nontrivial for the bnx2x driver, as the HW/FW configuration requires
> wait for completions.
> Since sleep was impossible (due to the sleepless-context), various mechanisms
> were utilized to prevent the calling thread from sleep, but the truth was that
> when the caller thread (i.e, the one calling ndo_set_rx_mode()) returned, the
> Rx mode was still not set in HW/FW.
> 
> bnx2x_set_rx_mode() will now overtly schedule for the Rx changes to be
> configured by the sp_rtnl_task which hold the RTNL lock and is sleepable
> context. 
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied to net-next, thanks.
