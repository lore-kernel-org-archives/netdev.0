From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH v3 4/4] vsock: cancel packets when failing to connect
Date: Mon, 12 Dec 2016 10:41:47 +0000
Message-ID: <CAF6A2B7-8359-4735-9C02-502579F54A74@vmware.com>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-2-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-3-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-4-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-5-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>, Stefan Hajnoczi <stefanha@redhat.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481217156-7160-5-git-send-email-bergwolf@gmail.com>
Content-Language: en-US
Content-ID: <C61CEE720E901848A8CBCC4B72830D81@namprd05.prod.outlook.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> On Dec 8, 2016, at 6:12 PM, Peng Tao <bergwolf@gmail.com> wrote:
> 
> Otherwise we'll leave the packets queued until releasing vsock device.
> E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
> will get the connect requests from failed host sockets.
> 
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
> net/vmw_vsock/af_vsock.c | 14 ++++++++++++++
> 1 file changed, 14 insertions(+)
> 
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index 8a398b3..c73b03a 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -1101,10 +1101,19 @@ static const struct proto_ops vsock_dgram_ops = {
> 	.sendpage = sock_no_sendpage,
> };
> 
> +static int vsock_transport_cancel_pkt(struct vsock_sock *vsk)
> +{
> +	if (!transport->cancel_pkt)
> +		return -EOPNOTSUPP;
> +
> +	return transport->cancel_pkt(vsk);
> +}
> +
> static void vsock_connect_timeout(struct work_struct *work)
> {
> 	struct sock *sk;
> 	struct vsock_sock *vsk;
> +	int cancel = 0;
> 
> 	vsk = container_of(work, struct vsock_sock, dwork.work);
> 	sk = sk_vsock(vsk);
> @@ -1115,8 +1124,11 @@ static void vsock_connect_timeout(struct work_struct *work)
> 		sk->sk_state = SS_UNCONNECTED;
> 		sk->sk_err = ETIMEDOUT;
> 		sk->sk_error_report(sk);
> +		cancel = 1;
> 	}
> 	release_sock(sk);
> +	if (cancel)
> +		vsock_transport_cancel_pkt(vsk);
> 
> 	sock_put(sk);
> }
> @@ -1223,11 +1235,13 @@ static int vsock_stream_connect(struct socket *sock, struct sockaddr *addr,
> 			err = sock_intr_errno(timeout);
> 			sk->sk_state = SS_UNCONNECTED;
> 			sock->state = SS_UNCONNECTED;
> +			vsock_transport_cancel_pkt(vsk);
> 			goto out_wait;
> 		} else if (timeout == 0) {
> 			err = -ETIMEDOUT;
> 			sk->sk_state = SS_UNCONNECTED;
> 			sock->state = SS_UNCONNECTED;
> +			vsock_transport_cancel_pkt(vsk);
> 			goto out_wait;
> 		}
> 
> -- 
> 2.7.4
> 

This looks fine to me:

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
