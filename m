From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Don't charge for data in sndbuf again when transmitting packet
Date: Mon, 3 Sep 2012 11:02:51 -0400
Message-ID: <378685E0-7225-4C9D-AE0F-7B8767ECB16A@gmail.com>
References: <ed0aceea14e890e55829f42d1594ae9417b8ca25.1346681739.git.tgraf@suug.ch>
Mime-Version: 1.0 (iPod Mail 7E18)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:42253 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200Ab2ICPCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 11:02:43 -0400
In-Reply-To: <ed0aceea14e890e55829f42d1594ae9417b8ca25.1346681739.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sep 3, 2012, at 10:27 AM, Thomas Graf <tgraf@suug.ch> wrote:

> SCTP charges wmem_alloc via sctp_set_owner_w() in sctp_sendmsg() and  
> via
> skb_set_owner_w() in sctp_packet_transmit(). If a sender runs out of
> sndbuf it will sleep in sctp_wait_for_sndbuf() and expects to be  
> waken up
> by __sctp_write_space().
>
> Buffer space charged via sctp_set_owner_w() is released in sctp_wfree 
> ()
> which calls __sctp_write_space() directly.
>
> Buffer space charged via skb_set_owner_w() is released via sock_wfree 
> ()
> which calls sk->sk_write_space() _if_ SOCK_USE_WRITE_QUEUE is not set.
> sctp_endpoint_init() sets SOCK_USE_WRITE_QUEUE on all sockets.
>
> Therefore if sctp_packet_transmit() manages to queue up more than  
> sndbuf
> bytes, sctp_wait_for_sndbuf() will never be woken up again unless it  
> is
> interrupted by a signal.
>
> This could be fixed by clearing the SOCK_USE_WRITE_QUEUE flag but ...
>
> Charging for the data twice does not make sense in the first place, it
> leads to overcharging sndbuf by a factor 2. Therefore this patch only
> charges a single byte in wmem_alloc when transmitting an SCTP packet  
> to
> ensure that the socket stays alive until the packet has been released.
>
> This means that control chunks are no longer accounted for in  
> wmem_alloc
> which I believe is not a problem as skb->truesize will typically lead
> to overcharging anyway and thus compensates for any control overhead.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: David Miller <davem@davemloft.net>
> ---
> net/sctp/output.c | 21 ++++++++++++++++++++-
> 1 file changed, 20 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 838e18b..be50aa2 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -364,6 +364,25 @@ finish:
>    return retval;
> }
>
> +static void sctp_packet_release_owner(struct sk_buff *skb)
> +{
> +    sk_free(skb->sk);
> +}
> +
> +static void sctp_packet_set_owner_w(struct sk_buff *skb, struct  
> sock *sk)
> +{
> +    skb_orphan(skb);
> +    skb->sk = sk;
> +    skb->destructor = sctp_packet_release_owner;
> +
> +    /*
> +     * The data chunks have already been accounted for in  
> sctp_sendmsg(),
> +     * therefore only reserve a single byte to keep socket around  
> until
> +     * the packet has been transmitted.
> +     */
> +    atomic_inc(&sk->sk_wmem_alloc);
> +}
> +
> /* All packets are sent to the network through this function from
>  * sctp_outq_tail().
>  *
> @@ -405,7 +424,7 @@ int sctp_packet_transmit(struct sctp_packet  
> *packet)
>    /* Set the owning socket so that we know where to get the
>     * destination IP address.
>     */
> -    skb_set_owner_w(nskb, sk);
> +    sctp_packet_set_owner_w(nskb, sk);
>
>    if (!sctp_transport_dst_check(tp)) {
>        sctp_transport_route(tp, NULL, sctp_sk(sk));
> -- 
> 1.7.11.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux- 
> sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
