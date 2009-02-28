From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Sat, 28 Feb 2009 12:31:46 -0700
Message-ID: <49A99122.3000507@mlbassoc.com>
References: <20090227144004.GC17040@xi.wantstofly.org> <49A7FEE1.2020705@mlbassoc.com> <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk> <49A97669.80309@mlbassoc.com> <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705070200070601050302"
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <jdb@comx.dk>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:2994 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZB1TcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 14:32:07 -0500
In-Reply-To: <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010705070200070601050302
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Jesper Dangaard Brouer wrote:
> On Sat, 28 Feb 2009, Gary Thomas wrote:
> 
>> Jesper Dangaard Brouer wrote:
>>>
>>> On Fri, 27 Feb 2009, Lennert Buytenhek wrote:
>>>> On Fri, Feb 27, 2009 at 08:44:53AM -0700, Gary Thomas wrote:
>>>>
>>>> Perhaps we should take this off-list..
>>>
>>> I'm still interrested... please Cc. me at jdb@comx.dk.
>>
>> Hi Jesper,
>>
>> Lennert and I have been working on this and we have parts of
>> it working (PowerPC GIANFAR 1000Mb driver).  I can get the
>> basic switch recognized and packets go out, but nothing seems
>> to come back in.
> 
> Strange behavior...
> 
> If you will send me the current patches/code, then I'll use some time
> monday to look at the register settings to see if I can spot the
> problem, by corrolating with my device driver.
> 

I'm using the 6131 driver (which is mostly the same as the 6095).
There are no other changes other than to force the link on the
CPU port (10).  Actual changes attached.   Note: the HACK in
the 'get_ethtool_stats' is so I can peek at the CPU port info,
using one of the unused external ports.

> 
>> I'll continue to work on this and let you know of the progress.
>> Lennert is away for a few days, so the actual progress may be
>> a bit slow...
> 
> Thanks for keeping me in the loop :-)

Thanks for any ideas you might have.

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------

--------------010705070200070601050302
Content-Type: text/plain;
 name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diffs"

Index: net/dsa/mv88e6131.c
===================================================================
--- net/dsa/mv88e6131.c	(.../test1-2008-08-14-branch/tools/linuxppc-2.6/net/dsa)	(revision 4831)
+++ net/dsa/mv88e6131.c	(.../test2-2009-02-24-branch/tools/linuxppc-2.6/net/dsa)	(working copy)
@@ -19,8 +19,11 @@
 	int ret;
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+        printk("%s(%p, %d) = %d\n", __FUNCTION__, bus, sw_addr, ret);
 	if (ret >= 0) {
 		ret &= 0xfff0;
+		if (ret == 0x0950)
+			return "Marvell 88E6095/88E6095F";
 		if (ret == 0x1060)
 			return "Marvell 88E6131";
 	}
@@ -36,7 +39,7 @@
 	/*
 	 * Set all ports to the disabled state.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -91,7 +94,7 @@
 	 * Configure the priority mapping registers.
 	 */
 	ret = mv88e6xxx_config_prio(ds);
-	if (ret < 0)
+        if (ret < 0)
 		return ret;
 
 	/*
@@ -161,8 +164,11 @@
 	 * MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values.
 	 */
-	REG_WRITE(addr, 0x01, 0x0003);
-
+//	REG_WRITE(addr, 0x01, 0x0003);
+	if (p == ds->cpu_port)
+		REG_WRITE(addr, 0x01, 0x003E);
+	else
+		REG_WRITE(addr, 0x01, 0x0003);
 	/*
 	 * Port Control: disable Core Tag, disable Drop-on-Lock,
 	 * transmit frames unmodified, disable Header mode,
@@ -268,7 +274,7 @@
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = mv88e6131_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -279,7 +285,7 @@
 
 static int mv88e6131_port_to_phy_addr(int port)
 {
-	if (port >= 0 && port != 3 && port <= 7)
+	if (port >= 0 && port <= 11)
 		return port;
 	return -1;
 }
@@ -343,6 +349,12 @@
 mv88e6131_get_ethtool_stats(struct dsa_switch *ds,
 				  int port, uint64_t *data)
 {
+    // HACK
+    if (port == 7) {
+        printk("%s(%d) => CPU\n", __FUNCTION__, port);
+        port = 10;        
+    }
+    // HACK
 	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6131_hw_stats),
 				    mv88e6131_hw_stats, port, data);
 }

--------------010705070200070601050302--
