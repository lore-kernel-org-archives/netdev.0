From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 09:35:27 -0600
Message-ID: <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
 <20170408202434.12018-2-johannes@sipsolutions.net>
 <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
 <1491838218.28432.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33925 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdDJPfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:35:30 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so107798647pgg.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:35:30 -0700 (PDT)
In-Reply-To: <1491838218.28432.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 9:30 AM, Johannes Berg wrote:
> On Mon, 2017-04-10 at 09:26 -0600, David Ahern wrote:
>> On 4/8/17 2:24 PM, Johannes Berg wrote:
>>> @@ -2300,14 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb,
>>> struct nlmsghdr *nlh, int err)
>>>  			  NLMSG_ERROR, payload, 0);
>>>  	errmsg = nlmsg_data(rep);
>>>  	errmsg->error = err;
>>> -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh-
>>>> nlmsg_len : sizeof(*nlh));
>>> +	memcpy(&errmsg->msg, nlh,
>>> +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
>>> +						 : sizeof(*nlh));
>>> +
>>
>> generically this makes userspace parsing more problematic: the
>> parsing layer may not know if the socket option has been set to
>> precisely know the size of errmsg->msg and how much data needs to be
>> skipped to get to the new attributes.
> 
> Yes, I know. I'd hope that userspace can remember that per socket - I
> don't see a good other way to do this.
> 
> If we insert the TLVs in front of, or instead of (with a TLV containing
> it), the request message then at least libnl's debugging will need to
> be changed.
> 
> As it is, I can assume that libnl will not set the CAP setting, and
> everything works fine even if I don't change libnl, which makes things
> easier.
> 
> Do you have any better ideas?

NETLINK_F_CAP_ACK and NETLINK_F_EXT_ACK should be incompatible -- if one
is set the other can not be set. CAP_ACK means abbreviate the response
and EXT_ACK means give me more data.
