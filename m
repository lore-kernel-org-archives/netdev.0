From: Donald Becker <becker@scyld.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 14:14:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210151353450.1159-100000@beohost.scyld.com>
References: <20021015.104014.34145167.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jmorris@intercode.com.au, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021015.104014.34145167.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Oct 2002, David S. Miller wrote:

> That is a critical path and it happens millions upon
> millions of times a second on a busy server.  Performance
> will be penalized by changes like this.

This is a good place to point out why this patch is bogus.

The topic is adding "hooks".

The proposed method always calls a function, which must exist.  The default
function is a no-op.  This is just about the worst way of doing things.
  - It is optimizing for the unlikely and already expensive case where
    there is a hook.
  - It makes the code difficult to follow
  - It has horrible code path and cache footprint behavior.
  - Your method adds a bunch of hooks when just one would do.

The usual approach is
   if (obj->hookfun)  obj->hookfun(obj, method_index, other_params);

Even this makes the code less readable, but at least doesn't jump all
over the instruction space.  The impact is a dereference and a test for
zero, and then a jump over a push/mov instructions for values that
should already be in registers.

> There is no way in hell that you are going to
> add a function call for every time we set the
> socket owner of a SKB.

I already bitch about how cost and cache impact of allocating and manipulating
skbuffs.  This definitely falls into the category of "adding more junk".

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
