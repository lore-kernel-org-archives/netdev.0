From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net 1/3] net: mvneta: Fix spinlock usage
Date: Wed, 09 Mar 2016 08:49:40 +0100
Message-ID: <87wppc2iqz.fsf@free-electrons.com>
References: <1457441826-6100-1-git-send-email-gregory.clement@free-electrons.com>
	<1457441826-6100-2-git-send-email-gregory.clement@free-electrons.com>
	<20160309144254.3fbf177f@xhacker>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Ofer Heifetz <oferh@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	"Marcin Wojtas" <mw@semihalf.com>,
	Dimitri Epshtein <dima@marvell.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:35763 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750887AbcCIHtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:49:43 -0500
In-Reply-To: <20160309144254.3fbf177f@xhacker> (Jisheng Zhang's message of
	"Wed, 9 Mar 2016 14:42:54 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,
 
 On mer., mars 09 2016, Jisheng Zhang <jszhang@marvell.com> wrote:

> Dear Gregory,
>
> On Tue, 8 Mar 2016 13:57:04 +0100 Gregory CLEMENT wrote:
>
>> In the previous patch, the spinlock was not initialized. While it didn't
>> cause any trouble yet it could be a problem to use it uninitialized.
>> 
>> The most annoying part was the critical section protected by the spinlock
>> in mvneta_stop(). Some of the functions could sleep as pointed when
>> activated CONFIG_DEBUG_ATOMIC_SLEEP. Actually, in mvneta_stop() we only
>> need to protect the is_stopped flagged, indeed the code of the notifier
>> for CPU online is protected by the same spinlock, so when we get the
>> lock, the notifer work is done.
>> 
>> Reported-by: Patrick Uiterwijk <patrick@puiterwijk.org>
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>>  drivers/net/ethernet/marvell/mvneta.c | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index b0ae69f84493..8dc7df2edff6 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -3070,17 +3070,17 @@ static int mvneta_stop(struct net_device *dev)
>>  	struct mvneta_port *pp = netdev_priv(dev);
>>  
>>  	/* Inform that we are stopping so we don't want to setup the
>> -	 * driver for new CPUs in the notifiers
>> +	 * driver for new CPUs in the notifiers. The code of the
>> +	 * notifier for CPU online is protected by the same spinlock,
>> +	 * so when we get the lock, the notifer work is done.
>>  	 */
>>  	spin_lock(&pp->lock);
>>  	pp->is_stopped = true;
>> +	spin_unlock(&pp->lock);
>
> This fix sleep in atomic issue. But
> I see race here. Let's assume is_stopped is false.

You forgot that the lock was hold in the mvneta_percpu_notifier so your
scenario can't happen.

>
> cpu0:                           	cpu1:
> mvneta_percpu_notifier():		mvneta_stop():
>

spin_lock(&pp->lock);

> if (pp->is_stopped) {
> 	spin_unlock(&pp->lock);
> 	break;
> }
>

                                      the lock is hold in
                                      mvneta_percpu_notifier(), so as
                                      said in the comment this cpu is
                                      waiting for on the following
                                      line:
                                      spin_lock(&pp->lock);

                                      This code will be executed only
                                      when the lock will be released
> 					pp->is_stopped = true;
> 					spin_unlock(&pp->lock);
>
>
> netif_tx_stop_all_queues(pp->dev);
> for_each_online_cpu(other_cpu) {
> ....
>
So what will happen is:
cpu0:                           	cpu1:
mvneta_percpu_notifier():		mvneta_stop():

spin_lock(&pp->lock);
if (pp->is_stopped) {
	spin_unlock(&pp->lock);
	break;
}
                                        spin_lock(&pp->lock);

netif_tx_stop_all_queues(pp->dev);
for_each_online_cpu(other_cpu) {
....
spin_unlock(&pp->lock);
					pp->is_stopped = true;
					spin_unlock(&pp->lock);


Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
