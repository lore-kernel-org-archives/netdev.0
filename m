From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: /net/mpls/conf/ethX//input duplicate entry
Date: Thu, 11 Jun 2015 13:30:39 -0500
Message-ID: <87d212rtbk.fsf@x220.int.ebiederm.org>
References: <CAE4R7bDhQ3speftJsggqV5Ruh-n0+n_9KR=i0DQYW-NrsUNKZw@mail.gmail.com>
	<5578B318.1050808@cumulusnetworks.com>
	<CAE4R7bBhz_k4a+FectxmjAKHjzAGhd0qihndURCr05fwM2yDRQ@mail.gmail.com>
	<55798554.7020102@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58865 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbFKSgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 14:36:01 -0400
In-Reply-To: <55798554.7020102@brocade.com> (Robert Shearman's message of
	"Thu, 11 Jun 2015 13:55:48 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 11/06/15 00:23, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 2:58 PM, roopa <roopa@cumulusnetworks.com> wrote:
>>> On 6/10/15, 1:43 PM, Scott Feldman wrote:
>>>>
>>>> I'm getting this dump_stack when reloading rocker driver.  Did some
>>>> sysctl MPLS nodes not get cleaned up on NETDEV_UNREGISTER?
>>>>
>>>> Steps to repro: load rocker (on system) with rocker device, rmmod
>>>> rocker, and then modprobe rocker.  I doubt this is specific to rocker:
>>>> and re-registration of a netdev should hit it. I am using UDEV rules
>>>> to rename kernel's ethX to a different name.  Maybe that's what
>>>> tripped it up?
>>>>
>>> On a quick look, wondering if this is because mpls driver does not seem to
>>> do a unregister and re-register sysctl
>>> on device name change.
>
> Mea culpa. Thanks for looking at this.
>
>>>
>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>> index 7b3f732..ec21a5d 100644
>>> --- a/net/mpls/af_mpls.c
>>> +++ b/net/mpls/af_mpls.c
>>> @@ -564,6 +564,14 @@ static int mpls_dev_notify(struct notifier_block *this,
>>> unsigned long event,
>>>          case NETDEV_UNREGISTER:
>>>                  mpls_ifdown(dev);
>>>                  break;
>>> +       case NETDEV_CHANGENAME:
>>> +               mpls_ifdown(dev);
>>> +               if ((dev->type == ARPHRD_ETHER) ||
>>> +                   (dev->type == ARPHRD_LOOPBACK)) {
>>> +                       mdev = mpls_add_dev(dev);
>>> +                       if (IS_ERR(mdev))
>>> +                               return notifier_from_errno(PTR_ERR(mdev));
>>> +               }
>>>          }
>>>          return NOTIFY_OK;
>>>   }
>>
>> Roopa, I tested this patch and problem goes away.  (It's missing a
>> break statement, BTW).  I didn't look into the correctness of the
>> patch, but at first glance it seems liek the right thing to do.  Maybe
>> breaking out the renaming portions into sub-functions could keep the
>> work done in NETDEV_CHANGENAME to a minimum.
>
> I agree that breaking out the sysctl registration/unregistration is a good idea
> to not have to do more work than is necessary, and to avoid unintended
> consequences (like routes using the interface being made unusable).

Yes.  It needs to be something like:

+       case NETDEV_CHANGENAME:
+		mdev = mpls_dev_get(dev);
+		if (mdev) {
+			mpls_dev_sysctl_unregister(mdev);
+			mpls_dev_sysctl_register(dev, mdev);
+		}
+		break;

Eric
