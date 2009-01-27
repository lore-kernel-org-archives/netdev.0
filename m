From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Mon, 26 Jan 2009 19:48:20 -0800
Message-ID: <20090126194820.41cdb7f5@extreme>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-4-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39436 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbZA0DsW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 22:48:22 -0500
In-Reply-To: <1233022678-9259-4-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jan 2009 18:17:40 -0800
Andy Grover <andy.grover@oracle.com> wrote:

> RDS handles per-socket congestion by updating peers with a complete
> congestion map (8KB). This code keeps track of these maps for itself
> and ones received from peers.
> 
> Signed-off-by: Andy Grover <andy.grover@oracle.com>
> ---
>  drivers/infiniband/ulp/rds/cong.c |  424 +++++++++++++++++++++++++++++++++++++
>  1 files changed, 424 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/infiniband/ulp/rds/cong.c
> 
> diff --git a/drivers/infiniband/ulp/rds/cong.c b/drivers/infiniband/ulp/rds/cong.c
> new file mode 100644
> index 0000000..b7c49d2
> --- /dev/null
> +++ b/drivers/infiniband/ulp/rds/cong.c
> @@ -0,0 +1,424 @@
> +/*
> + * Copyright (c) 2007 Oracle.  All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + *
> + */
> +#include <linux/types.h>
> +#include <linux/rbtree.h>
> +
> +#include "rds.h"
> +
> +/*
> + * This file implements the receive side of the unconventional congestion
> + * management in RDS.
> + *
> + * Messages waiting in the receive queue on the receiving socket are accounted
> + * against the sockets SO_RCVBUF option value.  Only the payload bytes in the
> + * message are accounted for.  If the number of bytes queued equals or exceeds
> + * rcvbuf then the socket is congested.  All sends attempted to this socket's
> + * address should return block or return -EWOULDBLOCK.
> + *
> + * Applications are expected to be reasonably tuned such that this situation
> + * very rarely occurs.  An application encountering this "back-pressure" is
> + * considered a bug.
> + *
> + * This is implemented by having each node maintain bitmaps which indicate
> + * which ports on bound addresses are congested.  As the bitmap changes it is
> + * sent through all the connections which terminate in the local address of the
> + * bitmap which changed.
> + *
> + * The bitmaps are allocated as connections are brought up.  This avoids
> + * allocation in the interrupt handling path which queues messages on sockets.
> + * The dense bitmaps let transports send the entire bitmap on any bitmap change
> + * reasonably efficiently.  This is much easier to implement than some
> + * finer-grained communication of per-port congestion.  The sender does a very
> + * inexpensive bit test to test if the port it's about to send to is congested
> + * or not.
> + */
> +
> +/*
> + * Interaction with poll is a tad tricky. We want all processes stuck in
> + * poll to wake up and check whether a congested destination became uncongested.
> + * The really sad thing is we have no idea which destinations the application
> + * wants to send to - we don't even know which rds_connections are involved.
> + * So until we implement a more flexible rds poll interface, we have to make
> + * do with this:
> + * We maintain a global counter that is incremented each time a congestion map
> + * update is received. Each rds socket tracks this value, and if rds_poll
> + * finds that the saved generation number is smaller than the global generation
> + * number, it wakes up the process.
> + */
> +static atomic_t		rds_cong_generation = ATOMIC_INIT(0);
> +
> +/*
> + * Congestion monitoring
> + */
> +static LIST_HEAD(rds_cong_monitor);
> +static DEFINE_RWLOCK(rds_cong_monitor_lock);
> +
> +/*
> + * Yes, a global lock.  It's used so infrequently that it's worth keeping it
> + * global to simplify the locking.  It's only used in the following
> + * circumstances:
> + *
> + *  - on connection buildup to associate a conn with its maps
> + *  - on map changes to inform conns of a new map to send
> + *
> + *  It's sadly ordered under the socket callback lock and the connection lock.
> + *  Receive paths can mark ports congested from interrupt context so the
> + *  lock masks interrupts.
> + */

So this is starting to look like another "Oracle special" like AIO
and HugeTLB. That has lots of caveat restrictions on the application.

