From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: audit.c skb - tty race condition - was sky2 panic in 2.6.32.1
 under load (new oops)
Date: Wed, 30 Dec 2009 15:44:20 -0500
Message-ID: <4B3BBBA4.5090400@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
 <4B34E847.8010809@majjas.com> <20091225152200.1cf11dfe@nehalam>
 <4B3581C7.8000702@majjas.com> <20091226095723.7ac82b18@nehalam>
 <4B367409.5060202@majjas.com> <4B379378.4000102@majjas.com>
 <20091227102238.0df149f9@nehalam> <4B37B7E2.5070307@majjas.com>
 <20091229093023.3ad24786@nehalam> <4B3A5048.9090700@majjas.com>
 <20091229114938.1f4d1c5c@nehalam> <4B3AFFE8.3060409@majjas.com>
 <20091229235835.1f260eb0@nehalam> <4B3B92B8.7010208@majjas.com>
 <4B3BA6E6.40906@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:42109 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbZL3Uoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 15:44:37 -0500
In-reply-to: <4B3BA6E6.40906@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple more observations:

1) enabling auditd for runlevel 3 mitigates the issue
2) starting a remote x session (XDMCP) while under load and while auditd 
is already running also triggers the sky2 interrupt status messages - so 
maybe not tty1 - but some sort of X & auditd interaction. Even in this 
case, the frequency of the error messages is much less than when auditd 
is started in runlevel 5 for the first time.

On 12/30/2009 2:15 PM, Michael Breuer wrote:
> And now looking at audit.c it seems reasonable that there is a race 
> condition when auditd is started at roughly the same time as X. I'm 
> guessing that the kaudit thread is fired up; the tty connected; and at 
> the same time X grabs the tty. Somewhere in there an skb gets hosed 
> and is then reused by whatever comes along - in my case sky2 as that's 
> where the subsequent demand is. If the demand happens first, the 
> contaminated skb (dk in what way yet) is probably waiting to manifest 
> as some other bug that's been frustrating people.
> On 12/30/2009 12:49 PM, Michael Breuer wrote:
>> On 12/30/2009 2:58 AM, Stephen Hemminger wrote:
>>> On Wed, 30 Dec 2009 02:23:20 -0500
>>> Michael Breuer<mbreuer@majjas.com>  wrote:
>>>
>>>> Ok - I called dump_txring from sky2_net_intr:
>>>> --- a/drivers/net/sky2.c
>>>> +++ b/drivers/net/sky2.c
>>>> @@ -2725,8 +2791,10 @@ static void sky2_watchdog(unsigned long arg)
>>>>    /* Hardware/software error handling */
>>>>    static void sky2_err_intr(struct sky2_hw *hw, u32 status)
>>>>    {
>>>> -       if (net_ratelimit())
>>>> +       if (net_ratelimit()) {
>>>>                   dev_warn(&hw->pdev->dev, "error interrupt
>>>> status=%#x\n", status);
>>>> +               dump_txring(hw, 0);
>>>> +       }
>>>>
>>>>           if (status&  Y2_IS_HW_ERR)
>>>>                   sky2_hw_intr(hw);
>>>>
>>>> And got this:
>>>> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt
>>>> status=0x40000008
>>>> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt
>>>> status=0x40000008
>>>> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 
>>>> done=29
>>>> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 
>>>> done=29
>>>> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
>>>> status=0x8
>>>> Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
>>>> status=0x8
>>>> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 
>>>> done=31
>>>> Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 
>>>> done=31
>>>>
>>> I notice that you have NOUVEAU Nvidia drivers loaded? The one 
>>> difference in HW
>>> between your board and mine is that I have ATI video card.
>>>
>> Seems the problem is linked to auditd and X11 (but not nouveau).
>>
>> Today, I ran a bunch of scenarios. I first determined that the 
>> problem only manifest in runlevel 5. Next, this occurred with or 
>> without KMS and with or without nouveau. This happened whether or not 
>> I was logged in (local or remote), and regardless of window manager 
>> (xdm, gdm, kdm). I then checked to see what else was different 
>> between runlevel 3 and 5 - only thing was auditd. I disabled auditd 
>> and reran - no errors.
>>
>> Now for the odd stuff:
>>
>> The errors only manifest if the high throughput data transfer is 
>> initiated when the system is in runlevel 5 and auditd was started by 
>> init when transitioning from runlevel 3 to 5. For example, the 
>> following scenarios do not cause the errors to manifest:
>>
>> runlevel3; start auditd runlevel 5; start transfer
>> runlevel3; chkconfig auditd off; runlevel5; start auditd; start transfer
>> runlevel3; start transfer (note: errors do not occur if I transition 
>> to runlevel 5 after the high bandwidth transfer has started)
>> runlevel3; startx; start transfer
>>
>> The only way I get the problem to manifest is transition to runlevel 
>> 5 with chkconfig auditd on (level 5 only) and then initate the 
>> windows backup.
>>
>> I'm guessing that there is some sort of race condition happening 
>> between X (xdm/gdm/kdm/greeter?) and auditd that is somehow 
>> corrupting something. I'd hazard a more or less obvious guess that 
>> whatever's being corrupted differs when there is already a high 
>> throughput transfer under way.
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

