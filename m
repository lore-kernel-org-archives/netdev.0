From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Tue, 10 May 2016 16:26:00 -0700
Message-ID: <57326E08.40803@gmail.com>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571915F5.5070504@codeaurora.org>
 <571A7F3D.1070609@codeaurora.org> <571A8207.60704@gmail.com>
 <57326C44.8020906@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57326C44.8020906@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/10/2016 04:18 PM, Timur Tabi wrote:
> Florian Fainelli wrote:
>> Are you utilizing the PHYLIB APIs properly? You need at least a
>> phy_start() to start the PHY state machine, and an adjust_link callback
>> to be provided to phy_connect() (or of_phy_connect()) to manage link
>> state changes. And that's the very basic minimum here, there could be
>> additional APIs that you may end up using.
>>
>> There are tons of example in tree of drivers doing this, bcmgenet,
>> bcmsysport, tg3 etc.
> 
> Thank you.  I think I finally got phylib working, more or less.
> 
> Unfortunately, it seems I have some kind of race condition.  The driver
> has a lot that's wrong with it, and I'm trying to fix it all.  One crazy
> the driver does is it create a workqueue to handle a lot of the tasks
> that would normally be handled in the interrupt handler itself.

That sounds like a typicall top half/bottom half split, fair enough.

> 
> With phylib support, I know my driver can call phy_mac_interrupt() when
> it gets a link status change interrupt.  I then have an .adjust_link
> callback which starts or stops the mac accordingly.

The Ethernet MAC should be started in ndo_open() and stopped in
ndo_close(), in between, there are link state changes, but you are not
supposed to stop or start your Ethernet MAC and its DMA for instance
during link change, if that is a HW requirement, your HW is pretty funky.

> 
> My problem is that I'm not really sure what adjust_link is supposed to
> be doing.

Well, it's pretty simple, it is about re-configuring your Ethernet MAC
based on what the PHY link state mandates: duplex, pause, speed changes,
EEE etc is what this callback is supposed to take care of, at the
Ethernet MAC level.

>  In addition, it seems that I need to keep the workqueue
> running, otherwise the interface will not function.  I bring the
> interface up, and the driver reports success, but pings do not work.
> 
> I'm getting really frustrated.  The sample code isn't really helping a
> whole lot, because I lack a fundamental understanding of what needs to
> be done.  None of the documentation I've read is helpful, and I don't
> know how to debug it.

Seriously, no documentation is helpful? The PHY library seems pretty
well documented to me, but I suppose I have a bias, oh, and patches are
welcome of course.

> 
> Can you give me some advice on how to debug this?

Take a look at drivers/net/ethernet/broadcom/genet/bcmgenet.c and see
how it deals with managing link state changes for instance. The code is
pretty straight forward: link interrupt (and other causes) trigger a
workqueue schedule, which then processes link state changes and calls
phy_mac_interrupt(), which in turn makes the PHY library adjust the
interface carrier state.
-- 
Florian
