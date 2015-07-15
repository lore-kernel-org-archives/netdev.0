From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks
 to RDMA CM
Date: Wed, 15 Jul 2015 13:57:48 +0300
Message-ID: <55A63CAC.60603@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150713181414.GJ23832-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/07/2015 21:14, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:37PM +0300, Haggai Eran wrote:
>> +	switch (ib_event->event) {
>> +	case IB_CM_REQ_RECEIVED:
>> +		req->device	= req_param->listen_id->device;
>> +		req->port	= req_param->port;
>> +		req->local_gid	= &req_param->primary_path->sgid;
>> +		req->service_id	= req_param->primary_path->service_id;
>> +		req->pkey	= be16_to_cpu(req_param->primary_path->pkey);
> 
> I feel pretty strongly that we should be using the pkey from the work
> completion, not the pkey in the message.
> 
> The reason, if someone is using pkey like vlan, and expecting a
> container to never receive packets outside the assigned pkey, then we
> need to check each and every packet for the correct pkey before
> associating it with that container.

The way I see it is that you have one RDMA CM agent in the system, and
the header parameters address it. This agent allows addressing several
namespaces, and they are de-muxed according to the parameters in the
payload.

So a container never receives a packet outside of its assigned pkeys,
but the pkey you look at (as well as the GID, and possibly the IP
address) all come from the payload.

> When doing the namespace patches you should probably also look at
> other CM GMPs than just the REQ and how the paths are setup and
> consider what to do with the pkey. I'd probably suggest that the pkey
> should be forced throughout the entire process to ensure it always
> matches the ip device - at least for containers that is the right
> thing.. I probably wouldn't turn it on for the root namespace though..

Once a connection has been established, following GMPs use a unique ID
to address this connection, so no more de-muxing is needed. What is
really missing here I guess is a mechanism that would enforce containers
to only use certain pkeys - perhaps with something like an RDMA cgroup.
It could force containers to only use approved pkeys not only with RDMA
CM, but through uverbs, and other user-space interfaces.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
