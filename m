From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH 2/3] ser_gigaset: fix deallocation of platform device
 structure
Date: Thu, 10 Dec 2015 06:04:31 -0800
Message-ID: <5669866F.6040407@hurleysoftware.com>
References: <cover.1449570042.git.tilman@imap.cc>
 <83c4ab9bbca911aad62343154eabfa1af077b021.1449570042.git.tilman@imap.cc>
 <1449616321.2384.36.camel@tiscali.nl> <56680C25.1050704@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56680C25.1050704@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On 12/09/2015 03:10 AM, Tilman Schmidt wrote:
> Am 09.12.2015 um 00:12 schrieb Paul Bolle:
> 
>>> --- a/drivers/isdn/gigaset/ser-gigaset.c
>>> +++ b/drivers/isdn/gigaset/ser-gigaset.c
>>> @@ -370,19 +370,23 @@ static void gigaset_freecshw(struct cardstate
>>> *cs)
>>>  	tasklet_kill(&cs->write_tasklet);
>>>  	if (!cs->hw.ser)
>>>  		return;
>>> -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>>>  	platform_device_unregister(&cs->hw.ser->dev);
>>> -	kfree(cs->hw.ser);
>>> -	cs->hw.ser = NULL;
>>>  }
>>>  
>>>  static void gigaset_device_release(struct device *dev)
>>>  {
>>>  	struct platform_device *pdev = to_platform_device(dev);
>>> +	struct cardstate *cs = dev_get_drvdata(dev);
>>>  
>>>  	/* adapted from platform_device_release() in
>>> drivers/base/platform.c */
>>>  	kfree(dev->platform_data);
>>>  	kfree(pdev->resource);
>>> +
>>> +	if (!cs)
>>> +		return;
>>> +	dev_set_drvdata(dev, NULL);

This is of marginal value and (I think) unnecessary; it implies
the core will use the device after release, which would trigger
many problems if true.


>> dev equals cs->hw.ser->dev.dev, doesn't it?
> 
> Correct.
> 
>> So what does setting
>> cs->hw.ser->dev.dev.driver_data to NULL just before freeing it buy us?
> 
> We're freeing cs->hw.ser, not cs->hw.ser->dev.
> Clearing the reference to cs from the device structure before freeing cs
> guards against possible use-after-free.
> 
>>> +	kfree(cs->hw.ser);
>>> +	cs->hw.ser = NULL;

This pattern is common, and defends against much more common
driver bugs.

Unfortunately, much of the good this pattern is intended to do in finding
use-after-free bugs is undone by explicit tests for null everywhere else.
Not saying that's the case here; rather, generally speaking.

Like the
	if (!tty && !tty->ops && ....)

code.

Better just to let it crash.

Regards,
Peter Hurley


>> I might be missing something, but what does setting this to NULL buy us
>> here?
> 
> Just defensive programming. Guarding against possible use-after-free or
> double-free.
> 
>>
>> (I realize that I'm asking questions to code that isn't actually new but
>> only moved around, but I think that's still an opportunity to have
>> another look at that code.)
> 
> I'm a big fan of one change per patch. If we also want to modify the
> moved code then that should be done in a separate patch. It makes
> bisecting so much easier. Same reason why I separated out patch 3/3. And
> btw same reason why I think patch 1/3 should go in as-is, as an obvious
> fix to commit f34d7a5b, and any concerns about whether those tests are
> useful should be addressed by a separate patch.
> 
> Regards,
> Tilman
> 
