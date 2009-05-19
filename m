From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Tue, 19 May 2009 09:22:02 -0500
Message-ID: <4A12C08A.1080600@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-5-git-send-email-mchan@broadcom.com> <4A01BF6A.90707@cs.wisc.edu> <1241715824.9177.8.camel@HP1> <4A034C2A.50107@cs.wisc.edu> <1242697859.10180.147.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Karen Xie <kxie@chelsio.com>, anilgv@broadcom.com,
	benli@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1242697859.10180.147.camel@HP1>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2009-05-07 at 14:01 -0700, Mike Christie wrote:
>> Michael Chan wrote:
>>> On Wed, 2009-05-06 at 09:48 -0700, Mike Christie wrote:
>>>> I think cxgb3i is one day going to want to support the same features 
>>>> bnx2i does. If that is right, then should we just make the NX2_UIO 
>>>> events common iscsi events, and hook cxb3i in? It would not use the 
>>>> iscsi set param interface at all and would work just like bnx2i. Is that 
>>>> possible? What about future drivers? Are done making iscsi cards and 
>>>> drivers. If so, thank goodness :)  If not then maybe we want to consider 
>>>> some future driver using the #2 module and possibly using this.
>>>>
>>>> If cxgb3i is really only going to support static ip setup and we think 
>>>> that bnx2i is going to be unique on how it sets up the network then I 
>>>> NX2_UIO private events are fine. Or is this a case of we are thinking 
>>>> that iscsi hardware people are creating crazy interfaces so there is no 
>>>> why to predict what they are going to do so there is no point in trying 
>>>> to design for them.
>>> If there is any possibility that cxgb3i will use something similar to
>>> bnx2i, I think we can change the message to a standard one and make the
>>> message structure somewhat more generic.  We'll probably still need a
>>> private area in the message for hardware or vendor specific information.
>>>
>> Ok sounds good to me.
>>
> 
> Here are the more generic NETLINK_ISCSI messages and the iscsi transport
> code to support them, please review.
> 
> diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
> index d69a53a..60cb6cb 100644
> --- a/drivers/scsi/scsi_transport_iscsi.c
> +++ b/drivers/scsi/scsi_transport_iscsi.c
> @@ -995,6 +995,39 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
>  }
>  EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
>  
> +int iscsi_offload_mesg(struct Scsi_Host *shost,
> +		       struct iscsi_transport *transport, uint32_t type,
> +		       char *data, uint16_t data_size)
> +{
> +	struct nlmsghdr	*nlh;
> +	struct sk_buff *skb;
> +	struct iscsi_uevent *ev;
> +	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
> +
> +	skb = alloc_skb(len, GFP_ATOMIC);
> +	if (!skb) {
> +		printk(KERN_ERR "can not deliver iscsi offload message:OOM\n");
> +		return -ENOMEM;
> +	}
> +
> +	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
> +	ev = NLMSG_DATA(nlh);
> +	memset(ev, 0, sizeof(*ev));
> +	ev->type = type;
> +	ev->transport_handle = iscsi_handle(transport);
> +	switch (type) {
> +	case ISCSI_KEVENT_PATH_REQ:
> +		ev->r.req_path.host_no = shost->host_no;
> +	case ISCSI_KEVENT_IF_DOWN:
> +		ev->r.notify_if_down.host_no = shost->host_no;
> +	}
> +
> +	memcpy((char*)ev + sizeof(*ev), data, data_size);
> +
> +	return iscsi_broadcast_skb(skb, GFP_KERNEL);


You can sync up what the gfp flag used here and for the alloc_skb call 
above. If you have process context, you probably want to use GFP_NOIO, 
because this could be called for reconnect for a disk in use.

If you do not have process context then you would need to use GFP_ATOMIC.


> +}
> +EXPORT_SYMBOL_GPL(iscsi_offload_mesg);
> +
>  void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
>  {
>  	struct nlmsghdr	*nlh;
> @@ -1393,6 +1426,30 @@ iscsi_set_host_param(struct iscsi_transport *transport,
>  }
>  
>  static int
> +iscsi_set_path(struct iscsi_transport *transport, struct iscsi_uevent *ev)
> +{
> +	struct Scsi_Host *shost;
> +	struct iscsi_path *params;
> +	int err;
> +
> +	if (!transport->set_path)
> +		return -ENOSYS;
> +
> +	shost = scsi_host_lookup(ev->u.set_path.host_no);
> +	if (!shost) {
> +		printk(KERN_ERR "set path could not find host no %u\n",
> +		       ev->u.set_path.host_no);
> +		return -ENODEV;
> +	}
> +
> +	params = (struct iscsi_path *)((char*)ev + sizeof(*ev));
> +	err = transport->set_path(shost, params);
> +				      
> +	scsi_host_put(shost);
> +	return err;
> +}
> +
> +static int
>  iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  {
>  	int err = 0;
> @@ -1411,7 +1468,8 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	if (!try_module_get(transport->owner))
>  		return -EINVAL;
>  
> -	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
> +	if (nlh->nlmsg_type != ISCSI_UEVENT_PATH_UPDATE)
> +		priv->daemon_pid = NETLINK_CREDS(skb)->pid;
>  

Instead of using broadcast above and in some other places and then doing 
this check, could we just use multicast groups or something else? The 
events from iscsid could be in one group and then events for uip would 
be in another?

Or is it more common to do it like this or will it break compat with 
other tools if we change it?
