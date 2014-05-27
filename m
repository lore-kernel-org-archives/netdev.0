From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Tue, 27 May 2014 14:40:15 -0700
Message-ID: <5385063F.30407@codeaurora.org>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org> <1400875040-13269-2-git-send-email-sboyd@codeaurora.org> <20140524124858.GR22111@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	=?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140524124858.GR22111@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/24/14 05:48, Mark Brown wrote:
> On Fri, May 23, 2014 at 12:57:17PM -0700, Stephen Boyd wrote:
>
>>  Optional properties:
>> -- vdd-supply:	supply for Ethernet mac
>> +- vdd-supply: analog 3.3V supply for Ethernet mac
>> +- vdd-io-supply: digital 1.8V IO supply for Ethernet mac
> So, according to the datasheet I managed to find this device has a
> supply VDD_IO (so normally written vdd-io-supply here), some other
> supplies which are tied to VDD_IO (so can probably be omitted) and a
> supply VDD_A3.3 none of which are optional.  There is an internal
> regulator which can be used to drop a higher voltage VDD_IO down for
> some of the supplies tied to it but that's essentially a noop from
> software as far as I can tell.  None of these supplies are obviously
> optional, though I've not read the datasheet in detail so I may have
> missed something here.
>
> That said it looks like this is intended to be a supply for an external
> PHY rather than the device itself, but even so my original question
> about it being able to operate without power still applies.  Looking at
> the code it's certainly not doing any of the handling of a missing
> supply that I would associate with using _optional().

I agree, both supplies don't look optional. Unfortunately
efm32gg-dk3750.dts doesn't look to be listing any supply, and this
driver only recently got support for the VDD_A3.3 supply that the omap
board uses (adding Uwe for any comments on efm setup). I presume on
these boards VDD_IO is tied to some always on power source that software
doesn't want to deal with. Nishant, what's VDD_IO connected to on omap?

What's the proper solution here? Should we use regulator_get() and check
for EPROBE_DEFER and ignore other errors?

By the way, the documentation for regulator_get_optional() and
regulator_get_exclusive() are confusing. It looks like we copy/pasted
the exclusive text (typo and all).

 * regulator_get_optional - obtain optional access to a regulator.
 * @dev: device for regulator "consumer"
 * @id: Supply name or regulator ID.
 *
 * Returns a struct regulator corresponding to the regulator producer,
 * or IS_ERR() condition containing errno.  Other consumers will be
 * unable to obtain this reference is held and the use count for the
 * regulator will be initialised to reflect the current state of the
 * regulator.


vs.

 * regulator_get_exclusive - obtain exclusive access to a regulator.
 * @dev: device for regulator "consumer"
 * @id: Supply name or regulator ID.
 *
 * Returns a struct regulator corresponding to the regulator producer,
 * or IS_ERR() condition containing errno.  Other consumers will be
 * unable to obtain this reference is held and the use count for the
 * regulator will be initialised to reflect the current state of the
 * regulator.


Should the get_optional() variant just drop the "Other consumers will
be... " part and should the get_exclusive() variant say "obtain this
regulator while this reference is held" ?


----8<----

From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] regulator: Fix regulator_get_{optional,exclusive}()
 documentation

regulator_get_optional() doesn't hold an exclusive reference to
the regulator. Fix the documentation and reword the exclusive
documentation to fix the grammatical error "this reference is
held".

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/regulator/core.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/regulator/core.c b/drivers/regulator/core.c
index b97ffd2365d3..2fae21a9d0e5 100644
--- a/drivers/regulator/core.c
+++ b/drivers/regulator/core.c
@@ -1430,9 +1430,9 @@ EXPORT_SYMBOL_GPL(regulator_get);
  *
  * Returns a struct regulator corresponding to the regulator producer,
  * or IS_ERR() condition containing errno.  Other consumers will be
- * unable to obtain this reference is held and the use count for the
- * regulator will be initialised to reflect the current state of the
- * regulator.
+ * unable to obtain this regulator while this reference is held and the
+ * use count for the regulator will be initialised to reflect the current
+ * state of the regulator.
  *
  * This is intended for use by consumers which cannot tolerate shared
  * use of the regulator such as those which need to force the
@@ -1456,10 +1456,7 @@ EXPORT_SYMBOL_GPL(regulator_get_exclusive);
  * @id: Supply name or regulator ID.
  *
  * Returns a struct regulator corresponding to the regulator producer,
- * or IS_ERR() condition containing errno.  Other consumers will be
- * unable to obtain this reference is held and the use count for the
- * regulator will be initialised to reflect the current state of the
- * regulator.
+ * or IS_ERR() condition containing errno.
  *
  * This is intended for use by consumers for devices which can have
  * some supplies unconnected in normal use, such as some MMC devices.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation
