From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to
 enable sock modifications
Date: Tue, 29 Nov 2016 12:01:43 -0800
Message-ID: <20161129200141.GB24152@ast-mbp.thefacebook.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36376 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756793AbcK2UBs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:01:48 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so17301680pgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:01:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 07:53:32AM -0800, David Ahern wrote:
> Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
> BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
> any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
> Currently only sk_bound_dev_if is exported to userspace for modification
> by a bpf program.
> 
> This allows a cgroup to be configured such that AF_INET{6} sockets opened
> by processes are automatically bound to a specific device. In turn, this
> enables the running of programs that do not support SO_BINDTODEVICE in a
> specific VRF context / L3 domain.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
> +struct bpf_sock {
> +	__u32 bound_dev_if;
> +};

overall looks great to me.
Could you also expose sk_protcol and sk_type as read only fields?
They have user space visible values already and will make this new
BPF_PROG_TYPE_CGROUP_SOCK program type much more useful beyond vrf
use case. Like we'll be able to write a tiny bpf program to block all
raw sockets or all udp sockets for an application within a given cgroup.
If someone would want to prevent udp traffic from an application,
it can be done here within close to zero overhead for socket() syscall
instead of checking every packet at networking layer.
It can help vrf use case as well, so you can auto-bindtodevice
only udp and tcp sockets instead of all... or do it for ipv4 or ipv6 only.
Plenty of interesting opportunities with just two extra fields
that cost nothing when not in use.
