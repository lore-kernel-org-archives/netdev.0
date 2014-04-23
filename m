From: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Patch 3/3] IB/ib_cm: hang in cm_destroy_id during PCI error
 injection
Date: Wed, 23 Apr 2014 13:58:10 -0500
Message-ID: <53580D42.1060201@linux.vnet.ibm.com>
References: <20140327142813.535289178@linux.vnet.ibm.com> <20140327142939.460692817@linux.vnet.ibm.com> <1828884A29C6694DAF28B7E6B8A82373992F353B@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373992F353B-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 4/23/2014 1:15 PM, Hefty, Sean wrote:
>> Index: b/drivers/infiniband/core/cm.c
>> ===================================================================
>> --- a/drivers/infiniband/core/cm.c
>> +++ b/drivers/infiniband/core/cm.c
>> @@ -161,6 +161,7 @@ struct cm_port {
>>   	struct ib_mad_agent *mad_agent;
>>   	struct kobject port_obj;
>>   	u8 port_num;
>> +	u8 device_fatal;
>>   	struct cm_counter_group counter_group[CM_COUNTER_GROUPS];
>>   };
>>
>> @@ -168,6 +169,7 @@ struct cm_device {
>>   	struct list_head list;
>>   	struct ib_device *ib_device;
>>   	struct device *device;
>> +	struct ib_event_handler event_handler;
>>   	u8 ack_delay;
>>   	struct cm_port *port[0];
>>   };
>> @@ -258,6 +260,10 @@ static int cm_alloc_msg(struct cm_id_pri
>>   	struct ib_mad_agent *mad_agent;
>>   	struct ib_mad_send_buf *m;
>>   	struct ib_ah *ah;
>> +	struct cm_port *port = cm_id_priv->av.port;
>> +
>> +	if (port->device_fatal)
>> +		return -EIO;
>>
>>   	mad_agent = cm_id_priv->av.port->mad_agent;
>>   	ah = ib_create_ah(mad_agent->qp->pd, &cm_id_priv->av.ah_attr);
>> @@ -290,6 +296,9 @@ static int cm_alloc_response_msg(struct
>>   	struct ib_mad_send_buf *m;
>>   	struct ib_ah *ah;
>>
>> +	if (port->device_fatal)
>> +		return -EIO;
>> +
>>   	ah = ib_create_ah_from_wc(port->mad_agent->qp->pd, mad_recv_wc->wc,
>>   				  mad_recv_wc->recv_buf.grh, port->port_num);
>>   	if (IS_ERR(ah))
>> @@ -3764,6 +3773,33 @@ static void cm_remove_port_fs(struct cm_
>>   	kobject_put(&port->port_obj);
>>   }
>>
>> +static void ib_cm_event_handler(struct ib_event_handler *handler,
>> +				struct ib_event *event)
>> +{
>> +	struct cm_device *cm_dev;
>> +	struct cm_port *port = NULL;
>> +
>> +	cm_dev = container_of(handler, struct cm_device, event_handler);
>> +	switch (event->event) {
>> +	case IB_EVENT_PORT_ACTIVE:
>> +		port = cm_dev->port[event->element.port_num - 1];
>> +		if (port == NULL)
>> +			return;
>> +		if (port->port_num == event->element.port_num)
>> +			port->device_fatal = 0;
>> +		break;
>> +	case IB_EVENT_DEVICE_FATAL:
>> +		port = cm_dev->port[event->element.port_num - 1];
>> +		if (port == NULL)
>> +			return;
>> +		if (port->port_num == event->element.port_num)
>> +			port->device_fatal = 1;
>> +		break;
> This is a device level event, not a port event.  The port_num value may not be valid.
The first patch of the series(IB/mlx4: send a IB_EVENT_DEVICE_FATAL to 
users during PCI error injection), when mlx4 send the IB_EVENT_DEVICE_FATAL
event I am passing the port number to that field so in that way I was 
able to make it work. Any other suggestions are welcome.

Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
