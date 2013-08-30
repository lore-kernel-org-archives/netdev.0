From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 4/6] vhost_net: determine whether or not to use zerocopy
	at one time
Date: Fri, 30 Aug 2013 22:35:50 +0400
Message-ID: <5220E606.8010008@cogentembedded.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-5-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1377836962-49780-5-git-send-email-jasowang@redhat.com>
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

Hello.

On 08/30/2013 08:29 AM, Jason Wang wrote:

> Currently, even if the packet length is smaller than VHOST_GOODCOPY_LEN, if
> upend_idx != done_idx we still set zcopy_used to true and rollback this choice
> later. This could be avoided by determine zerocopy once by checking all
> conditions at one time before.

> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/vhost/net.c |   46 +++++++++++++++++++---------------------------
>   1 files changed, 19 insertions(+), 27 deletions(-)

> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 8a6dd0d..ff60c2a 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -404,43 +404,35 @@ static void handle_tx(struct vhost_net *net)
>   			       iov_length(nvq->hdr, s), hdr_size);
>   			break;
>   		}
> -		zcopy_used = zcopy && (len >= VHOST_GOODCOPY_LEN ||
> -				       nvq->upend_idx != nvq->done_idx);
> +
> +		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
> +			&& (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx
> +			&& vhost_net_tx_select_zcopy(net);

    Could you leave && on a first of two lines, matching the previous style?

>
>   		/* use msg_control to pass vhost zerocopy ubuf info to skb */
>   		if (zcopy_used) {
> +			struct ubuf_info *ubuf;
> +			ubuf = nvq->ubuf_info + nvq->upend_idx;
> +
>   			vq->heads[nvq->upend_idx].id = head;
[...]
> +			vq->heads[nvq->upend_idx].len = VHOST_DMA_IN_PROGRESS;
> +			ubuf->callback = vhost_zerocopy_callback;
> +			ubuf->ctx = nvq->ubufs;
> +			ubuf->desc = nvq->upend_idx;
> +			msg.msg_control = ubuf;
> +			msg.msg_controllen = sizeof(ubuf);

    'sizeof(ubuf)' where 'ubuf' is a pointer? Are you sure it shouldn't be 
'sizeof(*ubuf)'?

WBR, Sergei
