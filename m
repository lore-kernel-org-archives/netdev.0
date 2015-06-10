From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: /net/mpls/conf/ethX//input duplicate entry
Date: Wed, 10 Jun 2015 16:23:16 -0700
Message-ID: <CAE4R7bBhz_k4a+FectxmjAKHjzAGhd0qihndURCr05fwM2yDRQ@mail.gmail.com>
References: <CAE4R7bDhQ3speftJsggqV5Ruh-n0+n_9KR=i0DQYW-NrsUNKZw@mail.gmail.com>
 <5578B318.1050808@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	rshearma <rshearma@brocade.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36172 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbFJXXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 19:23:36 -0400
Received: by qkx62 with SMTP id 62so32671513qkx.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 16:23:36 -0700 (PDT)
In-Reply-To: <5578B318.1050808@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 2:58 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 6/10/15, 1:43 PM, Scott Feldman wrote:
>>
>> I'm getting this dump_stack when reloading rocker driver.  Did some
>> sysctl MPLS nodes not get cleaned up on NETDEV_UNREGISTER?
>>
>> Steps to repro: load rocker (on system) with rocker device, rmmod
>> rocker, and then modprobe rocker.  I doubt this is specific to rocker:
>> and re-registration of a netdev should hit it. I am using UDEV rules
>> to rename kernel's ethX to a different name.  Maybe that's what
>> tripped it up?
>>
> On a quick look, wondering if this is because mpls driver does not seem to
> do a unregister and re-register sysctl
> on device name change.
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 7b3f732..ec21a5d 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -564,6 +564,14 @@ static int mpls_dev_notify(struct notifier_block *this,
> unsigned long event,
>         case NETDEV_UNREGISTER:
>                 mpls_ifdown(dev);
>                 break;
> +       case NETDEV_CHANGENAME:
> +               mpls_ifdown(dev);
> +               if ((dev->type == ARPHRD_ETHER) ||
> +                   (dev->type == ARPHRD_LOOPBACK)) {
> +                       mdev = mpls_add_dev(dev);
> +                       if (IS_ERR(mdev))
> +                               return notifier_from_errno(PTR_ERR(mdev));
> +               }
>         }
>         return NOTIFY_OK;
>  }

Roopa, I tested this patch and problem goes away.  (It's missing a
break statement, BTW).  I didn't look into the correctness of the
patch, but at first glance it seems liek the right thing to do.  Maybe
breaking out the renaming portions into sub-functions could keep the
work done in NETDEV_CHANGENAME to a minimum.

Are you sending official fix?

-scott
