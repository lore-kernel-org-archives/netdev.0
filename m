From: David Brownell <david-b@pacbell.net>
Subject: Re: 2.5.50 BUG_TRAP on !dev->deadbeaf, and oopses
Date: Sun, 08 Dec 2002 14:42:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF3CAC8.5070309@pacbell.net>
References: <3DE9290A.7070502@pacbell.net> <3DEA0452.B1F15BFD@isg.de>
 <3DEBA9F5.6000606@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following up on my earlier reply ...

> Hi Stefan,
> 
>>>   KERNEL: assertion (!dev->deadbeaf) failed at net/core/dev.c(2544)
>>>
>>> I think there's another bug, beyond the obvious speling erorz.  Namely,
>>> that "deadbeaf" is only set after that BUG_TRAP, or on one error path.
>>> The assertion prevents hotpluggable network drivers from unregistering
>>> when the hardware goes away ... which is a regression.
>>
>>
>>
>> actually, the assertion is triggered when someone tries to unregister a
>> netdevice twice, and that's also why you get


FWIW I just added a printk so I could see if the disconnect() method
was called more than once (by USB) per your guess ... no, it wasn't.
It's called once, leading to flakey diagnostices and a BUG().

So this is clearly some kind of network layer problem, as I described
in my original message (and then in this one).  Behavioral proof, as
well as the one that came from inspecting the kernel source code and
noticing that "deadbeaf" clearly can't be achieving what it seems to
be intending to do...

Is there someone who has a clear explanation of exactly how "deadbeaf"
was once expected to work -- and now (since sometime before about
2.5.40) evidently doesn't?

It seems to be driven by side effects, and whatever comments are in
the code aren't any help.  The only case "deadbeaf" could be set is
still documented as an error path ... but evidently those USB drivers
don't hit that "error" path any more on 2.5 (but they do on 2.4, and
did earlier in 2.5 also).

My thought is that there were some bugs covering for each other, and
one of them got fixed ... exposing this.  But without knowing what
the networking code was really expecting to do, I can't fix anything.



> Then why will grep of all kernel files not turn up other places where
> 'deadbeaf' gets set?  There's strange stuff going on here regardless
> (as well as speling issue), which looks pretty buglike.
> 
> Plus: this kind of bugcatch should use magic numbers, or maybe zero.
> Assuming "any nonzero value is valid", like this assertion does, is
> clearly going to fail for any of the class of bugs highlighted by
> slab poisoning.  (0xa5a5a5a5 gets accepted as valid...)
> 
> 
>>>   unregister_netdevice: device /dfd74058 never was registered
>>
>>
>>
>> From a short browsing through usb.c I don't see a similiar bug catcher
>> in usb_device_remove(), so have a look if the USB subsystem itself
>> removes a unplugged device twice for some reason.
> 
> 
> At least one failure path also involves "rmmod" of the network
> drivers, where the device hardware is still around; so that code
> would not always be called.
> 
> I wouldn't rule out problems in the relevant usbcore/sysfs bits,
> even now that they seem to have stabilized again (and yes, I was
> wondering about multiple disconnects too), but all that deadbeaf
> logic still looks fishy to me.

Right now I _would_ absolutely rule out such a problem.  And that
"deadbeaf" stuff still looks more than a little bit dubious.


> - Dave
> 
> 
> 
