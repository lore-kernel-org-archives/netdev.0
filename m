From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: PCI memory reservation failure - 2.4/2.6
Date: Sat, 15 May 2004 21:34:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A670D9.5010409@colorfullife.com>
References: <BDD74A21E0B47FEAC3AB8A10@[192.168.0.100]> <40A29211.2010707@colorfullife.com> <9C9F57570B19C8A682D96940@[192.168.0.100]>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090502040709030809050103"
Cc: linux-kernel@vger.kernel.org, Dominik Brodowski <linux@brodo.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Alec H. Peterson" <ahp@hilander.com>
In-Reply-To: <9C9F57570B19C8A682D96940@[192.168.0.100]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090502040709030809050103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Alec H. Peterson wrote:

>
> A module parameter sounds like a grand idea.  I'd be happy to take a 
> stab at it if others feel it is the way to go.

There are two possible approaches:
- just a module parameter. Probably something for 2.4.
- a combination of a dmi detection of buggy bios versions plus a pci 
quirk that resets start and end to 0.

Attached is the module parameter patch against 2.6. If it works I can 
write a backport to 2.4 and try to convince Marcelo to merge it.
Could you send me the output of dmidecode? I'll try to write the 
autodetection patch for 2.6.

--
    Manfred


--------------090502040709030809050103
Content-Type: text/plain;
 name="patch-yenta"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-yenta"

--- 2.6/drivers/pcmcia/yenta_socket.c	2004-05-15 11:21:38.000000000 +0200
+++ build-2.6/drivers/pcmcia/yenta_socket.c	2004-05-15 15:00:22.000000000 +0200
@@ -40,7 +40,7 @@
 #define to_ns(cycles)	((cycles)*120)
 
 static int yenta_probe_cb_irq(struct yenta_socket *socket);
-
+static int override_bios;
 
 /*
  * Generate easy-to-use ways of reading a cardbus sockets
@@ -548,7 +548,7 @@
 
 	start = config_readl(socket, offset) & mask;
 	end = config_readl(socket, offset+4) | ~mask;
-	if (start && end > start) {
+	if (start && end > start && !override_bios) {
 		res->start = start;
 		res->end = end;
 		if (request_resource(root, res) == 0)
@@ -1105,6 +1105,8 @@
 };
 MODULE_DEVICE_TABLE(pci, yenta_table);
 
+MODULE_PARM (override_bios, "i");
+MODULE_PARM_DESC (override_bios, "yenta ignore bios resource allocation");
 
 static struct pci_driver yenta_cardbus_driver = {
 	.name		= "yenta_cardbus",

--------------090502040709030809050103--
