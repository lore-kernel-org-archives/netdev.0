From: David Howells <dhowells@redhat.com>
Subject: Re: rxrpc: Fix deadlock between call creation and sendmsg/recvmsg
Date: Thu, 02 Mar 2017 16:13:47 +0000
Message-ID: <7782.1488471227@warthog.procyon.org.uk>
References: <383d28fd-9a64-77ac-b8c0-f23408afc0ce@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <383d28fd-9a64-77ac-b8c0-f23408afc0ce@canonical.com>
Content-ID: <7781.1488471227.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> I think the following part of the patch is problematic:
> 
>         call = rxrpc_find_call_by_user_ID(rx, user_call_ID);
>         if (!call) {
> +               ret = -EBADSLT;
>                 if (cmd != RXRPC_CMD_SEND_DATA)
> -                       return -EBADSLT;
> +                       goto error_release_sock;
> +               ret = -EBUSY;
> 
> At this point call is null, so the following code is performing a null
> pointer dereference on call when accessing call->state.
> 
> Detected by CoverityScan CID#1414316 ("Dereference after null check")
> 
> +               if (call->state == RXRPC_CALL_UNINITIALISED ||
> +                   call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
> +                   call->state == RXRPC_CALL_SERVER_PREALLOC ||
> +                   call->state == RXRPC_CALL_SERVER_SECURING ||
> +                   call->state == RXRPC_CALL_SERVER_ACCEPTING)
> +                       goto error_release_sock;
>                 call = rxrpc_new_client_call_for_sendmsg(rx, msg,
> user_call_ID,

Good catch, thanks,  I put the state check in the wrong half of the
if-statement.

David
