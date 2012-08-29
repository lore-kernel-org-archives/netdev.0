From: Chris Webb <chris@arachsys.com>
Subject: Re: Slow inbound traffic on macvtap interfaces
Date: Wed, 29 Aug 2012 18:52:56 +0100
Message-ID: <20120829175256.GC3529@arachsys.com>
References: <20120816092004.GA1894@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org, qemu-devel@nongnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.arachsys.com ([91.203.57.7]:44477 "EHLO
	alpha.arachsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab2H2Rw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 13:52:59 -0400
Content-Disposition: inline
In-Reply-To: <20120816092004.GA1894@arachsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Webb <chris@arachsys.com> writes:

> I'm experiencing a problem with qemu + macvtap which I can reproduce on a
> variety of hardware, with kernels varying from 3.0.4 (the oldest I tried) to
> 3.5.1 and with qemu[-kvm] versions 0.14.1, 1.0, and 1.1.
> 
> Large data transfers over TCP into a guest from another machine on the
> network are very slow (often less than 100kB/s) whereas transfers outbound
> from the guest, between two guests on the same host, or between the guest
> and its host run at normal speeds (>= 50MB/s).
> 
> The slow inbound data transfer speeds up substantially when a ping flood is
> aimed either at the host or the guest, or when the qemu process is straced.
> Presumably both of these are ways to wake up something that is otherwise
> sleeping too long?

I thought I'd try bisecting from when macvtap was introduced (2.6.34 where it
presumably worked fine), but in preparing to do that, I stumbled upon a way to
change the behaviour from slow to fast with different kernel .configs. Pinning
it down specifically, I found that on my laptop, the single change of host
kernel config

-CONFIG_INTEL_IDLE=y
+# CONFIG_INTEL_IDLE is not set

is sufficient to turn transfers into guests from slow to full wire speed.
The .configs of the 'slow' and 'fast' host kernels are respectively at

  http://cdw.me.uk/tmp/goingslow.config
  http://cdw.me.uk/tmp/goingfast.config

Our big servers that show the symptoms are Opteron 6128 boxes, and (perhaps
unsurprisingly) aren't affected by CONFIG_INTEL_IDLE. In fact, turning off the
whole of the CPU idle infrastructure as below didn't have any effect: transfers
into the guest remained slow.

@@ -441,10 +441,8 @@ CONFIG_ACPI=y
 # CONFIG_ACPI_BUTTON is not set
 CONFIG_ACPI_FAN=y
 CONFIG_ACPI_DOCK=y
-CONFIG_ACPI_PROCESSOR=y
+# CONFIG_ACPI_PROCESSOR is not set
 CONFIG_ACPI_IPMI=y
-CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
-CONFIG_ACPI_THERMAL=y
 CONFIG_ACPI_NUMA=y
 # CONFIG_ACPI_CUSTOM_DSDT is not set
 CONFIG_ACPI_BLACKLIST_YEAR=0
@@ -463,16 +461,12 @@ CONFIG_SFI=y
 # CPU Frequency scaling
 #
 # CONFIG_CPU_FREQ is not set
-CONFIG_CPU_IDLE=y
-CONFIG_CPU_IDLE_GOV_LADDER=y
-CONFIG_CPU_IDLE_GOV_MENU=y
-CONFIG_INTEL_IDLE=y
+# CONFIG_CPU_IDLE is not set
 
 #
 # Memory power savings
 #
-CONFIG_I7300_IDLE_IOAT_CHANNEL=y
-CONFIG_I7300_IDLE=y
+# CONFIG_I7300_IDLE is not set
 
 #
 # Bus options (PCI etc.)


(From earlier in the thread, the full unmodified kernel config for one of these
boxes is at

  http://cdw.me.uk/tmp/server-config.txt

and I've tested equivalent configs on kernels from 3.0.x to the head of
Linus' git tree.)

Is the CONFIG_INTEL_IDLE thing suggestive of what the problem might be at all?
Out of interest, what is the impact of disabling this on Intel machines?
Presumably in this case we rely on ACPI for processor idle?

Also, is there an equivalent for AMD machines which we could disable on our
large Opteron boxes, given that even getting rid of the whole CONFIG_CPU_IDLE
machinery didn't change anything as CONFIG_INTEL_IDLE did on the Intel box?

Best wishes,

Chris.
