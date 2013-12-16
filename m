From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 9/9] xen-netback: Aggregate TX unmap operations
Date: Mon, 16 Dec 2013 16:30:02 +0000
Message-ID: <52AF2A8A.50404@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-10-git-send-email-zoltan.kiss@citrix.com> <20131213154435.GP21900@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131213154435.GP21900@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/12/13 15:44, Wei Liu wrote:
> On Thu, Dec 12, 2013 at 11:48:17PM +0000, Zoltan Kiss wrote:
>> Unmapping causes TLB flushing, therefore we should make it in the largest
>> possible batches. However we shouldn't starve the guest for too long. So if
>> the guest has space for at least two big packets and we don't have at least a
>> quarter ring to unmap, delay it for at most 1 milisec.
>>
>
> Is this solution temporary or permanent? If it is permanent would it
> make sense to make these parameter tunable?

Well, I'm not entirely sure yet this is the best way to do this, so in 
this sense it's temporary. But generally we should do some sort of 
batching, as TLB flush cannot be avoided every time. If we settle on 
something we should make the tunable parameters tunable.
The problem is that it is a thin red line we should find here. My first 
approach was that I left the tx_dealloc_work_todo as it was, and after 
the thread woke up but before anything were done I made it sleep for 50 
ns and measured  how fast the guest is running out of free slots:

if (kthread_should_stop())
	break;

+i=0;
+do {
+	++i;
+	prev_free_slots = nr_free_slots(&vif->tx);
+	__set_current_state(TASK_UNINTERRUPTIBLE);
+	rc = schedule_hrtimeout_range(&tx_dealloc_delay_ktime, 10, 
HRTIMER_MODE_REL);
+	if (rc) trace_printk("%s sleep were interrupted! %d\n",vif->dev->name, 
rc);
+	curr_free_slots = nr_free_slots(&vif->tx);
+} while ( (curr_free_slots < 4 * (prev_free_slots - curr_free_slots)) 
&& i < 11);
+
xenvif_tx_dealloc_action(vif);

And worst case after 500 ns I let the thread to do the unmap anyway. But 
I was a bit worried about this approach, so I choose a bit more 
conservative one for this patch.

There are also ideas to use some other instrument for unmapping instead 
of the current separate thread approach. Putting it into the NAPI 
instance was the original idea, which caused problems. Placing it into 
the another thread where RX work happens also doesn't sound too good, 
these things can and should happen in parallel.
Other ideas were work queues and tasklets, I'll spend some more time to 
check if they are feasible.

Regards,

Zoli
