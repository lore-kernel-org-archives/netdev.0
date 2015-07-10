From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Fri, 10 Jul 2015 14:20:47 -0400 (EDT)
Message-ID: <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150710171027.GB6585@groeck-UX31A>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150710171027.GB6585@groeck-UX31A>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter,

On Jul 10, 2015, at 1:10 PM, Guenter Roeck linux@roeck-us.net wrote:

> On Fri, Jul 10, 2015 at 12:57:28PM -0400, Vivien Didelot wrote:
>> The current _mv88e6xxx_stats_wait function does not sleep while testing
>> the stats busy bit. Fix this by using the generic _mv88e6xxx_wait
>> function.
>> 
>> Note that it requires to move _mv88e6xxx_wait on top of
>> _mv88e6xxx_stats_wait to avoid undefined reference compilation error.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx.c | 52 +++++++++++++++++++--------------------------
>>  1 file changed, 22 insertions(+), 30 deletions(-)
>> 
>> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
>> index f6c7409..7753db1 100644
>> --- a/drivers/net/dsa/mv88e6xxx.c
>> +++ b/drivers/net/dsa/mv88e6xxx.c
>> @@ -557,19 +557,31 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
>>  	return false;
>>  }
>>  
>> +/* Must be called with SMI lock held */
>> +static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
>> +			   u16 mask)
>> +{
>> +	unsigned long timeout = jiffies + HZ / 10;
>> +
>> +	while (time_before(jiffies, timeout)) {
>> +		int ret;
>> +
>> +		ret = _mv88e6xxx_reg_read(ds, reg, offset);
>> +		if (ret < 0)
>> +			return ret;
>> +		if (!(ret & mask))
>> +			return 0;
>> +
>> +		usleep_range(1000, 2000);
>> +	}
>> +	return -ETIMEDOUT;
>> +}
>> +
>>  /* Must be called with SMI mutex held */
>>  static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
>>  {
>> -	int ret;
>> -	int i;
>> -
>> -	for (i = 0; i < 10; i++) {
>> -		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_OP);
>> -		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
>> -			return 0;
>> -	}
> 
> Hi Vivien,
> 
> is this really beneficial and/or needed ?

Except using existing generic code, no.

> It adds at least 1ms delay to a loop which did not have any delay at
> all unless the register read itself was sleeping.

I must have missed where is the benefit from spin reading 10 times this
register, rather than sleeping 1ms between tests. Does this busy bit
behaves differently from the phy, atu, scratch, or vtu busy bits?

> Is the original function seen to return a timeout error under some
> circumstances ?

I didn't experience it myself, but I guess it may happen. In addition to
that, the current implementation doesn't check eventual read error.
That's why I saw a benefit in using _mv88e6xxx_wait().

Thanks,
-v
