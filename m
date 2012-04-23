From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH] net: dcb: add CEE notify calls
Date: Mon, 23 Apr 2012 06:36:40 -0700
Message-ID: <4F955AE8.6040802@intel.com>
References: <20120420194923.8103.54825.stgit@jf-dev1-dcblab> <1335185512.15423.10.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	amirv@dev.mellanox.co.il
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1662 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2DWNgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 09:36:41 -0400
In-Reply-To: <1335185512.15423.10.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/2012 5:51 AM, Shmulik Ravid wrote:
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  net/dcb/dcbnl.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
>> index 8dfa1da..656c7c7 100644
>> --- a/net/dcb/dcbnl.c
>> +++ b/net/dcb/dcbnl.c
>> @@ -704,6 +704,7 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
>>  
>>  	ret = dcbnl_reply(err, RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
>>  			  pid, seq, flags);
>> +	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SAPP, seq, 0);
>>  out:
>>  	return ret;
>>  }
>> @@ -936,6 +937,7 @@ static int dcbnl_setall(struct net_device *netdev, struct nlattr **tb,
>>  
>>  	ret = dcbnl_reply(netdev->dcbnl_ops->setall(netdev), RTM_SETDCB,
>>  	                  DCB_CMD_SET_ALL, DCB_ATTR_SET_ALL, pid, seq, flags);
>> +	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SET_ALL, seq, 0);
>>  
>>  	return ret;
>>  }
>>
> 
> In case of a FW DCBx agent these notification could be a bit confusing.
> In this case, the dcbnl_setxxx operations are used to set the initial
> negotiation parameters. dcbnl_setall triggers the negotiation and some
> time after that the FW DCBx agent driver should send a notification with
> the newly negotiated values. The notifications sent form within the set
> operations will return the current negotiated values which may very soon
> change. If we want to keep the user mode code simple and unified maybe
> we should send these notifications only if the DCBx agent is host based.
> 
> Shmulik 
> 

No. We want all the firmware agents and host based agents to look the
same from the application. The situation you described is exactly the
same for user space as in firmware. The DCBx state machine starts and may
call dcbnl_setxxx with initial (local) values. At some later point these
may change (possibly because of negotiation with a peer) and we need to
call dcbnl_setxxx again.

I don't see how this complicates any user mode code? Presumably the agent
is listening to DCBx events because it really wants to know the current
state of DCBx. It seems to me skipping notifications will actually cause
more issues this results in the hardware being in some state that did not
trigger any events and the agent will now be out of sync. This is the
problem I am trying to solve.

btw with this patch we can remove the notify calls in bnx2x.

.John
