From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [openib-general] [PATCH v2 1/2] iWARP Connection Manager.
Date: Wed, 14 Jun 2006 11:06:44 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F1576635@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Andrew Morton" <akpm@osdl.org>, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:50954 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932175AbWFNSIG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 14:08:06 -0400
Content-class: urn:content-classes:message
To: "Steve Wise" <swise@opengridcomputing.com>,
	"Sean Hefty" <sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> On Tue, 2006-06-13 at 16:46 -0500, Steve Wise wrote:
>> On Tue, 2006-06-13 at 14:36 -0700, Sean Hefty wrote:
>>>>> Er...no. It will lose this event. Depending on the event...the
>>>>> carnage varies. We'll take a look at this.
>>>>> 
>>>> 
>>>> This behavior is consistent with the Infiniband CM (see
>>>> drivers/infiniband/core/cm.c function cm_recv_handler()).  But I
>>>> think we should at least log an error because a lost event will
>>>> usually stall the rdma connection.
>>> 
>>> I believe that there's a difference here.  For the Infiniband CM, an
>>> allocation error behaves the same as if the received MAD were lost
>>> or dropped.  Since MADs are unreliable anyway, it's not so much that
>>> an IB CM event gets lost, as it doesn't ever occur.  A remote CM
>>> should retry the send, which hopefully allows the
> connection to make forward progress.
>>> 
>> 
>> hmm.  Ok.  I see.  I misunderstood the code in cm_recv_handler().
>> 
>> Tom and I have been talking about what we can do to not drop the
>> event. Stay tuned.
> 
> Here's a simple solution that solves the problem:
> 
> For any given cm_id, there are a finite (and small) number of
> outstanding CM events that can be posted.  So we just
> pre-allocate them when the cm_id is created and keep them on
> a free list hanging off of the cm_id struct.  Then the event
> handler function will pull from this free list.
> 
> The only case where there is any non-finite issue is on the
> passive listening cm_id.  Each incoming connection request
> will consume a work struct.  So based on client connects, we
> could run out of work structs.
> However, the CMA has the concept of a backlog, which is
> defined as the max number of pending unaccepted connection
> requests.  So we allocate these work structs based on that
> number (or a computation based on that number), and if we run
> out, we simply drop the incoming connection request due to
> backlog overflow (I suggest we log the drop event too).
> When a MPA connection request is dropped, the (IETF
> conforming) MPA client will eventually time out the
> connection and the consumer can retry.
> 
> Comments?
> 

If the IWCM cannot accept a Connection Request event from
the driver then *someone* should generate a non-peer reject
MPA Response frame. Since the IWCM does not have the resources
to relay the event, it probably does not have the resources
to generate the MPA Response frame either. So simply returning
an "I'm Busy" error and expecting the driver to handle it
makes sense to me.

