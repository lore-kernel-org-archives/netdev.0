From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next PATCH] amd-xgbe: use __maybe_unused to hide pm functions
Date: Thu, 10 Nov 2016 11:47:48 +0100
Message-ID: <3786660.Dsz56fUYtX@wuerfel>
References: <20161108133802.1716319-1-arnd@arndb.de> <20161109.203251.2242759501432326877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Linux PM <linux-pm@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109.203251.2242759501432326877.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, November 9, 2016 8:32:51 PM CET David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Tue,  8 Nov 2016 14:37:32 +0100
> 
> > The amd-xgbe ethernet driver hides its suspend/resume functions
> > in #ifdef CONFIG_PM, but uses SIMPLE_DEV_PM_OPS() to make the
> > reference conditional on CONFIG_PM_SLEEP, which results in a
> > warning when PM_SLEEP is not set but PM is:
> > 
> > drivers/net/ethernet/amd/xgbe/xgbe-platform.c:553:12: error: 'xgbe_platform_resume' defined but not used [-Werror=unused-function]
> > drivers/net/ethernet/amd/xgbe/xgbe-platform.c:533:12: error: 'xgbe_platform_suspend' defined but not used [-Werror=unused-function]
> > 
> > This removes the incorrect #ifdef and instead uses a __maybe_unused
> > annotation to let the compiler know it can silently drop
> > the function definition.
> > 
> > Fixes: bd8255d8ba35 ("amd-xgbe: Prepare for supporting PCI devices")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> > I originally submitted this when in March 2016, but the patch has not
> > yet made it upstream, and the file contents have moved around so
> > the old patch no longer applied so I'm resending the rebased version
> > now.
> 
> By and large, drivers handle this by using a CONFIG_PM_SLEEP ifdef.
> 
> Unless you can make an extremely convincing argument why not to do
> so here, I'd like you to handle it that way instead.

[adding linux-pm to Cc]

The main reason is that everyone gets the #ifdef wrong, I run into
half a dozen new build regressions with linux-next every week on
average, the typical problems being:

- testing CONFIG_PM_SLEEP instead of CONFIG_PM, leading to an unused
  function warning
- testing CONFIG_PM instead of CONFIG_PM_SLEEP, leading to a build
  failure
- calling a function outside of the #ifdef only from inside an
  otherwise correct #ifdef, again leading to an unused function
  warning
- causing a warning inside of the #ifdef but only testing if that
  is disabled, leading to a problem if the macro is set (this is
  rare these days for CONFIG_PM as that is normally enabled)

Using __maybe_unused avoids all of the above. My plan for the
long run however is to change the macro to something like

#define SET_SYSTEM_SLEEP_PM_OPS(suspend_fn, resume_fn) \
        .suspend   = IS_ENABLED(CONFIG_PM_SLEEP) ? suspend_fn : NULL, \
        .resume    = IS_ENABLED(CONFIG_PM_SLEEP) ? resume_fn  : NULL, \
        .freeze    = IS_ENABLED(CONFIG_PM_SLEEP) ? suspend_fn : NULL, \
        .thaw      = IS_ENABLED(CONFIG_PM_SLEEP) ? resume_fn  : NULL, \
        .poweroff  = IS_ENABLED(CONFIG_PM_SLEEP) ? suspend_fn : NULL, \
        .restore   = IS_ENABLED(CONFIG_PM_SLEEP) ? resume_fn  : NULL, 

#define SET_RUNTIME_PM_OPS(suspend_fn, resume_fn, idle_fn) \
        .runtime_suspend = IS_ENABLED(CONFIG_PM) ? suspend_fn : NULL, \
        .runtime_resume  = IS_ENABLED(CONFIG_PM) ? resume_fn  : NULL, \
        .runtime_idle    = IS_ENABLED(CONFIG_PM) ? idle_fn    : NULL,

I just haven't found the energy to start that discussion. With a definition
like this, we would need neither #ifdef nor __maybe_unused. Unfortunately
we can't just replace the existing macro while keeping the same name
because that would break every single user that has the #ifdef.

There was some discussion about that a while ago but no patch was merged
for it. I think in order to pull this off, we'd have to introduced
replacements for the existing six macros and change over the ~1000
existing users before removing the existing definitions:

   202  SET_SYSTEM_SLEEP_PM_OPS
    14  SET_LATE_SYSTEM_SLEEP_PM_OPS
    11  SET_NOIRQ_SYSTEM_SLEEP_PM_OPS
   218  SET_RUNTIME_PM_OPS
   551  SIMPLE_DEV_PM_OPS
    12  UNIVERSAL_DEV_PM_OPS

This would of course be a nontrivial amount of work, but it could
be mostly automated using coccinelle. In files per subsystem,
this would be

      7 drivers/acpi
     14 drivers/ata
     17 drivers/char
      6 drivers/crypto
     26 drivers/dma
      7 drivers/extcon
      7 drivers/gpio
     41 drivers/gpu
     10 drivers/hwmon
      7 drivers/hwtracing
     29 drivers/i2c
     90 drivers/iio
     37 drivers/media
     28 drivers/mfd
     15 drivers/misc
     52 drivers/mmc
     11 drivers/mtd
     67 drivers/net
     10 drivers/pinctrl
     19 drivers/platform
     13 drivers/power
      7 drivers/pwm
     44 drivers/rtc
     46 drivers/spi
     15 drivers/staging
     11 drivers/thermal
     22 drivers/tty
     37 drivers/usb
     32 drivers/video
     15 drivers/watchdog
     38 sound/pci
     52 sound/soc

	Arnd
