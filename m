From: "=?UTF-8?Q?Rui_Tiago_Ca=C3=A7=C3=A3o_Matos?=" <rmatos@av.it.pt>
Subject: Possible bug on HTB class netlink attributes treatment
Date: Mon, 10 Mar 2008 17:46:08 +0000
Message-ID: <eae3b3410803101046t47849479g545e9efc1e72e81b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, "Thomas Graf" <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:39744 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbYCJRqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 13:46:10 -0400
Received: by an-out-0708.google.com with SMTP id d31so486182and.103
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 10:46:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I found what I think is a bug but I can't completely say if it is in
kernel code or in libnl.

The following program:

#include <stdio.h>
#include <netlink/netlink.h>
#include <linux/pkt_sched.h>
#include <netlink/route/qdisc.h>
#include <netlink/route/sch/htb.h>
#include <netlink/route/link.h>

int main(void)
{
        const char *in_iface_name = "eth1";
        struct nl_handle *netlink_handle;
        struct nl_cache *link_cache;
        struct rtnl_qdisc *htb_qdisc;
        int iface_idx;

        netlink_handle = nl_handle_alloc();
        nl_connect(netlink_handle, NETLINK_ROUTE);
        link_cache = rtnl_link_alloc_cache(netlink_handle);
        iface_idx = rtnl_link_name2i(link_cache, in_iface_name);

        htb_qdisc = rtnl_qdisc_alloc();
        rtnl_qdisc_set_ifindex(htb_qdisc, iface_idx);
        rtnl_qdisc_set_parent(htb_qdisc, TC_H_ROOT);
        rtnl_qdisc_set_handle(htb_qdisc, 0x00010000);
        rtnl_qdisc_set_kind(htb_qdisc, "htb");

/*        rtnl_htb_set_rate2quantum(htb_qdisc, 10); */
/*        rtnl_htb_set_defcls(htb_qdisc, 0x00010001); */

        rtnl_qdisc_add(netlink_handle, htb_qdisc, 0);
        fprintf(stderr, "%s\n", nl_geterror());
        rtnl_qdisc_put(htb_qdisc);

        return 0;
}

triggers this code on net/sched/sch_htb.c:

	if (tb[TCA_HTB_INIT] == NULL) {
		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
		return -EINVAL;
	}

Even though it is simply doing the equivalent of:

# tc qdisc add dev eth1 handle 1: root htb

But, if *either* one of those commented lines above is uncommented it
will succeed.

After reading the iproute2's tc code I've realized that on
q_htb.c:htb_parse_opt() there is always a default for rate2quantum.
But libnl doesn't provide one on htb.c:htb_qdisc_get_opts().

Given the above, what can be done?

1. Nothing. i.e. the user of libnl should know better.
    Then it should be documented.

2. Put a default on libnl.
    I don't like this, since when someone else comes around with
another netlink library (not realisitic, I know) the same mistake will
probably be made.

3. Put the default in the htb kernel code.
    This is the only sane option IMHO since that code needs it to
work, it shouldn't rely on userspace setting it properly.

What do you think?

Rui
