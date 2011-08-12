From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next RFC PATCH 4/7] tuntap: multiqueue support
Date: Fri, 12 Aug 2011 16:29:36 +0200
Message-ID: <1313159376.2354.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
	<20110812015520.31613.99890.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110812015520.31613.99890.stgit@intel-e5620-16-2.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 août 2011 à 09:55 +0800, Jason Wang a écrit :

>+       rxq = skb_get_rxhash(skb);
>+       if (rxq) {
>+               tfile = rcu_dereference(tun->tfiles[rxq % numqueues]);
>+               if (tfile)
>+                       goto out;
>+       }

You can avoid an expensive divide with following trick :

u32 idx = ((u64)rxq * numqueues) >> 32;



> -static struct tun_struct *tun_get(struct file *file)
> +static void tun_detach_all(struct net_device *dev)
>  {
> -	return __tun_get(file->private_data);
> +	struct tun_struct *tun = netdev_priv(dev);
> +	struct tun_file *tfile, *tfile_list[MAX_TAP_QUEUES];
> +	int i, j = 0;
> +
> +	spin_lock(&tun_lock);
> +
> +	for (i = 0; i < MAX_TAP_QUEUES && tun->numqueues; i++) {
> +		tfile = rcu_dereference_protected(tun->tfiles[i],
> +						lockdep_is_held(&tun_lock));
> +		if (tfile) {
> +			wake_up_all(&tfile->wq.wait);
> +			tfile_list[i++] = tfile;

	typo here, you want tfile_list[j++] = tfile;

> +			rcu_assign_pointer(tun->tfiles[i], NULL);
> +			rcu_assign_pointer(tfile->tun, NULL);
> +			--tun->numqueues;
> +		}
> +	}
> +	BUG_ON(tun->numqueues != 0);
> +	spin_unlock(&tun_lock);
> +
> +	synchronize_rcu();
> +	for(--j; j >= 0; j--)
> +		sock_put(&tfile_list[j]->sk);
>  }
>  

Could you take a look at net/packet/af_packet.c, to check how David did
the whole fanout thing ?

__fanout_unlink() 

Trick is to not leave NULL entries in the tun->tfiles[] array.

It makes things easier in hot path.
