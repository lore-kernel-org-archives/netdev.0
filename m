From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init) for
 Marvel 88E1116R PHYs
Date: Wed, 2 Apr 2014 12:01:25 -0700
Message-ID: <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
 <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533BD3CD.1010905@ahsoftware.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-02 2:09 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
> Am 02.04.2014 02:57, schrieb Florian Fainelli:
>
>> 2014-04-01 16:55 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
>>>
>>> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)
>>> changed the initialization of the mv643xx_eth driver to use phy_init_hw()
>>> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
>>> was broken such, that it used mdelay() instead of really waiting for a
>>> reset to finish.
>>
>>
>> So the only big difference before
>> 7cd1463664c2a15721ff4ccfb61d4d970815cb3d ("net: mv643xx_eth: use
>> phy_init_hw to reset PHY") is that we waited potentially forever for
>> the BMCR_RESET bit to get cleared, while now, we only wait for up to
>> 500 milliseconds.
>>
>> Could you verify the following two things before your patch gets merged:
>>
>> - how long does it take for your PHY to clear the BMCR_RESET bit, is
>> it more than the allowed time out in
>> drivers/net/phy/phy_device.c::phy_poll_reset
>> - is your PHY powered down (check BMCR_PWRDOWN), if that is the case,
>> we might be hitting some corner case where toggling BMCR_RESET will
>> power it on, but at the expense of waiting longer
>
>
> I've  done two tests with pr_info before and after the two resets in
> m88e1116r_config_init:
>
> with my patch:
> -----------------------
> dmesg | grep -A1 -B1  AHO
> [    1.090099] mv643xx_eth: MV-643xx 10/100/1000 ethernet driver version 1.4
> [    1.175916] AHO: before first reset
> [    1.179613] AHO: after first reset

That makes about 3.697 milliseconds

> [    1.183743] AHO: before second reset
> [    1.187530] AHO: after second reset

That makes about 3.787 milliseconds

> [    1.191905] mv643xx_eth_port mv643xx_eth_port.0 eth0: port 0 with MAC
> address xx
> --
> [    1.426487] netpoll: netconsole: device eth0 not up yet, forcing it
> [    1.505986] AHO: before first reset
> [    1.509725] AHO: after first reset
> [    1.513899] AHO: before second reset
> [    1.517754] AHO: after second reset
> [    1.521802] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> --
> [   21.372591] Adding 2996116k swap on /dev/sda3.  Priority:-1 extents:1
> across:2996116k
> [   28.305989] AHO: before first reset
> [   28.306200] AHO: after first reset
> [   28.306936] AHO: before second reset
> [   28.307153] AHO: after second reset
> [   31.509973] mv643xx_eth_port mv643xx_eth_port.0 eth0: link up, 1000 Mb/s,
> full duplex, flow control disabled
> -----------------------
>
>
> with mdelay (the value after reset is what contains MII_BMCR):
>
> -----------------------
> dmesg | grep -A1 -B1  AHO
> [    1.090072] mv643xx_eth: MV-643xx 10/100/1000 ethernet driver version 1.4
> [    1.175888] AHO: before first reset
> [    1.678806] AHO: after first reset 0x0

That's 502.918 milliseconds

> [    1.683281] AHO: before second reset
> [    2.186288] AHO: after second reset 0x0

That's 503.007 milliseconds

> [    2.191010] mv643xx_eth_port mv643xx_eth_port.0 eth0: port 0 with MAC
> address xx
> --
> [    2.426349] netpoll: netconsole: device eth0 not up yet, forcing it
> [    2.505917] AHO: before first reset
> [    2.605824] usb 1-1: new high-speed USB device number 2 using orion-ehci
> --
> [    2.829987] hub 1-1:1.0: 4 ports detected
> [    3.044502] AHO: after first reset 0x0
> [    3.049133] AHO: before second reset
> [    3.126110] usb 1-1.1: new high-speed USB device number 3 using
> orion-ehci
> --
> [    3.526107] usb 1-1.3: device descriptor read/64, error -32
> [    3.614264] AHO: after second reset 0x0
> [    3.618708] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> --
> [   21.335730] Adding 2996116k swap on /dev/sda3.  Priority:-1 extents:1
> across:2996116k
> [   28.195942] AHO: before first reset
> [   28.696270] AHO: after first reset 0x800
> [   28.696958] AHO: before second reset
> [   29.197354] AHO: after second reset 0x800
> [  111.612263] RPC: Registered named UNIX socket transport module.
> -----------------------
>
> So we see, the first reset in the last call of m88e1116r_config_init() fails
> to complete in 500ms and the phy seems to be stuck afterwards, but, for
> whatever reason, it doesn't need 500ms if mdelay isn't used (if we can trust
> the timestamps).

I wonder if the extra 2/3 microseconds we are seeing are nothing more
than the buffered printk. At any rate, it looks like the software
reset of this PHY needs to polled, and frequently for it to complete
successfully.

Can you resubmit with the following information:

- you specify the commit that introduce the problem in parenthesis,
e.g: deadbeef ("dead: beef: cafe babe")
- put this dmesg snippet in your log message to clearly illustrate
what is happening
- clarify that the PHY needs to be polled in a comment in
m88e1116r_config_init()

Meanwhile, it would be good if someone with access to this particular
PHY datasheet could look for known erratas, problems, non-standard
compliant behavior ....

>
> (You can also see, I have netconsole enabled using netconsole=... in the
> kernel cmdline).
>
> That behaviour is reproducible. The first reset in the last call to
> m88e1116r_config_init() always fails if mdelay is used.
>
> Regards,
>
> Alexander Holler
-- 
Florian
