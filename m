From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 06 Mar 2009 08:49:19 -0700
Message-ID: <49B145FF.5060208@mlbassoc.com>
References: <20090227145746.GD17040@xi.wantstofly.org>	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>	 <20090227222802.GZ17040@xi.wantstofly.org>	 <1235991382.30736.62.camel@localhost.localdomain>	 <1235991937.30736.65.camel@localhost.localdomain>	 <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>	 <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>	 <49AC5E6F.3010204@mlbassoc.com>	 <1236070372.30736.87.camel@localhost.localdomain>	 <49AD1C81.1020106@mlbassoc.com> <1236083560.3073
 6.114.camel@localhost.localdomain> <49AD2FE1.60305@mlbassoc.com> <49AD30F7.4080006@mlbassoc.com> <49ADA697.3050400@mlbassoc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070803010703020906050708"
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:3115 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbZCFPt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:49:57 -0500
In-Reply-To: <49ADA697.3050400@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070803010703020906050708
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Gary Thomas wrote:
> Gary Thomas wrote:
>> Gary Thomas wrote:
>>> Jesper Dangaard Brouer wrote:
>>>> On Tue, 2009-03-03 at 05:03 -0700, Gary Thomas wrote:
>>>>> Jesper Dangaard Brouer wrote:
>>>>>> On Mon, 2009-03-02 at 15:32 -0700, Gary Thomas wrote:
>>>>>>> Any ideas how I might troubleshoot why packets that come
>>>>>>> into lan1.1 (port 0) aren't being pushed to the CPU port?
>>>>>> The switch supports port monitoring, with seperate ingress and egress
>>>>>> mapping, thus you could place another PC on another port and direct
>>>>>> traffic towards that, and by tcpdump inspecting ingress and egress on
>>>>>> the different physical ports... Thats how I debugged it once...
>>>>> I'm a bit fuzzy on this - could you explain in a bit more detail?
>>>> You basically set the monitor destination port via REG_GLOBAL reg 0x1A
>>>> "Monitor Control".
>>>>
>>>> /* Register: Monitor Control (0x1A)
>>>>    -------------------------
>>>>     bit 15:12= Ingress Monitor Dest
>>>>     bit 11:8 = Egress  Monitor Dest
>>>>     bit  7:4 = ARP Dest
>>>>     bit  3:0 = Reserved
>>>> */
>>>>
>>>> Then you configure the port register 0x08 "port control2", that this
>>>> port is to be monitored: bit5=monitor_egress and bit4=monitor_ingress.
>>>>
>>>> /* Register: Port Control 2 (0x8)
>>>>    ------------------------
>>>>     bit 15    = IgnoreFSC: Force good FSC in frame
>>>>     bit 14    = VTU_prio_override   : VTU    setting overrides prio
>>>>     bit 13    = ATU_SA_prio_overrite: ATU SA setting overrides prio
>>>>     bit 12    = ATU_DA_prio_overrite: ATU DA setting overrides prio
>>>>     bit 11:10 = 802.1Q mode
>>>>      [00] = <Disabled>: use VLANtable only
>>>>      [01] = <Fallback>: fallback to VLANTable
>>>>      [10] = <Check>   : drop on miss (eq. not in VTU)
>>>>      [11] = <Secure>  : drop on miss and membership violation
>>>>     bit 9     = Discard Tagged
>>>>     bit 8     = Discard Untagged
>>>>     bit 7     = MapDA: Map using DA hits
>>>>     bit 6     = Default Forward (normal switch operation)
>>>>     bit 5     = Monitor egress
>>>>     bit 4     = Monitor ingress
>>>>     bit 3:0   = CPU port
>>>> */
>>>>
>>>>
>>>> Reading through the "Monitor Control" register description, there is a
>>>> interesting description about the "ARPdest" setting... Could you try to
>>>> set it to the CPU port and see if that helps?
>>>>
>>> It's already set this way (sans bits 4&5)
>>> 	REG_WRITE(REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1100) | 0x00f0);
>>>
>>> I tried turning on bit 4 on port 0 (lan1.1).  Now I can see what's
>>> coming into that port, but it doesn't look right:
>>>
>>> Here's the ARP going out:
>>>
>>> 13:46:29.348449 00:1d:11:81:00:00 > ff:ff:ff:ff:ff:ff, ethertype Unknown (0x4000), length 46:
>>>         0x0000:  ffff ffff ffff 001d 1181 0000 4000 0000
>>>         0x0010:  0806 0001 0800 0604 0001 001d 1181 0000
>>>         0x0020:  c0a8 0cbc 0000 0000 0000 c0a8 0c12
>>>
>>> Here's the ARP reply coming back:
>>>
>>> 13:46:29.348907 00:1e:c9:2f:73:6c > 00:1d:11:81:00:00, ethertype Unknown (0x8004), length 64:
>>>         0x0000:  001d 1181 0000 001e c92f 736c 8004 0000
>>>         0x0010:  0806 0001 0800 0604 0002 001e c92f 736c
>>>         0x0020:  c0a8 0c12 001d 1181 0000 c0a8 0cbc 0000
>>>         0x0030:  0000 0000 0000 0000 0000 0000 0000 0000
>>>
>>> I understand the 0x4000 DSA tag going out, but what's the 0x8004?
>>>
>> Note: without the extra monitor bit (#4), I don't see these packets
>> get back to my ethernet device.  Maybe the tag says something of why?
> 
> I found this tag in the 6131 manual - it basically says that it's
> a copied packet which was received on VID 0.  Exactly as expected.
> 
>> Any pointers on how I can test/debug the "VLAN" (internal routing) setup?
> 
> Do you understand where (which register settings) cause packets
> which come in on lan1.1 (VID=0 I think, port 0) to be sent on
> to the CPU port (10) along with the TO_CPU tag?  I've been through
> this document a dozen times and I still don't see where the mapping
> that direction happens...

After much experimentation, I finally found out what was
wrong.  Basically, the trunk masks have 8 bits on the 6131,
but 11 bits on the 609x and this wasn't being handled.  Once
the trunk masks were reset by the init code, there was no
path to the CPU port from the LAN ports :-(  The attached
patch is what I've ended up with.  It works, at least for
a single switch.

Next, I need to get it to work with multiple switches (separate
ethernet controllers, same/shared MII bus), as well as a cascaded
switch.



-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------

--------------070803010703020906050708
Content-Type: text/plain;
 name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diffs"

Index: net/dsa/mv88e6131.c
===================================================================
--- net/dsa/mv88e6131.c	(.../kvaerner-subsea-2008-08-14-branch/tools/linuxppc-2.6/net/dsa)	(revision 4831)
+++ net/dsa/mv88e6131.c	(.../elbit-systems-2009-02-24-branch/tools/linuxppc-2.6/net/dsa)	(working copy)
@@ -21,6 +21,8 @@
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
 		ret &= 0xfff0;
+		if (ret == 0x0950)
+			return "Marvell 88E6095/88E6095F";
 		if (ret == 0x1060)
 			return "Marvell 88E6131";
 	}
@@ -28,6 +30,49 @@
 	return NULL;
 }
 
+static void mv88e6131_show_all(struct dsa_switch *ds)
+{
+    int p, r;
+
+    printk("=== Global regs:\n");
+    for (r = 0;  r < 27;  r++) {
+        printk("  REG[0x%02x] = 0x%04X\n", r, REG_READ(REG_GLOBAL, r));
+    }
+    printk("=== Port regs:\n");
+    for (p = 0x0;  p < 0xB;  p++) {
+        for (r = 0;  r < 26;  r++) {
+            if ((r == 2) || (r == 5) || ((r >= 12) && (r <= 15))) 
+                continue;
+            printk("  REG[0x%02x.%02x] = 0x%04x\n", p, r, REG_READ(REG_PORT(p), r));
+        }
+    }
+    printk("=== VTU table:\n");
+    REG_WRITE(REG_GLOBAL, 0x06, 0x0FFF);
+    while (true) {
+        // Issue VTU 'get next' command
+        REG_WRITE(REG_GLOBAL, 0x05, 0xC000);
+        while ((REG_READ(REG_GLOBAL, 0x05) & 0x8000) != 0) msleep(1);
+        p = REG_READ(REG_GLOBAL, 0x06) & 0x1FFF;
+        if ((p & 0x1000) == 0) {
+            break;
+        }
+        printk("   VTU[0x%03x] = 0x%04x/0x%04x/0x%04x\n", p & 0x0FFF,
+               REG_READ(REG_GLOBAL, 0x07),
+               REG_READ(REG_GLOBAL, 0x08),
+               REG_READ(REG_GLOBAL, 0x09));
+    }
+    printk("=== Trunk mask table\n");
+    for (r = 0;  r < 8;  r++) {
+        REG_WRITE(REG_GLOBAL2, 0x07, (r << 12));
+        printk("   MASK[0x%1x] = 0x%04x\n", r, REG_READ(REG_GLOBAL2, 0x07));
+    }
+    printk("=== Trunk mapping table\n");
+    for (r = 0;  r < 16;  r++) {
+        REG_WRITE(REG_GLOBAL2, 0x08, (r << 11));
+        printk("   MAP[0x%1x] = 0x%04x\n", r, REG_READ(REG_GLOBAL2, 0x08));
+    }
+}
+
 static int mv88e6131_switch_reset(struct dsa_switch *ds)
 {
 	int i;
@@ -36,7 +81,7 @@
 	/*
 	 * Set all ports to the disabled state.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -91,7 +136,7 @@
 	 * Configure the priority mapping registers.
 	 */
 	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
+        if (ret < 0)
 		return ret;
 
 	/*
@@ -136,7 +181,7 @@
 	 * Clear all trunk masks.
 	 */
 	for (i = 0; i < 8; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
+		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0x7ff);
 
 	/*
 	 * Clear all trunk mappings.
@@ -159,9 +204,10 @@
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values.
+	 * or flow control state to any particular values for normal ports.
+         * CPU port is forced link+full+1000Mb
 	 */
-	REG_WRITE(addr, 0x01, 0x0003);
+	REG_WRITE(addr, 0x01, (p == ds->cpu_port) ? 0x003E : 0x0003);
 
 	/*
 	 * Port Control: disable Core Tag, disable Drop-on-Lock,
@@ -212,7 +258,7 @@
 	 * addresses.
 	 */
 	REG_WRITE(addr, 0x08,
-			((p == ds->cpu_port) ? 0x00c0 : 0x0080) |
+                        ((p == ds->cpu_port) ? 0x00c0 : 0x0080) |
 			 ds->cpu_port);
 
 	/*
@@ -268,7 +314,7 @@
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = mv88e6131_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -279,7 +325,7 @@
 
 static int mv88e6131_port_to_phy_addr(int port)
 {
-	if (port >= 0 && port != 3 && port <= 7)
+	if (port >= 0 && port <= 11)
 		return port;
 	return -1;
 }

--------------070803010703020906050708--
