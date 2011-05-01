From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: call dev_alloc_name from
 register_netdevice
Date: Sun, 1 May 2011 08:41:14 +0200
Message-ID: <20110501064113.GA2661@psychotron.orion>
References: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
 <20110430103444.60c08b13@nehalam>
 <20110430205752.GE2658@psychotron.orion>
 <20110430214735.73036260@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, mirqus@gmail.com, xemul@openvz.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229Ab1EAGlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2011 02:41:22 -0400
Content-Disposition: inline
In-Reply-To: <20110430214735.73036260@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 01, 2011 at 06:47:35AM CEST, shemminger@vyatta.com wrote:
>On Sat, 30 Apr 2011 22:57:52 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Sat, Apr 30, 2011 at 07:34:44PM CEST, shemminger@vyatta.com wrote:
>> >On Sat, 30 Apr 2011 13:21:32 +0200
>> >Jiri Pirko <jpirko@redhat.com> wrote:
>> >
>> >> Force dev_alloc_name() to be called from register_netdevice() by
>> >> dev_get_valid_name(). That allows to remove multiple explicit
>> >> dev_alloc_name() calls.
>> >> 
>> >> The possibility to call dev_alloc_name in advance remains.
>> >> 
>> >> This also fixes veth creation regresion caused by
>> >> 84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743
>> >> 
>> >> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> >
>> >The problem with this then you have to audit all the calls
>> >to register_netdevice to make sure that user can't provide a bad
>> >value which then is passed a format string. Why not just fix
>> >just veth which would be safer.
>> 
>> Well it looks convenient to do name allocations inside
>> register_netdevice generically. For special cases dev_get_valid_name()
>> can be still used as before (this I think should be also prohibited in
>> future).
>> 
>> Also I think that drivers should be responsible for what they are
>> passing from user to core. Btw could you please give me an example of
>> "a bad value" causing any harm in particular situation?
>> 
>> Thanks
>> 
>> Jirka
>
>I am concerned that code like that before a driver could be passed
>a string with format characters; and make a device with % in the name
>and some configuration might depend on that.
>
>dev_alloc_name tries to be as safe as possible about the processing
>of format string so it should be safe from names like 'eth%s'

That is correct. For example:
[root@f14 ~]# ip link add name "test%d" type dummy
[root@f14 ~]# ip link add name "te%dst" type dummy
[root@f14 ~]# ip link add name "test%s" type dummy
RTNETLINK answers: Invalid argument
[root@f14 ~]# ip link add name "te%sst" type dummy
RTNETLINK answers: Invalid argument
[root@f14 ~]# ip link add name "test%p" type dummy
RTNETLINK answers: Invalid argument
[root@f14 ~]# ip link add name "test%f" type dummy
RTNETLINK answers: Invalid argument
[root@f14 ~]# 

Looks safe to me.

>
