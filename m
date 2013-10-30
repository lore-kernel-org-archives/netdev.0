From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Wed, 30 Oct 2013 23:50:50 +0300
Message-ID: <5271712A.6020105@cogentembedded.com>
References: <201309140410.38396.sergei.shtylyov@cogentembedded.com> <20130917.154446.554384673039269498.davem@davemloft.net> <523CEAD2.7030706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <523CEAD2.7030706@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/21/2013 04:39 AM, Sergei Shtylyov wrote:

>>> Sometimes the PHY reset that sh_eth_phy_start() does effects the PHY registers
>>> registers values of which are vital for the correct functioning of the driver.
>>> Unfortunately, the existing PHY platform fixup mechanism doesn't help  here as
>>> it only hooks PHY resets done by ioctl() calls. Calling phy_scan_fixups() from
>>> the driver helps here. With a proper platform fixup, this fixes NFS
>>> timeouts on
>>> the SH-Mobile Lager board.

    Timeouts happen because of the sideband ETH_LINK signal connected to PHY's 
LED0 pin -- it bounces on/off after each packet in the default LED mode and 
that seems to hinder packet sending and/or reception...

>     "And sets the PHY LED pins to the desired mode", I should have added.

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> The PHY layer is designed to naturally already take care of this kind of
>> thing.  I think that part of the problem is that you're fighting the
>> natural control flow the PHY layer provides.

>> When the phy_connect() is performed, what we end up doing is calling
>> phy_attach_direct() which invokes the ->probe() method of the driver
>> and then afterwards we do phy_init_hw() which takes care of doing
>> the fixup calls.

>     Yes, I have studied the code paths beforehand.

>> So if you really need to do a BMCR reset then run the fixups I'd like
>> you to look into making that happen within the provided control
>> flow rather than with an exceptional explicit call to run the fixups.

>     That could change the behavior of many Ethernet drivers in sometimes
> unpredictable ways I think (due to extended registers the PHYs sometimes have,
> like in this case) if you meant including the PHY reset into phylib control
> flows. Anyway, that would have required more complex patches only good for
> merging at the merge window time while I aimed at a quick fix for a problem at
> hand (which is NFS timeout/slowdown and LED mode mismatch to what was designed
> for the board).
>     Some other drivers also do reset the PHYs but usually that's accompanied
> by a loop polling for reset completion, so a naive code like that one on the
> phylib's ioctl() path couldn't have helped if I wanted to hook reset writes in
> the same fashion in phy_write(). In my case reset seems just quick enough for
> the extended PHY register reads/writes to work correctly without polling the
> reset bit first...
>     That's why I took an easy way and used already exported phy_scan_fixups()
> to undo what the PHY reset did to some of the PHY's registers. The question is
> why it was exported in the first place? It doesn't seem to be used by anything
> but phylib internally...

    Well, how about I create phy_reset() function (that will care about BMCR 
polling and calling PHY driver/fixups) that those drivers that currently do 
reset their PHYs can call (instead of open coding BMCR reset)? That way it 
seems to be less invasive than embedding PHY reset into phylib's control flow...

>> I'm willing to be convinced that this is a better or necessary approach
>> but you'll need to explain it to me.

>     Well, I didn't write this driver, so I'm probably not the best person to
> be asked about its design (maybe Iwamatsu-san could add something here). I
> don't know about the purpose of the explicit PHY reset in the driver more than
> the accompanying comment says (and it doesn't say much other than that it
> takes the PHY out of power-down). Perhaps we could just painlessly remove it,
> who knows?

    Unfortunately, Iwamatsu-san hasn't commented on its purpose... :-(

WBR, Sergei

