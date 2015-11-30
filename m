From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 06/13] net: mvneta: enable mixed egress processing using
 HR timer
Date: Mon, 30 Nov 2015 16:57:36 +0100
Message-ID: <CAPv3WKf5hRKsSuwVx94qoAzJTd6MSK=WfSi0Av7X3U_L47G=Ug@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<1448178839-3541-7-git-send-email-mw@semihalf.com>
	<20151126164540.GH4665@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151126164540.GH4665@kw.sim.vm.gnt>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

2015-11-26 17:45 GMT+01:00 Simon Guinot <simon.guinot@sequanux.org>:
> Hi Marcin,
>
> On Sun, Nov 22, 2015 at 08:53:52AM +0100, Marcin Wojtas wrote:
>> Mixed approach allows using higher interrupt threshold (increased back to
>> 15 packets), useful in high throughput. In case of small amount of data
>> or very short TX queues HR timer ensures releasing buffers with small
>> latency.
>>
>> Along with existing tx_done processing by coalescing interrupts this
>> commit enables triggering HR timer each time the packets are sent.
>> Time threshold can also be configured, using ethtool.
>>
>> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
>> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
>> ---
>>  drivers/net/ethernet/marvell/mvneta.c | 89 +++++++++++++++++++++++++++++++++--
>>  1 file changed, 85 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index 9c9e858..f5acaf6 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -21,6 +21,8 @@
>>  #include <linux/module.h>
>>  #include <linux/interrupt.h>
>>  #include <linux/if_vlan.h>
>> +#include <linux/hrtimer.h>
>> +#include <linux/ktime.h>
>
> ktime.h is already included by hrtimer.h.
>
>>  #include <net/ip.h>
>>  #include <net/ipv6.h>
>>  #include <linux/io.h>
>> @@ -226,7 +228,8 @@
>>  /* Various constants */
>>
>>  /* Coalescing */
>> -#define MVNETA_TXDONE_COAL_PKTS              1
>> +#define MVNETA_TXDONE_COAL_PKTS              15
>> +#define MVNETA_TXDONE_COAL_USEC              100
>
> Maybe we should keep the default configuration and let the user choose
> to enable (or not) this feature ?

I think that this feature should be enabled by default, same as in RX
(which is enabled by HW in ingress). It satisfies all kinds of traffic
or queues sizes. I'd prefer a situation that if someone really wants
to disable it (even if I don't know the possible justification), then
let him use ethtool for this purpose.

>
>>  #define MVNETA_RX_COAL_PKTS          32
>>  #define MVNETA_RX_COAL_USEC          100
>>
>> @@ -356,6 +359,11 @@ struct mvneta_port {
>>       struct net_device *dev;
>>       struct notifier_block cpu_notifier;
>>
>> +     /* Egress finalization */
>> +     struct tasklet_struct tx_done_tasklet;
>> +     struct hrtimer tx_done_timer;
>> +     bool timer_scheduled;
>
> I think we could use hrtimer_is_queued() instead of introducing a new
> variable.
>

Good point, i'll try that.

Best regards,
Marcin
