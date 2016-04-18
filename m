From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration
Date: Mon, 18 Apr 2016 13:10:51 -0700
Message-ID: <CA+HUmGhUqXn35x6Nnhcrk+WH8PuiaxwsrZNy-NsJ94wybCukGA@mail.gmail.com>
References: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
	<87ega2sqhf.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35658 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbcDRUKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 16:10:52 -0400
Received: by mail-oi0-f54.google.com with SMTP id p188so200764537oih.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 13:10:52 -0700 (PDT)
In-Reply-To: <87ega2sqhf.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 11:48 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> These interactions all seem a little bit funny.  At a quick skim it
> would make more sense to increment the port count in macvlan_init,
> and completely remove the need to mess with port counts anywhere except
> macvlan_init and macvlan_uninit.

Thanks Eric, let me try that.

>
> If for some reason that can't be done the code can easily look at
> dev->reg_state.  If dev->reg_state == NETREG_UNITIALIZED it should
> be exactly the same as your new flag being set.
>

I am not sure that in macvlan_uninit one can tell whether it is being
invoked in the context of a failed register_netdevice (if that is what
you meant).

In case of register_netdevice failing in
call_netdevice_notifiers(NETDEV_REGISTER) the call sequence is:

macvlan_common_newlink
  register_netdevice
    call_netdevice_notifiers(NETDEV_REGISTER, dev) (<== fail here)
      rollback_registered(dev);
        rollback_registered_many
          dev->reg_state = NETREG_UNREGISTERING
          dev->netdev_ops->ndo_uninit(dev)
      dev->reg_state = NETREG_UNREGISTERED;


Francesco
