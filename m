From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tun/macvtap: limit the packets queued through
 rcvbuf
Date: Tue, 14 Jan 2014 16:45:24 +0800
Message-ID: <52D4F924.2040502@redhat.com>
References: <1389682387-28601-1-git-send-email-jasowang@redhat.com> <20140114082516.GB1101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbaANIpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:45:52 -0500
In-Reply-To: <20140114082516.GB1101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2014 04:25 PM, Michael S. Tsirkin wrote:
> On Tue, Jan 14, 2014 at 02:53:07PM +0800, Jason Wang wrote:
>> We used to limit the number of packets queued through tx_queue_length. This
>> has several issues:
>>
>> - tx_queue_length is the control of qdisc queue length, simply reusing it
>>   to control the packets queued by device may cause confusion.
>> - After commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 ("macvtap: Add
>>   support of packet capture on macvtap device."), an unexpected qdisc
>>   caused by non-zero tx_queue_length will lead qdisc lock contention for
>>   multiqueue deivce.
>> - What we really want is to limit the total amount of memory occupied not
>>   the number of packets.
>>
>> So this patch tries to solve the above issues by using socket rcvbuf to
>> limit the packets could be queued for tun/macvtap. This was done by using
>> sock_queue_rcv_skb() instead of a direct call to skb_queue_tail(). Also two
>> new ioctl() were introduced for userspace to change the rcvbuf like what we
>> have done for sndbuf.
>>
>> With this fix, we can safely change the tx_queue_len of macvtap to
>> zero. This will make multiqueue works without extra lock contention.
>>
>> Cc: Vlad Yasevich <vyasevic@redhat.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> No, I don't think we can change userspace-visible behaviour like that.
>
> This will break any existing user that tries to control
> queue length through sysfs,netlink or device ioctl.

But it looks like a buggy API, since tx_queue_len should be for qdisc
queue length instead of device itself. If we really want to preserve the
behaviour, how about using a new feature flag and change the behaviour
only when the device is created (TUNSETIFF) with the new flag?
>
> Take a look at my patch in msg ID 20140109071721.GD19559@redhat.com
> which gives one way to set tx_queue_len to zero without
> breaking userspace.

If I read the patch correctly, it will make no way for the user who
really want to change the qdisc queue length for tun.
>
>
>> ---
>>  drivers/net/macvtap.c       | 31 ++++++++++++++++++++---------
>>  drivers/net/tun.c           | 48 +++++++++++++++++++++++++++++++++------------
>>  include/uapi/linux/if_tun.h |  3 +++
>>  3 files changed, 60 insertions(+), 22 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index a2c3a89..c429c56 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -292,9 +292,6 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
>>  	if (!q)
>>  		return RX_HANDLER_PASS;
>>  
>> -	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>> -		goto drop;
>> -
>>  	skb_push(skb, ETH_HLEN);
>>  
>>  	/* Apply the forward feature mask so that we perform segmentation
>> @@ -310,8 +307,10 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
>>  			goto drop;
>>  
>>  		if (!segs) {
>> -			skb_queue_tail(&q->sk.sk_receive_queue, skb);
>> -			goto wake_up;
>> +			if (sock_queue_rcv_skb(&q->sk, skb))
>> +				goto drop;
>> +			else
>> +				goto wake_up;
>>  		}
>>  
>>  		kfree_skb(skb);
>> @@ -319,11 +318,17 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
>>  			struct sk_buff *nskb = segs->next;
>>  
>>  			segs->next = NULL;
>> -			skb_queue_tail(&q->sk.sk_receive_queue, segs);
>> +			if (sock_queue_rcv_skb(&q->sk, segs)) {
>> +				skb = segs;
>> +				skb->next = nskb;
>> +				goto drop;
>> +			}
>> +
>>  			segs = nskb;
>>  		}
>>  	} else {
>> -		skb_queue_tail(&q->sk.sk_receive_queue, skb);
>> +		if (sock_queue_rcv_skb(&q->sk, skb))
>> +			goto drop;
>>  	}
>>  
>>  wake_up:
>> @@ -333,7 +338,7 @@ wake_up:
>>  drop:
>>  	/* Count errors/drops only here, thus don't care about args. */
>>  	macvlan_count_rx(vlan, 0, 0, 0);
>> -	kfree_skb(skb);
>> +	kfree_skb_list(skb);
>>  	return RX_HANDLER_CONSUMED;
>>  }
>>  
>> @@ -414,7 +419,7 @@ static void macvtap_dellink(struct net_device *dev,
>>  static void macvtap_setup(struct net_device *dev)
>>  {
>>  	macvlan_common_setup(dev);
>> -	dev->tx_queue_len = TUN_READQ_SIZE;
>> +	dev->tx_queue_len = 0;
>>  }
>>  
>>  static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
>> @@ -469,6 +474,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
>>  	sock_init_data(&q->sock, &q->sk);
>>  	q->sk.sk_write_space = macvtap_sock_write_space;
>>  	q->sk.sk_destruct = macvtap_sock_destruct;
>> +	q->sk.sk_rcvbuf = TUN_RCVBUF;
>>  	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
>>  	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
>>  
>> @@ -1040,6 +1046,13 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>  		q->sk.sk_sndbuf = u;
>>  		return 0;
>>  
>> +	case TUNSETRCVBUF:
>> +		if (get_user(u, up))
>> +			return -EFAULT;
>> +
>> +		q->sk.sk_rcvbuf = u;
>> +		return 0;
>> +
>>  	case TUNGETVNETHDRSZ:
>>  		s = q->vnet_hdr_sz;
>>  		if (put_user(s, sp))
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 09f6662..7a08fa3 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -177,6 +177,7 @@ struct tun_struct {
>>  
>>  	int			vnet_hdr_sz;
>>  	int			sndbuf;
>> +	int			rcvbuf;
>>  	struct tap_filter	txflt;
>>  	struct sock_fprog	fprog;
>>  	/* protected by rtnl lock */
>> @@ -771,17 +772,6 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	if (!check_filter(&tun->txflt, skb))
>>  		goto drop;
>>  
>> -	if (tfile->socket.sk->sk_filter &&
>> -	    sk_filter(tfile->socket.sk, skb))
>> -		goto drop;
>> -
>> -	/* Limit the number of packets queued by dividing txq length with the
>> -	 * number of queues.
>> -	 */
>> -	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
>> -			  >= dev->tx_queue_len / tun->numqueues)
>> -		goto drop;
>> -
>>  	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>>  		goto drop;
>>  
>> @@ -798,7 +788,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	nf_reset(skb);
>>  
>>  	/* Enqueue packet */
>> -	skb_queue_tail(&tfile->socket.sk->sk_receive_queue, skb);
>> +	if (sock_queue_rcv_skb(tfile->socket.sk, skb))
>> +		goto drop;
>>  
>>  	/* Notify and wake up reader process */
>>  	if (tfile->flags & TUN_FASYNC)
>> @@ -1668,6 +1659,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>  
>>  		tun->filter_attached = false;
>>  		tun->sndbuf = tfile->socket.sk->sk_sndbuf;
>> +		tun->rcvbuf = tfile->socket.sk->sk_rcvbuf;
>>  
>>  		spin_lock_init(&tun->lock);
>>  
>> @@ -1837,6 +1829,17 @@ static void tun_set_sndbuf(struct tun_struct *tun)
>>  	}
>>  }
>>  
>> +static void tun_set_rcvbuf(struct tun_struct *tun)
>> +{
>> +	struct tun_file *tfile;
>> +	int i;
>> +
>> +	for (i = 0; i < tun->numqueues; i++) {
>> +		tfile = rtnl_dereference(tun->tfiles[i]);
>> +		tfile->socket.sk->sk_sndbuf = tun->sndbuf;
>> +	}
>> +}
>> +
>>  static int tun_set_queue(struct file *file, struct ifreq *ifr)
>>  {
>>  	struct tun_file *tfile = file->private_data;
>> @@ -1878,7 +1881,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>  	struct ifreq ifr;
>>  	kuid_t owner;
>>  	kgid_t group;
>> -	int sndbuf;
>> +	int sndbuf, rcvbuf;
>>  	int vnet_hdr_sz;
>>  	unsigned int ifindex;
>>  	int ret;
>> @@ -2061,6 +2064,22 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>  		tun_set_sndbuf(tun);
>>  		break;
>>  
>> +	case TUNGETRCVBUF:
>> +		rcvbuf = tfile->socket.sk->sk_rcvbuf;
>> +		if (copy_to_user(argp, &rcvbuf, sizeof(rcvbuf)))
>> +			ret = -EFAULT;
>> +		break;
>> +
>> +	case TUNSETRCVBUF:
>> +		if (copy_from_user(&rcvbuf, argp, sizeof(rcvbuf))) {
>> +			ret = -EFAULT;
>> +			break;
>> +		}
>> +
>> +		tun->rcvbuf = rcvbuf;
>> +		tun_set_rcvbuf(tun);
>> +		break;
>> +
>>  	case TUNGETVNETHDRSZ:
>>  		vnet_hdr_sz = tun->vnet_hdr_sz;
>>  		if (copy_to_user(argp, &vnet_hdr_sz, sizeof(vnet_hdr_sz)))
>> @@ -2139,6 +2158,8 @@ static long tun_chr_compat_ioctl(struct file *file,
>>  	case TUNSETTXFILTER:
>>  	case TUNGETSNDBUF:
>>  	case TUNSETSNDBUF:
>> +	case TUNGETRCVBUF:
>> +	case TUNSETRCVBUF:
>>  	case SIOCGIFHWADDR:
>>  	case SIOCSIFHWADDR:
>>  		arg = (unsigned long)compat_ptr(arg);
>> @@ -2204,6 +2225,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>>  
>>  	tfile->sk.sk_write_space = tun_sock_write_space;
>>  	tfile->sk.sk_sndbuf = INT_MAX;
>> +	tfile->sk.sk_rcvbuf = TUN_RCVBUF;
>>  
>>  	file->private_data = tfile;
>>  	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
>> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
>> index e9502dd..8e04657 100644
>> --- a/include/uapi/linux/if_tun.h
>> +++ b/include/uapi/linux/if_tun.h
>> @@ -22,6 +22,7 @@
>>  
>>  /* Read queue size */
>>  #define TUN_READQ_SIZE	500
>> +#define TUN_RCVBUF	(512 * PAGE_SIZE)
>>  
>>  /* TUN device flags */
>>  #define TUN_TUN_DEV 	0x0001	
> That's about 16x less than we were able to queue previously
> by default.
> How can you be sure this won't break any applications?
>

Ok, we can change it back to 500 * 65535, but I'm not sure whether this
or not this value (about 32M) is too big for a single socket.
>> @@ -58,6 +59,8 @@
>>  #define TUNSETQUEUE  _IOW('T', 217, int)
>>  #define TUNSETIFINDEX	_IOW('T', 218, unsigned int)
>>  #define TUNGETFILTER _IOR('T', 219, struct sock_fprog)
>> +#define TUNGETRCVBUF   _IOR('T', 220, int)
>> +#define TUNSETRCVBUF   _IOW('T', 221, int)
>>  
>>  /* TUNSETIFF ifr flags */
>>  #define IFF_TUN		0x0001
>> -- 
>> 1.8.3.2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
