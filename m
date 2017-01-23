From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: ignore null_entry on route dumps
Date: Mon, 23 Jan 2017 09:51:07 -0700
Message-ID: <a1eaeddc-69df-e0fa-c06a-285c3234249c@cumulusnetworks.com>
References: <1485147377-11922-1-git-send-email-dsa@cumulusnetworks.com>
 <20170122.235829.1911961579892347071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35535 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdAWQvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:51:09 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so42469170pfa.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 08:51:09 -0800 (PST)
In-Reply-To: <20170122.235829.1911961579892347071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/17 9:58 PM, David Miller wrote:
> 
> David, please slow down.
> 
> How is the NULL entry getting selected to be dumped and passed
> down here in the first place?

The null_entry might be a 'marker' but is integral to the ipv6 fib. For starters:

static int __net_init fib6_net_init(struct net *net)
{
...
        net->ipv6.fib6_main_tbl = kzalloc(sizeof(*net->ipv6.fib6_main_tbl),
                                          GFP_KERNEL);
...
        net->ipv6.fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
        net->ipv6.fib6_main_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;

...


Same goes for every other table allocated:

static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
{
        struct fib6_table *table;

        table = kzalloc(sizeof(*table), GFP_ATOMIC);
        if (table) {
                table->tb6_id = id;
                table->tb6_root.leaf = net->ipv6.ip6_null_entry;
..
        }


And if you look at the fib6_add code:

                        sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
                        atomic_inc(&info->nl_net->ipv6.ip6_null_entry->rt6i_ref);
                        sfn->fn_flags = RTN_ROOT;
                        sfn->fn_sernum = sernum;

                        /* Now add the first leaf node to new subtree */

                        sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
                                        rt->rt6i_src.plen,
                                        offsetof(struct rt6_info, rt6i_src),
                                        allow_create, replace_required, sernum);

Meaning that a walk of the table is going to dump the ip6_null_entry route, potentially multiple times.

As far as the dump request the chain rtnetlink message invokes inet6_dump_fib:

inet6_dump_fib
- fib6_dump_table
  + fib6_walk
    * fib6_walk_continue
      - fib6_dump_node
        + rt6_dump_route

Seems to me the most appropriate place to check that rt is the null_entry route is rt6_dump_route but perhaps fib6_dump_node could as well. This patch buts the check in rt6_dump_route. 
