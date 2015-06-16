From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Tue, 16 Jun 2015 14:25:07 +0300
Message-ID: <55800793.4040103@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F@ORSMSX109.amr.corp.intel.com>
 <20150615220852.GB4384@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	"Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150615220852.GB4384-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16/06/2015 01:08, Jason Gunthorpe wrote:
> On Mon, Jun 15, 2015 at 09:32:53PM +0000, Hefty, Sean wrote:
>>>  drivers/infiniband/core/cm.c | 7 +++++++
>>>  include/rdma/ib_cm.h         | 2 ++
>>>  2 files changed, 9 insertions(+)
>>>
>>> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
>>> index c5f5f89e274a..46f99ec4080a 100644
>>> +++ b/drivers/infiniband/core/cm.c
>>> @@ -2983,6 +2983,13 @@ static void cm_format_sidr_req_event(struct cm_work
>>> *work,
>>>  	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
>>>  	param->listen_id = listen_id;
>>>  	param->service_id = sidr_req_msg->service_id;
>>> +	if (work->mad_recv_wc->wc->wc_flags & IB_WC_GRH) {
>>> +		param->grh = 1;
>>> +		memcpy(&param->dgid, &work->mad_recv_wc->recv_buf.grh->dgid,
>>> +		       sizeof(param->dgid));
>>> +	} else {
>>> +		param->grh = 0;
>>
>> What is the use case here?  Are you trying to sort by device?  How does the GID of the GMP relate to the listen?
> 
> Ouch, that is getting fugly, it used by cma_save_req_info, which feeds
> the data into ib_get_net_dev_by_params - basically it chooses the
> alias GUID'd netdev to use.
> 
> But how is that going to work? How is the sender to know it should be
> sending a GRH with the CM message?

If the admin wants to use SIDR with alias GIDs, they will need to
configure the system to enable GRH for such GMPs. (This series doesn't
include such a patch).

> 
> Falling back to use the primary_path sgid seems like a poor
> substitute, if APM is being used that might be a totally different
> port than the CM message.

Note that the patchset uses primary_path for CM requests always (not as
a fallback), and uses GRH as a fallback for SIDR requests.

Regarding APM, currently the ib_cm code always sends the GMP to the
primary path anyway, right? And in any case, one would expect the
primary path's GID to have a valid net_device and local routing rules,
so I think for the purpose of demuxing and validating the request using
the primary path should be fine.

> 
> I'm also not sure about the pkey, it seems to me that the pkey used to
> select the ingress netdevice should be the pkey of the rx'd CM GMP,
> not the pkey of the future RDMA channel, so this looks like it should
> change:
> 
> +static int cma_save_req_info(const struct ib_cm_event *ib_event,
> +			     struct cma_req_info *req)
> [..]
> +	switch (ib_event->event) {
> +	case IB_CM_REQ_RECEIVED:
> +		req->pkey	= be16_to_cpu(req_param->primary_path->pkey);
> [..]
> +	case IB_CM_SIDR_REQ_RECEIVED:
> +		req->pkey	= sidr_param->pkey;
> 
> Some comment for the GID, if the GRH is present, then the DGID from
> there should alwas be used, not the content of the REQ.

Why do you think the GMP's net_device should be used over the one of the
future RDMA channel?

Thinking about the network namespaces implications, I'm having trouble
thinking of a good use case where a port redirector is in one namespace
and the future RDMA channel is in another namespace.

> 
> All this is because the CM IP protocol didn't include the LLADDR of
> the target's IPoIB interface.. If we are already looking at a breaking
> change to force GRH, how hard would it be to add on the LLADDR
> somehow instead?

So far we can work without GRH for CM requests, and also without GRH for
SIDR requests if we rely on layer 3 for the interface resolution. I'm
not against adding a LLADDR to the protocol somehow, but I don't think
we should abandon all these use cases and the interoperability with
existing software.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
