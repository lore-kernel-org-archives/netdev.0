From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] memory leak in netlink user->kernel processing
Date: Mon, 01 Oct 2007 16:36:26 +0200
Message-ID: <470105EA.3090209@trash.net>
References: <20071001142907.GA10022@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbXJAOgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:36:51 -0400
In-Reply-To: <20071001142907.GA10022@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> netlink_kernel_create can be called with NULL as an input callback in several
> places, f.e. in kobject_uevent_init. This means that if one sends packet from
> user to kernel for such a socket, the packet will be leaked in the socket
> queue forever.
> 
> This patch adds a simple generic cleanup callback for these sockets.


This should already be handled by netlink_getsockbypid:

        /* Don't bother queuing skb if kernel socket has no input
function */
        nlk = nlk_sk(sock);
        if ((nlk->pid == 0 && !nlk->data_ready) ||
            (sock->sk_state == NETLINK_CONNECTED &&
             nlk->dst_pid != nlk_sk(ssk)->pid)) {
                sock_put(sock);
                return ERR_PTR(-ECONNREFUSED);
        }
