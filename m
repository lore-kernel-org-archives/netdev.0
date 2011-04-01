From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 2/2] sctp: malloc enough room for asconf-ack chunk
Date: Fri, 01 Apr 2011 17:42:55 +0800
Message-ID: <4D959E1F.80504@cn.fujitsu.com>
References: <4D959D2E.40605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: lksctp <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59497 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab1DAJmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 05:42:38 -0400
In-Reply-To: <4D959D2E.40605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometime the ASCONF_ACK parameters can equal to the fourfold of
ASCONF parameters, this only happend in some special case:

  ASCONF parameter is :
    Unrecognized Parameter (4 bytes)
  ASCONF_ACK parameter should be:
    Error Cause Indication parameter (8 bytes header)
     + Error Cause (4 bytes header)
       + Unrecognized Parameter (4bytes)

Four 4bytes Unrecognized Parameters in ASCONF chunk will cause panic.

Pid: 0, comm: swapper Not tainted 2.6.38-next+ #22 Bochs Bochs
EIP: 0060:[<c0717eae>] EFLAGS: 00010246 CPU: 0
EIP is at skb_put+0x60/0x70
EAX: 00000077 EBX: c09060e2 ECX: dec1dc30 EDX: c09469c0
ESI: 00000000 EDI: de3c8d40 EBP: dec1dc58 ESP: dec1dc2c
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process swapper (pid: 0, ti=dec1c000 task=c09aef20 task.ti=c0980000)
Stack:
 c09469c0 e1894fa4 00000044 00000004 de3c8d00 de3c8d00 de3c8d44 de3c8d40
 c09060e2 de25dd80 de3c8d40 dec1dc7c e1894fa4 dec1dcb0 00000040 00000004
 00000000 00000800 00000004 00000004 dec1dce0 e1895a2b dec1dcb4 de25d960
Call Trace:
 [<e1894fa4>] ? sctp_addto_chunk+0x4e/0x89 [sctp]
 [<e1894fa4>] sctp_addto_chunk+0x4e/0x89 [sctp]
 [<e1895a2b>] sctp_process_asconf+0x32f/0x3d1 [sctp]
 [<e188d554>] sctp_sf_do_asconf+0xf8/0x173 [sctp]
 [<e1890b02>] sctp_do_sm+0xb8/0x159 [sctp]
 [<e18a2248>] ? sctp_cname+0x0/0x52 [sctp]
 [<e189392d>] sctp_assoc_bh_rcv+0xac/0xe3 [sctp]
 [<e1897d76>] sctp_inq_push+0x2d/0x30 [sctp]
 [<e18a21b2>] sctp_rcv+0x7a7/0x83d [sctp]
 [<c077a95c>] ? ipv4_confirm+0x118/0x125
 [<c073a970>] ? nf_iterate+0x34/0x62
 [<c074789d>] ? ip_local_deliver_finish+0x0/0x194
 [<c074789d>] ? ip_local_deliver_finish+0x0/0x194
 [<c0747992>] ip_local_deliver_finish+0xf5/0x194
 [<c074789d>] ? ip_local_deliver_finish+0x0/0x194
 [<c0747a6e>] NF_HOOK.clone.1+0x3d/0x44
 [<c0747ab3>] ip_local_deliver+0x3e/0x44
 [<c074789d>] ? ip_local_deliver_finish+0x0/0x194
 [<c074775c>] ip_rcv_finish+0x29f/0x2c7
 [<c07474bd>] ? ip_rcv_finish+0x0/0x2c7
 [<c0747a6e>] NF_HOOK.clone.1+0x3d/0x44
 [<c0747cae>] ip_rcv+0x1f5/0x233
 [<c07474bd>] ? ip_rcv_finish+0x0/0x2c7
 [<c071dce3>] __netif_receive_skb+0x310/0x336
 [<c07221f3>] netif_receive_skb+0x4b/0x51
 [<e0a4ed3d>] cp_rx_poll+0x1e7/0x29c [8139cp]
 [<c072275e>] net_rx_action+0x65/0x13a
 [<c0445a54>] __do_softirq+0xa1/0x149
 [<c04459b3>] ? __do_softirq+0x0/0x149
 <IRQ>
 [<c0445891>] ? irq_exit+0x37/0x72
 [<c040a7e9>] ? do_IRQ+0x81/0x95
 [<c07b3670>] ? common_interrupt+0x30/0x38
 [<c0428058>] ? native_safe_halt+0xa/0xc
 [<c040f5d7>] ? default_idle+0x58/0x92
 [<c0408fb0>] ? cpu_idle+0x96/0xb2
 [<c0797989>] ? rest_init+0x5d/0x5f
 [<c09fd90c>] ? start_kernel+0x34b/0x350
 [<c09fd0cb>] ? i386_start_kernel+0xba/0xc1

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/sm_make_chunk.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..b3434cc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3106,10 +3106,10 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 	/* create an ASCONF_ACK chunk.
 	 * Based on the definitions of parameters, we know that the size of
-	 * ASCONF_ACK parameters are less than or equal to the twice of ASCONF
+	 * ASCONF_ACK parameters are less than or equal to the fourfold of ASCONF
 	 * parameters.
 	 */
-	asconf_ack = sctp_make_asconf_ack(asoc, serial, chunk_len * 2);
+	asconf_ack = sctp_make_asconf_ack(asoc, serial, chunk_len * 4);
 	if (!asconf_ack)
 		goto done;
 
-- 
1.6.5.2


