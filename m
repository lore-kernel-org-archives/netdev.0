From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [ambassador] eliminate pci_find_device()
Date: Thu, 21 Oct 2004 07:51:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410211151.i9LBpCS8009194@ginger.cmf.nrl.navy.mil>
References: <20041021113841.GA3720@infradead.org>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-reply-to: Your message of "Thu, 21 Oct 2004 12:38:41 BST."
             <20041021113841.GA3720@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20041021113841.GA3720@infradead.org>,Christoph Hellwig writes:
>>    // Did one of our cards generate the interrupt?
>this debug check is superflous.

i know that.  however, i didnt want to change the original more than
necessary.  dropping this check doesnt bother me.

>> @@ -1554,19 +1556,19 @@
>>    if (housekeeping.data) {
>> -    while (dev) {
>> +    list_for_each(p, &amb_devs) {
>> +      dev = list_entry(p, struct amb_dev, entry);
>
>this really should be a per-device timer - or even better using
>schedule_delayed_work()
>
>With these two changes you could get rid of amb_devs easily.  If you still
>want to keep it for some reason at least use list_for_each_entry.

my primary reason for keeping it is that i cant easily test the changes
to the driver.  i have a programmable card that i set to the correct
vendor/device id.  it doesnt do any 'real' work.  i dont really know
anyone with a real ambassador (or horizon) card.  this driver is essentially
"reference only" as far as i can tell.  i can change to list_for_each_entry.

>> +	list_del(&dev->entry);
>> +    
>> +	PRINTD(DBG_INFO|DBG_INIT, "closing %p (atm_dev = %p)", dev, dev->atm_dev);
>> +	// the drain should not be necessary
>> +	drain_rx_pools(dev);
>> +	interrupts_off(dev);
>> +	amb_reset(dev, 0);
>> +	free_irq(dev->irq, dev);
>> +	pci_disable_device(pci_dev);
>> +	destroy_queues(dev);
>> +	atm_dev_deregister(dev->atm_dev);
>> +	kfree(dev);
>> +	pci_release_region(pci_dev, 1);
>
>this doesn't look correct (without knowing the atm subsystem in detail), in
>general you need to unregister from the subsystem first so you don't get
>new work, and then you can start tearing the hardware down.

still that what was the order in the original driver.  i am sure it
races with housekeeping as well if that makes you feel any better.
(yes, i know, seperate timers wouldnt race.)
