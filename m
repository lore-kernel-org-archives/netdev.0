From: Thomas Graf <tgraf@suug.ch>
Subject: [ANNOUNCE] netlink library
Date: Sat, 30 Oct 2004 21:44:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030194435.GG12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fellow netlink supporters,

This might be interesting for everyone planning to write a netlink
application in the future. I will work further on it but I think
it's worth a release and a short annoucenement. Comments
very much appreciated.

libnl - netlink library
=======================

http://people.suug.ch/~tgr/libnl/

The library is divided into a core providing:
 o handling netlink connections
 o sending of raw data or complete netlink messages.
 o receiving of single messages with MSG_PEEK support to ajdust receive buffer
 o receiving of complete multipart message sets with the support of callbacks
 o callback points for handlers, currently the following are
   implemented:
     - "valid" message (multipart/single)
     - "finish" end of multipart message
     - "overrun" overrun occured
     - "skipped" message to be skipped
     - "ack" netlink ack message
     - "error" netlink error message
     - "invalid" invalid/malformed message
     - "msg_in" called for every message received
     - "msg_out" called before a message gets sent out
   Handlers of such callbacks can return one of the actions:
   proceed,skip,exit to change the behaviour of the parser.

   3 sets of default handlers exist:
    - default: what you would expect, quiet
    - verbose: same as default but prints error messages and
               warns if a valid message is not handled, etc.
    - debug: same as verbose but prints message headers for every
             callback and does hex/ascii dumps in msg_in and msg_out.

 o abstract data types for network addresses and arbitary data
 o netlink message construction tools to build netlink messages.
   Supports appending of raw data, TLVs and nested TLVs and results
   in a nlmsghdr that can be directly used, reqired memory is allocated
   as needed, etc.
 o character string from/to type number transformation routines

... a caching API for netlink users:

 o caching API that netlink users can use to store a list of items
   from a dump.
 o cache_ops which can be implemented by netlink users to abstract
   their functionality to a generic API. Currently the following
   must be implemented:
    - request_update, must request a dump via netlink message
    - msg_parser, must parse a responose and add items to cache
    - free_data, must free data of a cache item
    - dump_brief, must briefly dump item attributes (1-line)
    - dump_full, must dump all attributes
    - dump_with_stas, must dump all attributes including statistics
    - filter, must compare 2 objects of its own and tell if they match
 o generic routines to access such caches:
     dump_cache
     dump_cache_with_filter
     foreach
     foreach_filter

... implementation for specific netlink families/users:

 o the core provides an API for netlink families/users implementions
   to register themselves.

Link Layer
----------
 o implements above cache API
 o setting of link attributes
 o name <-> ifindex conversions


Neighbour
--------
 o implements above cache API
 o adding/modyfing/deleting of neighbours

TCA (Generic routines for all generic TC related routines)
----------------------------------------------------------
 o statistic API with backward compatibility if new stats
   are being added.
 o generic message parsers

Qdisc/Classes
-------------
 o implements above cache API
 o provides register API to qdisc/class sub implementations.
    The following are implemented so far: cbq, dsmark, fifo, prio, sfq, tbf
 o Deletion of single, root, and ingress qdisc
 o Add/Modify yet to be written

Filters
-------
 o implements above cache API
 o provides register API to cls sub implementations. u32 is the only supported so far.
 o Add/Deletion of filters

Some Design Notes
-----------------

 o No kernel headers are included in public header files, all
   definitions used in public header files are included in those header
   files but protected with ifdefs so they can be overruled by including
   the kernel header before the library headers.
 o Own strctures are used instead of just providing the kernel
   structures received in the TLVs so older applications can live forever.

Examples (Probably better than the huge list above ;->)
======================================================

Link layer
----------
Retrieving a local cache:
   struct nl_cache link_cache = RTNL_INIT_LINK_CACHE();
   nl_cache_update(&nl_handle, &link_cache);
 
Translating link names to corresponding ifindex:
   int ifindex = rtnl_link_name2i(&link_cache, "eth0");
 
Retrieving the link handle for a given ifindex:
   struct rtnl_link *l = rtnl_link_get(&link_cache, ifindex);

Dumping all links:
   nl_cache_dump(NL_DUMP_BRIEF, &link_cache, stdout);

Dumping links based on filter:
   struct rtnl_link filter = RTNL_INIT_LINK();
   rtnl_link_set_mtu(&filter, 1500);
   rtnl_link_set_txqlen(&filter, 0);
   nl_cache_dump_filter(NL_DUMP_FULL, &link_cache,
       (struct nl_common *) &filter, stdout);

Changing link settings
   struct rtnl_link change_req = RTNL_INIT_LINK();
   rtnl_link_set_weight(&change_req, 300);
   rtnl_link_change(&nl_handle, l, &change_req);


Printing all links with classes/qdiscs/filters appended to them
nicely formatted: (Read Bottom-Up)
---------------------------------------------------------------

#include <stdio.h>
#include <string.h>
#include <syslog.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <linux/rtnetlink.h>
#include <linux/pkt_sched.h>
#include <linux/pkt_cls.h>
#include <netlink/netlink.h>
#include <netlink/qdisc.h>
#include <netlink/class.h>
#include <netlink/link.h>
#include <netlink/filter.h>
#include <netlink/helpers.h>

static struct nl_handle h = NL_INIT_HANDLE();
static int type = NL_DUMP_FULL;

void print_qdisc(struct nl_common *c, void *arg);

struct xdata
{
	int level;
	uint32_t parent;
};

static void
update_cache(struct nl_cache *c)
{
	if (nl_cache_update(&h, c) < 0) {
		fprintf(stderr, "%s\n", nl_geterror());
		exit(1);
	}
}

static void
print_filters(uint32_t ifindex, uint32_t parent, int level)
{
	struct nl_cache fc = RTNL_INIT_FILTER_CACHE();
	struct rtnl_filter f = RTNL_INIT_FILTER();

	rtnl_filter_set_parent(&f, parent);
	rtnl_filter_set_ifindex(&f, ifindex);

	FILTER_CACHE_IFINDEX(&fc) = ifindex;

	update_cache(&fc);

	nl_set_dump_prefix(level);
	nl_cache_dump_filter(type, &fc, (struct nl_common *) &f, stdout);

	nl_cache_clear(&fc);
}

static void
print_class(struct nl_common *a, void *arg)
{
	struct xdata *x = arg;
	struct rtnl_class *c = (struct rtnl_class *) a;

	nl_set_dump_prefix(x->level);
	rtnl_class_dump(type, c, stdout);

	if (c->tc_info) {
		struct nl_cache qc = RTNL_INIT_QDISC_CACHE();
		struct rtnl_qdisc f = RTNL_INIT_QDISC();
		struct xdata z = {
			.level = (x->level + 2),
			.parent = c->tc_info,
		};

		/*
		 * class has qdisc attatched, get and print it
		 */
		rtnl_qdisc_set_handle(&f, c->tc_info);

		QDISC_CACHE_IFINDEX(&qc) = c->tc_ifindex;
		update_cache(&qc);

		nl_cache_foreach_filter(&qc, (struct nl_common *) &f, &print_qdisc, &z);
		nl_cache_clear(&qc);
	}

	if (1) {
		struct nl_cache cc = RTNL_INIT_CLASS_CACHE();
		struct rtnl_class f = RTNL_INIT_CLASS();
		struct xdata z = { .level = (x->level + 2), };

		/*
		 * get child classes of this class
		 */
		rtnl_class_set_parent(&f, c->tc_handle);

		CLASS_CACHE_IFINDEX(&cc) = c->tc_ifindex;
		update_cache(&cc);
		nl_cache_foreach_filter(&cc, (struct nl_common *) &f, &print_class, &z);
		nl_cache_clear(&cc);
	}

	print_filters(c->tc_ifindex, c->tc_handle, (x->level + 2));
}

void print_qdisc(struct nl_common *c, void *arg)
{
	struct xdata *x = arg;
	struct rtnl_qdisc *q = (struct rtnl_qdisc *) c;

	nl_set_dump_prefix(x->level);
	rtnl_qdisc_dump(type, q, stdout);

	if (1) {
		struct nl_cache cc = RTNL_INIT_CLASS_CACHE();
		struct rtnl_class f = RTNL_INIT_CLASS();
		struct xdata z = { .level = (x->level + 2), };

		/*
		 * get child classes
		 */
		rtnl_class_set_parent(&f, x->parent);
		rtnl_class_set_kind(&f, q->tc_kind);

		CLASS_CACHE_IFINDEX(&cc) = q->tc_ifindex;
		update_cache(&cc);
		nl_cache_foreach_filter(&cc, (struct nl_common *) &f, &print_class, &z);
		nl_cache_clear(&cc);
	}

	print_filters(q->tc_ifindex, q->tc_handle, (x->level + 2));
}


void print_link(struct nl_common *c, void *arg)
{
	struct rtnl_link *l = (struct rtnl_link *) c;
	rtnl_link_dump(type, l, stdout);

	if (1) {
		struct nl_cache qc = RTNL_INIT_QDISC_CACHE();
		struct rtnl_qdisc f = RTNL_INIT_QDISC();
		struct xdata x = {
			.level = 2,
			.parent = TC_H_ROOT,
		};

		/*
		 * get all qdiscs with no parent (root qdiscs)
		 */
		rtnl_qdisc_set_parent(&f, TC_H_UNSPEC);
		rtnl_qdisc_set_ifindex(&f, l->l_index);
		
		QDISC_CACHE_IFINDEX(&qc) = l->l_index;
		update_cache(&qc);
		nl_cache_foreach_filter(&qc, (struct nl_common *) &f, &print_qdisc, &x);
		nl_cache_clear(&qc);
	}
}

int main(int argc, char *argv[])
{
	struct nl_cache lc = RTNL_INIT_LINK_CACHE();

	if (argc > 1) {
		if (!strcasecmp(argv[1], "brief"))
			type = NL_DUMP_BRIEF;
		else if (!strcasecmp(argv[1], "full"))
			type = NL_DUMP_FULL;
		else if (!strcasecmp(argv[1], "stats"))
			type = NL_DUMP_STATS;
	}

	nl_use_default_verbose_handlers(&h);

	if (nl_connect(&h, NETLINK_ROUTE) < 0) {
		fprintf(stderr, "%s\n", nl_geterror());
		return 1;
	}

	update_cache(&lc);
	nl_cache_provide(&lc);
	nl_cache_foreach(&lc, &print_link, NULL);
	nl_cache_clear(&lc);

	nl_close(&h);
	
	return 0;
}
