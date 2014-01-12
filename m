From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/3] b43: Fix oops if firmware is not available
Date: Sun, 12 Jan 2014 13:21:12 -0600
Message-ID: <52D2EB28.2000507@lwfinger.net>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>		 <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>	 <1389497251.3720.40.camel@deadeye.wl.decadent.org.uk>	 <52D21226.4070306@lwfinger.net> <1389500647.3720.51.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:57857 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaALTVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 14:21:16 -0500
In-Reply-To: <1389500647.3720.51.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 10:24 PM, Ben Hutchings wrote:
> On Sat, 2014-01-11 at 21:55 -0600, Larry Finger wrote:
>> On 01/11/2014 09:27 PM, Ben Hutchings wrote:
>>> On Sat, 2014-01-11 at 13:48 -0600, Larry Finger wrote:
>>>> On openSUSE systems, the script that installs the firmware for b43 also
>>>> unloads and reloads the driver. When the firmware was not previously
>>>> available, the driver has stalled at a wait_for_completion(). When the
>>>> unload routine releases that hold, the driver encounters structures
>>>> that have already been deleted and generates a fatal condition. When
>>>> the user does a manual restart, the file system cleanup frequently
>>>> results in the firmware files being deleted and the user is never able
>>>> to install the firmware. The fix is to change the wait_for_completion()
>>>> with a wait_for_completion_timeout() with a 60 second wait period.
>>>>
>>>> There is a potential race condition; however, the chances that less
>>>> than a minute has elapsed between the initial driver load and a
>>>> subsequent unload is very unlikely.
>>>
>>> A minute-long race is 'unlikely' to be hit?  Seriously?!
>>
>> Ben,
>>
>> If you force a reboot before the minute expires, nothing weird happens. The only
>> race condition happens when the user has to
>
> ...remove the module.  Exactly how the bug reporter triggered module
> removal seems irrelevant.
>
>> log in, open a terminal, run a
>> script that downloads 13.5 MiB of files from the Internet, and then executes the
>> firmware extraction program. On my 10 Mbps external line and a 2 GHz CPU, that
>> takes 32 s, plus any time to enter the password for a sudo operation. That was
>> the basis for my conclusion that a race is unlikely.
>>
>> What is the minimum time that should be allowed for a request_firmware_nowait()
>> to respond? I know we had to go to asynchronous fw loading because the
>> synchronous  version would timeout at 30 s.
>
> You could switch back to synchronous firmware loading soon, as it's not
> going to support a usermode helper any more.
>
> But until then, the proper fix for this is going to be to cancel the
> waiter earlier in teardown.

After closer inspection, it turns out the waiter was never canceled in the 
teardown. I have had to move the completion struct to make it available at 
module exit, but now I have a better fix.

Thanks for the critical review.

Larry
