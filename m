From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bpf filter : support for vlan tag
Date: Tue, 16 Oct 2012 08:46:38 +0200
Message-ID: <1350369998.3954.563.camel@edumazet-glaptop>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42034 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab2JPGqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 02:46:54 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so3309823eek.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 23:46:52 -0700 (PDT)
In-Reply-To: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-15 at 19:10 -0700, Ani Sinha wrote:
> Hi :
> 
> I was looking at the kernel side implementation of the BPF filter. I
> do not see any code that supports filtering of packets based on
> provided vlan tag information from the skbuff. This will make it
> impossible to provide any filter to tcpdump that will filter packets
> based on the tag information if libpcap uses the kernel filter.
> 
> Any help will be much appreciated.

Right, we need a basic support, using a new ancillary definition.

Is the following patch enough to address your need, or do you also need
access to vlan_tx_tag_present() ?

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 24d251f..0218e41 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -123,6 +123,7 @@ enum {
 	BPF_S_ANC_CPU,
 	BPF_S_ANC_ALU_XOR_X,
 	BPF_S_ANC_SECCOMP_LD_W,
+	BPF_S_ANC_VLAN_TAG,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 3d92ebb..de4a5dc 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -341,6 +341,9 @@ load_b:
 		case BPF_S_ANC_CPU:
 			A = raw_smp_processor_id();
 			continue;
+		case BPF_S_ANC_VLAN_TAG:
+			A = vlan_tx_tag_get(skb);
+			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
@@ -600,6 +603,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(RXHASH);
 			ANCILLARY(CPU);
 			ANCILLARY(ALU_XOR_X);
+			ANCILLARY(VLAN_TAG);
 			}
 		}
 		ftest->code = code;
