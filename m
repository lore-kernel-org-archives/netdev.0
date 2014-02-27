From: "Gross, Mark" <mark.gross@intel.com>
Subject: RE: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Thu, 27 Feb 2014 17:38:09 +0000
Message-ID: <BD75D217E5BAC84080F8EFB2582976378B327178@ORSMSX109.amr.corp.intel.com>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
	<1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>
	<53062F97.3050407@wwwdotorg.org>
	<CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>
	<5306E599.7020605@wwwdotorg.org>
 <CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Chen-Yu Tsai <wens@csie.org>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"mgross@linux.intel.com" <mgross@linux.intel.com>
To: Linus Walleij <linus.walleij@linaro.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please know that no one should not consider me an authority on ACPI at this time.  But, I have some comments / context / thoughts below.

Also I apologize in advance for any email formatting issues caused by replying to this via my work exchange account / outlook client.  Folks can use mgross@linux.intel.com to avoid outlook-isms from me in the future.

> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij@linaro.org]
> Sent: Tuesday, February 25, 2014 1:14 AM
> To: Stephen Warren; Alexandre Courbot; Grant Likely;
> devicetree@vger.kernel.org
> Cc: Chen-Yu Tsai; Heikki Krogerus; Johannes Berg; David S. Miller; Rhyland
> Klein; linux-wireless; netdev; linux-kernel; Arnd Bergmann; Gross, Mark
> Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
> 
> On Fri, Feb 21, 2014 at 6:35 AM, Stephen Warren
> <swarren@wwwdotorg.org> wrote:
> > On 02/20/2014 06:55 PM, Chen-Yu Tsai wrote:
> 
> >> That's correct. However using con_id to pass this results in
> >> different behavior across DT and ACPI. A better way is to export the
> >> labeling function so consumers can set meaningful labels themselves.
> >
> > But this code is the consumer of those GPIOs. IF the parameter to
> > devm_gpiod_get_index() isn't intended to be used, why does it exist?
> 
> Kerneldoc says:
> 
> /**
>  * gpiod_get_index - obtain a GPIO from a multi-index GPIO function
>  * @dev:        GPIO consumer, can be NULL for system-global GPIOs
>  * @con_id:     function within the GPIO consumer
>  * @idx:        index of the GPIO to obtain in the consumer
>  *
> 
> Basically it is just exposing the fact that of_find_gpio() and
> acpi_find_gpio() both take a con_id as argument.
> 
> If we drill into this, we find that it is used to conjure the arbitrary string
> before the gpios in the DT case, like:
> 
> foo-gpios = <...>;
> 
> As in tegra30-beaver.dts...
> 
>     sdhci@78000000 {
>             status = "okay";
>             cd-gpios = <&gpio TEGRA_GPIO(I, 5) GPIO_ACTIVE_LOW>;
>             wp-gpios = <&gpio TEGRA_GPIO(T, 3) GPIO_ACTIVE_HIGH>;
>             power-gpios = <&gpio TEGRA_GPIO(D, 7) GPIO_ACTIVE_HIGH>;
>             bus-width = <4>;
>     };
> 
> Instead of passing the GPIOs as index 0,1,2 they are named and I do admit
> this has a nice "things are under control" aspect to it.
[Gross, Mark] FWIW I don't think this is as "under control" as you do.  Those names in the above sdhci example are derived from a specific SDHCI tegra spec sheet or schematic.  Those names likely come from the data sheet for the controller.  I would like SDHCI kernel drivers to work pretty much the same for all compatible controllers.  The set of compatible controllers have spec sheets that use different naming conventions for their pins and thus a name space pollution of the SDHCI enumeration ABI will be a problem.

> 
> In the ACPI case the con_id is not used for anything.
> 
> So it is basically there to satisfy the habit in some device tree bindings to
> name gpio arrays instead of just passing gpios = <...>; (The latter should be
> encouraged going forward.)
[Gross, Mark] This is in fact just an idiom of the ACPI ABI inherited from writing linux drivers that work on systems with BIOS/FW developed for MS-Windows.  For the devices I work on we have a number of driver teams filing bugs against the BIOS/FW to add named GPIO objects to device name spaces such that they can directly query for the GPIO their driver needs and avoid assuming the 3rd GPIO is the special one they need for whatever...

So if you have the luxury of being able to influence (file bugs against or write) the platform enumeration ABI then with ACPI you can have a named gpio today.  Note: there is an expectation that the _PRP feature to go into the next version of ACPI and that should enable a trivial 1-1 mapping (when _prp is used by the ACPI platform) between the different platform enumeration API's (DT and ACPI).

Still, from a platform enumeration ABI point of view I see the arbitrariness of indexes not much worse than the arbitrary naming of pins off of spec sheets or schematics.  Given that the authors of those specs/layouts come up with a new naming schemes every time they log into their workstations (especially for the schematics).  I do admit names are a little better but still have the scaling issue WRT namespaces and arbitrary naming by HW engineers over time.

> 
> As DT is ABI we need to keep this forever, and driver may need to look for
> foo-gpios=<> and gpios=<> alike for backward compatibility if we'd change it,
> sweet isn't it? :-)
> 
> I don't quite like this, as it is adding stupid nonsens arguments for ACPI GPIO
> producers (which only take an index AFAICT), but it is a first sacrifice on the
> altar of trying to mask the differences between DT and ACPI probe paths
> about which I have mixed feelings.
[Gross, Mark] I don't have mixed feelings.  I want to see converged probe paths that can handle both ACPI and DT platform ABI's seamlessly so we can reuse drivers across architectures effectively.  I think the _PRP will help with that even though its use assumes you have influence over the platform FW and this will not help with supporting of legacy BIOS's will burden us with gpio index assumptions.

--mark

> 
> Yours,
> LInus Walleij
