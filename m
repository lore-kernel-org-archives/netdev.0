From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from remove_one
Date: Wed, 15 Dec 2010 14:52:29 +0100
Message-ID: <4D08C81D.8020606@kernel.org>
References: <4D0796D7.3030309@kernel.org> <1292348880.7394.63.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292348880.7394.63.camel@nseg_linux_HP1.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2010 06:48 PM, Michael Chan wrote:
> 
> On Tue, 2010-12-14 at 08:09 -0800, Tejun Heo wrote:
>> Michael pointed out that bnx2_close() already cancels bp->reset_task
>> and thus it is guaranteed to be idle when bnx2_remove_one() is called.
>> Remove the unnecessary cancel_work_sync() in remove_one.
>>
>> Signed-off-by: Tejun Heo <tj@kernel.org>
>> Cc: Michael Chan <mchan@broadcom.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

After looking through the code, I don't think this is necessarily
correct.  ->ndo_close() doesn't guarantee that the watchdog timer has
finished running (the timer is deleted with del_timer() not
del_timer_sync()).  ie. the watchdog timer could still be running
after ->ndo_close() and may schedule reset_task.  If remove_one
doesn't flush the task, it may still be running when remove_one() is
called.

David, am I missing something?  Wouldn't it cleaner to guarantee that
->ndo_close() is called with the guarantee that the watchdog timer is
not running anymore?

-- 
tejun
