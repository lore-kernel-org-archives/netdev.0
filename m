From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] of/phylib: Use device tree properties to initialize
	Marvell PHYs.
Date: Mon, 22 Nov 2010 08:35:16 -0800 (PST)
Message-ID: <20101122.083516.112578583.davem@davemloft.net>
References: <1290204798-28569-1-git-send-email-ddaney@caviumnetworks.com>
	<20101120042848.GB7005@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cyril-l0cyMroinI0@public.gmane.org, arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org
To: grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20101120042848.GB7005-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date: Fri, 19 Nov 2010 21:28:49 -0700

> On Fri, Nov 19, 2010 at 02:13:18PM -0800, David Daney wrote:
>> Some aspects of PHY initialization are board dependent, things like
>> indicator LED connections and some clocking modes cannot be determined
>> by probing.  The dev_flags element of struct phy_device can be used to
>> control these things if an appropriate value can be passed from the
>> Ethernet driver.  We run into problems however if the PHY connections
>> are specified by the device tree.  There is no way for the Ethernet
>> driver to know what flags it should pass.
>> 
>> If we are using the device tree, the struct phy_device will be
>> populated with the device tree node corresponding to the PHY, and we
>> can extract extra configuration information from there.
>> 
>> The next question is what should the format of that information be?
>> It is highly device specific, and the device tree representation
>> should not be tied to any arbitrary kernel defined constants.  A
>> straight forward representation is just to specify the exact bits that
>> should be set using the "marvell,reg-init" property:
>> 
>>       phy5: ethernet-phy@5 {
>>         reg = <5>;
>>         compatible = "marvell,88e1149r";
>>         marvell,reg-init =
>>                 /* led[0]:1000, led[1]:100, led[2]:10, led[3]:tx */
>>                 <3 0x10 0 0x5777>, /* Reg 3,16 <- 0x5777 */
>>                 /* mix %:0, led[0123]:drive low off hiZ */
>>                 <3 0x11 0 0x00aa>, /* Reg 3,17 <- 0x00aa */
>>                 /* default blink periods. */
>>                 <3 0x12 0 0x4105>, /* Reg 3,18 <- 0x4105 */
>>                 /* led[4]:rx, led[5]:dplx, led[45]:drive low off hiZ */
>>                 <3 0x13 0 0x0a60>; /* Reg 3,19 <- 0x0a60 */
>>       };
>> 
>>       phy6: ethernet-phy@6 {
>>         reg = <6>;
>>         compatible = "marvell,88e1118";
>>         marvell,reg-init =
>>                 /* Fix rx and tx clock transition timing */
>>                 <2 0x15 0xffcf 0>, /* Reg 2,21 Clear bits 4, 5 */
>>                 /* Adjust LED drive. */
>>                 <3 0x11 0 0x442a>, /* Reg 3,17 <- 0442a */
>>                 /* irq, blink-activity, blink-link */
>>                 <3 0x10 0 0x0242>; /* Reg 3,16 <- 0x0242 */
>>       };
>> 
>> The Marvell PHYs have a page select register at register 22 (0x16), we
>> can specify any register by its page and register number.  These are
>> the first and second word.  The third word contains a mask to be ANDed
>> with the existing register value, and the fourth word is ORed with the
>> result to yield the new register value.  The new marvell_of_reg_init
>> function leaves the page select register unchanged, so a call to it
>> can be dropped into the .config_init functions without unduly
>> affecting the state of the PHY.
>> 
>> If CONFIG_OF_MDIO is not set, there is no of_node, or no
>> "marvell,reg-init" property, the PHY initialization is unchanged.
>> 
>> Signed-off-by: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>> Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
>> Cc: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
>> Cc: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>> Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
>> Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> 
> Untested/compiled, but looks good to me.
> 
> Reviewed-by: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>

Also applied, thanks everyone.
