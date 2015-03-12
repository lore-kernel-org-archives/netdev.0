From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] 9p/trans_virtio: fix hot-unplug
Date: Thu, 12 Mar 2015 11:54:10 +1030
Message-ID: <874mprxb2d.fsf@rustcorp.com.au>
References: <20150309154814-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: virtualization@lists.linux-foundation.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150309154814-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On device hot-unplug, 9p/virtio currently will kfree channel while
> it might still be in use.
>
> Of course, it might stay used forever, so it's an extremely ugly hack,
> but it seems better than use-after-free that we have now.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

I'll apply it, but it looks like a bandaid.

The right answer would seem to be:
1) Use reference counting: 1 for client, 1 for transport.
2) When hot unplug, complete (ie. fail) all outstanding requests.
3) From then on, fail all incoming requests.
4) When refcount hits 0, free the structure.

Thanks,
Rusty.



> ---
>  net/9p/trans_virtio.c | 25 +++++++++++++++++++++----
>  1 file changed, 21 insertions(+), 4 deletions(-)
>
> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
> index d8e376a..d1b2f306 100644
> --- a/net/9p/trans_virtio.c
> +++ b/net/9p/trans_virtio.c
> @@ -658,14 +658,31 @@ p9_virtio_create(struct p9_client *client, const char *devname, char *args)
>  static void p9_virtio_remove(struct virtio_device *vdev)
>  {
>  	struct virtio_chan *chan = vdev->priv;
> -
> -	if (chan->inuse)
> -		p9_virtio_close(chan->client);
> -	vdev->config->del_vqs(vdev);
> +	unsigned long warning_time;
> +	bool inuse;
>  
>  	mutex_lock(&virtio_9p_lock);
> +
> +	/* Remove self from list so we don't get new users. */
>  	list_del(&chan->chan_list);
> +	warning_time = jiffies;
> +
> +	/* Wait for existing users to close. */
> +	while (chan->inuse) {
> +		mutex_unlock(&virtio_9p_lock);
> +		msleep(250);
> +               if (time_after(jiffies, warning_time + 10 * HZ)) {
> +			dev_emerg(&vdev->dev, "p9_virtio_remove: "
> +				  "waiting for device in use.\n");
> +			warning_time = jiffies;
> +               }
> +		mutex_lock(&virtio_9p_lock);
> +	}
> +
>  	mutex_unlock(&virtio_9p_lock);
> +
> +	vdev->config->del_vqs(vdev);
> +
>  	sysfs_remove_file(&(vdev->dev.kobj), &dev_attr_mount_tag.attr);
>  	kobject_uevent(&(vdev->dev.kobj), KOBJ_CHANGE);
>  	kfree(chan->tag);
> -- 
> MST
