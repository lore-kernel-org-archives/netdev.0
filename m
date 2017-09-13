From: Shmulik Ladkani <shmulik@nsof.io>
Subject: netfilter: xt_bpf: ABI issue in xt_bpf_info_v1?
Date: Wed, 13 Sep 2017 16:24:42 +0300
Message-ID: <20170913162442.368691c9@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        Rafael Buchbinder <rbk@nsof.io>, shmulik.ladkani@gmail.com,
        eyal@nsof.io
To: netfilter-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:45401 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdIMNYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 09:24:48 -0400
Received: by mail-wm0-f49.google.com with SMTP id g206so6786951wme.0
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 06:24:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Commit 2c16d60 'netfilter: xt_bpf: support ebpf' introduced
'xt_bpf_info_v1', to support attaching an eBPF object by fd.

Alas, seems this ABI is problematic, as the 'fd', which is local to the
process attaching the ebpf object (namely iptables) is stored in the
matchinfo structure.

This leads to subsequent invocation of iptables to fail:

# iptables -A INPUT -m bpf --object-pinned /sys/fs/bpf/xxx -j ACCEPT
# iptables -A INPUT -s 5.6.7.8 -j ACCEPT
iptables: Invalid argument. Run `dmesg' for more information.

Tracing 2nd invocation shows:

setsockopt(4, SOL_IP, IPT_SO_SET_REPLACE, "filter\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 5400) = -1 EINVAL

In the 2nd invocation, iptables loads existing rules from the kernel
using IPT_SO_GET_ENTRIES, adds the new innocent one, and then issues
IPT_SO_SET_REPLACE.
However the existing rules contain the former ebpf rule which contains
the fd number from the initial 'iptables -m bpf' invocation.

Thus, when IPT_SO_SET_REPLACE eventually hits 'bpf_mt_check_v1', and
'bpf_prog_get_type' is called, the arbitrary fd has either no associated
file, or has no associated bpf_prog - leading 'bpf_prog_get_type' to
fail.

One way to fix is to have iptables open the object (using the stored
xt_bpf_info_v1->path), gaining a new process local fd for the object,
just after getting the rules from IPT_SO_GET_ENTRIES.
However we didn't see any other extensions doing something like that in
iptables.

Another way to solve is to fix the ABI (or have a v2 one), that does NOT
pass the fd from userspace, only the path of the pinned object.
Then, 'bpf_mt_check_v1' will open the file from the given path in order
to get the bpf_prog.

Please advise.

Best,
Shmulik
