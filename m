From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Fix kernel panic while received AUTH chunk with
 BAD shared key identifier
Date: Tue, 05 Feb 2008 17:26:37 +0900
Message-ID: <47A81DBD.6000802@cn.fujitsu.com>
References: <4795A960.7000700@cn.fujitsu.com> <20080124121608.GA20633@hmsreliant.think-freely.org> <479A126F.4010505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:58931 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790AbYBEI3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 03:29:18 -0500
In-Reply-To: <479A126F.4010505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SCTP-AUTH is enabled, received AUTH chunk with BAD shared key 
identifier will cause kernel panic.

Test as following:
step1: enabled /proc/sys/net/sctp/auth_enable
step 2:  connect  to SCTP server with auth capable. Association is 
established between endpoints. Then send a AUTH chunk with a bad 
shareid, SCTP server will kernel panic after received that AUTH chunk.

SCTP client                   SCTP server
  INIT         ---------->  
    (with auth capable)
               <----------    INIT-ACK
                              (with auth capable)
  COOKIE-ECHO  ---------->
               <----------    COOKIE-ACK
  AUTH         ---------->


AUTH chunk is like this:
  AUTH chunk
    Chunk type: AUTH (15)
    Chunk flags: 0x00
    Chunk length: 28
    Shared key identifier: 10
    HMAC identifier: SHA-1 (1)
    HMAC: 0000000000000000000000000000000000000000

The assignment of NULL to key can safely be removed, since key_for_each 
(which is just list_for_each_entry under the covers does an initial 
assignment to key anyway).

If the endpoint_shared_keys list is empty, or if the key_id being 
requested does not exist, the function as it currently stands returns 
the actuall list_head (in this case endpoint_shared_keys.  Since that 
list_head isn't surrounded by an actuall data structure, the last 
iteration through list_for_each_entry will do a container_of on key, and 
we wind up returning a bogus pointer, instead of NULL, as we should.

> Neil Horman wrote:
>> On Tue, Jan 22, 2008 at 05:29:20PM +0900, Wei Yongjun wrote:
>>
>> FWIW, Ack from me.  The assignment of NULL to key can safely be 
>> removed, since
>> key_for_each (which is just list_for_each_entry under the covers does 
>> an initial
>> assignment to key anyway).
>> If the endpoint_shared_keys list is empty, or if the key_id being 
>> requested does
>> not exist, the function as it currently stands returns the actuall 
>> list_head (in
>> this case endpoint_shared_keys.  Since that list_head isn't 
>> surrounded by an
>> actuall data structure, the last iteration through 
>> list_for_each_entry will do a
>> container_of on key, and we wind up returning a bogus pointer, 
>> instead of NULL,
>> as we should.  Wei's patch corrects that.
>>
>> Regards
>> Neil
>>
>> Acked-by: Neil Horman <nhorman@tuxdriver.com>
>>
>
> Yep, the patch is correct.
>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>
> -vlad
>

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

--- a/net/sctp/auth.c	2008-01-21 00:03:25.000000000 -0500
+++ b/net/sctp/auth.c	2008-01-21 21:31:47.000000000 -0500
@@ -420,15 +420,15 @@ struct sctp_shared_key *sctp_auth_get_sh
 				const struct sctp_association *asoc,
 				__u16 key_id)
 {
-	struct sctp_shared_key *key = NULL;
+	struct sctp_shared_key *key;
 
 	/* First search associations set of endpoint pair shared keys */
 	key_for_each(key, &asoc->endpoint_shared_keys) {
 		if (key->key_id == key_id)
-			break;
+			return key;
 	}
 
-	return key;
+	return NULL;
 }
 
 /*



