From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: set real_num_tx_queues to zreo
 avoid to trigger BUG_ON
Date: Mon, 22 Feb 2016 13:33:48 +0000
Message-ID: <56CB0E3C.8080401@citrix.com>
References: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
 <20160219.233643.95383657086552033.davem@davemloft.net>
 <33183CC9F5247A488A2544077AF19020B02E492F@SZXEMA503-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Huangpeng (Peter)" <peter.huangpeng@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: "Gonglei (Arei)" <arei.gonglei@huawei.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <33183CC9F5247A488A2544077AF19020B02E492F@SZXEMA503-MBS.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/02/16 06:00, Gonglei (Arei) wrote:
> Hi,
> 
> Thanks for rapid feedback :)
> 
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Saturday, February 20, 2016 12:37 PM
>>
>> From: Gonglei <arei.gonglei@huawei.com>
>> Date: Sat, 20 Feb 2016 09:27:26 +0800
>>
>>> It's possible for a race condition to exist between xennet_open() and
>>> talk_to_netback(). After invoking netfront_probe() then other
>>> threads or processes invoke xennet_open (such as NetworkManager)
>>> immediately may trigger BUG_ON(). Besides, we also should reset
>>> real_num_tx_queues in xennet_destroy_queues().
>>
>> One should really never invoke register_netdev() until the device is
>> %100 fully initialized.
>>
>> This means you cannot call register_netdev() until it is completely
>> legal to invoke your ->open() method.
>>
>> And I think that is what the real problem is here.
>>
>> If you follow the correct rules for ordering wrt. register_netdev()
>> there are no "races".  Because ->open() must be legally invokable
>> from the exact moment you call register_netdev().
>>
> 
> Yes, I agree. Though that's the historic legacy problem. ;)
> 
>> I'm not applying this, as it really sounds like the fundamental issue
>> is the order in which the xen-netfront private data is initialized
>> or setup before being registered.
> 
> That means register_netdev() should be invoked after xennet_connect(), right?

No.  This would mean that the network device is removed and re-added
when a guest is migrated which at best would result in considerably more
downtime (e.g., the IP address has to be renegotiated with DHCP).

David
