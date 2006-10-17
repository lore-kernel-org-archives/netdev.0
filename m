From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Tue, 17 Oct 2006 14:02:39 -0700
Message-ID: <453544EF.4000502@intel.com>
References: <44AC05A8.9030503@intel.com>	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>	 <1152191018.5103.48.camel@jzny2>	 <20060706.235909.78729229.davem@davemloft.net>	 <1152275283.5341.144.camel@jzny2>  <4533D594.2070908@intel.com> <1161090331.5555.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030506070508030102030106"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54136 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1750716AbWJQVEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 17:04:33 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161090331.5555.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030506070508030102030106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:
> On Mon, 2006-16-10 at 11:55 -0700, Auke Kok wrote:
>> jamal wrote:
> 
>>> I think when the e1000 says via ethtool "rx is on" - it means that it 
>>> is _advertising_ flow control as opposed to detecting partner has flow
>>> control capability.
>>> Auke, can you also check this as well?
 >>
>> Just found this in my todo box - a bit late :(
>>
>> yes, that appears to be the correct interpretation: we never read back the 
>> detected FC  state from the hardware.

For now, we should really report the FC status in e1000 at link up time. Jamal: this 
should help you out for now, I'll send something like this upstream later on.

Cheers,

Auke




--------------030506070508030102030106
Content-Type: text/x-patch;
 name="e1000_display_fc_mode_on_link_up.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_display_fc_mode_on_link_up.patch"


e1000: Display Flow Control setting used after link negotiation

No part of e1000 was reporting which Fc settings were effectively
negotiated with the link partner so that it would be impossible
to know if FC was actually used at all.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ce0d35f..ff7f396 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2426,15 +2426,22 @@ e1000_watchdog(unsigned long data)
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
+			uint32_t ctrl;
 			boolean_t txb2b = 1;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
 
-			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s\n",
+			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
+			       "Flow Control: %s\n",
 			       adapter->link_speed,
 			       adapter->link_duplex == FULL_DUPLEX ?
-			       "Full Duplex" : "Half Duplex");
+			       "Full Duplex" : "Half Duplex",
+			       ((ctrl & E1000_CTRL_TFCE) && (ctrl &
+			       E1000_CTRL_RFCE)) ? "RX/TX" : ((ctrl &
+			       E1000_CTRL_RFCE) ? "RX" : ((ctrl &
+			       E1000_CTRL_TFCE) ? "TX" : "None" )));
 
 			/* tweak tx_queue_len according to speed/duplex
 			 * and adjust the timeout factor */

--------------030506070508030102030106--
