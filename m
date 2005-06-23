From: Jeff Moyer <jmoyer@redhat.com>
Subject: [patch 0/3] netpoll: support multiple netpoll clients per net_device
Date: Wed, 22 Jun 2005 21:26:29 -0400
Message-ID: <17082.4037.875432.648439@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261899AbVFWB0m@vger.kernel.org>
To: mpm@selenic.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series restores the ability to register multiple netpoll clients
against the same network interface.  To this end, I created a new structure:

struct netpoll_info {
	spinlock_t poll_lock;
	int poll_owner;
	int rx_flags;
	spinlock_t rx_lock;
	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
};

This is the structure which gets pointed to by the net_device.  All of the
flags and locks which are specific to the INTERFACE go here.  Any variables
which must be kept per struct netpoll were left in the struct netpoll.  So
now, we have a cleaner separation of data and its scope.

Since we never really supported having more than one struct netpoll
register an rx_hook, I did not re-implement the rx_list.  Instead, there is
a single pointer in the netpoll_info structure (np_rx).  Note that if we
decide that we would like to register multiple rx_hooks per net_device,
this architecture does not preclude such extension.

We need to protect setting and clearing of the rx_np pointer, so I added a
lock (rx_lock) to the netpoll_info struct. [1]  There is one lock per
struct net_device, and I am certain that it will be low contention, as rx_np
will only be changed during an insmod or rmmod.

In the process of making these changes, I fixed a bug in netpoll_poll_unlock.
The function released the lock before setting the poll_owner to -1.


I have tested this by registering two netpoll clients, and verifying that
they both function properly.  The clients were netconsole, and a quick
module I hacked together to send console messages to syslog.  I issued
sysrq-h, sysrq-m, and sysrq-t's both by echo'ing to /proc/sysrq-trigger and
by hitting the key combination on the keyboard.  This verifies that the
modules work both inside and out of interrupt context.

Cheers,

Jeff

[1] Matt notes that we may be able to merge this lock with the poll_lock in
    the future.
