From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Thu, 20 Jan 2005 16:35:59 +0100
Message-ID: <20050120153559.GG26856@postel.suug.ch>
References: <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106232168.1041.125.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106232168.1041.125.camel@jzny.localdomain> 2005-01-20 09:42
> I like it. Assuming we can have arbitrary hierachies; you just show one
> level - but that may be just the example at hand. Given that should be
> able to meet the layout requirements that Lennert alluded to earlier.

It doesn't include any context code, the BNF:

PARSER    := TOPNODE*
TOPNODE   := NODELIST DESC LONG_DESC
NODELIST  := NODE*
NODE      := DESC [ NODELIST ] [ ARGUMENT ] [ ATTRS ] [ END_POINT ]
END_POINT := possible end of command
ATTRS     := ATTR*
ATTR      := KEY [ VALUE ]
ARGUMENT  := VALUE [ DESC ]

Not sure if this helps, I attached a complete module below.

> > The status of the whole thing: link and neighbour are finished,
> > core architecture finished as well, route is half done, addresses
> > are half done (both easy to finish). libnl has net/sched/
> > finished but is still missing code for a lot of modules. 
> 
> This is the part i am a little uncomfortable with. If you can make that
> library maybe part of iproute2 it would ease maintanance. Extend
> libnetlink or have another layer on top of it. 
> I know you have already put the effort, but consider this thought.

We can move it into iproute2 but the code really differs from iproute2
and code sharing is almost impossible. We can make iproute2 use it
at some point but that doesn't make much sense for me.


> >  - Seq counter in netlink, increased evertime a netlink message
> >    gets processed and returned in ack. A netlink request may contain
> >    a flag and the expected sequence number and the request gets only
> >    processed if they match, otherwise the request fails. (my favourite)

Do you have any objections on this?

> >  - Lock file in userspace (how to enfroce everyone to use it?)
> >  - Try to detect changes from third party after commit. Quite
> >    hard but possible, reduces race window but doesn't close it
> >    completely.
> > 
> 
> Other apps changing things will screw you. If that gets handled then we
> are set. I actually did start working on a netlink redirect(hook) for a
> very different reason, but it should serve this purpose. Essentially you
> register to be the proxy for netlink and all messages go via you. You
> can then munge them, etc before issuing the response or allowing it to
> go on to configure things. With this your "lock" would be to ask for
> certain things to be redirected to you during an update phase.
> Ok, maybe i will put more effort on it over the weekend (Sunday). 

Indeed, that would serve me well and we can avoid the userspace daemon.
It doesn't even have to be a proxy, a simple callback hook capable of
returning an action would be enough for my purpose.

NOTE: Read bottom-up:

/*
 * neigh.c             linux net config utility
 *
 * $Id$
 *
 * Copyright (c) 2004 Thomas Graf <tgraf@suug.ch>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <nc/config.h>
#include <nc/parse.h>
#include <nc/utils.h>
#include <nc/link.h>

static struct nl_cache neigh_cache = RTNL_INIT_NEIGH_CACHE();
static int dump_type = NL_DUMP_BRIEF;
static struct rtnl_neigh filter = RTNL_INIT_NEIGH();
static struct {
	char *lladdr, *dev, *dst, *proxy, *router, *incomplete;
	char *reachable, *stale, *delay, *probe, *failed, *noarp;
	char *perm;
} storage;

static int set_dump_type(struct grammar_node *g)
{
	dump_type = (int) g->gn_data;
	return 0;
}

static int set_dev(struct grammar_node *g)
{
	int err;
	struct nl_cache *c = nl_cache_lookup(RTNL_LINK);
	
	BUG_ON(!g);

	err = update_link_cache();
	if (err < 0)
		return err;

	return rtnl_neigh_set_ifindex_name(&filter, c, gr_arg_val(g));
}

static int set_lladdr(struct grammar_node *g)
{
	BUG_ON(!g);
	return rtnl_neigh_set_lladdr(&filter, gr_arg_val(g));
}

static int set_dst(struct grammar_node *g)
{
	BUG_ON(!g);
	return rtnl_neigh_set_dst(&filter, gr_arg_val(g));
}

static int set_state2(struct grammar_node *g)
{
	BUG_ON(!g);
	rtnl_neigh_set_state(&filter, (int) g->gn_data);
	return 0;
}


static int set_state(struct grammar_node *g)
{
	BUG_ON(!g);

	if (gr_is_enabled(g))
		rtnl_neigh_set_state(&filter, (int) g->gn_data);
	else if (gr_is_disabled(g))
		rtnl_neigh_unset_state(&filter, (int) g->gn_data);
	else {
		put_err("Invalid toggle value '%s', must be {on|off}\n",
		    gr_arg_val(g));
		return -1;
	}

	return 0;
}

static int set_flag(struct grammar_node *g)
{
	BUG_ON(!g);

	if (gr_is_enabled(g))
		rtnl_neigh_set_flag(&filter, (int) g->gn_data);
	else if (gr_is_disabled(g))
		rtnl_neigh_unset_flag(&filter, (int) g->gn_data);
	else {
		put_err("Invalid toggle value '%s', must be {on|off}\n",
		    gr_arg_val(g));
		return -1;
	}

	return 0;
}

static inline struct rtnl_neigh * get_neigh(int i)
{
	return (struct rtnl_neigh *) nl_cache_get(&neigh_cache, i);
}

CACHE_MGEN(lladdr, &nlh_route, &neigh_cache)
{
	return nl_addr2str_r(&(get_neigh(i)->n_lladdr), buf, len);
}

CACHE_MGEN(dst, &nlh_route, &neigh_cache)
{
	return nl_addr2str_r(&(get_neigh(i)->n_dst), buf, len);
}

CACHE_MGEN(ifname_dst, &nlh_route, &neigh_cache)
{
	struct nl_cache *c = nl_cache_lookup(RTNL_LINK);
	struct rtnl_neigh *n = get_neigh(i);

	if (update_link_cache() < 0)
		return NULL;

	if (storage.dst) {
		struct nl_addr f;

		if (nl_str2addr(storage.dst, &f) < 0)
			goto fallback;
		
		if (n->n_dst.a_len == f.a_len &&
		    !memcmp(n->n_dst.a_addr, f.a_addr, n->n_dst.a_len))
			return (char *) rtnl_link_i2name(c, n->n_ifindex);
		else
			return NULL;
	}

fallback:
	return (char *) rtnl_link_i2name(c, n->n_ifindex);
}

static inline void reset_filter(void)
{
	memset(&filter, 0, sizeof(filter));
}

static int update_neigh_cache(void)
{
	if (nl_cache_update(&nlh_route, &neigh_cache) < 0) {
		put_err("%s\n", nl_geterror());
		return -1;
	}

	return 0;
}

static int do_neigh_list(struct grammar_node *g)
{
	int err;

	BUG_ON(!g);

	err = update_link_cache();
	if (err < 0)
		goto out;

	err = update_neigh_cache();
	if (err < 0)
		goto out;

	nl_cache_dump_filter(dump_type, &neigh_cache,
		(struct nl_common *) &filter, fd_out);

	err = 0;
out:
	dump_type = NL_DUMP_BRIEF;
	reset_filter();
	return err;
}

static int do_neigh_add(struct grammar_node *g)
{
	int err = -1;

	BUG_ON(!g);

	filter.n_family = filter.n_lladdr.a_family;

	err = rtnl_neigh_set_dst(&filter, gr_arg_val(g));
	if (err < 0)
		goto out;
	
	err = rtnl_neigh_add(&nlh_route, &filter);
	if (err < 0)
		goto out;

	err = 0;
out:
	reset_filter();
	return err;
}

static int do_neigh_del(struct grammar_node *g)
{
	int err = -1;

	BUG_ON(!g);
	
	err = rtnl_neigh_set_dst(&filter, gr_arg_val(g));
	if (err < 0)
		goto out;

	err = rtnl_neigh_delete(&nlh_route, &filter);
	if (err < 0)
		goto out;

	err = 0;
out:
	reset_filter();
	return err;
}

static int do_neigh_modify(struct grammar_node *g)
{
	int err;

	BUG_ON(!g);

	if (filter.n_mask == 0)
		return 0;

	err = rtnl_neigh_set_dst(&filter, gr_arg_val(g));
	if (err < 0)
		goto out;

	err = rtnl_neigh_change(&nlh_route, &filter, &filter);
	if (err < 0)
		goto out;

	err = 0;
out:
	reset_filter();
	return err;
}

ATTRLIST(neigh_flags_attrs)
	ATTR_FLAG(proxy, NTF_PROXY, &storage.dst, set_flag, "Proxy")
	ATTR_FLAG(router, NTF_ROUTER, &storage.router, set_flag, "Router")
	ATTR_FLAG(incomplete, NUD_INCOMPLETE, &storage.incomplete, set_state,
	    "Lookup is incomplete")
	ATTR_FLAG(reachable, NUD_REACHABLE, &storage.reachable, set_state,
	    "Reachable")
	ATTR_FLAG(stale, NUD_STALE, &storage.stale, set_state, "Stale entry")
	ATTR_FLAG(delay, NUD_DELAY, &storage.delay, set_state, "Delayed")
	ATTR_FLAG(probe, NUD_PROBE, &storage.probe, set_state, "Probe")
	ATTR_FLAG(failed, NUD_FAILED, &storage.failed, set_state, "Failed")
	ATTR_FLAG(noarp, NUD_NOARP, &storage.noarp, set_state, "No ARP")
	ATTR_FLAG(permanent, NUD_PERMANENT, &storage.perm, set_state,
	    "Permanent entry")
END_ATTRLIST

NODELIST(neigh_flags)
	END_POINT
	NODE(flags)
		ATTRS(neigh_flags_attrs)
	END_NODE
END_NODELIST

ATTRLIST(neigh_filter)
	ATTR(lladdr)
		CALLBACK(set_lladdr)
		ARG(GA_TEXT, &storage.lladdr,CACHE_MGEN_FUNC(lladdr),"<LLADDR>")
		DESC("Link layer address")
	END_ATTR
	ATTR(dst)
		CALLBACK(set_dst)
		ARG(GA_TEXT, &storage.dst, CACHE_MGEN_FUNC(dst), "<ADDR>")
		DESC("Destination address")
	END_ATTR
	ATTR(dev)
		CALLBACK(set_dev)
		ARG(GA_TEXT, &storage.dev, CACHE_MGEN_FUNC(ifname), "<DEV>")
		DESC("Link the neighbour is on")
	END_ATTR
END_ATTRLIST

NODELIST(neigh_where)
	END_POINT
	NODE(where)
		ATTRS(neigh_filter)
		FOLLOW(neigh_flags)
		DESC("Only dump neighbours matching a filter")
	END_NODE
END_NODELIST

NODELIST(neigh_list_attrs)
	END_POINT
	NODE(brief)
		DATA(NL_DUMP_BRIEF)
		FOLLOW(neigh_where)
		CALLBACK(set_dump_type)
		DESC("Brief listing of attributes")
	END_NODE
	NODE(full)
		DATA(NL_DUMP_FULL)
		FOLLOW(neigh_where)
		CALLBACK(set_dump_type)
		DESC("Verbose listing (all attributes)")
	END_NODE
	NODE(stats)
		DATA(NL_DUMP_STATS)
		FOLLOW(neigh_where)
		CALLBACK(set_dump_type)
		DESC("Verbose listing (all attributes/statistics)")
	END_NODE
	NODE(where)
		ATTRS(neigh_filter)
		FOLLOW(neigh_flags)
		DESC("Only dump neighbours matching a filter")
	END_NODE
END_NODELIST

NODELIST(neigh_add_state)
	NODE(permanent)
		CALLBACK(set_state2)
		DATA(NUD_PERMANENT)
		DESC("Permanent entry")
	END_NODE
	NODE(stale)
		CALLBACK(set_state2)
		DATA(NUD_STALE)
		DESC("Stale entry")
	END_NODE
	NODE(noarp)
		CALLBACK(set_state2)
		DATA(NUD_NOARP)
		DESC("No ARP")
	END_NODE
	NODE(reachable)
		CALLBACK(set_state2)
		DATA(NUD_REACHABLE)
		DESC("Reachable")
	END_NODE
	NODE(failed)
		CALLBACK(set_state2)
		DATA(NUD_FAILED)
		DESC("Failed")
	END_NODE
END_NODELIST


NODELIST(neigh_add_lladdr)
	NODE(lladdr)
		CALLBACK(set_lladdr)
		FOLLOW(neigh_add_state)
		ARG(GA_TEXT, &storage.lladdr,CACHE_MGEN_FUNC(lladdr),"<LLADDR>")
		DESC("Link layer address")
	END_NODE
END_NODELIST

NODELIST(neigh_add_dev)
	NODE(dev)
		CALLBACK(set_dev)
		FOLLOW(neigh_add_lladdr)
		ARG(GA_TEXT, &storage.dev, CACHE_MGEN_FUNC(ifname), "<DEV>")
		DESC("Link")
	END_NODE
END_NODELIST

NODELIST(neigh_del_dev)
	NODE(dev)
		CALLBACK(set_dev)
		ARG(GA_TEXT, &storage.dev, CACHE_MGEN_FUNC(ifname_dst), "<DEV>")
		DESC("Link")
	END_NODE
END_NODELIST

ATTRLIST(neigh_set_attrs)
	ATTR(lladdr)
		CALLBACK(set_lladdr)
		ARG(GA_TEXT, &storage.lladdr,CACHE_MGEN_FUNC(lladdr),"<LLADDR>")
		DESC("Link layer address")
	END_ATTR
	ATTR_FLAG(proxy, NTF_PROXY, &storage.proxy, set_flag, "Proxy")
	ATTR_FLAG(router, NTF_ROUTER, &storage.router, set_flag, "Router")
	ATTR_FLAG(incomplete, NUD_INCOMPLETE, &storage.incomplete, set_state,
	    "Incomplete lookup")
	ATTR_FLAG(reachable, NUD_REACHABLE, &storage.reachable, set_state,
	    "Reachable")
	ATTR_FLAG(stale, NUD_STALE, &storage.stale, set_state, "Stale entry")
	ATTR_FLAG(delay, NUD_DELAY, &storage.delay, set_state, "Delayed")
	ATTR_FLAG(probe, NUD_PROBE, &storage.probe, set_state, "Probe")
	ATTR_FLAG(failed, NUD_FAILED, &storage.failed, set_state, "Failed")
	ATTR_FLAG(noarp, NUD_NOARP, &storage.noarp, set_state, "No ARP")
	ATTR_FLAG(permanent, NUD_PERMANENT, &storage.perm, set_state,
	    "Permanent entry")
END_ATTRLIST

NODELIST(neigh_modify)
	NODE(set)
		ATTRS(neigh_set_attrs)
	END_NODE
END_NODELIST

NODELIST(neigh_modify_dev)
	NODE(dev)
		CALLBACK(set_dev)
		FOLLOW(neigh_modify)
		ARG(GA_TEXT, &storage.dev, CACHE_MGEN_FUNC(ifname_dst), "<DEV>")
		DESC("Link")
	END_NODE
END_NODELIST

NODELIST(neigh_ops)
	NODE(add)
		FOLLOW(neigh_add_dev)
		CALLBACK(do_neigh_add)
		ARG(GA_TEXT, &storage.dst, CACHE_MGEN_FUNC(dst), "<ADDR>")
		DESC("Add a neighbour")
	END_NODE
	NODE(modify)
		FOLLOW(neigh_modify_dev)
		CALLBACK(do_neigh_modify)
		ARG(GA_TEXT, &storage.dst, CACHE_MGEN_FUNC(dst), "<ADDR>")
		DESC("Modify a neighbour")
	END_NODE
	NODE(delete)
		FOLLOW(neigh_del_dev)
		CALLBACK(do_neigh_del)
		ARG(GA_TEXT, &storage.dst, CACHE_MGEN_FUNC(dst), "<ADDR>")
		DESC("Delete a neighbour")
	END_NODE
	NODE(list)
		FOLLOW(neigh_list_attrs)
		CALLBACK(do_neigh_list)
		DESC("List neighbour attributes")
	END_NODE
END_NODELIST

TOPNODE(ng, neighbour)
	FOLLOW(neigh_ops)
	DESC("Neighbour (ARP) configuration")
	LONG_DESC(
	"    Module to view and modify the neighbour tables.\n"
	"    \n" \
	"    The neighbour table establishes bindings between protocol\n" \
	"    addresses and link layer addresses for hosts sharing the same\n" \
	"    physical link. This module allows you to view the content of\n" \
	"    these tables and to manipulate their content.\n")
END_TOPNODE

static void __init neigh_init(void)
{
	MAKE_LIST(neigh_ops);
	MAKE_LIST(neigh_list_attrs);
	MAKE_LIST(neigh_where);
	MAKE_LIST(neigh_filter);
	MAKE_LIST(neigh_add_dev);
	MAKE_LIST(neigh_add_lladdr);
	MAKE_LIST(neigh_add_state);
	MAKE_LIST(neigh_del_dev);
	MAKE_LIST(neigh_modify_dev);
	MAKE_LIST(neigh_modify);
	MAKE_LIST(neigh_set_attrs);
	MAKE_LIST(neigh_flags);
	MAKE_LIST(neigh_flags_attrs);

	register_top_node(&ng);
}
