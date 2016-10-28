From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: Re: [PATCH net-next v1 13/16] tipc: create TIPC_DISCONNECTING as a
 new sk_state
Date: Fri, 28 Oct 2016 13:14:33 +0200
Message-ID: <e6735f7a-beb6-8e15-ad49-b4860d37caf6@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
 <1477578157-13256-14-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
 <1477580603.7065.210.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:61155 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756062AbcJ1LOy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 07:14:54 -0400
In-Reply-To: <1477580603.7065.210.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2016 05:03 PM, Eric Dumazet wrote:
> On Thu, 2016-10-27 at 16:22 +0200, Parthasarathy Bhuvaragan wrote:
>> In this commit, we create a new tipc socket state TIPC_DISCONNECTING in
>> sk_state. TIPC_DISCONNECTING is replacing the socket connection status
>> update using SS_DISCONNECTING.
>> TIPC_DISCONNECTING is set for connection oriented sockets at:
>> - tipc_shutdown()
>> - connection probe timeout
>> - when we receive an error message on the connection.
>>
>> There is no functional change in this commit.
>>
>> Acked-by: Ying Xue <ying.xue@windriver.com>
>> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
>> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
>> ---
>>  include/uapi/linux/tipc.h |  1 +
>>  net/tipc/socket.c         | 39 +++++++++++++++++++++++----------------
>>  2 files changed, 24 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
>> index ae45de5e0d93..f5c03fdfc8a8 100644
>> --- a/include/uapi/linux/tipc.h
>> +++ b/include/uapi/linux/tipc.h
>> @@ -184,6 +184,7 @@ enum {
>>  	TIPC_PROBING,
>>  	TIPC_ESTABLISHED,
>>  	TIPC_OPEN,
>> +	TIPC_DISCONNECTING,
>>  };
>
>
> Note that all these TIPC socket states might conflict with
> sk_fullsock(), sk_listener(), inet6_sk(), ip_skb_dst_mtu(),
> sk_const_to_full_sk() , skb_to_full_sk() helpers.
>
> So there is definitely a high risk.
>
>
Eric, i can map the tipc state to a corresponding tcp state like the 
patch below. This resembles the way its done in l2tp and sctp.
Do you see any issue with that?

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index f2d9294d0920..e697f809549e 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -180,15 +180,17 @@ struct tipc_event {
   *     Definitions for the TIPC protocol sk_state field.
   */
  enum {
-       TIPC_LISTEN = 1,
-       TIPC_PROBING,
-       TIPC_ESTABLISHED,
-       TIPC_OPEN,
-       TIPC_DISCONNECTING,
-       TIPC_CLOSING,
-       TIPC_CONNECTING,
+       TIPC_LISTEN = TCP_LISTEN,
+       TIPC_ESTABLISHED = TCP_ESTABLISHED,
+       TIPC_CLOSE = TCP_CLOSE,
+       TIPC_CONNECTING = TCP_SYN_SENT,
+       TIPC_DISCONNECTING = TCP_CLOSE_WAIT,
  };

I will deleted TIPC_OPEN and TIPC_PROBING, the former can be set to 
TIPC_CLOSE like its done in tcp and the later can be replaced this with 
a probes_out counter.

/Partha
