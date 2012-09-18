From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V4 PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Tue, 18 Sep 2012 23:20:51 +0530
Message-ID: <5058B47B.1050604@chelsio.com>
References: <1347470328-32490-1-git-send-email-naresh@chelsio.com>  <5057F791.8020702@chelsio.com> <1347957374.2388.15.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1347957374.2388.15.camel@dabdike.int.hansenpartnership.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/18/2012 2:06 PM, James Bottomley wrote:
> On Tue, 2012-09-18 at 09:54, Naresh Kumar Inna wrote:
>> Hi James,
>>
>> Could you please consider merging version V4 of the driver patches, if
>> you think they are in good shape now?
> 
> Well, definitely not yet; you seem to have missed the memo on readq:
> 
>   CC [M]  drivers/scsi/cxgbi/cxgb4i/cxgb4i.o
> drivers/scsi/csiostor/csio_hw.c: In function csio_hw_mc_read:
> drivers/scsi/csiostor/csio_hw.c:194:3: error: implicit declaration of
> function readq [-Werror=implicit-function-declaration]
> 
> It's only defined on platforms which can support an atomic 64 bit
> operation (which is mostly not any 32 bit platforms) ... so this could
> do with compile testing on those.
> 
> To see how to handle readq/writeq in the 32 bit case, see the uses in
> fnic or qla2xxx
> 

Thanks for reviewing. I will fix up readq/writeq, as well as other
32-bit compilation issues, if any.

> You also have a couple of unnecessary version.h includes.
> 

I will get rid of them.

> Since you're a new driver, could you not do a correctly unlocked
> queuecommand routine?  You'll find the way you've currently got it coded
> (holding the host lock for the entire queuecommand routine) is very
> performance detrimental.
> 

Yes, I am aware of that. However, some of this code was written and
tested before the lock-less queuecommand came into existence. Going the
lock-less route would require me to test the driver thoroughly again. It
definitely is in my to-do list, but I would like to take that up after
the initial submission goes through. Would that be OK?

> You have a lot of locking statements which aren't easy to audit by hand
> because there are multiple unlocks.  Things like this:
> 
> csio_scan_finished(struct Scsi_Host *shost, unsigned long time)
> {
> 	struct csio_lnode *ln = shost_priv(shost);
> 	int rv = 0;
> 
> 	spin_lock_irq(shost->host_lock);
> 	if (!ln->hwp || csio_list_deleted(&ln->sm.sm_list)) {
> 		spin_unlock_irq(shost->host_lock);
> 		return 1;
> 	}
> 
> 	rv = csio_scan_done(ln, jiffies, time, csio_max_scan_tmo * HZ,
> 			    csio_delta_scan_tmo * HZ);
> 
> 	spin_unlock_irq(shost->host_lock);
> 
> 	return rv;
> }
> 
> Are better coded as
> 
> csio_scan_finished(struct Scsi_Host *shost, unsigned long time)
> {
> 	struct csio_lnode *ln = shost_priv(shost);
> 	int rv = 1;
> 
> 	spin_lock_irq(shost->host_lock);
> 	if (!ln->hwp || csio_list_deleted(&ln->sm.sm_list))
> 		goto out;
> 
> 	rv = csio_scan_done(ln, jiffies, time, csio_max_scan_tmo * HZ,
> 			    csio_delta_scan_tmo * HZ);
> 
>  out:
> 	spin_unlock_irq(shost->host_lock);
> 
> 	return rv;
> }
> 
> It's shorter and the unlock clearly matches the lock.  You could even
> invert the if logic and just make the csio_scan_done() conditional on it
> avoiding the goto.
> 

I will try to minimize the lock/unlock mismatch instances per your
suggestions, if not eliminate them altogether.

> I'd also really like the people who understand FC to take a look over
> this as well.
> 

Sure.

Thanks,
Naresh.
