From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw     HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Thu, 22 Jul 2010 12:58:42 -0400
Message-ID: <4C4878C2.9000903@signal11.us>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>	 <1278623485.10421.73.camel@localhost.localdomain>	 <4C369CDC.9080104@signal11.us>	 <1278662497.10421.94.camel@localhost.localdomain>	 <4C371DE8.9020002@signal11.us>	 <1278680790.10421.106.camel@localhost.localdomain>	 <4C372CEE.3070109@signal11.us>	 <1278696815.10421.137.camel@localhost.localdomain>	 <alpine.LNX.2.00.1007221612450.4741@pobox.suse.cz> <1279812115.2621.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>,
	David S Miller <davem@davemloft.net>,
	Michael Poole <mdpoole@troilus.org>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from core.signal11.us ([64.251.29.136]:35275 "EHLO core.signal11.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755827Ab0GVQ6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 12:58:45 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by core.signal11.us (Postfix) with SMTP id 4B9B410428E
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 12:58:44 -0400 (EDT)
In-Reply-To: <1279812115.2621.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2010 11:21 AM, Marcel Holtmann wrote:
>>>>>>> what is usb-hid.ko doing here? I would expect a bunch of code
>>>>>>> duplication with minor difference between USB and Bluetooth.
>>>>>>>
>>>>>>>                
>>>>>> usbhid doesn't have a lot of code for hidraw. Two functions are involved:
>>>>>>        usbhid_output_raw_report()
>>>>>>            - calls usb_control_msg() with Get_Report
>>>>>>        usbhid_get_raw_report()
>>>>>>            - calls usb_control_msg() with Set_Report
>>>>>>                OR
>>>>>>            - calls usb_interrupt_msg() on the Ouput pipe.
>>>>>>
>>>>>> This is of course easier than bluetooth because usb_control_msg() is
>>>>>> synchronous, even when requesting reports, mostly because of the nature
>>>>>> of USB, where the request and response are part of the same transfer.
>>>>>>
>>>>>> For Bluetooth, it's a bit more complicated since the kernel treats it
>>>>>> more like a networking interface (and indeed it is). My understanding is
>>>>>> that to make a synchronous transfer in bluetooth, one must:
>>>>>>        - send the request packet
>>>>>>        - block (wait_event_*())
>>>>>>        - when the response is received in the input handler, wake_up_*().
>>>>>>
>>>>>> There's not really any code duplication, mostly because initiating
>>>>>> synchronous USB transfers (input and output) is easy (because of the
>>>>>> usb_*_msg() functions), while making synchronous Bluetooth transfers
>>>>>> must be done manually. If there's a nice, convenient, synchronous
>>>>>> function in Bluetooth similar to usb_control_msg() that I've missed,
>>>>>> then let me know, as it would simplify this whole thing.
>>>>>>
>>>>>>              
>>>>> there is not and I don't think we ever get one. My question here was
>>>>> more in the direction why HID core is doing these synchronously in the
>>>>> first place. Especially since USB can do everything async as well.
>>>>>            
>>>> I'm open to suggestions. The way I see it is from a user space
>>>> perspective. With Get_Feature being on an ioctl(), I don't see any clean
>>>> way to do it other than synchronously. Other operating systems (I can
>>>> say for sure Windows, Mac OS X, and FreeBSD) handle Get/Set Feature the
>>>> same way (synchronously) from user space.
>>>>
>>>> You seem to be proposing an asynchronous interface. What would that look
>>>> like from user space?
>>>>          
>>> not necessarily from user space, but at least from HID core to HIDP and
>>> usb-hid transports. At least that is what I would expect, Jiri?
>>>        
>> Sorry for this taking too long (vacations, conferences, you name it) for
>> me to respond.
>>
>> As all the _raw() callbacks are purely intended for userspace interaction
>> anyway, it's perfectly fine (and in fact desirable) for the low-level
>> transport drivers to perform these operations synchronously (and that's
>> what USB implementation does as well).
>>
>> Marcel, if your opposition to synchronous interface is strong, we'll have
>> to think about other aproaches, but from my POV, the patch is fine as-is
>> for Bluetooth.
>>      
> that the ioctl() API is synchronous is fine to me, however pushing that
> down to the transport drivers seems wrong to me. I think the HID core
> should be able to handle a fully asynchronous transport driver. I know
> that with the USB subsystem you are little bit spoiled here, but for
> Bluetooth it is not the case. And in the end even using the asynchronous
> USB URB calls would be nice as well.
>    

How are the URB calls better than using the synchronous calls? (see below)

> So why not make the core actually wait for responses from the transport
> driver.

Because this makes the USB side a lot more complicated, and it would 
introduce transport specific code into the core. Further, it would 
involve the transport driver calling hidraw with _every_ single packet 
it receives. Further, it would have to call hidraw with HANDSHAKE 
protocol error packets as well.

>   I would make the transport drivers a lot simpler in the long
> run.

It would make the USB transport driver and drivers/hid/hidraw much more 
complicated right now, at the expense of making the BT transport driver 
marginally simpler (and I'm not even convinced whether it would really 
be simpler). (see below for more)

>   And I know that most likely besides Bluetooth and USB you won't see
> another, but you never know.
>
>    

I just don't understand the objection. In each transport type, the 
waiting will have to be done in a different way. USB and BT are 
different enough that this is the case already, without having to 
imagine future buses which use HID. In BT, you have to check each packet 
which comes back from the BT network to see whether it is the response 
packet that hidraw is waiting for. Further, you have to check for 
HANDSHAKE packets indicating protocol error. Where better for this to be 
done than in hidp? Further, how can this possibly happen in 
drivers/hid/hidraw, as it doesn't know about the details of bluetooth to 
make this determination, and why should it? In my last email ( 
http://lkml.org/lkml/2010/7/9/231 ) to which I got no response, I laid 
out how doing the blocking in drivers/hid/hidraw would only make all the 
parts except bluetooth more complicated (including the core, and the USB 
side), and would also introduce bluetooth-specific things into the core.

Further, you're saying that using the asynchronous USB URB calls would 
be a benefit. How is it a benefit to replace a single function call 
which does exactly what I want, with a set of asynchronous calls and 
then adding my own blocking to make it do the same thing? This sounds to 
me like it would be 1: more text, 2: duplication of code, 3: error 
prone. I can't understand how this is of benefit. Please explain to me 
what I'm missing.

In theory, what you're saying makes sense. Making common code and logic 
actually common is always good. In practice though, in this case, I 
submit that there really isn't any commonality, and the only way for 
there to be commonality is to do the USB side the hard way. Further, 
drivers/hid/hidraw can't wait for a bluetooth packet without having code 
that's bluetooth-specific. It seems just that simple to me.

I'll give it some more thought, and take another look at the code to see 
if there's something obvious that I'm missing. If you know what I'm 
missing in my understanding of the problem, please tell me :)

Alan.



