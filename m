From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: RE: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Fri, 14 Oct 2016 08:58:22 +0000
Message-ID: <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
References: <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_f395ea6cd1274fac83d2744121da7441FEMBX1012deboschcom_"
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: Julia Cartwright <julia@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-v.fe.bosch.de ([139.15.237.11]:15795 "EHLO
        smtp6-v.fe.bosch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbcJNI60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 04:58:26 -0400
In-Reply-To: <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_f395ea6cd1274fac83d2744121da7441FEMBX1012deboschcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Julia,
> Have you tested on a vanilla (non-RT) kernel?  I doubt there is anything =
RT specific
> about what you are seeing, but it might be nice to get confirmation.  Als=
o, bisection
> would probably be easier if you confirm on a vanilla kernel.
>=20
> I find it unlikely that it's a kernel config option that changed which re=
gressed you, but
> instead was a code change to a driver.  Which driver is now the question,=
 and the
> surface area is still big (processor mapping attributes for this region, =
PCI root
> complex configuration, PCI brige configuration, igb driver itself, etc.).
>=20
> Big enough that I'd recommend a bisection.  It looks like a bisection bet=
ween 3.18
> and 4.8 would take you about 18 tries to narrow down, assuming all goes w=
ell.
>=20

I have now repeated my tests using the vanilla kernel.
There I got the very same issue.
Using kernel 4.0 is fine, however starting with kernel 4.1, the issue appea=
rs.


Here is my exact (reproducible) test description:
I applied the following patch to the kernel to get the igb trace.
This patch instruments the igb_rd32() function to measure the call
to readl() which is used to access registers of the igb NIC.


++++++++++++++++++ BEGIN PATCH ++++++++++++++++++++++++++++++++++++

Index: linux-4.8/drivers/net/ethernet/intel/igb/trace.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux-4.8/drivers/net/ethernet/intel/igb/trace.h
@@ -0,0 +1,34 @@
+
+#if !defined(_TRACE_IGB_H_) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_IGB_H_=20
+
+#include <linux/tracepoint.h>
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM igb
+
+
+#define _TRACE_H_
+
+
+TRACE_EVENT(igb,
+        TP_PROTO(u32 val),
+        TP_ARGS(val),
+        TP_STRUCT__entry(
+                __field(u32, val)
+        ),
+        TP_fast_assign(
+                __entry->val =3D val;
+        ),
+        TP_printk("val: %u",
+                   __entry->val)
+);
+
+
+#endif
+
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH drivers/net/ethernet/intel/igb=20
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_FILE trace
+
+#include <trace/define_trace.h>
Index: linux-4.8/drivers/net/ethernet/intel/igb/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-4.8.orig/drivers/net/ethernet/intel/igb/Makefile
+++ linux-4.8/drivers/net/ethernet/intel/igb/Makefile
@@ -28,6 +28,7 @@
 #
 # Makefile for the Intel(R) 82575 PCI-Express ethernet driver
 #
+ccflags-y +=3D -I.
=20
 obj-$(CONFIG_IGB) +=3D igb.o
=20
Index: linux-4.8/drivers/net/ethernet/intel/igb/igb_main.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-4.8.orig/drivers/net/ethernet/intel/igb/igb_main.c
+++ linux-4.8/drivers/net/ethernet/intel/igb/igb_main.c
@@ -57,6 +57,9 @@
 #include <linux/i2c.h>
 #include "igb.h"
=20
+#define CREATE_TRACE_POINTS
+#include "trace.h"
+
 #define MAJ 5
 #define MIN 3
 #define BUILD 0
@@ -753,7 +756,9 @@ u32 igb_rd32(struct e1000_hw *hw, u32 re
 	if (E1000_REMOVED(hw_addr))
 		return ~value;
=20
+        trace_igb(801);
 	value =3D readl(&hw_addr[reg]);
+        trace_igb(802);
=20
 	/* reads should not return all F's */
 	if (!(~value) && (!reg || !(~readl(hw_addr)))) {


++++++++++++++++++ END PATCH ++++++++++++++++++++++++++++++++++++


I build the kernel with this patch applied, rebooted the PC to run this ker=
nel and used the=20
following script for my test.

++++++++++++++++++ BEGIN SCRIPT  +++++++++++++++++++++++++++++++++
#!/bin/bash

for f in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor ; do
    if [ -w $f ]; then
        echo "performance" > $f
    fi
done

if true; then
    rmmod igb
    modprobe igb
    ethtool -L eth2 combined 1
    ifconfig eth2 up 192.168.100.111
fi

ifconfig

mount /sys/kernel/debug

( cd /sys/kernel/debug/tracing
  echo 0 > tracing_on
  echo 0 > events/enable
  echo 1 > events/igb/enable
  echo "print-parent" > trace_options
  echo "latency-format" > trace_options
  echo 1 > tracing_on

  sleep 4
  cat trace
)
++++++++++++++++++ END SCRIPT  +++++++++++++++++++++++++++++++++

The results of this for kernel 4.0:
[...]
kworker/-1239    3...1 49699046us : igb: val: 801
kworker/-1239    3...1 49699047us : igb: val: 802
kworker/-1239    3...1 49699047us : igb: val: 801
kworker/-1239    3...1 49699048us+: igb: val: 802
kworker/-1239    3...1 49699099us : igb: val: 801
kworker/-1239    3...1 49699100us : igb: val: 802
kworker/-1239    3...1 49699100us : igb: val: 801
kworker/-1239    3...1 49699102us : igb: val: 802
kworker/-1239    3...1 49699102us : igb: val: 801
kworker/-1239    3...1 49699103us : igb: val: 802
kworker/-1239    3...1 49699103us : igb: val: 801
kworker/-1239    3...1 49699104us : igb: val: 802
kworker/-1239    3...1 49699104us : igb: val: 801
kworker/-1239    3...1 49699105us : igb: val: 802
kworker/-1239    3...1 49699105us : igb: val: 801
kworker/-1239    3...1 49699107us : igb: val: 802
kworker/-1239    3...1 49699107us : igb: val: 801
kworker/-1239    3...1 49699108us : igb: val: 802
kworker/-1239    3...1 49699108us : igb: val: 801
kworker/-1239    3...1 49699109us : igb: val: 802
kworker/-1239    3...1 49699109us : igb: val: 801
kworker/-1239    3...1 49699110us : igb: val: 802
kworker/-1239    3...1 49699110us : igb: val: 801
kworker/-1239    3...1 49699111us : igb: val: 802
kworker/-1239    3...1 49699111us : igb: val: 801
kworker/-1239    3...1 49699113us+: igb: val: 802
kworker/-1239    3...1 49699163us : igb: val: 801
kworker/-1239    3...1 49699164us : igb: val: 802
kworker/-1239    3...1 49699164us : igb: val: 801
kworker/-1239    3...1 49699166us : igb: val: 802
kworker/-1239    3...1 49699166us : igb: val: 801
kworker/-1239    3...1 49699167us : igb: val: 802
kworker/-1239    3...1 49699167us : igb: val: 801
kworker/-1239    3...1 49699168us : igb: val: 802
kworker/-1239    3...1 49699168us : igb: val: 801
kworker/-1239    3...1 49699169us : igb: val: 802
kworker/-1239    3...1 49699169us : igb: val: 801
kworker/-1239    3...1 49699170us : igb: val: 802
kworker/-1239    3...1 49699171us : igb: val: 801
kworker/-1239    3...1 49699173us : igb: val: 802
kworker/-1239    3...1 49699173us : igb: val: 801
kworker/-1239    3...1 49699174us : igb: val: 802





The results of this for kernel 4.1:
[...]
kworker/-1333    2...1 75697302us+: igb: val: 801
kworker/-1333    2...1 75697323us+: igb: val: 802
kworker/-1333    2...1 75697373us+: igb: val: 801
kworker/-1333    2...1 75697395us : igb: val: 802
kworker/-1333    2...1 75697395us+: igb: val: 801
kworker/-1333    2...1 75697415us : igb: val: 802
kworker/-1333    2...1 75697416us+: igb: val: 801
kworker/-1333    2...1 75697436us : igb: val: 802
kworker/-1333    2...1 75697436us+: igb: val: 801
kworker/-1333    2...1 75697457us : igb: val: 802
kworker/-1333    2...1 75697457us+: igb: val: 801
kworker/-1333    2...1 75697478us : igb: val: 802
kworker/-1333    2...1 75697478us+: igb: val: 801
kworker/-1333    2...1 75697499us : igb: val: 802
kworker/-1333    2...1 75697499us+: igb: val: 801
kworker/-1333    2...1 75697520us : igb: val: 802
kworker/-1333    2...1 75697520us+: igb: val: 801
kworker/-1333    2...1 75697541us : igb: val: 802
kworker/-1333    2...1 75697541us+: igb: val: 801
kworker/-1333    2...1 75697562us : igb: val: 802
kworker/-1333    2...1 75697562us+: igb: val: 801
kworker/-1333    2...1 75697583us : igb: val: 802
kworker/-1333    2...1 75697583us+: igb: val: 801
kworker/-1333    2...1 75697604us+: igb: val: 802
kworker/-1333    2...1 75697654us+: igb: val: 801
kworker/-1333    2...1 75697675us : igb: val: 802
kworker/-1333    2...1 75697675us+: igb: val: 801
kworker/-1333    2...1 75697696us : igb: val: 802
kworker/-1333    2...1 75697696us+: igb: val: 801
kworker/-1333    2...1 75697717us : igb: val: 802
kworker/-1333    2...1 75697717us+: igb: val: 801
kworker/-1333    2...1 75697738us : igb: val: 802
kworker/-1333    2...1 75697738us+: igb: val: 801
kworker/-1333    2...1 75697759us : igb: val: 802
kworker/-1333    2...1 75697759us+: igb: val: 801
kworker/-1333    2...1 75697780us : igb: val: 802
kworker/-1333    2...1 75697781us+: igb: val: 801
kworker/-1333    2...1 75697801us : igb: val: 802
kworker/-1333    2...1 75697801us+: igb: val: 801
kworker/-1333    2...1 75697822us : igb: val: 802


It can be cleary seen that with the kernel 4.1 the time for the execution o=
f the "readl"
function is much slower! It tasks always about 21us!
In comparison to that the kernel 4.0 is fast. Here the time for "readl" is =
about
1-2 us.
All measurements have been done on the very same PC.
The PC is an HP EliteDesk 800 G1,=20
a dual port Intel i350-T2 server adapter has been plugged in.
CPU: Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz
x86_64 bit mode.

Please find attached the kernel configuration for the 4.1 kernel.

I had a look at the generated .o file of igb_main.o.
However, in both cases - kernel 4.0 and kernel 4.1 - the code for the=20
igb_rd32 function looks the same.
Especially the call to the readl() function is the very same.

This means, that I think that some other stuff in kernel 4.1 has changed,
which has impact on the igb accesses.

Any idea what component could cause this kind of issue?

Thanks for any feedback!

Regards

Mathias


--_002_f395ea6cd1274fac83d2744121da7441FEMBX1012deboschcom_
Content-Type: application/x-gzip; name="config.gz"
Content-Description: config.gz
Content-Disposition: attachment; filename="config.gz"; size=23977;
	creation-date="Fri, 14 Oct 2016 08:36:40 GMT";
	modification-date="Fri, 14 Oct 2016 08:33:16 GMT"
Content-Transfer-Encoding: base64

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

--_002_f395ea6cd1274fac83d2744121da7441FEMBX1012deboschcom_--
