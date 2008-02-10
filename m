From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [RFC] ipvs: Cleanup sync daemon code
Date: Sun, 10 Feb 2008 12:51:27 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802101236530.15729@titan.stealer.net>
References: <Pine.LNX.4.64.0802100029150.15729@titan.stealer.net>
 <20080210045952.GA8255@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757330AbYBJLvu@vger.kernel.org>
In-Reply-To: <20080210045952.GA8255@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 9 Feb 2008, Christoph Hellwig wrote:

> On Sun, Feb 10, 2008 at 12:38:11AM +0100, Sven Wegener wrote:
>>  struct ip_vs_sync_thread_data {
>> -	struct completion *startup;
>> +	struct completion *startup; /* set to NULL once completed */
>
> This is not needed anmore.  kthread_run guarantees that the newly
> creates thread is run before returning to the caller.

The completion is currently used to return an error code for errors that 
happen during initialization in the threads (open socket, allocate 
memory). We could move the setup code out of the threads and have them 
only run an error-safe loop.

>> +/* wait queue for master sync daemon */
>> +static DECLARE_WAIT_QUEUE_HEAD(sync_master_wait);
>
> I don't think you need this one either.  You can use wake_up_process
> on the task_struct pointer instead.

Thanks, now using schedule_timeout with wake_up_process.

>>  	spin_lock(&ip_vs_sync_lock);
>>  	list_add_tail(&sb->list, &ip_vs_sync_queue);
>> +	if (++ip_vs_sync_count == 10)
>> +		wake_up_interruptible(&sync_master_wait);
>>  	spin_unlock(&ip_vs_sync_lock);
>>  }
>
>> -static int sync_thread(void *startup)
>> +static int sync_thread(void *data)
>
> Btw, it might make sense to remove sync_thread and just call the
> master and backup threads directly.

When the setup code has been moved out of the threads, the code gets much 
simpler.

>> +void __init ip_vs_sync_init(void)
>> +{
>> +	/* set up multicast address */
>> +	mcast_addr.sin_family = AF_INET;
>> +	mcast_addr.sin_port = htons(IP_VS_SYNC_PORT);
>> +	mcast_addr.sin_addr.s_addr = htonl(IP_VS_SYNC_GROUP);
>>  }
>
> Why can't this be initialized at compile time by:
>
> static struct sockaddr_in mcast_addr = {
> 	.sin_family		= AF_INET,
> 	.sin_port		= htons(IP_VS_SYNC_PORT),
> 	.sin_addr.s_addr	= htonl(IP_VS_SYNC_GROUP),
> }
>
> (the hton* might need __constant_hton* also I'm not sure without trying)

Thanks.
