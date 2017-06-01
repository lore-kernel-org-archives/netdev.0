From: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_attr_interfmode_store
Date: Thu, 01 Jun 2017 09:05:07 +0800
Message-ID: <592F6843.9000204@163.com>
References: <1496226547-5921-1-git-send-email-baijiaju1990@163.com>
 <85905124-7167-aeb0-8aff-4ceec09e9542@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <85905124-7167-aeb0-8aff-4ceec09e9542-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/01/2017 01:33 AM, Larry Finger wrote:
> On 05/31/2017 05:29 AM, Jia-Ju Bai wrote:
>> The driver may sleep under a spin lock, and the function call path is:
>> b43legacy_attr_interfmode_store (acquire the lock by spin_lock_irqsave)
>>    b43legacy_radio_set_interference_mitigation
>>      b43legacy_radio_interference_mitigation_disable
>>        b43legacy_calc_nrssi_slope
>>          b43legacy_synth_pu_workaround
>>            might_sleep and msleep --> may sleep
>>
>> Fixing it may be complex, and a possible way is to remove
>> spin_lock_irqsave and spin_lock_irqrestore in
>> b43legacy_attr_interfmode_store, and the code has been protected by
>> mutex_lock and mutex_unlock.
>>
>> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
>> ---
>>   drivers/net/wireless/broadcom/b43legacy/sysfs.c |    2 --
>>   1 file changed, 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/broadcom/b43legacy/sysfs.c 
>> b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
>> index 2a1da15..9ede143 100644
>> --- a/drivers/net/wireless/broadcom/b43legacy/sysfs.c
>> +++ b/drivers/net/wireless/broadcom/b43legacy/sysfs.c
>> @@ -137,14 +137,12 @@ static ssize_t 
>> b43legacy_attr_interfmode_store(struct device *dev,
>>       }
>>         mutex_lock(&wldev->wl->mutex);
>> -    spin_lock_irqsave(&wldev->wl->irq_lock, flags);
>>         err = b43legacy_radio_set_interference_mitigation(wldev, mode);
>>       if (err)
>>           b43legacyerr(wldev->wl, "Interference Mitigation not "
>>                  "supported by device\n");
>>       mmiowb();
>> -    spin_unlock_irqrestore(&wldev->wl->irq_lock, flags);
>>       mutex_unlock(&wldev->wl->mutex);
>>         return err ? err : count;
>>
>
> Jia-Ju,
>
> Did you actually observe the attempt to sleep under the spin lock, or 
> did you discover this using some tool? In other words, have either of 
> your patches been tested?
>
> Larry
>
Hi,

In fact, my reported bugs are found by a static analysis tool written by 
me, and they are checked by my review of the driver code.
I admit my patches are not well tested, and they may not well fix the bugs.
I am looking forward to opinions and suggestions :)

Thanks,
Jia-Ju Bai
