From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 17:54:21 +0100
Message-ID: <20050119165421.GB26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106144009.1047.989.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106144009.1047.989.camel@jzny.localdomain> 2005-01-19 09:13
> What i mean is that we should probably leave iproute2 code alone so that
> people can run old scripts etc with it.  i.e the netsh tool should just
> either reuse libnetlink and add any things to it or create a brand new
> library.

Inspected some more code and I've finished already more than I thought.
The architecture currently allows specifying the grammar with macros
like this:

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

Looks a bit complicated but is actually quite easy, you can do it the
linux way. This will get your full completion and context help for
your grammar and also completion of arguments like link names,
addresses in neighbour cache, etc. All you have to do is specify
a function returning a list of possibilities. It allows you to
build recursive grammars and multiple end points in the automation.

The above results in this:

axs# neigh ?
  Backtrace:
      ->neighbour - Neighbour (ARP) configuration

  Description:
    Module to view and modify the neighbour tables.

    The neighbour table establishes bindings between protocol
    addresses and link layer addresses for hosts sharing the same
    physical link. This module allows you to view the content of
    these tables and to manipulate their content.

  Next level commands:
      add <ADDR> ...                 Add a neighbour
      modify <ADDR> ...              Modify a neighbour
      delete <ADDR> ...              Delete a neighbour
      list ...                       List neighbour attributes
axs# neigh modify ?
  Backtrace:
      ->neighbour - Neighbour (ARP) configuration
        ->modify - Modify a neighbour

  Expecting argument: <ADDR>
axs# neigh modify <TAB>
192.168.23.12		192.168.23.13
axs# neigh modify 192.168.23.1

Note: the <TAB> above will look up the addresses in the neighbour
table and list the possible entries, since all share a common
prefix it is automatically filled in. There is quite some
thinking in these completion functions, the link name completion
in neighbour context will only show up links which actually have
neighbour entries.

The status of the whole thing: link and neighbour are finished,
core architecture finished as well, route is half done, addresses
are half done (both easy to finish). libnl has net/sched/
finished but is still missing code for a lot of modules. Session
management (commit/rollback) was once in but was too unstable,
needs a partial rewrite (design flaws) but should fit in quite
easly because libnl was designed to support it. It will basically
look like: nl_session_start(); ... any high level operations ..
if (nl_session_commit() < 0) nl_session_rollback();

Problems? Keeping the cache valid (multiple netlink programs).
The final update just before the commit and the commit itself
must be atomic.

Solutions:
 - Use ATOMIC flag (dangerous)
 - Seq counter in netlink, increased evertime a netlink message
   gets processed and returned in ack. A netlink request may contain
   a flag and the expected sequence number and the request gets only
   processed if they match, otherwise the request fails. (my favourite)
 - Lock file in userspace (how to enfroce everyone to use it?)
 - Try to detect changes from third party after commit. Quite
   hard but possible, reduces race window but doesn't close it
   completely.

Background: I keep 2 caches, 1 cache represents the current state
in the kernel, it gets updated when required. The second cache
contains the local caches. The first cache gets merged into the
second before the update and then gets commited. In case of a
failure the first cache is used to restore things.

Thoughts?
