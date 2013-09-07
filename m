From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net] net: sctp: fix smatch warning in sctp_send_asconf_del_ip
Date: Sat, 7 Sep 2013 22:19:19 +0200
Message-ID: <5D9A6A19-C20F-4A68-8237-614529EAD85D@sfc.wide.ad.jp>
References: <1378579881-27881-1-git-send-email-dborkman@redhat.com> <B8C81C0E-1D13-40A9-A39F-4E5C8069366D@sfc.wide.ad.jp> <20130907201128.GA15351@neilslaptop.think-freely.org>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:51004 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751834Ab3IGUT2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 16:19:28 -0400
In-Reply-To: <20130907201128.GA15351@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 7, 2013, at 10:11 PM, Neil Horman wrote:

> On Sat, Sep 07, 2013 at 09:40:15PM +0200, Michio Honda wrote:
>> Hi, 
>> 
>> Sorry for that I didn't respond to that warning.
>> You are right, laddr == NULL && addrcnt == 1 is the indicator of the function called by
>> asconf_mgmt().
>> 
>> Since your patch is actually redundant, I would suggest putting comment on the 
>> line of "if ((laddr == NULL) && (addrcnt == 1)) {", and/or on the checking in your patch.
>> 
> How can you guarantee its redundant, it seems possible to me to have an
> association for which the laddr might not be found (the NULL case) while having
> a multientry bind list, leading to a NULL dereference?  I think we need the
> check.
I meant that laddr == NULL && addrcnt > 1 doesn't happen as Daniel said - laddr == NULL
means the deleting address is the last one, so sctp_bindx_rem() fails before this, and 
sctp_asconf_mgmt() always passes addrcnt == 1.

I agree with that using this as an indicator of asconf_del_ip() called from 
sctp_asconf_mgmt() is error prone, so I agree with that patch.
I just suggesting putting a comment that explains why we put the check in that 
patch.

Cheers,
- Michio

> 
> Or do you mean to indicate that checkout laddr == NULL & addrcnt == 1 is
> actually redundant.  If so, where is the redundant check?
> Neil
> 
>> Cheers,
>> - Michio
>> 
>> On Sep 7, 2013, at 8:51 PM, Daniel Borkmann wrote:
>> 
>>> This was originally reported in [1] and posted by Neil Horman [2], he said:
>>> 
>>> Fix up a missed null pointer check in the asconf code. If we don't find
>>> a local address, but we pass in an address length of more than 1, we may
>>> dereference a NULL laddr pointer. Currently this can't happen, as the only
>>> users of the function pass in the value 1 as the addrcnt parameter, but
>>> its not hot path, and it doesn't hurt to check for NULL should that ever
>>> be the case.
>>> 
>>> The callpath from sctp_asconf_mgmt() looks okay. But this could be triggered
>>> from sctp_setsockopt_bindx() call with SCTP_BINDX_REM_ADDR and addrcnt > 1
>>> while passing all possible addresses from the bind list to SCTP_BINDX_REM_ADDR
>>> so that we do *not* find a single address in the association's bind address
>>> list that is not in the packed array of addresses. If this happens when we
>>> have an established association with ASCONF-capable peers, then we could get
>>> a NULL pointer dereference as we only check for laddr == NULL && addrcnt == 1
>>> and call later sctp_make_asconf_update_ip() with NULL laddr.
>>> 
>>> BUT: this actually won't happen as sctp_bindx_rem() will catch such a case
>>> and return with an error earlier. As this is incredably unintuitive and error
>>> prone, add a check to catch at least future bugs here. As Neil says, its not
>>> hot path. Introduced by 8a07eb0a5 ("sctp: Add ASCONF operation on the
>>> single-homed host").
>>> 
>>> [1] http://www.spinics.net/lists/linux-sctp/msg02132.html
>>> [2] http://www.spinics.net/lists/linux-sctp/msg02133.html
>>> 
>>> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: Michio Honda <micchie@sfc.wide.ad.jp>
>>> ---
>>> net/sctp/socket.c | 3 +++
>>> 1 file changed, 3 insertions(+)
>>> 
>>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>>> index 5462bbb..911b71b 100644
>>> --- a/net/sctp/socket.c
>>> +++ b/net/sctp/socket.c
>>> @@ -806,6 +806,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>>> 			goto skip_mkasconf;
>>> 		}
>>> 
>>> +		if (laddr == NULL)
>>> +			return -EINVAL;
>>> +
>>> 		/* We do not need RCU protection throughout this loop
>>> 		 * because this is done under a socket lock from the
>>> 		 * setsockopt call.
>>> -- 
>>> 1.7.11.7
>>> 
>> 
>> 
