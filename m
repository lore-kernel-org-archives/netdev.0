From: roopa <roopa@cumulusnetworks.com>
Subject: Re: /net/mpls/conf/ethX//input duplicate entry
Date: Wed, 10 Jun 2015 14:58:48 -0700
Message-ID: <5578B318.1050808@cumulusnetworks.com>
References: <CAE4R7bDhQ3speftJsggqV5Ruh-n0+n_9KR=i0DQYW-NrsUNKZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	rshearma@brocade.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34045 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964892AbbFJV6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:58:53 -0400
Received: by qgf75 with SMTP id 75so20814531qgf.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 14:58:53 -0700 (PDT)
In-Reply-To: <CAE4R7bDhQ3speftJsggqV5Ruh-n0+n_9KR=i0DQYW-NrsUNKZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/15, 1:43 PM, Scott Feldman wrote:
> I'm getting this dump_stack when reloading rocker driver.  Did some
> sysctl MPLS nodes not get cleaned up on NETDEV_UNREGISTER?
>
> Steps to repro: load rocker (on system) with rocker device, rmmod
> rocker, and then modprobe rocker.  I doubt this is specific to rocker:
> and re-registration of a netdev should hit it. I am using UDEV rules
> to rename kernel's ethX to a different name.  Maybe that's what
> tripped it up?
>
On a quick look, wondering if this is because mpls driver does not seem 
to do a unregister and re-register sysctl
on device name change.

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732..ec21a5d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -564,6 +564,14 @@ static int mpls_dev_notify(struct notifier_block 
*this, unsigned long event,
         case NETDEV_UNREGISTER:
                 mpls_ifdown(dev);
                 break;
+       case NETDEV_CHANGENAME:
+               mpls_ifdown(dev);
+               if ((dev->type == ARPHRD_ETHER) ||
+                   (dev->type == ARPHRD_LOOPBACK)) {
+                       mdev = mpls_add_dev(dev);
+                       if (IS_ERR(mdev))
+                               return notifier_from_errno(PTR_ERR(mdev));
+               }
         }
         return NOTIFY_OK;
  }
