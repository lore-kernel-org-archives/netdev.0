From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH RFC 0/9]net: stmmac PM related fixes.
Date: Tue, 14 Jan 2014 10:05:54 +0000
Message-ID: <52D50C02.3040708@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <srinivas.kandagatla@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave/Peppe,
Do you have any plans to take this series?

Peppe already Acked these series.

Please let me know if you want me to rebase these patches to a
particular branch.

Thanks,
srini

On 18/11/13 11:30, srinivas.kandagatla@st.com wrote:
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
>  any
> 1> Test PM suspend freeeze via pm_test
> It did not work for following reasons.
>  - If the power to gmac is removed when it enters in low power state.
> stmmac_resume could not cope up with such behaviour, it was expecting the ip
> register contents to be still same as before entering low power, This
> assumption is wrong. So I started to add some code to do Hardware
> initialization, thats when I started to re-arrange the code. stmmac_open
> contains both resource and memory allocations and hardware initialization. I
> had to separate these two things in two different functions.
> 
> These two patches do that
>   net: stmmac: move dma allocation to new function
>   net: stmmac: move hardware setup for stmmac_open to new function
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
>   net: stmmac: make stmmac_mdio_reset non-static
>   net: stmmac: restore pinstate in pm resume.
> helps the resume function to reset the phy and put back the pins in default
> state.
> 
> Comments?
> 
> Thanks,
> srini
> 
> Srinivas Kandagatla (9):
>   net: stmmac: support max-speed device tree property
>   net: stmmac: mdio: remove reset gpio free
>   net: stmmac: move dma allocation to new function
>   net: stmmac: move hardware setup for stmmac_open to new function
>   net: stmmac: make stmmac_mdio_reset non-static
>   net: stmmac: fix power mangement suspend-resume case
>   net: stmmac: use suspend functions for hibernation
>   net: stmmac: restore pinstate in pm resume.
>   net: stmmac: notify the PM core of a wakeup event.
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  360 ++++++++++----------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    3 +-
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   51 +--
>  include/linux/stmmac.h                             |    1 +
>  5 files changed, 209 insertions(+), 210 deletions(-)
> 
