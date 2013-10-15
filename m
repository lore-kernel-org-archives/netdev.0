From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH net 1/2] virtio-net: don't respond to cpu hotplug notifier
	if we're not ready
Date: Tue, 15 Oct 2013 08:18:32 +0800
Message-ID: <525C89D8.4020306@cn.fujitsu.com>
References: <1381744595-26881-1-git-send-email-jasowang@redhat.com>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1381744595-26881-1-git-send-email-jasowang@redhat.com>
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

On 10/14/2013 05:56 PM, Jason Wang wrote:
> We're trying to re-configure the affinity unconditionally in cpu hotplug
> callback. This may lead the issue during resuming from s3/s4 since
> 
> - virt queues haven't been allocated at that time.
> - it's unnecessary since thaw method will re-configure the affinity.
> 
> Fix this issue by checking the config_enable and do nothing is we're not ready.
> 
> The bug were introduced by commit 8de4b2f3ae90c8fc0f17eeaab87d5a951b66ee17
> (virtio-net: reset virtqueue affinity when doing cpu hotplug).
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Thank you.

Reviewed-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>


> ---
> The patch is need for 3.8 and above.
> ---
>  drivers/net/virtio_net.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index defec2b..c4bc1cc 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1116,6 +1116,11 @@ static int virtnet_cpu_callback(struct notifier_block *nfb,
>  {
>  	struct virtnet_info *vi = container_of(nfb, struct virtnet_info, nb);
>  
> +	mutex_lock(&vi->config_lock);
> +
> +	if (!vi->config_enable)
> +		goto done;
> +
>  	switch(action & ~CPU_TASKS_FROZEN) {
>  	case CPU_ONLINE:
>  	case CPU_DOWN_FAILED:
> @@ -1128,6 +1133,9 @@ static int virtnet_cpu_callback(struct notifier_block *nfb,
>  	default:
>  		break;
>  	}
> +
> +done:
> +	mutex_unlock(&vi->config_lock);
>  	return NOTIFY_OK;
>  }
>  
> 
