From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Wed, 22 Oct 2014 22:06:41 -0700
Message-ID: <54488CE1.2000106@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-7-git-send-email-linux@roeck-us.net> <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2014 09:37 PM, Florian Fainelli wrote:
> 2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
>> Some Marvell switches provide chip temperature data.
>> Add support for reporting it to the dsa infrastructure.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
> [snip]
>
>> +/* hwmon support ************************************************************/
>> +
>> +#if defined(CONFIG_HWMON) || (defined(MODULE) && defined(CONFIG_HWMON_MODULE))
>
> IS_ENABLED(CONFIG_HWMON)?
>

Hi Florian,

unfortunately, that won't work; I had it initially and got a nice error message
from Fengguang's build test bot.

Problem is that hwmon can be built as module and the dsa subsystem can be built
into the kernel. In that case, hwmon functionality in the driver must be disabled.
The above condition covers that case. The nouveau graphics driver has the same
problem and uses the same conditional to solve it.

An alternative would be to select HWMON in the NET_DSA Kconfig entry; the
Broadcom Tigon3 driver does that. I just don't know if that is a good idea.
I am open to suggestions.

>> +
>> +static ssize_t temp1_input_show(struct device *dev,
>> +                               struct device_attribute *attr, char *buf)
>> +{
>> +       struct dsa_switch *ds = dev_get_drvdata(dev);
>> +       int temp, ret;
>> +
>> +       ret = ds->drv->get_temp(ds, &temp);
>> +       if (ret < 0)
>> +               return ret;
>> +
>> +       return sprintf(buf, "%d\n", temp * 1000);
>> +}
>> +static DEVICE_ATTR_RO(temp1_input);
>
> You probably want the number of temperature sensors to come from the
> switch driver, and support arbitrary number of temperature sensors?

In that case we would need the number of sensors, pass a sensor index,
and create a dynamic number of attributes. The code would get much more
complex without real benefit unless there is such a chip - and if there is,
we can still change the code at that time. I would prefer to keep it simple
for now.

Thanks,
Guenter
