From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Mon, 6 Dec 2004 16:12:35 -0700
Message-ID: <20041206231235.GA18097@mail.com>
References: <20041206024437.GB7891@mail.com> <1102304058.3343.217.camel@sfeldma-mobl.dsl-verizon.net> <20041206041002.GC7891@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041206041002.GC7891@mail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 09:10:03PM -0700, Ray Lehtiniemi wrote:
> 
> any idea why lspci -vv shows non-64bit, non-133 MHz?  (i am assuming
> that is what the minus sign means)
> 
>         Capabilities: [e4] PCI-X non-bridge device.
>                 Command: DPERE- ERO+ RBC=0 OST=0
>                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-

turns out this is a bug in pci-utils-2.1.11.  it was not correctly
fetching the config information from the card, and was displaying
zeroed data instead.  i've included a patch at the end of this email
and have also forwarded it to martin mares.



> > Can you put one on D and the other on another bus?
> 
> not sure... have to look at the chassis tomorrow morning. a co-worker
> actually built the box, i've not seen it in person yet.

nope, can't move things around. this is a NexGate NSA 2040G, and everything
is built into the motherboard.




> > What kind of numbers are you getting?

i'm seeing about 100Kpps, with all settings at their defaults on the 2.4.20
kernel.

basically, i have a couple of desktop PCs generating 480 streams
of UDP data at 50 packets per second.  Packet size on the wire, including
96 bits of IFG, is 128 bytes.  these packets are forwarded through a user
process on the NexGen box to an echoer process which is also running on the
traffic generator boxes. the echoer sends them back to the NexGen user process,
which forwards them back to the generator process.  timestamps are logged
for each packet at send, loop and recv points.

anything over 480 streams, and i start to get large latencies and packet drops,
as measured by the timestamps in the sender and echoer process.

does 100Kpps sound reasonable for an untweaked 2.4.20 kernel?


thanks





diff -ur pciutils-2.1.11/lspci.c pciutils-2.1.11-rayl/lspci.c
--- pciutils-2.1.11/lspci.c	2002-12-26 13:24:50.000000000 -0700
+++ pciutils-2.1.11-rayl/lspci.c	2004-12-06 15:54:33.573313973 -0700
@@ -476,16 +476,19 @@
 static void
 show_pcix_nobridge(struct device *d, int where)
 {
-  u16 command = get_conf_word(d, where + PCI_PCIX_COMMAND);
-  u32 status = get_conf_long(d, where + PCI_PCIX_STATUS);
+  u16 command;
+  u32 status;
   printf("PCI-X non-bridge device.\n");
   if (verbose < 2)
     return;
+  config_fetch(d, where, 8);
+  command = get_conf_word(d, where + PCI_PCIX_COMMAND);
   printf("\t\tCommand: DPERE%c ERO%c RBC=%d OST=%d\n",
 	 FLAG(command, PCI_PCIX_COMMAND_DPERE),
 	 FLAG(command, PCI_PCIX_COMMAND_ERO),
 	 ((command & PCI_PCIX_COMMAND_MAX_MEM_READ_BYTE_COUNT) >> 2U),
 	 ((command & PCI_PCIX_COMMAND_MAX_OUTSTANDING_SPLIT_TRANS) >> 4U));
+  status = get_conf_long(d, where + PCI_PCIX_STATUS);
   printf("\t\tStatus: Bus=%u Dev=%u Func=%u 64bit%c 133MHz%c SCD%c USC%c, DC=%s, DMMRBC=%u, DMOST=%u, DMCRS=%u, RSCEM%c",
 	 ((status >> 8) & 0xffU), // bus
 	 ((status >> 3) & 0x1fU), // dev
@@ -509,6 +512,7 @@
   printf("PCI-X bridge device.\n");
   if (verbose < 2)
     return;
+  config_fetch(d, where, 8);
   secstatus = get_conf_word(d, where + PCI_PCIX_BRIDGE_SEC_STATUS);
   printf("\t\tSecondary Status: 64bit%c, 133MHz%c, SCD%c, USC%c, SCO%c, SRD%c Freq=%d\n",
 	 FLAG(secstatus, PCI_PCIX_BRIDGE_SEC_STATUS_64BIT),



-- 
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
