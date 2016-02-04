From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Thu, 4 Feb 2016 14:47:48 +0200
Message-ID: <20160204142327-mutt-send-email-mst@redhat.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-2-git-send-email-razor@blackwall.org>
 <20160204103226.333d98ca@samsung9>
 <56B291F0.9010909@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	linux-api@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbcBDMrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 07:47:52 -0500
Content-Disposition: inline
In-Reply-To: <56B291F0.9010909@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 03:49:04PM -0800, Rick Jones wrote:
> On 02/03/2016 03:32 PM, Stephen Hemminger wrote:
> 
> >But why check for valid value at all. At some point in the
> >future, there will be yet another speed adopted by some standard body
> >and the switch statement would need another value.
> >
> >Why not accept any value? This is a virtual device.
> >
> 
> And even for not-quite-virtual devices - such as a VC/FlexNIC in an HPE
> blade server there can be just about any speed set.  I think we went down a
> path of patching some things to address that many years ago.  It would be a
> shame to undo that.
> 
> rick

I'm not sure I understand. The question is in defining the UAPI.
We currently have:

 * @speed: Low bits of the speed
 * @speed_hi: Hi bits of the speed

with the assumption that all values come from the defines.

So if we allow any value here we need to define what it means.

If the following is acceptable, then we can drop
most of validation:


--->
ethtool: future-proof interface for speed extensions

Many virtual and not quite virtual devices allow any speed to be set
through ethtool. Document this fact to make sure people don't assume the
enum lists all possible values.  Reserve values greater than INT_MAX for
future extension and to avoid conflict with SPEED_UNKNOWN.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 57fa390..9462844 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -31,7 +31,7 @@
  *	physical connectors and other link features that are
  *	advertised through autonegotiation or enabled for
  *	auto-detection.
- * @speed: Low bits of the speed
+ * @speed: Low bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @duplex: Duplex mode; one of %DUPLEX_*
  * @port: Physical connector type; one of %PORT_*
  * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
@@ -47,7 +47,7 @@
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
  * @maxrxpkt: Historically used to report RX IRQ coalescing; now
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
- * @speed_hi: High bits of the speed
+ * @speed_hi: High bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
  *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
  *	value will be %ETH_TP_MDI_INVALID.  Read-only.
@@ -1303,7 +1303,7 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|5|10|20|25|40|50|56|100]GbE. */
+/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000


-- 
MST
