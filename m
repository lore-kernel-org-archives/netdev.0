From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Mon, 19 Dec 2016 17:39:04 +0100
Message-ID: <20161219163904.GE21006@bigcity.dyn.berto.se>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <87e3f9e6-0f5a-986c-772d-006cb25b9fd9@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35982 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763115AbcLSQjS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 11:39:18 -0500
Received: by mail-lf0-f43.google.com with SMTP id t196so57925255lff.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 08:39:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87e3f9e6-0f5a-986c-772d-006cb25b9fd9@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thanks for the spelling feedback, will include your suggestions in v3.
Which I hope to post once rc1 is released and netdev opens, as you 
suggested to me previously.

On 2016-12-18 23:26:11 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/12/2016 07:09 PM, Niklas Söderlund wrote:
> 
> > Add generic functionality to support Wake-on-Lan using MagicPacket which
> > are supported by at least a few versions of sh_eth. Only add
> > functionality for WoL, no specific sh_eth version are marked to support
> 
>    Versions.
> 
> > WoL yet.
> > 
> > WoL is enabled in the suspend callback by setting MagicPacket detection
> > and disabling all interrupts expect MagicPacket. In the resume path the
> > driver needs to reset the hardware to rearm the WoL logic, this prevents
> > the driver from simply restoring the registers and to take advantage of
> > that sh_eth was not suspended to reduce resume time. To reset the
> > hardware the driver close and reopens the device just like it would do
> 
>    Closes.
> 
> > in a normal suspend/resume scenario without WoL enabled, but it both
> > close and open the device in the resume callback since the device needs
> 
>    Closes and opens.
> 
> > to be open for WoL to work.
> 
> > One quirk needed for WoL is that the module clock needs to be prevented
> > from being switched off by Runtime PM. To keep the clock alive the
> 
>    I tried to find the code in question and failed, getting muddled in the
> RPM maze. Could you point at this code for my education? :-)

In my investigation I observed this (simplified) call graph with regards
to clocks for suspend:

pm_suspend
  pm_clk_suspend
    clk_disable
      clk_core_disable
        cpg_mstp_clock_disable

The interesting function here are clk_core_disable(). In that function a
'enable_count' for each clock is decremented and the clock is only
turned of if the count reaches zero, hence cpg_mstp_clock_disable() are
only called if the counter reaches 0. At runtime the enable_count can be
displayed by examining /sys/kernel/debug/clk/clk_summary.

However the value for enable_count show at runtime are not the values
which are used when the pm_clk_suspend() are called. For a clock to not
be switched off when suspending the enable_count needs to incremented,
which a few drivers do if they can be used as a wake-up source.

> 
> > suspend callback need to call clk_enable() directly to increase the
> 
>    My main concern is why we need to manipulate the clock directly --
> can't you call RPM to achieve the same effect?

In my early attempts to keep the clock alive when suspending I used 
pm_clk_resume()/pm_clk_suspend() to increment/decrement the clock usage 
count. pm_clk_resume()/pm_clk_suspend() calls clk_enable()/clk_disable() 
for all clocks in the device's PM clock list, among other things.

Geert pointed out to me that this might have side effects and to manages 
its clock directly is preferred. Looking how these functions are used at 
other places I can only agree with Geert that this feels like the wrong 
solution and a layer violation.

> 
> > usage count of the clock. Then when Runtime PM decreases the clock usage
> > count it won't reach 0 and be switched off.
> 
>    You mean it does this even though we don't call pr_runtime_put_sync()
> as done in sh_eth_close()?

Yes.

I had a look at the pm_runtime_* functions in include/linux/pm_runtime.h 
and drivers/base/power/runtime.c and could not find any clock handling.  
Maybe they only deal with power domains?

I might have missed something when looking in to this. But if I do not 
call clk_enable()/clk_disable() (or something equivalent) in the sh_eth 
suspend/resume callbacks WoL do not work. That is it suspends fine but 
sending a MagicPacket do not wake the system :-)

> 
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> [...]
> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
