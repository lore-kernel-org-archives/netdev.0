From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Fri, 30 Jun 2017 17:14:11 +0800
Message-ID: <e53994a8-25df-a7dc-cbf0-cbc4063e734c@huawei.com>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
 <20170628202819.GA22815@lunn.ch>
 <1bff07ed-d423-dfa2-61e3-3f35c4536632@huawei.com>
 <20170629135648.GD9244@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170629135648.GD9244@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/29 21:56, Andrew Lunn wrote:
>>> You only call dev_close() if the device is running. What if somebody
>>> runs the self test on an interface when it has never been opened? It
>>> looks like you will call phy_resume(). But since it has never been
>>> suspended, you could be in trouble.
>> Here is what I can think of:
>> 1. when the mac driver is first loaded, the phy has a default state. suspended?
> 
> Nope. The PHY will only be suspended when you actually call
> phy_suspend.
> 
>> 2. If user runs the self test after using 'ifconfig ethX down', then I suppose
>> phy is already suspended.
> 
> Assuming the phy has at some point been up, after a down, it should be
> suspended.
> 
> The key thing here is, phy_resume() can only be called after a
> successful phy_suspend(). Those are the power management rules, and
> the expectations of the drivers. Doing a resume without first doing an
> explicit suspend is asking for bad things to happen.
> 
> You are having trouble because you are not using the API for what it
> was intended. Maybe you need to take a step back and look at the
> bigger picture of how self tests are being performed. Why do you need
> the dev_close()/dev_open()? Maybe
> netif_device_detach()/netif_device_attach() would be better?
> How do other drivers do self test?
> 
Basically, when doing a loopback test, we put a skb in the tx ring, and
see if we can receive it in the rx ring. And We can't find other functions
that meets our requirement, except dev_close()/dev_open.

netif_device_detach only stop the stack from sending packet, napi_disable is
needed to stop the stack from receiving packet.
And after phy loopback test, netif_device_attach does not bring back the link.
Is there a way to bring back the link?

We still need to resume the phy after 'ifconfig ethX down'. Also how can I
tell the difference between phy being suspended after 'ifconfig ethX down'
and phy being not suspended after mac driver is first loaded?

It seems that ixgbe_ethtool in mainline kernel also use netif_tx_disable,
napi_disable and other hardware specific method to setup self test.
But newest ixgbe_ethtool code in github also use dev_close to do self test.

Any idea?

Best Regard
Yunsheng Lin
