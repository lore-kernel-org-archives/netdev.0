From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Fri, 02 May 2003 21:00:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030502.210000.35018302.davem@redhat.com>
References: <20030502.134804.78707298.davem@redhat.com>
	<20030503040949.804182C003@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030503040949.804182C003@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Sat, 03 May 2003 14:07:41 +1000

   This argument applies to all objects.  If you reference count
   everything which holds a reference to an object, you can infer the
   reference count of the object from the sum of reference counts of its
   referees.
   
   In practice, as you pointed out in an earlier mail (I think sockets
   were your example), doing this proves to be extremely painful.  And
   we're feeling the pain now.
   
Please ignore the example code I wrote in that email.
Most of it is inconsistent and frankly garbage. :-)

The "->can_unload()" check is actually simpler than we might initially
suspect.  Something like ipv6 might check:

	if (atomic_read(&inet6_sock_nr) == 0 &&
	    atomic_read(&inet6_dev_nr) == 0 &&
	    rt6_cache_empty())
		return 1;
	return 0;

Now, here is the important part!  When this thing returns "1" the
module.c code does this:

	call_rcu(&mod->rcu_head, mod->cleanup, NULL);

This makes sure the guy who killed the last object has indeed
left the module code.
