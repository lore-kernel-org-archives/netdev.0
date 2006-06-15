From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [openib-general] [PATCH v2 1/7] AMSO1100 Low Level Driver.
Date: Thu, 15 Jun 2006 14:45:57 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15767E3@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "openib-general" <openib-general@openib.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:13071 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1031474AbWFOVqR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 17:46:17 -0400
Content-class: urn:content-classes:message
To: "Steve Wise" <swise@opengridcomputing.com>,
	"Bob Sharp" <bsharp@NetEffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> On Thu, 2006-06-15 at 08:41 -0500, Steve Wise wrote:
>> On Wed, 2006-06-14 at 20:35 -0500, Bob Sharp wrote:
>> 
>>>> +void c2_ae_event(struct c2_dev *c2dev, u32 mq_index) {
>>>> +
>> 
>> <snip>
>> 
>>>> +	case C2_RES_IND_EP:{
>>>> +
>>>> +		struct c2wr_ae_connection_request *req =
>>>> +			&wr->ae.ae_connection_request;
>>>> +		struct iw_cm_id *cm_id =
>>>> +			(struct iw_cm_id *)resource_user_context;
>>>> +
>>>> +		pr_debug("C2_RES_IND_EP event_id=%d\n", event_id);
>>>> +		if (event_id != CCAE_CONNECTION_REQUEST) {
>>>> +			pr_debug("%s: Invalid event_id: %d\n",
>>>> +				__FUNCTION__, event_id);
>>>> +			break;
>>>> +		}
>>>> +		cm_event.event = IW_CM_EVENT_CONNECT_REQUEST;
>>>> +		cm_event.provider_data = (void*)(unsigned
long)req->cr_handle;
>>>> +		cm_event.local_addr.sin_addr.s_addr = req->laddr;
>>>> +		cm_event.remote_addr.sin_addr.s_addr = req->raddr;
>>>> +		cm_event.local_addr.sin_port = req->lport;
>>>> +		cm_event.remote_addr.sin_port = req->rport;
>>>> +		cm_event.private_data_len =
>>>> +			be32_to_cpu(req->private_data_length);
>>>> +
>>>> +		if (cm_event.private_data_len) {
>>> 
>>> 
>>> It looks to me as if pdata is leaking here since it is not tracked
>>> and the upper layers do not free it.  Also, if pdata is freed after
>>> the call to cm_id->event_handler returns, it exposes an issue in
>>> user space where the private data is garbage.  I suspect the iwarp
>>> cm should be copying this data before it returns.
>>> 
>> 
>> Good catch.
>> 
>> Yes, I think the IWCM should copy the private data in the upcall.  If
>> it does, then the amso driver doesn't need to kmalloc()/copy at all.
>> It can pass a ptr to its MQ entry directly...
>> 
> 
> Now that I've looked more into this, I'm not sure there's a
> simple way for the IWCM to copy the pdata on the upcall.
> Currently, the IWCM's event upcall, cm_event_handler(),
> simply queues the work for processing on a workqueue thread.
> So there's no per-event logic at all there.
> Lemme think on this more.  Stay tuned.
> 
> Either way, the amso driver has a memory leak...
> 

Having the IWCM copy the pdata during the upcall also leaves
the greatest flexibility for the driver on how/where the pdata
is captured. The IWCM has to deal with user-mode, indefinite
delays waiting for a response and user-mode processes that die
while holding a connection request. So it makes sense for that
layer to do the allocating and copying.

