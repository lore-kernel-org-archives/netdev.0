From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
 dependency.
Date: Tue, 16 Oct 2012 21:09:27 +0100
Message-ID: <1350418167.2649.47.camel@bwh-desktop.uk.solarflarecom.com>
References: <50654A62.5090003@linux.intel.com>
	 <20121002.222238.1580734803370802133.davem@davemloft.net>
	 <1349300710.2763.8.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121003.204336.1981040659629176119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <haicheng.li@linux.intel.com>, <netdev@vger.kernel.org>,
	<tshimizu818@gmail.com>, <linux-kernel@vger.kernel.org>,
	<haicheng.lee@gmail.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121003.204336.1981040659629176119.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-10-03 at 20:43 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 3 Oct 2012 22:45:10 +0100
> 
> > I thought of it as being a peripheral feature (which most Solarflare
> > hardware doesn't implement) so it made sense for SFC_PTP to be optional
> > like SFC_MTD and so on.  But I'm quite happy to use a select instead, if
> > you want that to be the convention for all drivers implementing PHC.
> 
> I think that consistency might trump those conerns you mentioned, at
> least in this case.

Currently such kconfig options look like, for example:

config IGB_PTP
        bool "PTP Hardware Clock (PHC)"
        default n
        depends on IGB && EXPERIMENTAL
        select PPS
        select PTP_1588_CLOCK
        ---help---
          Say Y here if you want to use PTP Hardware Clock (PHC) in the
          driver.  Only the basic clock operations have been implemented.

          Every timestamp and clock read operations must consult the
          overflow counter to form a correct time value.

There are a number of problems with this:

1. PTP_1588_CLOCK depends on PPS, so this has to select it as well.
2. PPS and PTP_1588_CLOCK depend on EXPERIMENTAL, so this has to as
   well.
3. It's a boolean, so whatever it selects is built-in, even though the
   driver it relates to may be a module.

I think the various kconfig options should be changed as follows:

1. Only PTP_1588_CLOCK selects PPS.
2. Nothing depends on EXPERIMENTAL.  (This stuff has been in for 18
   months and it's even being backported to RHEL 6 now.)
3. Either:
   (a) The per-driver PHC options select nothing, and the driver options
       do e.g.:
	select PTP_1588_CLOCK if IGB_PTP
   (b) The per-driver PHC options are removed and the driver options do:
	select PTP_1588_CLOCK
       (i.e. PHC support is unconditional)

Any objections to this, or preference for (a) vs (b)?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
