From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic packet
Date: Mon, 19 Dec 2016 18:11:20 +0100
Message-ID: <CAMuHMdXVVS_eLozvDnEz67_Fwg7jGDK0YEGh84rS+EAm4RFnag@mail.gmail.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <87e3f9e6-0f5a-986c-772d-006cb25b9fd9@cogentembedded.com> <20161219163904.GE21006@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35240 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758123AbcLSRLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 12:11:22 -0500
In-Reply-To: <20161219163904.GE21006@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Niklas,

On Mon, Dec 19, 2016 at 5:39 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2016-12-18 23:26:11 +0300, Sergei Shtylyov wrote:
>> On 12/12/2016 07:09 PM, Niklas S=C3=B6derlund wrote:
>> > One quirk needed for WoL is that the module clock needs to be prevente=
d
>> > from being switched off by Runtime PM. To keep the clock alive the
>>
>>    I tried to find the code in question and failed, getting muddled in t=
he
>> RPM maze. Could you point at this code for my education? :-)
>
> In my investigation I observed this (simplified) call graph with regards
> to clocks for suspend:
>
> pm_suspend
>   pm_clk_suspend
>     clk_disable
>       clk_core_disable
>         cpg_mstp_clock_disable
>
> The interesting function here are clk_core_disable(). In that function a
> 'enable_count' for each clock is decremented and the clock is only
> turned of if the count reaches zero, hence cpg_mstp_clock_disable() are
> only called if the counter reaches 0. At runtime the enable_count can be
> displayed by examining /sys/kernel/debug/clk/clk_summary.
>
> However the value for enable_count show at runtime are not the values
> which are used when the pm_clk_suspend() are called. For a clock to not
> be switched off when suspending the enable_count needs to incremented,
> which a few drivers do if they can be used as a wake-up source.
>
>>
>> > suspend callback need to call clk_enable() directly to increase the
>>
>>    My main concern is why we need to manipulate the clock directly --
>> can't you call RPM to achieve the same effect?
>
> In my early attempts to keep the clock alive when suspending I used
> pm_clk_resume()/pm_clk_suspend() to increment/decrement the clock usage
> count. pm_clk_resume()/pm_clk_suspend() calls clk_enable()/clk_disable()
> for all clocks in the device's PM clock list, among other things.
>
> Geert pointed out to me that this might have side effects and to manages
> its clock directly is preferred. Looking how these functions are used at
> other places I can only agree with Geert that this feels like the wrong
> solution and a layer violation.

>> > usage count of the clock. Then when Runtime PM decreases the clock usa=
ge
>> > count it won't reach 0 and be switched off.
>>
>>    You mean it does this even though we don't call pr_runtime_put_sync()
>> as done in sh_eth_close()?
>
> Yes.
>
> I had a look at the pm_runtime_* functions in include/linux/pm_runtime.h
> and drivers/base/power/runtime.c and could not find any clock handling.
> Maybe they only deal with power domains?

There should be a generic way to prevent a device from being suspended.
This will make sure the module clock is not disabled, and the power domain
(if applicable) is not powered down.

Note that the clock handling is a special form of power domain handling,
as it uses a clock domain.

Gr{oetje,eeting}s,

                        Geert
