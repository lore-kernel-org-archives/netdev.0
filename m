From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 6 Dec 2012 13:20:11 -0800
Message-ID: <CAOxq_8Ob_NFd=-6ZBxGhFVsbffSL3EpEeVoB6PihcN1hF-ewyQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
	<CAOxq_8O8Vkm5Napp_h6HVj6C=EH2gd_PQJJ1N5d_VQZrRZFYNQ@mail.gmail.com>
	<B23C28F0-4005-4970-984D-3BAD063EA513@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	tcpdump-workers@lists.tcpdump.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:43690 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422781Ab2LFVUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 16:20:12 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so6473265vcd.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 13:20:11 -0800 (PST)
In-Reply-To: <B23C28F0-4005-4970-984D-3BAD063EA513@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 5:50 PM, Guy Harris <guy@alum.mit.edu> wrote:
>
> On Oct 31, 2012, at 3:35 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>
>> yes but if the packet is passed to the filter within libpcap (when we
>> are not using the kernel filter) before the reinsertion,
>
> ...that would be a bug.
>
> Currently, that bug doesn't exist in the recvfrom() code path, but *does* appear to exist in the tpacket code path - and that code path also runs the filter before the SLL header is constructed.  That should be fixed.

Something like this?

Index: libpcap-1.1.1/pcap-linux.c
===================================================================
--- libpcap-1.1.1.orig/pcap-linux.c
+++ libpcap-1.1.1/pcap-linux.c
@@ -132,6 +132,7 @@ static const char rcsid[] _U_ =
 #include <sys/utsname.h>
 #include <sys/mman.h>
 #include <linux/if.h>
+#include <linux/if_packet.h>
 #include <netinet/in.h>
 #include <linux/if_ether.h>
 #include <net/if_arp.h>
@@ -3469,23 +3476,6 @@ pcap_read_linux_mmap(pcap_t *handle, int
  return -1;
  }

- /* run filter on received packet
- * If the kernel filtering is enabled we need to run the
- * filter until all the frames present into the ring
- * at filter creation time are processed.
- * In such case md.use_bpf is used as a counter for the
- * packet we need to filter.
- * Note: alternatively it could be possible to stop applying
- * the filter when the ring became empty, but it can possibly
- * happen a lot later... */
- bp = (unsigned char*)h.raw + tp_mac;
- run_bpf = (!handle->md.use_bpf) ||
- ((handle->md.use_bpf>1) && handle->md.use_bpf--);
- if (run_bpf && handle->fcode.bf_insns &&
- (bpf_filter(handle->fcode.bf_insns, bp,
- tp_len, tp_snaplen) == 0))
- goto skip;
-
  /*
  * Do checks based on packet direction.
  */
@@ -3582,6 +3576,23 @@ pcap_read_linux_mmap(pcap_t *handle, int
  }
 #endif

+ /* run filter on received packet
+ * If the kernel filtering is enabled we need to run the
+ * filter until all the frames present into the ring
+ * at filter creation time are processed.
+ * In such case md.use_bpf is used as a counter for the
+ * packet we need to filter.
+ * Note: alternatively it could be possible to stop applying
+ * the filter when the ring became empty, but it can possibly
+ * happen a lot later... */
+ bp = (unsigned char*)h.raw + tp_mac;
+ run_bpf = (!handle->md.use_bpf) ||
+ ((handle->md.use_bpf>1) && handle->md.use_bpf--);
+ if (run_bpf && handle->fcode.bf_insns &&
+ (bpf_filter(handle->fcode.bf_insns, bp,
+ tp_len, tp_snaplen) == 0))
+ goto skip;
+
  /*
  * The only way to tell the kernel to cut off the
  * packet at a snapshot length is with a filter program;
