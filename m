From: Leigh Brown <leigh@solinno.co.uk>
Subject: Re: Spurious timeouts in mvmdio
Date: Mon, 16 Dec 2013 18:28:03 +0000
Message-ID: <a599b2acdb35fa014ed9480f367fe3a7@doppler.thel33t.co.uk>
References: <529CA42A.3040504@freebox.fr>
 <20131203122346.GD29282@titan.lakedaemon.net>
 <20131203124033.GT16735@n2100.arm.linux.org.uk>
 <abe249f5cba5c267e2c536bd62c57908@doppler.thel33t.co.uk>
 <529E5F03.8040607@gmail.com>
 <8d65780eb7bfe49bb0734a09f05f70a6@doppler.thel33t.co.uk>
 <529E66A4.4050000@gmail.com>
 <ae69666fd3b61411d7bbd9ac993cec13@doppler.thel33t.co.uk>
 <20131203234209.GW16735@n2100.arm.linux.org.uk>
 <52AF4160.9080703@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52AF4160.9080703@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-12-16 18:07, Nicolas Schichan wrote:
> On 12/04/2013 12:42 AM, Russell King - ARM Linux wrote:
>> Alternatively, code it like this instead.
>> 
>>   drivers/net/ethernet/marvell/mvmdio.c |   32 
>> +++++++++++++++-----------------
>>   1 files changed, 15 insertions(+), 17 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/marvell/mvmdio.c 
>> b/drivers/net/ethernet/marvell/mvmdio.c
>> index 7354960b583b..a6f59831fc5b 100644
>> --- a/drivers/net/ethernet/marvell/mvmdio.c
>> +++ b/drivers/net/ethernet/marvell/mvmdio.c
>> @@ -76,31 +76,29 @@ static int orion_mdio_wait_ready(struct mii_bus 
>> *bus)
>>   {
>>   	struct orion_mdio_dev *dev = bus->priv;
>>   	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
>> -	unsigned long end = jiffies + timeout;
>> -	int timedout = 0;
>> 
>> -	while (1) {
>> -	        if (orion_mdio_smi_is_done(dev))
>> +	if (dev->err_interrupt > 0) {
>> +		if (wait_event_timeout(dev->smi_busy_wait,
>> +				       orion_mdio_smi_is_done(dev),
>> +				       1 + timeout))
>>   			return 0;
>> -	        else if (timedout)
>> -			break;
>> +	} else {
>> +		unsigned long end = jiffies + timeout;
>> 
>> -	        if (dev->err_interrupt <= 0) {
>> -			usleep_range(MVMDIO_SMI_POLL_INTERVAL_MIN,
>> -				     MVMDIO_SMI_POLL_INTERVAL_MAX);
>> +		while (1) {
>> +	        	if (orion_mdio_smi_is_done(dev))
>> +				return 0;
>> 
>>   			if (time_is_before_jiffies(end))
>> -				++timedout;
>> -	        } else {
>> -			wait_event_timeout(dev->smi_busy_wait,
>> -				           orion_mdio_smi_is_done(dev),
>> -				           timeout);
>> -
>> -			++timedout;
>> -	        }
>> +				break;
>> +
>> +			usleep_range(MVMDIO_SMI_POLL_INTERVAL_MIN,
>> +				     MVMDIO_SMI_POLL_INTERVAL_MAX);
>> +		}
>>   	}
>> 
>>   	dev_err(bus->parent, "Timeout: SMI busy for too long\n");
>> +
>>   	return  -ETIMEDOUT;
>>   }
> 
> Hi Russell,
> 
> I did not find any commit for this in 3.13-rc4.
> 
> Would you prefer I submit my attempt at refactoring the
> orion_mdio_wait_ready() code ?

I prefer this patch (which I think you originally proposed) because it 
is just as
correct and the code size is a bit smaller in arm mode, and the same 
size in thumb
mode (on my compiler gcc 4.7.2, at least).  I coded the loop in that way 
to make it
small.

I don't mind submitting it to David as I made the mistake in the first 
place.

Regards,

Leigh.

diff --git a/drivers/net/ethernet/marvell/mvmdio.c 
b/drivers/net/ethernet/marvell/mvmdio.c
index 7354960..a42a750 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -92,6 +92,12 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
  			if (time_is_before_jiffies(end))
  				++timedout;
  	        } else {
+			/* wait_event_timeout does not guarantee a delay of at
+			 * least one whole jiffie, so timeout must be no less
+			 * than two.
+			 */
+			 if (timeout < 2)
+			 	timeout = 2;
  			wait_event_timeout(dev->smi_busy_wait,
  				           orion_mdio_smi_is_done(dev),
  				           timeout);
