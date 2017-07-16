From: David Ahern <dsahern@gmail.com>
Subject: BUG triggered in tcp_openreq_init_rwin most likely due to
 13d3b1ebe2876
Date: Sun, 16 Jul 2017 17:47:52 -0600
Message-ID: <5d6eb001-2f2b-d9d4-5c5e-a0b22cd53f65@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Lawrence Brakmo <brakmo@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33121 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdGPXsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 19:48:00 -0400
Received: by mail-pg0-f67.google.com with SMTP id z1so2261727pgs.0
        for <netdev@vger.kernel.org>; Sun, 16 Jul 2017 16:48:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

I am getting the following while testing IPv6 changes:

[ 3904.250981] TCP: request_sock_TCPv6: Possible SYN flooding on port
12345. Sending cookies.  Check SNMP counters.
[ 3904.252862]
==================================================================
[ 3904.254057] BUG: KASAN: null-ptr-deref in
tcp_openreq_init_rwin+0x1d5/0x2b4
[ 3904.255113] Read of size 1 at addr 0000000000000012 by task vrf-test/1166
[ 3904.256149]
[ 3904.256405] CPU: 0 PID: 1166 Comm: vrf-test Not tainted 4.12.0+ #307
[ 3904.257373] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[ 3904.258899] Call Trace:
[ 3904.259291]  <IRQ>
[ 3904.259629]  dump_stack+0x81/0xb6
[ 3904.260167]  kasan_report+0x234/0x269
[ 3904.260688]  __asan_load1+0x45/0x47
[ 3904.261176]  tcp_openreq_init_rwin+0x1d5/0x2b4
[ 3904.261811]  tcp_conn_request+0xb1e/0xe11
[ 3904.262448]  tcp_v6_conn_request+0x72/0x85
[ 3904.263010]  ? tcp_v6_conn_request+0x72/0x85
[ 3904.263605]  tcp_rcv_state_process+0xe6/0x1243
[ 3904.264236]  ? lock_release+0x27f/0x444
[ 3904.264793]  tcp_v6_do_rcv+0x321/0x559
[ 3904.265316]  ? tcp_v6_do_rcv+0x321/0x559
[ 3904.265858]  ? tcp_filter+0x82/0x95
[ 3904.266357]  tcp_v6_rcv+0x6c7/0xb33
[ 3904.266886]  ip6_input_finish+0x1de/0x5ca
[ 3904.267471]  ip6_input+0x66/0x6c


This is enough to prevent the problem the crash which suggest the recent
bpf sock_ops is the culprit:

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ff83c1637d8..88904882b4ad 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -364,7 +364,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
            (req->rsk_window_clamp > full_space || req->rsk_window_clamp
== 0))
                req->rsk_window_clamp = full_space;

-       rcv_wnd = tcp_rwnd_init_bpf((struct sock *)req);
+       rcv_wnd = 0; // tcp_rwnd_init_bpf((struct sock *)req);
        if (rcv_wnd == 0)
                rcv_wnd = dst_metric(dst, RTAX_INITRWND);
        else if (full_space < rcv_wnd * mss)


Note: I am *not* using any of the new sock_ops hooks; I simply have the
cgroup bpf hooks enabled and in use for VRF.

Reproduction includes creating a VRF and enabling cgroup code for it:
    ip li add red type vrf table 123
    ip li set red up
    ip addr add dev red 172.16.1.1/32
    ip vrf exec red ping -c1 172.16.1.1

By adding vrf bpf to a cgroup the cgroup_bpf_enabled is set causing the
rest of BPF_CGROUP_RUN_PROG_SOCK_OPS to be evaluated.

>From here, use your favorite test server and make SYN-ACKs get lost (not
sure that is required but is a reliable trigger for me). In my case I am
using my a simple networking test program:

ip6tables -A INPUT -p tcp --sport 12345 -j DROP
vrf-test -6 -s &
vrf-test -6 -r 2001:db8:1::1 &
vrf-test -6 -r 2001:db8:1::1 &
<BOOM>
