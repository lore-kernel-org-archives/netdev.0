From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH]: sctp: Fix skb_over_panic resulting from multiple invalid
 parameter errors (CVE-2010-1173)
Date: Wed, 28 Apr 2010 09:47:48 -0400
Message-ID: <20100428134748.GA4818@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eteo@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	security@kernel.org, nhorman@tuxdriver.com
To: vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35364 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198Ab0D1NsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 09:48:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Recently, it was reported to me that the kernel could oops in the
following way:

<5> kernel BUG at net/core/skbuff.c:91!
<5> invalid operand: 0000 [#1]
<5> Modules linked in: sctp netconsole nls_utf8 autofs4 sunrpc iptable_filter
ip_tables cpufreq_powersave parport_pc lp parport vmblock(U) vsock(U) vmci(U)
vmxnet(U) vmmemctl(U) vmhgfs(U) acpiphp dm_mirror dm_mod button battery ac md5
ipv6 uhci_hcd ehci_hcd snd_ens1371 snd_rawmidi snd_seq_device snd_pcm_oss
snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_ac97_codec snd soundcore
pcnet32 mii floppy ext3 jbd ata_piix libata mptscsih mptsas mptspi mptscsi
mptbase sd_mod scsi_mod
<5> CPU:    0
<5> EIP:    0060:[<c02bff27>]    Not tainted VLI
<5> EFLAGS: 00010216   (2.6.9-89.0.25.EL) 
<5> EIP is at skb_over_panic+0x1f/0x2d
<5> eax: 0000002c   ebx: c033f461   ecx: c0357d96   edx: c040fd44
<5> esi: c033f461   edi: df653280   ebp: 00000000   esp: c040fd40
<5> ds: 007b   es: 007b   ss: 0068
<5> Process swapper (pid: 0, threadinfo=c040f000 task=c0370be0)
<5> Stack: c0357d96 e0c29478 00000084 00000004 c033f461 df653280 d7883180
e0c2947d 
<5>        00000000 00000080 df653490 00000004 de4f1ac0 de4f1ac0 00000004
df653490 
<5>        00000001 e0c2877a 08000800 de4f1ac0 df653490 00000000 e0c29d2e
00000004 
<5> Call Trace:
<5>  [<e0c29478>] sctp_addto_chunk+0xb0/0x128 [sctp]
<5>  [<e0c2947d>] sctp_addto_chunk+0xb5/0x128 [sctp]
<5>  [<e0c2877a>] sctp_init_cause+0x3f/0x47 [sctp]
<5>  [<e0c29d2e>] sctp_process_unk_param+0xac/0xb8 [sctp]
<5>  [<e0c29e90>] sctp_verify_init+0xcc/0x134 [sctp]
<5>  [<e0c20322>] sctp_sf_do_5_1B_init+0x83/0x28e [sctp]
<5>  [<e0c25333>] sctp_do_sm+0x41/0x77 [sctp]
<5>  [<c01555a4>] cache_grow+0x140/0x233
<5>  [<e0c26ba1>] sctp_endpoint_bh_rcv+0xc5/0x108 [sctp]
<5>  [<e0c2b863>] sctp_inq_push+0xe/0x10 [sctp]
<5>  [<e0c34600>] sctp_rcv+0x454/0x509 [sctp]
<5>  [<e084e017>] ipt_hook+0x17/0x1c [iptable_filter]
<5>  [<c02d005e>] nf_iterate+0x40/0x81
<5>  [<c02e0bb9>] ip_local_deliver_finish+0x0/0x151
<5>  [<c02e0c7f>] ip_local_deliver_finish+0xc6/0x151
<5>  [<c02d0362>] nf_hook_slow+0x83/0xb5
<5>  [<c02e0bb2>] ip_local_deliver+0x1a2/0x1a9
<5>  [<c02e0bb9>] ip_local_deliver_finish+0x0/0x151
<5>  [<c02e103e>] ip_rcv+0x334/0x3b4
<5>  [<c02c66fd>] netif_receive_skb+0x320/0x35b
<5>  [<e0a0928b>] init_stall_timer+0x67/0x6a [uhci_hcd]
<5>  [<c02c67a4>] process_backlog+0x6c/0xd9
<5>  [<c02c690f>] net_rx_action+0xfe/0x1f8
<5>  [<c012a7b1>] __do_softirq+0x35/0x79
<5>  [<c0107efb>] handle_IRQ_event+0x0/0x4f
<5>  [<c01094de>] do_softirq+0x46/0x4d

Its an skb_over_panic BUG halt that results from processing an init chunk in
which too many of its variable length parameters are in some way malformed.

The problem is in sctp_process_unk_param:
if (NULL == *errp)
	*errp = sctp_make_op_error_space(asoc, chunk,
					 ntohs(chunk->chunk_hdr->length));

	if (*errp) {
		sctp_init_cause(*errp, SCTP_ERROR_UNKNOWN_PARAM,
				 WORD_ROUND(ntohs(param.p->length)));
		sctp_addto_chunk(*errp,
			WORD_ROUND(ntohs(param.p->length)),
				  param.v);

When we allocate an error chunk, we assume that the worst case scenario requires
that we have chunk_hdr->length data allocated, which would be correct nominally,
given that we call sctp_addto_chunk for the violating parameter.  Unfortunately,
we also, in sctp_init_cause insert a sctp_errhdr_t structure into the error
chunk, so the worst case situation in which all parameters are in violation
requires chunk_hdr->length+(sizeof(sctp_errhdr_t)*param_count) bytes of data.

The result of this error is that a deliberately malformed packet sent to a
listening host can cause a remote DOS, described in CVE-2010-1173:
http://cve.mitre.org/cgi-bin/cvename.cgi?name=2010-1173

I've tested the below fix and confirmed that it fixes the issue.  It
pre-allocates the error chunk in sctp_verify_init, where we are able to count
the total number of variable length parameters, so we know how many error
headers we might need.  Then we simply use that chunk, if we find an error, or
discard/free it if all the parameters are valid.  Applies on top of the
lksctp-dev tree

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 sm_make_chunk.c |   24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)


diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f592163..990457b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2134,6 +2134,8 @@ int sctp_verify_init(const struct sctp_association *asoc,
 	union sctp_params param;
 	int has_cookie = 0;
 	int result;
+	unsigned int param_cnt;
+	unsigned int len;
 
 	/* Verify stream values are non-zero. */
 	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
@@ -2149,6 +2151,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 
 		if (SCTP_PARAM_STATE_COOKIE == param.p->type)
 			has_cookie = 1;
+		param_cnt++;
 
 	} /* for (loop through all parameters) */
 
@@ -2169,6 +2172,20 @@ int sctp_verify_init(const struct sctp_association *asoc,
 		return sctp_process_missing_param(asoc, SCTP_PARAM_STATE_COOKIE,
 						  chunk, errp);
 
+	if (!*errp) {
+		/*
+		 * Pre-allocate the error packet here
+		 * we do this as we need to reserve space
+		 * for the worst case scenario in which 
+		 * every parameter is in error and needs 
+		 * an errhdr attached to it
+		 */
+		len = ntohs(chunk->chunk_hdr->length);
+		len += sizeof(sctp_errhdr_t)*param_cnt;
+
+		*errp = sctp_make_op_error_space(asoc, chunk, len);
+	}
+
 	/* Verify all the variable length parameters */
 	sctp_walk_params(param, peer_init, init_hdr.params) {
 
@@ -2176,9 +2193,11 @@ int sctp_verify_init(const struct sctp_association *asoc,
 		switch (result) {
 		    case SCTP_IERROR_ABORT:
 		    case SCTP_IERROR_NOMEM:
-				return 0;
 		    case SCTP_IERROR_ERROR:
-				return 1;
+				len = ntohs((*errp)->chunk_hdr->length);
+				if ((*errp) && (len == sizeof(sctp_chunkhdr_t)))
+					sctp_chunk_free(*errp);
+				return (result == SCTP_IERROR_ERROR) ? 1 : 0;
 		    case SCTP_IERROR_NO_ERROR:
 		    default:
 				break;
@@ -2186,6 +2205,7 @@ int sctp_verify_init(const struct sctp_association *asoc,
 
 	} /* for (loop through all parameters) */
 
+	sctp_chunk_free(*errp);
 	return 1;
 }
 
