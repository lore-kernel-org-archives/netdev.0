From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Wed, 05 Dec 2012 14:19:22 +0800
Message-ID: <50BEE76A.3080707@redhat.com>
References: <20121129215724.30020.69464.stgit@sifl> <8577392.82G063LYx2@sifl> <20121204173625.GA13993@redhat.com> <338664993.8Hd16PoY2S@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948Ab2LEGT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 01:19:29 -0500
In-Reply-To: <338664993.8Hd16PoY2S@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2012 02:17 AM, Paul Moore wrote:
> On Tuesday, December 04, 2012 07:36:26 PM Michael S. Tsirkin wrote:
>> On Tue, Dec 04, 2012 at 11:18:57AM -0500, Paul Moore wrote:
>>> Okay, based on your explanation of TUNSETQUEUE, the steps below are what I
>>> believe we need to do ... if you disagree speak up quickly please.
>>>
>>> A. TUNSETIFF (new, non-persistent device)
>>>
>>> [Allocate and initialize the tun_struct LSM state based on the calling
>>> process, use this state to label the TUN socket.]
>>>
>>> 1. Call security_tun_dev_create() which authorizes the action.
>>> 2. Call security_tun_dev_alloc_security() which allocates the tun_struct
>>> LSM blob and SELinux sets some internal blob state to record the label of
>>> the calling process.
>>> 3. Call security_tun_dev_attach() which sets the label of the TUN socket
>>> to match the label stored in the tun_struct LSM blob during A2.  No
>>> authorization is done at this point since the socket is new/unlabeled.
>>>
>>> B. TUNSETIFF (existing, persistent device)
>>>
>>> [Relabel the existing tun_struct LSM state based on the calling process,
>>> use this state to label the TUN socket.]
>>>
>>> 1. Attempt to relabel/reset the tun_struct LSM blob from the currently
>>> stored value, set during A2, to the label of the current calling process.
>>> *** THIS IS NOT CURRENTLY DONE IN THE RFC PATCH ***
>>> 2. Call security_tun_dev_attach() which sets the label of the TUN socket
>>> to match the label stored in the tun_struct LSM blob during B1. No
>>> authorization is done at this point since the socket is new/unlabeled.
>>>
>>> C. TUNSETQUEUE
>>>
>>> [Use the existing tun_struct LSM state to label the new TUN socket.]
>>>
>>> 1. Call security_tun_dev_attach() which sets the label of the TUN socket
>>> to match the label stored in the tun_struct LSM blob set during either A2
>>> or B1. No authorization is done at this point since the socket is
>>> new/unlabeled.
>> Here's what bothers me. libvirt currently opens tun and passes
>> fd to qemu. What would prevent qemu from attaching fd using TUNSETQUEUE
>> to another device it does not own?
> True, assuming all the above is correct and that I'm understanding it 
> correctly (Jason?), we should probably add a new SELinux access control for 
> TUNSETQUEUE.

Yes, we need make sure qemu can call TUNSETQUEUE for the device it does
not own.
>
> The current DAC code exists in tun_not_capable().
>
