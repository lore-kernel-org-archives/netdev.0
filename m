From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: some bluetooth fixes
Date: Fri, 06 Feb 2004 15:58:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076079512.2806.40.camel@pegasus>
References: <20040206050042.20a2b3b0.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040206050042.20a2b3b0.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andi,

> While reading bluetooth code I noticed some bugs and potential overflows.
> 
> Also I commented one ref-counting bug.
> 
> Patch against 2.6.2.

thanks for looking at it. Same applies to 2.4, right?

> diff -u linux-2.6.2-work32/net/bluetooth/cmtp/sock.c-o linux-2.6.2-work32/net/bluetooth/cmtp/sock.c
> --- linux-2.6.2-work32/net/bluetooth/cmtp/sock.c-o	2004-02-05 08:09:54.000000000 +0100
> +++ linux-2.6.2-work32/net/bluetooth/cmtp/sock.c	2004-02-05 14:57:57.000000000 +0100
> @@ -87,8 +87,10 @@
>  		if (!nsock)
>  			return err;
>  
> -		if (nsock->sk->sk_state != BT_CONNECTED)
> +		if (nsock->sk->sk_state != BT_CONNECTED) { 
> +			fput(nsock->file);
>  			return -EBADFD;
> +		}
>  
>  		err = cmtp_add_connection(&ca, nsock);
>  		if (!err) {

The same should apply to net/bluetooth/bnep/sock.c

> diff -u linux-2.6.2-work32/net/bluetooth/hci_sock.c-o linux-2.6.2-work32/net/bluetooth/hci_sock.c
> --- linux-2.6.2-work32/net/bluetooth/hci_sock.c-o	2004-02-05 08:09:54.000000000 +0100
> +++ linux-2.6.2-work32/net/bluetooth/hci_sock.c	2004-02-05 14:57:59.000000000 +0100
> @@ -392,6 +392,8 @@
>  
>  	skb->pkt_type = *((unsigned char *) skb->data);
>  	skb_pull(skb, 1);
> +	/* AK: looks broken. Who guarantees that hdev doesn't go away while
> +	   the skb is queued ? */
>  	skb->dev = (void *) hdev;
>  
>  	if (skb->pkt_type == HCI_COMMAND_PKT) {

Why should hdev go away?

> diff -u linux-2.6.2-work32/net/bluetooth/hci_conn.c-o linux-2.6.2-work32/net/bluetooth/hci_conn.c
> --- linux-2.6.2-work32/net/bluetooth/hci_conn.c-o	2004-02-05 08:09:54.000000000 +0100
> +++ linux-2.6.2-work32/net/bluetooth/hci_conn.c	2004-02-05 15:06:10.000000000 +0100
> @@ -353,21 +353,24 @@
>  	struct hci_conn_info *ci;
>  	struct hci_dev *hdev;
>  	struct list_head *p;
> -	int n = 0, size;
> +	int n = 0, size, err;
>  
>  	if (copy_from_user(&req, (void *) arg, sizeof(req)))
>  		return -EFAULT;
>  
> -	if (!(hdev = hci_dev_get(req.dev_id)))
> -		return -ENODEV;
> +	if (req.conn_num >= (2*PAGE_SIZE)/sizeof(struct hci_conn_info))
> +		return -EINVAL; 
>  
>  	size = req.conn_num * sizeof(struct hci_conn_info) + sizeof(req);
>  
> -	if (verify_area(VERIFY_WRITE, (void *)arg, size))
> -		return -EFAULT;
> -
>  	if (!(cl = (void *) kmalloc(size, GFP_KERNEL)))
>  		return -ENOMEM;
> +
> +	if (!(hdev = hci_dev_get(req.dev_id))) { 
> +		kfree(cl);
> +		return -ENODEV;
> +	}
> +
>  	ci = cl->conn_info;
>  
>  	hci_dev_lock_bh(hdev);

Why 2*PAGE_SIZE in this case? What is different?

Regards

Marcel
