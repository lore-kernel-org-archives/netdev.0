From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 0/9]net: stmmac PM related fixes.
Date: Tue, 19 Nov 2013 06:24:39 +0100
Message-ID: <528AF617.70802@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <srinivas.kandagatla@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:44117 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751865Ab3KSFZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 00:25:08 -0500
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2013 12:30 PM, srinivas.kandagatla@st.com wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>
> Hi Peppe,
>
> During PM_SUSPEND_FREEZE testing, I have noticed that PM support in STMMAC is
> partly broken. I had to re-arrange the code to do PM correctly. There were lot
> of things I did not like personally and some bits did not work in the first
> place. I thought this is the nice opportunity to clean the mess up.
>
> Here is what I did:
>
> 1> Test PM suspend freeeze via pm_test
> It did not work for following reasons.
>   - If the power to gmac is removed when it enters in low power state.
> stmmac_resume could not cope up with such behaviour, it was expecting the ip
> register contents to be still same as before entering low power, This
> assumption is wrong. So I started to add some code to do Hardware
> initialization, thats when I started to re-arrange the code. stmmac_open
> contains both resource and memory allocations and hardware initialization. I
> had to separate these two things in two different functions.
>
> These two patches do that
>    net: stmmac: move dma allocation to new function
>    net: stmmac: move hardware setup for stmmac_open to new function
>
> And rest of the other patches are fixing the loose ends, things like mdio
> reset, which might be necessary in cases likes hibernation(I did not test).
>
> In hibernation cases the driver was just unregistering with subsystems and
> releasing resources which I did not like and its not necessary to do this as
> part of PM. So using the same stmmac_suspend/resume made more sense for
> hibernation cases than using stmmac_open/release.
> Also fixed a NULL pointer dereference bug too.
>
> 2> Test WOL via PM_SUSPEND_FREEZE
> Did get an wakeup interrupt, but could not wakeup a freeze system.
> So I had to add pm_wakeup_event to the driver.
> net: stmmac: notify the PM core of a wakeup event. patch.
>
> Also few patches like
>    net: stmmac: make stmmac_mdio_reset non-static
>    net: stmmac: restore pinstate in pm resume.
> helps the resume function to reset the phy and put back the pins in default
> state.
>
> Comments?

Srini, as we had internally discussed before sending the patches to the
net ML, I agreed with your work. Some parts of the PM stuff was fully
tested on our product kernels (where the PM was a bit different
especially on HoM) and nobody raised issues to me for this code.
Also some rework you did, for example to move the dma allocation in
a new function is fine for me.

So you continue to have my Acked-by for all.

peppe

>
> Thanks,
> srini
>
> Srinivas Kandagatla (9):
>    net: stmmac: support max-speed device tree property
>    net: stmmac: mdio: remove reset gpio free
>    net: stmmac: move dma allocation to new function
>    net: stmmac: move hardware setup for stmmac_open to new function
>    net: stmmac: make stmmac_mdio_reset non-static
>    net: stmmac: fix power mangement suspend-resume case
>    net: stmmac: use suspend functions for hibernation
>    net: stmmac: restore pinstate in pm resume.
>    net: stmmac: notify the PM core of a wakeup event.
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  360 ++++++++++----------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    3 +-
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   51 +--
>   include/linux/stmmac.h                             |    1 +
>   5 files changed, 209 insertions(+), 210 deletions(-)
>
