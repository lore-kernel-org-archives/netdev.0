From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 7 Apr 2015 17:11:48 +1000
Message-ID: <20150407171148.7a41ee90@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/bN.hAlF2cMlclQxIpWqnCrL"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/bN.hAlF2cMlclQxIpWqnCrL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
include/uapi/linux/bpf.h between commit 96be4325f443 ("ebpf: add
sched_cls_type and map it to sk_filter's verifier ops"), 03e69b508b6f
("ebpf: add prandom helper for packet sampling"), c04167ce2ca0 ("ebpf:
add helper for obtaining current processor id"), 94caee8c312d ("ebpf:
add sched_act_type and map it to sk_filter's verifier ops"),
608cd71a9c7c ("tc: bpf: generalize pedit action") and 91bc4822c3d6
("tc: bpf: add checksum helpers") from the net-next tree and commit
2541517c32be ("tracing, perf: Implement BPF programs attached to
kprobes"), d9847d310ab4 ("tracing: Allow BPF programs to call
bpf_ktime_get_ns()") and 9c959c863f82 ("tracing: Allow BPF programs to
call bpf_trace_printk()") from the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/uapi/linux/bpf.h
index 23df3e7f8e7d,cc47ef41076a..000000000000
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@@ -118,12 -118,9 +118,13 @@@ enum bpf_map_type=20
  enum bpf_prog_type {
  	BPF_PROG_TYPE_UNSPEC,
  	BPF_PROG_TYPE_SOCKET_FILTER,
 +	BPF_PROG_TYPE_SCHED_CLS,
 +	BPF_PROG_TYPE_SCHED_ACT,
+ 	BPF_PROG_TYPE_KPROBE,
  };
 =20
 +#define BPF_PSEUDO_MAP_FD	1
 +
  /* flags for BPF_MAP_UPDATE_ELEM command */
  #define BPF_ANY		0 /* create new element or update existing */
  #define BPF_NOEXIST	1 /* create new element if it didn't exist */
@@@ -166,45 -164,9 +168,48 @@@ enum bpf_func_id=20
  	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
  	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, fla=
gs) */
  	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 +	BPF_FUNC_get_prandom_u32, /* u32 prandom_u32(void) */
 +	BPF_FUNC_get_smp_processor_id, /* u32 raw_smp_processor_id(void) */
 +
 +	/**
 +	 * skb_store_bytes(skb, offset, from, len, flags) - store bytes into pac=
ket
 +	 * @skb: pointer to skb
 +	 * @offset: offset within packet from skb->data
 +	 * @from: pointer where to copy bytes from
 +	 * @len: number of bytes to store into packet
 +	 * @flags: bit 0 - if true, recompute skb->csum
 +	 *         other bits - reserved
 +	 * Return: 0 on success
 +	 */
 +	BPF_FUNC_skb_store_bytes,
 +
 +	/**
 +	 * l3_csum_replace(skb, offset, from, to, flags) - recompute IP checksum
 +	 * @skb: pointer to skb
 +	 * @offset: offset within packet where IP checksum is located
 +	 * @from: old value of header field
 +	 * @to: new value of header field
 +	 * @flags: bits 0-3 - size of header field
 +	 *         other bits - reserved
 +	 * Return: 0 on success
 +	 */
 +	BPF_FUNC_l3_csum_replace,
 +
 +	/**
 +	 * l4_csum_replace(skb, offset, from, to, flags) - recompute TCP/UDP che=
cksum
 +	 * @skb: pointer to skb
 +	 * @offset: offset within packet where TCP/UDP checksum is located
 +	 * @from: old value of header field
 +	 * @to: new value of header field
 +	 * @flags: bits 0-3 - size of header field
 +	 *         bit 4 - is pseudo header
 +	 *         other bits - reserved
 +	 * Return: 0 on success
 +	 */
 +	BPF_FUNC_l4_csum_replace,
+ 	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, voi=
d *src) */
+ 	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
+ 	BPF_FUNC_trace_printk,    /* int bpf_trace_printk(const char *fmt, int f=
mt_size, ...) */
  	__BPF_FUNC_MAX_ID,
  };
 =20

--Sig_/bN.hAlF2cMlclQxIpWqnCrL
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVI4M8AAoJEMDTa8Ir7ZwVMZ8P/RYjKSxEYLzaGEvmeV9XoQaF
6CHfSnLigCTnhiObh4XW0K3CT/meemcvG1iByriHvujAgwy627vtKUidAha/9oXT
8fGIOCKPPqimitdvPzCYajiTnSb1j75sTe9eS2GIcEnDDYkkZ34/RpWOel7bM/Hs
cd1LvYj3R6cgl5s8Ri1QPyoUQukTgVUMv69EjB3aVgZGkNt5UsFzcVxu0DWh33VQ
4+Bl2k14sbmURC41PaQA5WO6WfW8dbUETfRVyedKYx0+PnV1p3ZBUUjzbk8IjK5C
2vSOOHb5jVw+ZRD+3dQJnYVqsdjPma9WoHOUt1WXrv5HzMzYE54Xmvu79CdGyWhD
D0CGKPeefESy24XcfzMaG8Q7t+npMlZlDJBAHsCn02eUMYdPgDD5IOFbyZNyUZ3s
KcE6iIBA5tJJmMd4QXr1mjL+vfengEGOn+ZvnNgD9vUwHp6aZuAovJnquJBKHida
kbNgo3n1gEQLaWVV4Yj9rgaIZbFMqAcWun9TA5c7sTjK6SlbCu0sev2JudVUeYHi
2+Nc2b/kcREycDtQv3Dg0VjevQGBiYWNQoW8nKtkMX/bMhOU8YQJo9MANEUPlj2f
2whY1lBjZYcWtMlT0dphB0/WAn9VmIwHK258Ue/j6pSa7V7MOM3WjHCsqMDYUTWy
UYR4BRovea2CfWO6InpK
=EbFY
-----END PGP SIGNATURE-----

--Sig_/bN.hAlF2cMlclQxIpWqnCrL--
