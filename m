From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_op_bss_info_changed
Date: Wed, 31 May 2017 19:07:15 -0500
Message-ID: <284d6d5d-d548-9e05-eafd-a6b521af5a04@lwfinger.net>
References: <1496225353-5544-1-git-send-email-baijiaju1990@163.com>
 <877f0xnwyk.fsf@kamboji.qca.qualcomm.com> <20170531173107.25eeda48@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Michael_B=c3=bcsch?= <m@bues.ch>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170531173107.25eeda48@wiggum>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/31/2017 10:32 AM, Michael Büsch wrote:
> On Wed, 31 May 2017 13:26:43 +0300
> Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> 
>> Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> writes:
>>
>>> The driver may sleep under a spin lock, and the function call path is:
>>> b43legacy_op_bss_info_changed (acquire the lock by spin_lock_irqsave)
>>>    b43legacy_synchronize_irq
>>>      synchronize_irq --> may sleep
>>>
>>> To fix it, the lock is released before b43legacy_synchronize_irq, and the
>>> lock is acquired again after this function.
>>>
>>> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
>>> ---
>>>   drivers/net/wireless/broadcom/b43legacy/main.c |    2 ++
>>>   1 file changed, 2 insertions(+)
>>>
>>> diff --git a/drivers/net/wireless/broadcom/b43legacy/main.c b/drivers/net/wireless/broadcom/b43legacy/main.c
>>> index f1e3dad..31ead21 100644
>>> --- a/drivers/net/wireless/broadcom/b43legacy/main.c
>>> +++ b/drivers/net/wireless/broadcom/b43legacy/main.c
>>> @@ -2859,7 +2859,9 @@ static void b43legacy_op_bss_info_changed(struct ieee80211_hw *hw,
>>>   	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_MASK, 0);
>>>   
>>>   	if (changed & BSS_CHANGED_BSSID) {
>>> +		spin_unlock_irqrestore(&wl->irq_lock, flags);
>>>   		b43legacy_synchronize_irq(dev);
>>> +		spin_lock_irqsave(&wl->irq_lock, flags);
>>
>> To me this looks like a fragile workaround and not a real fix. You can
>> easily add new race conditions with releasing the lock like this.
>>
> 
> 
> I think releasing the lock possibly is fine. It certainly is better than
> sleeping with a lock held.
> We disabled the device interrupts just before this line.
> 
> However I think the synchronize_irq should be outside of the
> conditional right after the write to B43legacy_MMIO_GEN_IRQ_MASK. (So
> two lines above)
> I don't think it makes sense to only synchronize if BSS_CHANGED_BSSID
> is set.
> 
> 
> On the other hand b43 does not have this irq-disabling foobar anymore.
> So somebody must have removed it. Maybe you can find the commit that
> removed this stuff from b43 and port it to b43legacy?
> 
> 
> So I would vote for moving the synchronize_irq up outside of the
> conditional and put the unlock/lock sequence around it.
> And as a second patch on top of that try to remove this stuff
> altogether like b43 did.

The patch that removed it in b43 is

commit 36dbd9548e92268127b0c31b0e121e63e9207108
Author: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Date:   Fri Sep 4 22:51:29 2009 +0200

     b43: Use a threaded IRQ handler

     Use a threaded IRQ handler to allow locking the mutex and
     sleeping while executing an interrupt.
     This removes usage of the irq_lock spinlock, but introduces
     a new hardirq_lock, which is _only_ used for the PCI/SSB lowlevel
     hard-irq handler. Sleeping busses (SDIO) will use mutex instead.

     Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
     Tested-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
     Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

I vaguely remember this patch. Although it is roughly a 1000-line fix, I will 
try to port it to b43legacy. I still have an old BCM4306 PCMCIA card that I can 
test in a PowerBook G4.

I agree with Michael that this is the way to go. Both of Jia-Ju's patches should 
be rejected.

Larry
