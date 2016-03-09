From: Ben Hawkes <hawkes@google.com>
Subject: Re: Linux netfilter IPT_SO_SET_REPLACE memory corruption
Date: Wed, 9 Mar 2016 09:33:41 -0800
Message-ID: <CABWXx8Hk_V910+AOWSwU5L7Z1k3Wz1Uy0kVCzYAyr8zOA9J4Mg@mail.gmail.com>
References: <CABWXx8H08vO+jXQgMCJ5xRukza0o1HA_VVfshsrgy2wBY8toCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:36512 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbcCIRdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:33:43 -0500
Received: by mail-yw0-f181.google.com with SMTP id g3so45767046ywa.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:33:42 -0800 (PST)
In-Reply-To: <CABWXx8H08vO+jXQgMCJ5xRukza0o1HA_VVfshsrgy2wBY8toCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small correction: IPT_SO_SET_REPLACE is reached via setsockopt, not ioctl.

On Wed, Mar 9, 2016 at 9:25 AM, Ben Hawkes <hawkes@google.com> wrote:
> N.B. I was redirected to this list by security@kernel.org. I'm told
> that networking related issues such as this are handled on the public
> netdev mailing list.
>
> A memory corruption vulnerability exists in the IPT_SO_SET_REPLACE
> ioctl in the netfilter code for iptables support. This ioctl is can be
> triggered by an unprivileged user on PF_INET sockets when unprivileged
> user namespaces are available (CONFIG_USER_NS=y). Android does not
> enable this option, but desktop/server distributions and Chrome OS
> will commonly enable this to allow for containers support or
> sandboxing.
>
> In the mark_source_chains function (net/ipv4/netfilter/ip_tables.c) it
> is possible for a user-supplied ipt_entry structure to have a large
> next_offset field. This field is not bounds checked prior to writing a
> counter value at the supplied offset:
>
> newpos = pos + e->next_offset;
> ...
> e = (struct ipt_entry *) (entry0 + newpos);
> e->counters.pcnt = pos;
>
> This means that an out of bounds 32-bit write can occur in a 64kb
> range from the allocated heap entry, with a controlled offset and a
> partially controlled write value ("pos") or zero. The attached
> proof-of-concept (netfilter_setsockopt_v3.c) triggers the corruption
> multiple times to set adjacent heap structures to zero.
>
> This issue affects (at least) kernel versions 3.10, 3.18 and 4.4, and
> could be used for local privilege escalation. It appears that a
> similar codepath is accessible via arp_tables.c/ARPT_SO_SET_REPLACE as
> well.
>
> Furthermore, a recent refactoring of this codepath
> (https://github.com/torvalds/linux/commit/2e4e6a17af35be359cc8f1c924f8f198fbd478cc)
> introduced an integer overflow in xt_alloc_table_info, which on 32-bit
> systems can lead to small structure allocation and a copy_from_user
> based heap corruption. The attached proof-of-concept
> (netfilter_setsockopt_v4.c) triggers this issue on 4.4.
