From: "David S. Miller" <davem@redhat.com>
Subject: dev->destructor
Date: Tue, 29 Apr 2003 23:26:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.232631.68131803.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen, you're right about the dev->destructor problem.
I misread your postings, and I'm very sorry about that.
We were talking about two different things, and admittedly
I had forgotten how some of this stuff works.

Alexey, currently dev->{open,close} are what does get/put
of device module reference.

However, device unregister can explode if dev->destructor is
present.  Unlike in dev->destructor==NULL case, we do not
wait for remnant dev->refcnt to go away.  Therefore we could
invoke dev->destructor() after module is unloaded.

I guess there are two ways to address this problem:

1) dev_get() gets module reference and dev_put() puts is.
   Ugly, as this means dev_get() can fail, but this does
   cover all the possible cases.

2) Make unregister_netdev() wait for refcount to reach 1
   regardless of whether dev->destructor is NULL or not.

I don't like #1.  Do you see some holes in #2?

As Stephen brought up, this also means we should do something
about that NETDEV_UNREGISTER code in dst_dev_event() :-(
