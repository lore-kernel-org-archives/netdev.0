From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, tests: fix endianness selection
Date: Thu, 08 Jun 2017 16:18:17 -0400 (EDT)
Message-ID: <20170608.161817.761227155789293644.davem@davemloft.net>
References: <086cffcb4e5cf48bc21be6961c16df53db9155cb.1496941264.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdFHUST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:18:19 -0400
In-Reply-To: <086cffcb4e5cf48bc21be6961c16df53db9155cb.1496941264.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  8 Jun 2017 19:06:25 +0200

> I noticed that test_l4lb was failing in selftests:
 ...
> Tracking down the issue actually revealed that endianness selection
> in bpf_endian.h is broken when compiled with clang with bpf target.
> test_pkt_access.c, test_l4lb.c is compiled with __BYTE_ORDER as
> __BIG_ENDIAN, test_xdp.c as __LITTLE_ENDIAN! test_l4lb noticeably
> fails, because the test accounts bytes via bpf_ntohs(ip6h->payload_len)
> and bpf_ntohs(iph->tot_len), and compares them against a defined
> value and given a wrong endianness, the test outcome is different,
> of course.
> 
> Turns out that there are actually two bugs: i) when we do __BYTE_ORDER
> comparison with __LITTLE_ENDIAN/__BIG_ENDIAN, then depending on the
> include order we see different outcomes. Reason is that __BYTE_ORDER
> is undefined due to missing endian.h include. Before we include the
> asm/byteorder.h (e.g. through linux/in.h), then __BYTE_ORDER equals
> __LITTLE_ENDIAN since both are undefined, after the include which
> correctly pulls in linux/byteorder/little_endian.h, __LITTLE_ENDIAN
> is defined, but given __BYTE_ORDER is still undefined, we match on
> __BYTE_ORDER equals to __BIG_ENDIAN since __BIG_ENDIAN is also
> undefined at that point, sigh. ii) But even that would be wrong,
> since when compiling the test cases with clang, one can select between
> bpfeb and bpfel targets for cross compilation. Hence, we can also not
> rely on what the system's endian.h provides, but we need to look at
> the compiler's defined endianness. The compiler defines __BYTE_ORDER__,
> and we can match __ORDER_LITTLE_ENDIAN__ and __ORDER_BIG_ENDIAN__,
> which also reflects targets bpf (native), bpfel, bpfeb correctly,
> thus really only rely on that. After patch:
> 
>   # ./test_progs
>   test_pkt_access:PASS:ipv4 74 nsec
>   test_pkt_access:PASS:ipv6 42 nsec
>   test_xdp:PASS:ipv4 2340 nsec
>   test_xdp:PASS:ipv6 1461 nsec
>   test_l4lb:PASS:ipv4 400 nsec
>   test_l4lb:PASS:ipv6 530 nsec
>   test_tcp_estats:PASS: 0 nsec
>   Summary: 7 PASSED, 0 FAILED
> 
> Fixes: 43bcf707ccdc ("bpf: fix _htons occurences in test_progs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
