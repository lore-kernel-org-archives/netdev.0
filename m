From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 6 Dec 2012 13:22:08 -0800
Message-ID: <CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<12918.1353190488@obiwan.sandelman.ca>
	<87obivu7n7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34762 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422673Ab2LFVWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 16:22:09 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so6475184vcd.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 13:22:08 -0800 (PST)
In-Reply-To: <87obivu7n7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 17, 2012 at 3:33 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> the vlan header in packets as we receive them.
>
> The code is correct except for the case of packets in vlan 0.  Currently
> the packet reconstruction is ambiguous.  The most recent kernels have
> a TP_STATUS_VLAN_VALID flag that can be checked to see if the packet was
> in vlan 0 or if there was no vlan at all.  libpcap probably should be
> taught how to handle TP_STATUS_VLAN_VALID so that it can get the vlan 0
> handling correct.
>

May be this?

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
@@ -1486,7 +1487,13 @@ pcap_read_packet(pcap_t *handle, pcap_ha
  continue;

  aux = (struct tpacket_auxdata *)CMSG_DATA(cmsg);
- if (aux->tp_vlan_tci == 0)
+#if defined(TP_STATUS_VLAN_VALID)
+                        if (!(aux->tp_vlan_tci & TP_STATUS_VLAN_VALID))
+#else
+ if (aux->tp_vlan_tci == 0) /* this is ambigious but without the
+
TP_STATUS_VLAN_VALID flag, there is
+                                                      nothing that we can do */
+#endif
  continue;

  len = packet_len > iov.iov_len ? iov.iov_len : packet_len;
@@ -3565,7 +3555,11 @@ pcap_read_linux_mmap(pcap_t *handle, int
  }

 #ifdef HAVE_TPACKET2
- if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
+#if defined(TP_STATUS_VLAN_VALID)
+                if (handle->md.tp_version == TPACKET_V2 &&
(h.h2->tp_vlan_tci & TP_STATUS_VLAN_VALID) &&
+#else
+                if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
+#endif
     handle->md.vlan_offset != -1 &&
     tp_snaplen >= (unsigned int) handle->md.vlan_offset) {
  struct vlan_tag *tag;
