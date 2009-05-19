From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Tue, 19 May 2009 16:58:03 -0500
Message-ID: <4A132B6B.5030008@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-5-git-send-email-mchan@broadcom.com> <4A01BF6A.90707@cs.wisc.edu> <1241715824.9177.8.camel@HP1> <4A034C2A.50107@cs.wisc.edu> <1242697859.10180.147.camel@HP1> <4A12C08A.1080600@cs.wisc.edu> <1242766039.10180.178.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Karen Xie <kxie@chelsio.com>,
	Anil Veerabhadrappa <anilgv@broadcom.com>,
	Benjamin Li <benli@broadcom.com>
To: open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:45432 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbZESV6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 17:58:14 -0400
In-Reply-To: <1242766039.10180.178.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> 
> On Tue, 2009-05-19 at 07:22 -0700, Mike Christie wrote:
>> Michael Chan wrote:
>>> Here are the more generic NETLINK_ISCSI messages and the iscsi transport
>>> code to support them, please review.
>>>
>>> diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
>>> index d69a53a..60cb6cb 100644
>>> --- a/drivers/scsi/scsi_transport_iscsi.c
>>> +++ b/drivers/scsi/scsi_transport_iscsi.c
>>> @@ -995,6 +995,39 @@ int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
>>>  }
>>>  EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
>>>  
>>> +int iscsi_offload_mesg(struct Scsi_Host *shost,
>>> +		       struct iscsi_transport *transport, uint32_t type,
>>> +		       char *data, uint16_t data_size)
>>> +{
>>> +	struct nlmsghdr	*nlh;
>>> +	struct sk_buff *skb;
>>> +	struct iscsi_uevent *ev;
>>> +	int len = NLMSG_SPACE(sizeof(*ev) + data_size);
>>> +
>>> +	skb = alloc_skb(len, GFP_ATOMIC);
>>> +	if (!skb) {
>>> +		printk(KERN_ERR "can not deliver iscsi offload message:OOM\n");
>>> +		return -ENOMEM;
>>> +	}
>>> +
>>> +	nlh = __nlmsg_put(skb, 0, 0, 0, (len - sizeof(*nlh)), 0);
>>> +	ev = NLMSG_DATA(nlh);
>>> +	memset(ev, 0, sizeof(*ev));
>>> +	ev->type = type;
>>> +	ev->transport_handle = iscsi_handle(transport);
>>> +	switch (type) {
>>> +	case ISCSI_KEVENT_PATH_REQ:
>>> +		ev->r.req_path.host_no = shost->host_no;
>>> +	case ISCSI_KEVENT_IF_DOWN:
>>> +		ev->r.notify_if_down.host_no = shost->host_no;
>>> +	}
>>> +
>>> +	memcpy((char*)ev + sizeof(*ev), data, data_size);
>>> +
>>> +	return iscsi_broadcast_skb(skb, GFP_KERNEL);
>>
>> You can sync up what the gfp flag used here and for the alloc_skb call 
>> above. If you have process context, you probably want to use GFP_NOIO, 
>> because this could be called for reconnect for a disk in use.
>>
>> If you do not have process context then you would need to use GFP_ATOMIC.
>>
>>
> 
> We have process context, but I think we should make it more general for
> other future drivers and use GFP_ATOMIC.


If you have process context just use GFP_NOIO. We can change it later 
when/if a driver needs it. I think we like to avoid GFP_ATOMIC if we 
can. Or just add a gfp_t argument to the function so the caller can do 
what is right for them if you want to make it general.


> 
>>> +}
>>> +EXPORT_SYMBOL_GPL(iscsi_offload_mesg);
>>> +
>>>  void iscsi_conn_error_event(struct iscsi_cls_conn *conn, enum iscsi_err error)
>>>  {
>>>  	struct nlmsghdr	*nlh;
>>> @@ -1393,6 +1426,30 @@ iscsi_set_host_param(struct iscsi_transport *transport,
>>>  }
>>>  
>>>  static int
>>> +iscsi_set_path(struct iscsi_transport *transport, struct iscsi_uevent *ev)
>>> +{
>>> +	struct Scsi_Host *shost;
>>> +	struct iscsi_path *params;
>>> +	int err;
>>> +
>>> +	if (!transport->set_path)
>>> +		return -ENOSYS;
>>> +
>>> +	shost = scsi_host_lookup(ev->u.set_path.host_no);
>>> +	if (!shost) {
>>> +		printk(KERN_ERR "set path could not find host no %u\n",
>>> +		       ev->u.set_path.host_no);
>>> +		return -ENODEV;
>>> +	}
>>> +
>>> +	params = (struct iscsi_path *)((char*)ev + sizeof(*ev));
>>> +	err = transport->set_path(shost, params);
>>> +				      
>>> +	scsi_host_put(shost);
>>> +	return err;
>>> +}
>>> +
>>> +static int
>>>  iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>>>  {
>>>  	int err = 0;
>>> @@ -1411,7 +1468,8 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>>>  	if (!try_module_get(transport->owner))
>>>  		return -EINVAL;
>>>  
>>> -	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
>>> +	if (nlh->nlmsg_type != ISCSI_UEVENT_PATH_UPDATE)
>>> +		priv->daemon_pid = NETLINK_CREDS(skb)->pid;
>>>  
>> Instead of using broadcast above and in some other places and then doing 
>> this check, could we just use multicast groups or something else? The 
>> events from iscsid could be in one group and then events for uip would 
>> be in another?
> 
> We need to do this check because we don't want the daemon_pid to be
> overwritten with a pid that is not iscsid's.  If it was overwritten,
> unicast NETLINK_ISCSI messages will not reach iscsid.
> 
> We can use multicast group 2 for the new messages if you prefer.  This
> way, I think iscsid will not receive the new messages since it is only
> listening on group 1.  The pid check will still be needed though.
> 

ok.
