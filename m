From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Mon, 10 Dec 2012 16:11:34 -0800 (PST)
Message-ID: <alpine.OSX.2.00.1212101608510.71685@animac.local>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
 <87obivu7n7.fsf@xmission.com> <CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com> <87sj7iesdl.fsf@xmission.com> <CAOxq_8NbmOtvyH6Q=AVeOUAj7DoFO8cnVUQA5sgyEG7jEJXpHA@mail.gmail.com> <87hanyekr3.fsf@xmission.com> <alpine.OSX.2.00.1212061730200.58531@animac.local>
  <87y5had4gi.fsf@xmission.com> <8795.1354845553@obiwan.sandelman.ca>
Reply-To: ani@aristanetworks.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Michael Richardson <mcr@sandelman.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:60401 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab2LKALi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 19:11:38 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1442268dak.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 16:11:37 -0800 (PST)
In-Reply-To: <8795.1354845553@obiwan.sandelman.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 6 Dec 2012, Michael Richardson wrote:

> Date: Thu, 6 Dec 2012 17:59:13
> From: Michael Richardson <mcr@sandelman.ca>
> To: Eric W. Biederman <ebiederm@xmission.com>
> Cc: ani@aristanetworks.com, tcpdump-workers@lists.tcpdump.org,
>     netdev@vger.kernel.org, Francesco Ruggeri <fruggeri@aristanetworks.com>
> Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
>
>
> >>>>> "Eric" == Eric W Biederman <ebiederm@xmission.com> writes:
>     Eric> It is a bit odd that you are indenting with spaces instead of tabs
>     Eric> in a file that is indented with tab.  Again libpcap isn't my code so I
>     Eric> don't care but someone else might.

Here's an updated patch. I have converted spaces to tabs consistent with
rest of the file. I have also set up github and sent a pull request

 :

commit b977ebd9d9608bb8a8e4927e7a6286bdfd6b94a8
Author: Ani Sinha <ani@aristanetworks.com>
Date:   Mon Dec 10 14:58:15 2012 -0800

    Linux kernel 3.0 uses TP_STATUS_VLAN_VALID flag in packet
    auxilliary data aux->tp_status to indicate a packet tagged
    with a valid vlan ID 0 with another packet that is not
    vlan tagged. Use this flag to check for the presence of
    a vlan tagged packet. Also be careful not to cause any
    breakage when libpcap is compiled against a newer kernel
    (>=3.0) and used on top of an older kernel that does not
    use this flag.

    Signed-off-by: Ani Sinha <ani@aristanetworks.com>

diff --git a/pcap-linux.c b/pcap-linux.c
index a42c3ac..ffcabdf 100644
--- a/pcap-linux.c
+++ b/pcap-linux.c
@@ -133,6 +133,7 @@ static const char rcsid[] _U_ =
 #include <sys/utsname.h>
 #include <sys/mman.h>
 #include <linux/if.h>
+#include <linux/if_packet.h>
 #include <netinet/in.h>
 #include <linux/if_ether.h>
 #include <net/if_arp.h>
@@ -1543,7 +1544,13 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
 				continue;

 			aux = (struct tpacket_auxdata *)CMSG_DATA(cmsg);
-			if (aux->tp_vlan_tci == 0)
+#if defined(TP_STATUS_VLAN_VALID)
+			if ((aux->tp_vlan_tci == 0) && !(aux->tp_status & TP_STATUS_VLAN_VALID))
+#else
+			if (aux->tp_vlan_tci == 0) /* this is ambigious but without the
+						TP_STATUS_VLAN_VALID flag, there is
+						nothing that we can do */
+#endif
 				continue;

 			len = packet_len > iov.iov_len ? iov.iov_len : packet_len;
@@ -3936,7 +3943,12 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
 		}

 #ifdef HAVE_TPACKET2
-		if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
+		if ((handle->md.tp_version == TPACKET_V2) &&
+#if defined(TP_STATUS_VLAN_VALID)
+		(h.h2->tp_vlan_tci || (h.h2->tp_status & TP_STATUS_VLAN_VALID)) &&
+#else
+		h.h2->tp_vlan_tci &&
+#endif
 		    handle->md.vlan_offset != -1 &&
 		    tp_snaplen >= (unsigned int) handle->md.vlan_offset) {
 			struct vlan_tag *tag;
