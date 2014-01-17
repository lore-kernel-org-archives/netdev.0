From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH v2 01/16] reset: add non CONFIG_RESET_CONTROLLER routines
Date: Fri, 17 Jan 2014 11:46:02 +0800
Message-ID: <CAGb2v647_Am_spers6X0+16JShNa-Xo9Fozc1eZnYzbeU-wgoQ@mail.gmail.com>
References: <1389337217-29032-1-git-send-email-wens@csie.org>
 <1389337217-29032-2-git-send-email-wens@csie.org> <1389360637.5854.53.camel@pizza.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-sunxi <linux-sunxi@googlegroups.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Emilio Lopez <emilio@elopez.com.ar>,
	Mike Turquette <mturquette@linaro.org>,
	"Ivan T. Ivanov" <iivanov@mm-sol.com>,
	Barry Song <Baohua.Song@csr.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:53410 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaAQDqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 22:46:23 -0500
In-Reply-To: <1389360637.5854.53.camel@pizza.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jan 10, 2014 at 9:30 PM, Philipp Zabel <p.zabel@pengutronix.de> wrote:
> Hi,
>
> [Added Ivan, Stephen and Barry to Cc:]
>
> Am Freitag, den 10.01.2014, 15:00 +0800 schrieb Chen-Yu Tsai:
>> Some drivers are shared between platforms that may or may not
>> have RESET_CONTROLLER selected for them.
>
> I expected that drivers compiled for platforms without reset controllers
> but use the reset API should select or depend on RESET_CONTROLLER.
> Stubbing out device_reset and reset_control_get will turn a compile time
> error into a runtime error for everyone forgetting to do this when
> writing a new driver that needs the reset.

Since this was the intended behavior, I'll drop this patch and select
RESET_CONTROLLER for the stmmac driver for now.


Thanks
ChenYu

>
>>  Add dummy functions
>> when RESET_CONTROLLER is not selected, thereby eliminating the
>> need for drivers to enclose reset_control_*() calls within
>> #ifdef CONFIG_RESET_CONTROLLER, #endif
>>
>> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
>
> This was already proposed by Ivan and Barry earlier, and so far we
> didn't get to a proper conclusion:
>
> https://lkml.org/lkml/2013/10/10/179
> http://lists.infradead.org/pipermail/linux-arm-kernel/2013-June/174758.html
>
> If included, the stubs should at least return an error to indicate a
> reset couldn't be performed, but then I lose the compile time error for
> drivers which should select RESET_CONTROLLER but don't.
>
> Also this alone won't help you if you build multi-arch kernels where one
> platform enables RESET_CONTROLLER and the other expects it to be
> disabled.
>
> regards
> Philipp
>
>> ---
>>  include/linux/reset.h | 39 +++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 39 insertions(+)
>>
>> diff --git a/include/linux/reset.h b/include/linux/reset.h
>> index 6082247..38aa616 100644
>> --- a/include/linux/reset.h
>> +++ b/include/linux/reset.h
>> @@ -4,6 +4,8 @@
>>  struct device;
>>  struct reset_control;
>>
>> +#ifdef CONFIG_RESET_CONTROLLER
>> +
>>  int reset_control_reset(struct reset_control *rstc);
>>  int reset_control_assert(struct reset_control *rstc);
>>  int reset_control_deassert(struct reset_control *rstc);
>> @@ -14,4 +16,41 @@ struct reset_control *devm_reset_control_get(struct device *dev, const char *id)
>>
>>  int device_reset(struct device *dev);
>>
>> +#else /* !CONFIG_RESET_CONTROLLER */
>> +
>> +static inline int reset_control_reset(struct reset_control *rstc)
>> +{
>> +     return 0;
>> +}
>> +
>> +static inline int reset_control_assert(struct reset_control *rstc)
>> +{
>> +     return 0;
>> +}
>> +
>> +static inline int reset_control_deassert(struct reset_control *rstc)
>> +{
>> +     return 0;
>> +}
>
> Those should probably have a WARN_ON(1) like the GPIO API stubs.
>
>> +
>> +static inline struct reset_control *reset_control_get(struct device *dev,
>> +             const char *id)
>> +{
>> +     return NULL;
>> +}
> [...]
>> +static inline struct reset_control *devm_reset_control_get(struct device *dev,
>> +             const char *id)
>> +{
>> +     return NULL;
>> +}
>
> These should return ERR_PTR(-ENOSYS).
>
>> +
>> +static inline int device_reset(struct device *dev)
>> +{
>> +     return 0;
>> +}
>
> And this should return -ENOSYS.
>
> Drivers that also need to run on platforms with CONFIG_RESET_CONTROLLER
> disabled (and that don't need the reset) should ignore -ENOSYS and
> -ENOENT return values from device_reset/(devm_)reset_control_get.
>
> I wonder if it might be a good idea to add a RESET_CONTROLLER_OPTIONAL
> that drivers need to select to enable the API stubs? That way we could
> keep the compile time error for new drivers that need resets but forget
> to select RESET_CONTROLLER.
> Or add a
> #warning If this driver can work without reset, please select CONFIG_RESET_CONTROLLER_OPTIONAL
>
> Another possibility would be to add device_reset_optional and
> (devm_)reset_control_get_optional variants and only provide stubs for
> those, but not for device_reset/(devm_)reset_control_get. Then drivers
> that need to work on platforms without the reset controller API enabled
> could explicitly use the _optional variants, and all other drivers would
> still be checked at compile time.
>
> regards
> Philipp
>
