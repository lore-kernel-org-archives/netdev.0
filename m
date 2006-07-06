From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Thu, 06 Jul 2006 09:42:19 +0200
Message-ID: <44ACBEDB.2020101@trash.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AA3DD3.1090106@trash.net> <200607052057.05526.stefan@loplof.de> <44AC2857.5030706@trash.net> <44AC2C4C.9060001@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090106080409040603050000"
Cc: Stefan Rompf <stefan@loplof.de>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:15831 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964963AbWGFHmX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 03:42:23 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <44AC2C4C.9060001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090106080409040603050000
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> Stefan Rompf wrote:
>>
>>> Anyway, is it good to propagate __LINK_STATE_PRESENT then? The same
>>> situation here, add a VLAN while the main interface is "not present",
>>> and you are out. Can you try to revert the quoted part of my patch,
>>> I'll rethink which flags should be copied on device creation.
>>
>>
>> I tried both adding LINK_STATE_XOFF to the negated flags and using
>> VLAN_LINK_STATE_MASK, both as expected solve the problem for me.
>> I have to admit I was wondering about LINK_STATE_PRESENT as well
>> (was going to complain about that too until I noticed it is also
>> set in VLAN_LINK_STATE_MASK). Maybe Ben can tell us the idea behind
>> this?
> 
> 
> I believe this link-state logic was added by someone else.  I'm not
> sure exactly what these flags are supposed to do, so I am not sure if they
> should be propagated to the VLAN or not.

I looked into this. The present flag used to get propagated from the
real device until this patch, presumably to make sure no operations
on the vlan device will be passed through to the underlying device
when it is not present. This patch should take care both of this
problem and the problem of propagating __LINK_STATE_XOFF without
ever clearing it again. Stefan, does this look right to you?


--------------090106080409040603050000
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[VLAN]: Fix link state propagation

When the queue of the underlying device is stopped at initialization time
or the device is marked "not present", the state will be propagated to the
vlan device and never change. The queue state doesn't need to be propagated
at all and shouldn't be without using netif_wake_queue/netif_stop_queue,
the present state needs to be kept up to date by the NETDEV_CHANGE
notifier.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 87d93ab26dd0c29d3f6dd3cddfd4eeea21c139f8
tree 9e3777ce697fa4c09f814967f53cb0bd142ff92c
parent 4c2d0d9de3da2b2d420d91dd654ecf1551e24eca
author Patrick McHardy <kaber@trash.net> Thu, 06 Jul 2006 09:37:33 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 06 Jul 2006 09:37:33 +0200

 net/8021q/vlan.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 458031b..8b26227 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -68,8 +68,9 @@ static struct packet_type vlan_packet_ty
 };
 
 /* Bits of netdev state that are propagated from real device to virtual */
-#define VLAN_LINK_STATE_MASK \
-	((1<<__LINK_STATE_PRESENT)|(1<<__LINK_STATE_NOCARRIER)|(1<<__LINK_STATE_DORMANT))
+#define VLAN_LINK_STATE_MASK ((1<<__LINK_STATE_PRESENT))
+#define VLAN_LINK_STATE_INITIAL_MASK \
+	(VLAN_LINK_STATE_MASK | (1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
 
 /* End of global variables definitions. */
 
@@ -479,7 +480,7 @@ #endif
 	new_dev->flags = real_dev->flags;
 	new_dev->flags &= ~IFF_UP;
 
-	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
+	new_dev->state = real_dev->state & VLAN_LINK_STATE_INITIAL_MASK;
 
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
@@ -608,11 +609,17 @@ static int vlan_device_event(struct noti
 	switch (event) {
 	case NETDEV_CHANGE:
 		/* Propagate real device state to vlan devices */
+		flgs = dev->state & VLAN_LINK_STATE_MASK;
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
 			vlandev = grp->vlan_devices[i];
 			if (!vlandev)
 				continue;
 
+			if ((vlandev->state & VLAN_LINK_STATE_MASK) != flgs) {
+				vlandev->state &= ~VLAN_LINK_STATE_MASK;
+				vlandev->state |= flgs;
+				netdev_state_change(vlandev);
+			}
 			vlan_transfer_operstate(dev, vlandev);
 		}
 		break;

--------------090106080409040603050000--
