From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: spidernet: dynamic phy setup code
Date: Fri, 02 Feb 2007 19:20:21 +0900 (JST)
Message-ID: <200702021020.l12AKLrS011304@toshiba.co.jp>
References: <200702011204.30526.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, jim@jklewis.com,
	netdev@vger.kernel.org
To: jens@de.ibm.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200702011204.30526.jens@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Jens-san,

Thanks for your comments.

>Ishizaki-san,
>
>> This patch partially works on celleb but remains 
>> following several problems.
>> 1. It doesn't recover once an ethernet cable which is
>>    connected to a spider_net card is unpluged. 
>
>My understanding is that you are using the LINK interrupt to detect this.

Yes. We use the LINK interrupt for this purpose.

>For the blade this is not connected but reenabling it wont hurt, I hope.
>
>> 2. It doesn't work when the spider_net card is connected to 
>>    a 100Mbps ethernet switch.
>> 
>> To solve these problems, we need to restore some codes
>> you removed from your patch.
>> 
>> (1)
>> >- if (card->aneg_count > 10) {
>> >-  /* timeout */
>> >-  card->aneg_count = 0;
>> >-  is1000 = !is1000;
>> >-  goto re_setup;
>> 
>> >- if (phy->speed == 1000 && !is1000) {
>> >-  is1000 = 1;
>> >-  goto re_setup;
>> >- } else if(phy->speed != 1000 && is1000) {
>> >-  is1000 = 0;
>> >-  goto re_setup;
>> >- }
>> 
>> We need to use different auto-neg initial settings between
>> for 10/100Mbps ethernet switches and for Gbps ethernet switches.
>> Driver don't know which type of network switch is connected to
>> network card, so we try both settings alternately in auto negtiation
>> sequences by using a variable "is1000".
>
>I still dont see why you need different settings for different speed switches.
>This is getting to a point where access to some hardware would be handy.
>What exact phy are using anyway ?

We use bcm5461. There is a possibility that we don't know the appropriate
setting which is applicable for both type of switches.

>> Furthermore, we have a problem that poll_link() may succeed even when
>> the auto-neg initial setting is for different network switch type,
>> and the network card does not work on this case. We retry auto-neg
>> with the another initial setting on this case.
>
>See above, could you give some more details why this is the case. Or maybe Ben
>knows more about this ?

We didn't investigate for the detail, but we met the following phenomena.
1. When auto-neg starts with Gbps setting and ethernet card is connected to
   a 100Mbps switch, LINK is not detected.
2. When auto-neg starts with 100/10Mbps setting and ethernet card is 
   connected to Gbps switch, LINK is detected (poll_link() succeeds), but
   the network is not available.

>> #We are commented that "is1000" should be in spider_net_card.
>> #We fixed it in another patch. Please refer the following.
>> #http://ozlabs.org/pipermail/linuxppc-dev/2007-January/030203.html
>> 
>> But we don't think this is the best solution, and we are still
>> developing 
>> our spidernet driver. If you have a good alternative idea, please
tell
>> us.
>> 
>> (2)
>> >- spider_net_write_reg(card, SPIDER_NET_GMACST,
>> >-        spider_net_read_reg(card, SPIDER_NET_GMACST));
>> >- spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
>> 
>> These codes are enabling LINK status interrupt which is disabled
>> at the beginning of auto-neg.
>> Without this operation, auto negotiation works only when a connection
>> detected for the first time, and auto negotiation will not work 
>> when an ethernet cable is unpluged or pluged.
>
>I will reenable it and see wether it affects us. The pin is not
connected so
>we should never enter this part of the code.
>
>> (3)
>> >- mii_phy_probe(phy, phy->mii_id);
>> It seems that PHY reset is necessary before auto negotiation,
>> after a link once went down.
>> We can't call directly reset routine from driver, so we call
>> mii_phy_probe().
>> We are still developping the patch as we noted, and we are considering
>> to call mii_phy_probe() from spider_net_setup_aneg(), or to call
>> reset_one_mii_phy() from bcm54xx_setup_aneg().
>
>IMHO using mii_phy_probe is the right way to do this.

OK. We will do so.

>> We think these (1)-(3) are necessary, but we are afraid that you removed
>> them
>> by a reason that they causes some trouble in Cell Blade. If so please
>> tell us.
>
>I'll do some investigations and let you know of the results.

Thanks for your cooperation to us.

By the way, we have a suggestion. Would you please make your spidernet
patch based main-line code(not based on our patch)? 
Our patch are still changing, so we think it's more convenient
for you and us to maintain the code.
We will not mind whether it includes our code or not.

We will post our recent spidernet patch set based on 2.6.20-rc6.
This patch set is merged Jens-san's spidernet patch and works on celleb.
We hope this patch set will work on Cell blade.

We intend this patch set is just for a test so far(not intended to be
taken for main-line immediately). Please try this, if you can.

Best regards,
Kou Ishizaki
