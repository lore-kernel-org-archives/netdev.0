From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Wed, 20 Aug 2014 08:44:58 +0200
Message-ID: <20140820064458.GA1916@nanopsycho.orion>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
 <20140819203401.GA1954@gospo.home.greyhouse.net>
 <20140819203748.GA4326@nanopsycho.orion>
 <20140819204634.GB1954@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net, nikolay@redhat.com,
	dingtianhong@huawei.com, sfeldma@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:52536 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaHTGpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 02:45:04 -0400
Received: by mail-lb0-f175.google.com with SMTP id 10so6491429lbg.34
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 23:45:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140819204634.GB1954@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 19, 2014 at 10:46:34PM CEST, gospo@cumulusnetworks.com wrote:
>On Tue, Aug 19, 2014 at 10:37:48PM +0200, Jiri Pirko wrote:
>> Tue, Aug 19, 2014 at 10:34:01PM CEST, gospo@cumulusnetworks.com wrote:
>> >On Tue, Aug 19, 2014 at 04:02:12PM +0200, Jiri Pirko wrote:
>> >> Userspace needs to be notified if one changes some option.
>> >> 
>> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> ---
>> >>  drivers/net/bonding/bond_options.c | 2 ++
>> >>  include/linux/netdevice.h          | 1 +
>> >>  2 files changed, 3 insertions(+)
>> >> 
>> >> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>> >> index dc73463..d8dc17f 100644
>> >> --- a/drivers/net/bonding/bond_options.c
>> >> +++ b/drivers/net/bonding/bond_options.c
>> >> @@ -625,6 +625,8 @@ int __bond_opt_set(struct bonding *bond,
>> >>  out:
>> >>  	if (ret)
>> >>  		bond_opt_error_interpret(bond, opt, ret, val);
>> >> +	else
>> >> +		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
>> >Is this valuable where the configuration change to the bonding driver
>> >came from netlink.  Do you have a good example why this useful in the
>> >netlink path as well as when using sysfs?  It would seem more logical to
>> >add call_netdevice_notifiers to bonding_sysfs_store_option so anything
>> >listening to netlink messages or the netlink cache can know to check for
>> >changes.
>> 
>> But this is called for sysfs as well.
>Sorry for the confusion.  I was suggesting that this call is *only* used
>for sysfs changes not for changes from sysfs and netlink as it would
>with your patch.
>
>> Example of use is that application can monitor rtnetlink to see if for
>> example active slave changed, or whatever other option changed.
>Any application monitoring netlink messages will already know about the
>configuration change if it came down via netlink.  There would not be a
>need for an extra message.
>
>My question was:  Is there a need for 2 netlink messages to indicate
>that a bonding configuration change was needed when the config came over
>netlink.  I did not see the need for 2 netlink messages in this case and
>was asking for clarification from you.

Imagine 2 applications. One is just monitoring netlink events ("ip
mon"), the second is setting up bond via netlink. Now, the second sends
a message to kernel, that is unicast to kernel. The first application
does not see that message. Therefore there is need to generate the event
message in kernel and send it back to userspace via multicast.
That message the first application will see. And that is exactly what
my patch is doing.

>
>> 
>> >
>> >>  
>> >>  	return ret;
>> >>  }
>> >> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> >> index 967ddcc..44bc4bd 100644
>> >> --- a/include/linux/netdevice.h
>> >> +++ b/include/linux/netdevice.h
>> >> @@ -2017,6 +2017,7 @@ struct pcpu_sw_netstats {
>> >>  #define NETDEV_CHANGEUPPER	0x0015
>> >>  #define NETDEV_RESEND_IGMP	0x0016
>> >>  #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
>> >> +#define NETDEV_CHANGEINFODATA	0x0018
>> >>  
>> >>  int register_netdevice_notifier(struct notifier_block *nb);
>> >>  int unregister_netdevice_notifier(struct notifier_block *nb);
>> >> -- 
>> >> 1.9.3
>> >> 
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
