From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 2/3] [RFC] Add c/r support for connected INET sockets
 (v3)
Date: Thu, 29 Oct 2009 16:15:45 -0400
Message-ID: <4AE9F7F1.8000803@librato.com>
References: <1256666008-8231-1-git-send-email-danms@us.ibm.com> <1256666008-8231-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	John Dykstra <jdykstra72@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp201.iad.emailsrvr.com ([207.97.245.201]:46675 "EHLO
	smtp201.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbZJ2UPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 16:15:42 -0400
In-Reply-To: <1256666008-8231-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dan Smith wrote:
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.
> 
> We probably need comments from the netdev people about the quality of
> sanity checking we do on the values in the ckpt_hdr_socket_inet
> structure on restart.
> 
> Note that this still doesn't address lingering sockets yet.
> 
> Changes in v3:
>  - Prevent restart from allowing a bind on a <1024 port unless the
>    user is granted that capability
>  - Add some sanity checking in the inet_precheck() function to make sure
>    the values read from the checkpoint image are within acceptable ranges
>  - Check the result of sock_restore_header_info() and fail if needed
> 
> Changes in v2:
>  - Restore saddr, rcv_saddr, daddr, sport, and dport from the sockaddr
>    structure instead of saving them separately
>  - Fix 'sock' naming in sock_cptrst()
>  - Don't take the queue lock before skb_queue_tail() since it is
>    done for us
>  - Allow "listen only" restore behavior if RESTART_SOCK_LISTENONLY
>    flag is specified on sys_restart()
>  - Pull the implementation of the list of listening sockets back into
>    this patch
>  - Fix dangling printk
>  - Add some comments around the parent/child restore logic
> 
> Cc: netdev@vger.kernel.org
> Cc: Oren Laadan <orenl@librato.com>
> Cc: John Dykstra <jdykstra72@gmail.com>
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---

This looks good:
Acked-by: Oren Laadan <orenl@cs.columbia.edu>

I still want to move this to right under the restart-specific fields:
	struct list_head listen_sockets;/* listening parent sockets */

Also, I'm looking for a better name for RESTART_SOCK_LISTENONLY
(it isn't listen only, udp sockets are preserved...), something
that will convey the idea that we drop old connections,
perhaps:
	RESTART_NET_RESET
	RESTART_CONN_RESET
	RESTART_DROPCONN
?

Oren.

