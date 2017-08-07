From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv2] bpf: fix selftest/bpf/test_pkt_md_access on s390x
Date: Mon, 07 Aug 2017 11:39:00 +0200
Message-ID: <59883534.9080105@iogearbox.net>
References: <20170807081636.65099-1-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
        brueckner@linux.vnet.ibm.com, yhs@fb.com
To: Thomas Richter <tmricht@linux.vnet.ibm.com>, ast@kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39121 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752367AbdHGJjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 05:39:05 -0400
In-Reply-To: <20170807081636.65099-1-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:16 AM, Thomas Richter wrote:
> Commit 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")
> introduced new eBPF test cases. One of them (test_pkt_md_access.c)
> fails on s390x. The BPF verifier error message is:
>
> [root@s8360046 bpf]# ./test_progs
> test_pkt_access:PASS:ipv4 349 nsec
> test_pkt_access:PASS:ipv6 212 nsec
> [....]
> libbpf: load bpf program failed: Permission denied
> libbpf: -- BEGIN DUMP LOG ---
> libbpf:
> 0: (71) r2 = *(u8 *)(r1 +0)
> invalid bpf_context access off=0 size=1
>
> libbpf: -- END LOG --
> libbpf: failed to load program 'test1'
> libbpf: failed to load object './test_pkt_md_access.o'
> Summary: 29 PASSED, 1 FAILED
> [root@s8360046 bpf]#
>
> This is caused by a byte endianness issue. S390x is a big endian
> architecture.  Pointer access to the lowest byte or halfword of a
> four byte value need to add an offset.
> On little endian architectures this offset is not needed.
>
> Fix this and use the same approach as the originator used for other files
> (for example test_verifier.c) in his original commit.
>
> With this fix the test program test_progs succeeds on s390x:
> [root@s8360046 bpf]# ./test_progs
> test_pkt_access:PASS:ipv4 236 nsec
> test_pkt_access:PASS:ipv6 217 nsec
> test_xdp:PASS:ipv4 3624 nsec
> test_xdp:PASS:ipv6 1722 nsec
> test_l4lb:PASS:ipv4 926 nsec
> test_l4lb:PASS:ipv6 1322 nsec
> test_tcp_estats:PASS: 0 nsec
> test_bpf_obj_id:PASS:get-fd-by-notexist-prog-id 0 nsec
> test_bpf_obj_id:PASS:get-fd-by-notexist-map-id 0 nsec
> test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
> test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
> test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
> test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
> test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
> test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
> test_bpf_obj_id:PASS:check total prog id found by get_next_id 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
> test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
> test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
> test_bpf_obj_id:PASS:check total map id found by get_next_id 0 nsec
> test_pkt_md_access:PASS: 277 nsec
> Summary: 30 PASSED, 0 FAILED
> [root@s8360046 bpf]#

Fixes: 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")

> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

(Patch is for -net tree.)

Thanks Thomas!
