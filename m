From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [BUG] division by zero in tcpnv_acked()
Date: Mon, 30 Oct 2017 16:00:43 +0300
Message-ID: <09a41510-848d-8c2b-62b5-c3ca8a6103ab@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:43278 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751167AbdJ3NAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 09:00:47 -0400
Content-Language: ru-RU
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got this on two different machines:

[   24.405015] divide error: 0000 [#1] SMP
[   24.405403] Modules linked in: nf_log_ipv6 nf_log_common xt_LOG xt_u32 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip6table_nat 
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_filter ip6_tables xt_tcpudp ipt_REJECT nf_reject_ipv4 xt_multiport xt_mark xt_owner 
iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables 8021q garp mrp stp llc nfsd 
auth_rpcgss nfs_acl nfs lockd grace sunrpc fscache cls_u32 sch_fq sch_prio intel_rapl iosf_mbi sb_edac edac_core x86_pkg_temp_thermal 
intel_powerclamp ipmi_ssif coretemp ast kvm_intel ttm kvm drm_kms_helper drm fb_sys_fops syscopyarea sysfillrect sysimgblt irqbypass lpc_ich 
mei_me ipmi_msghandler mei ghash_clmulni_intel wmi joydev input_leds mac_hid shpchp acpi_pad tcp_nv xfs raid456 async_raid6_recov async_memcpy
[   24.409249]  async_pq async_xor async_tx xor raid10 raid6_pq igb libcrc32c i2c_algo_bit isci dca raid1 ptp libsas pps_core raid0 
scsi_transport_sas multipath fjes linear [last unloaded: ipmi_devintf]
[   24.410898] CPU: 0 PID: 2915 Comm: python2 Not tainted 4.9.59-14 #1
[   24.411766] Hardware name: AIC 1S-HV26-08/MB-DPSB04-06, BIOS IVYBV060 10/21/2015
[   24.412677] task: ffff881fca8e8000 task.stack: ffffc9001c748000
[   24.413615] RIP: 0010:tcpnv_acked (net/ipv4/tcp_nv.c:183) tcp_nv
[   24.414327] RSP: 0018:ffffc9001c74bb30 EFLAGS: 00010206
[   24.414351] RAX: 000000000f424000 RBX: ffff883fe76507c0 RCX: 0000000000000000
[   24.416399] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff883fe76507c0
[   24.417510] RBP: ffffc9001c74bb58 R08: 0000000000000001 R09: 0000000000000000
[   24.418640] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000fffef2aa
[   24.419787] R13: 00000000d7d9d925 R14: 00000000d7d9d905 R15: 0000000000000000
[   24.420653] FS:  00007f148f406700(0000) GS:ffff881fffa00000(0000) knlGS:0000000000000000
[   24.421855] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   24.423074] CR2: 00007f148f4de000 CR3: 0000001fe60f8000 CR4: 00000000001406f0
[   24.424332] Call Trace:
[ 24.425593] Code: 48 63 c9 48 0f af c1 49 8d 0c 00 44 8b 87 d8 04 00 00 48 c1 e9 08 89 8f d4 04 00 00 8b 46 08 48 69 c0 00 12 7a 00 31 d2 
6b f1 64 <48> f7 f6 3b 87 e0 04 00 00 76 06 89 87 e0 04 00 00 0f b6 87 d1
All code
========
    0:	48 63 c9             	movslq %ecx,%rcx
    3:	48 0f af c1          	imul   %rcx,%rax
    7:	49 8d 0c 00          	lea    (%r8,%rax,1),%rcx
    b:	44 8b 87 d8 04 00 00 	mov    0x4d8(%rdi),%r8d
   12:	48 c1 e9 08          	shr    $0x8,%rcx
   16:	89 8f d4 04 00 00    	mov    %ecx,0x4d4(%rdi)
   1c:	8b 46 08             	mov    0x8(%rsi),%eax
   1f:	48 69 c0 00 12 7a 00 	imul   $0x7a1200,%rax,%rax
   26:	31 d2                	xor    %edx,%edx
   28:	6b f1 64             	imul   $0x64,%ecx,%esi
   2b:*	48 f7 f6             	div    %rsi		<-- trapping instruction
   2e:	3b 87 e0 04 00 00    	cmp    0x4e0(%rdi),%eax
   34:	76 06                	jbe    0x3c
   36:	89 87 e0 04 00 00    	mov    %eax,0x4e0(%rdi)
   3c:	0f                   	.byte 0xf
   3d:	b6 87                	mov    $0x87,%dh
   3f:	d1                   	.byte 0xd1


// At entry tcpnv_acked() checks only for negative rtt_us
// Probably it's ok to check here <= 0 ?

	/* Some calls are for duplicates without timetamps */
	if (sample->rtt_us < 0)
		return;

// <cut>

	/* Calculate moving average of RTT */
	if (nv_rtt_factor > 0) {
		if (ca->nv_last_rtt > 0) {
			avg_rtt = (((u64)sample->rtt_us) * nv_rtt_factor +
				   ((u64)ca->nv_last_rtt)
				   * (256 - nv_rtt_factor)) >> 8;

// This should be positive

		} else {
			avg_rtt = sample->rtt_us;

// Here coule be zero

			ca->nv_min_rtt = avg_rtt << 1;
		}
		ca->nv_last_rtt = avg_rtt;
	} else {
		avg_rtt = sample->rtt_us;
	}

	/* rate in 100's bits per second */
	rate64 = ((u64)sample->in_flight) * 8000000;
	rate = (u32)div64_u64(rate64, (u64)(avg_rtt * 100));

// Also cast to u64 should be done before multipying by 100: (u64)(0x80000000 * 100) == 0
