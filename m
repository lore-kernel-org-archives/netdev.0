From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Thu, 13 Dec 2012 09:15:41 -0800
Message-ID: <50CA0D3D.5000503@gmail.com>
References: <20121212170520.GA3060@minipsycho.orion> <20121212092700.7ef2607a@nehalam.linuxnetplumber.net> <20121212181017.GB3060@minipsycho.orion> <20121212101208.361ccda0@nehalam.linuxnetplumber.net> <20121212182556.GC3060@minipsycho.orion> <20121212103632.2020efce@nehalam.linuxnetplumber.net> <20121212184925.GD3060@minipsycho.orion> <20121212105448.490aca5c@nehalam.linuxnetplumber.net> <20121212190613.GE3060@minipsycho.orion> <20121212113433.21c05614@nehalam.linuxnetplumber.net> <20121213161750.GA1914@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63522 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab2LMRQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 12:16:37 -0500
Received: by mail-ob0-f174.google.com with SMTP id ta14so2281587obb.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 09:16:37 -0800 (PST)
In-Reply-To: <20121213161750.GA1914@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> That is what the operstate mechanism was for. Why did we build that mechanism
>> if it doesn't work from userspace.
>>
>> Maybe the fix is to make setting linkstate also set carrier bits.
>
> Hmm. You mean to call netif_carrier_on/off as a reaction to operstate
> change? How exactly would you like to do that?
>
> Thanks
>
> Jiri

This would break existing applications and would not really be in the
spirit of the operstate mechanism as I read the documentation:

./Documentation/networking/operstates.txt
  63 IF_OPER_DORMANT (5):
  64  Interface is L1 up, but waiting for an external event, f.e. for a
  65  protocol to establish. (802.1X)

The L1 up is netif_carrier_on here.

We use this in user space when we do not want applications to start
using the link until we have negotiated and configured some link layer
attributes. To do this we set IFLA_LINKMODE and then use the
IF_OPER_DORMANT event to trigger the application eventually setting
IF_OPER_UP when the link layer negotiation is complete. If you take the
carrier down this breaks. In my case the protocol is LLDP but I think
there are other examples. This is basically the example Stephen already
gave.

I guess I still am missing why teamd doesn't just set IFLA_LINKMODE
then manage the operstate this way? Sure teamd would have to become a
bit smarter but it would save adding additional interfaces to the
kernel. In the LinkAgg case you could just pin the operstate down this
would also allow protocols to run under the linkagg over the LLC in
IEEE speak which I think is being discussed in the latest round of
LLDP/LinkAgg spec updates (I'll check on that later today).

Thanks,
John


-- 
John Fastabend         Intel Corporation
