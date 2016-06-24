From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH] vsock: make listener child lock ordering explicit
Date: Fri, 24 Jun 2016 13:51:46 +0000
Message-ID: <8FE6F2FE-EEAE-4804-95D1-F33CAD17C72E@vmware.com>
References: <1466695738-2393-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	"Jorgen S. Hansen" <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:35237 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751476AbcFXNvy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 09:51:54 -0400
In-Reply-To: <1466695738-2393-1-git-send-email-stefanha@redhat.com>
Content-Language: en-US
Content-ID: <4E54DF489389874DA7BDCC24B46A6E71@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 23, 2016, at 5:28 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> There are several places where the listener and pending or accept queue
> child sockets are accessed at the same time.  Lockdep is unhappy that
> two locks from the same class are held.
> 
> Tell lockdep that it is safe and document the lock ordering.
> 
> Originally Claudio Imbrenda <imbrenda@linux.vnet.ibm.com> sent a similar
> patch asking whether this is safe.  I have audited the code and also
> covered the vsock_pending_work() function.
> 
> Suggested-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> net/vmw_vsock/af_vsock.c | 12 ++++++++++--
> 1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index b5f1221..b96ac91 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -61,6 +61,14 @@
>  * function will also cleanup rejected sockets, those that reach the connected
>  * state but leave it before they have been accepted.
>  *
> + * - Lock ordering for pending or accept queue sockets is:
> + *
> + *     lock_sock(listener);
> + *     lock_sock_nested(pending, SINGLE_DEPTH_NESTING);
> + *
> + * Using explicit nested locking keeps lockdep happy since normally only one
> + * lock of a given class may be taken at a time.
> + *
>  * - Sockets created by user action will be cleaned up when the user process
>  * calls close(2), causing our release implementation to be called. Our release
>  * implementation will perform some cleanup then drop the last reference so our
> @@ -443,7 +451,7 @@ void vsock_pending_work(struct work_struct *work)
> 	cleanup = true;
> 
> 	lock_sock(listener);
> -	lock_sock(sk);
> +	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
> 
> 	if (vsock_is_pending(sk)) {
> 		vsock_remove_pending(listener, sk);
> @@ -1292,7 +1300,7 @@ static int vsock_accept(struct socket *sock, struct socket *newsock, int flags)
> 	if (connected) {
> 		listener->sk_ack_backlog--;
> 
> -		lock_sock(connected);
> +		lock_sock_nested(connected, SINGLE_DEPTH_NESTING);
> 		vconnected = vsock_sk(connected);
> 
> 		/* If the listener socket has received an error, then we should
> -- 
> 2.7.4
> 

Looks good to me - thanks for fixing this!

/jsh
