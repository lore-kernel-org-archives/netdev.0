From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v6 net-next 17/17] net: qualcomm: add QCA7000 UART driver
Date: Tue, 23 May 2017 23:01:01 +0200
Message-ID: <41c7302e-b25c-9f57-470a-dd95200a060f@gmx.de>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
 <1495545173-22150-18-git-send-email-stefan.wahren@i2se.com>
 <053235ad-a963-6a09-ccb0-b643115dee00@gmx.de>
 <1059621060.236992.1495568289051@email.1und1.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-serial@vger.kernel.org, Jiri Slaby <jslaby@suse.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1059621060.236992.1495568289051@email.1und1.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.05.2017 21:38, Stefan Wahren wrote:
> 
>> Lino Sanfilippo <LinoSanfilippo@gmx.de> hat am 23. Mai 2017 um 20:16 geschrieben:
>>
>>
>> Hi,
>>
>> On 23.05.2017 15:12, Stefan Wahren wrote:
>>
>>
>>> +}
>>> +
>>> +static void qca_uart_remove(struct serdev_device *serdev)
>>> +{
>>> +	struct qcauart *qca = serdev_device_get_drvdata(serdev);
>>> +
>>> +	netif_carrier_off(qca->net_dev);
>>> +	cancel_work_sync(&qca->tx_work);
>>> +	unregister_netdev(qca->net_dev);
>>
>> Note that it is still possible that the tx work is queued right after cancel_work_sync()
>> returned and before the net device is unregistered (and thus the check for the net device
>> being up at the beginning of the tx work function is passed and the function is executed).
> 
> Even if the carrier is off? Since i see this pattern in some drivers, can you please point me to a reference like a thread or something else?
> 

The check in the tx work function is against the "running" state not against the carrier. So why should 
the carrier matter in this case? 


>> I suggest to avoid this possible race by first unregistering the netdevice and then 
>> calling cancel_work_sync().
> 
> What makes you sure that's safe to unregister the netdev while the tx work queue is possibly active?

unregister_netdevice() calls netdev_close() if the interface is still up. netdev_close() calls flush_work()
so the unregistration is delayed until the tx work function is finished. Furthermore both close() and
tx work are synchronized by means of the qca->lock which also guarantees that unregister_netdevice() wont
be finished until the tx work is done.

But I may have missed something and if unregistering the device while the tx work could be running worries you,
we could first close and later unregister the device like in the following sequence:


dev_close();
/* the tx work wont be scheduled any more now, however we have to wait for a potentially
   earlier scheduled work */ 
cancel_work_sync(&qca->tx_work);
/* we can be sure that the tx work will neither be running nor be started again, so 
   it is safe to unregister the netdev */
unregister_netdev(qca->net_dev);
serdev_device_close(serdev);
free_netdev(qca->net_dev);
 
What do you think?

Regards,
Lino
