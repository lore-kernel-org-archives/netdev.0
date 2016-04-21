From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v2
Date: Thu, 21 Apr 2016 11:39:45 -0700
Message-ID: <CA+HUmGhxBuCYcRcyDMctTxcw-p+Z3-kdx72aaWNLi-WjpEk2sQ@mail.gmail.com>
References: <1461188301-4466-1-git-send-email-fruggeri@arista.com>
	<8737qe6en1.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34415 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbcDUSjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:39:47 -0400
Received: by mail-oi0-f53.google.com with SMTP id k142so96192536oib.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 11:39:47 -0700 (PDT)
In-Reply-To: <8737qe6en1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 10:44 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
<
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 95394ed..e770221 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -1303,6 +1303,8 @@ static int macvtap_device_event(struct notifier_block *unused,
>>               }
>>               break;
>>       case NETDEV_UNREGISTER:
>> +             if (vlan->minor == 0)
>> +                     break;
>
> I don't understand this bit.  A minor of 0 is never assigned.  That is
> clear from the code.  On what code path can you get here without
> assigning a minor?
>

You can have vlan->minor == 0 if macvtap_device_event(NETDEV_REGISTER)
failed.

macvtap_device_event is invoked in the context of macvtap_newlink and
it can fail if for example a macvtap interface using the same ifindex
already exists in a different namespace. That is how we originally ran
into the port->count issue.
In that case the sequence is

macvtap_newlink
  macvlan_common_newlink
    register_netdevice
      call_netdevice_notifiers(NETDEV_REGISTER, dev)
        macvtap_device_event(NETDEV_REGISTER)
          <fail here, vlan->minor = 0>
      rollback_registered(dev);
        rollback_registered_many
          call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
            macvtap_device_event(NETDEV_UNREGISTER)
              <nothing to do here>

Should this bit go into a separate patch?
Would a comment like this help:

/* We can have vlan->minor == 0 if NETDEV_REGISTER above failed */

Marc Angel posted https://marc.info/?l=linux-netdev&m=146116146925511&w=2
about conflicts if one tries to create macvtap interfaces with the same
ifindex in different namespaces.

Thanks,
Francesco


>
> Eric
