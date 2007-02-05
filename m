From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Question on IOAT
Date: Mon, 5 Feb 2007 21:03:59 +0100
Message-ID: <200702052104.00951.olaf.kirch@oracle.com>
References: <200702051759.58928.olaf.kirch@oracle.com> <41b516cb0702051024i4982468dpc4c843d8627f6855@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chris.leech@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48173 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933063AbXBEUFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 15:05:37 -0500
In-Reply-To: <41b516cb0702051024i4982468dpc4c843d8627f6855@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 19:24, Chris Leech wrote:
> It is busy waiting, but only because the TCP socket use initiates the
> DMA copies from the softirq and they have time to complete during the
> switch back to application context.

But to me it looks as if the code in tcp_recvmsg will also initiate DMA
copies when the user calls recvmsg and there is data queued on the
socket. So in that case, what you end up doing in the same process
context is queue DMA ops -> issue pending -> busy wait. In that case,
sleeping would sound like the right approach, wouldn't it?

> Going back to sleep and creating 
> more context switching made things worse.  I'm working on seeing if
> completion interrupts could be used with a better thought out
> implementation, the performance implications aren't fully clear to me
> yet.
>
> For other uses, interrupts are probably desired.

The NFS client's RPC code hooks into the data_ready callback,
tries to find the task that the reply is going to, and copies the data.
So per your argument above, for the NFS client it should be okay to
busy wait after switching to the task.

This would leave the NFS server, which basically uses some kind
of poll/recvmsg scheme. In essence, it doesn't call recvmsg until
the data has been queued. I guess this kind of code would benefit
from using async IO - then the stack can DMA directly into the
buffer and then wake up the process.

> It's just not there now, but it can be added easily, it's one bit in
> the descriptor and a register read in the interrupt handler to see
> which channel(s) need attention.

Hm, okay.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
