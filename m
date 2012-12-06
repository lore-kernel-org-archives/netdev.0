From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Thu, 06 Dec 2012 11:56:45 -0500
Message-ID: <6001427.qD54i2BbtH@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <7448004.siKCIqQqTi@sifl> <20121206161200.GA4340@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424328Ab2LFQ5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 11:57:10 -0500
In-Reply-To: <20121206161200.GA4340@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, December 06, 2012 06:12:00 PM Michael S. Tsirkin wrote:
> On Thu, Dec 06, 2012 at 10:46:11AM -0500, Paul Moore wrote:
> > On Thursday, December 06, 2012 12:33:25 PM Michael S. Tsirkin wrote:
> > > OK so just to verify: this can be used to ensure that qemu
> > > process that has the queue fd can only attach it to
> > > a specific device, right?
> > 
> > Whenever a new queue is created via TUNSETQUEUE/tun_set_queue() the
> > security_tun_dev_create_queue() LSM hook is called.  When SELinux is
> > enabled this hook ends up calling selinux_tun_dev_create_queue() which
> > checks that the calling process (process_t) is allowed to create a new
> > queue on the specified device (tundev_t) .  If you are familiar with
> > SELinux security policy, the allow rule would look like this:
> >
> >   allow process_t tundev_t:tun_socket create_queue;
> > 
> > In practice, if we assume libvirt is creating the TUN device and running
> > with a SELinux label of virtd_t and that QEMU instances are running with
> > a SELinux label of svirt_t then the allow rule would look like this:
> >
> >   allow svirt_t virtd_t:tun_socket create_queue;
> > 
> > There is also the matter of the MLS/MCS constraints providing additional
> > separation but that is another level of detail which I don't believe is
> > important for our discussion.
> 
> Hmm. How do the rules for SETIFF look ATM?
> I am just checking default policy does not let qemu do with
> SETQUEUE something with a device which it can not
> attach to using SETIFF.

The SETQUEUE/tun_socket:create_queue permissions do not yet exist in any 
released SELinux policy as we are just now adding them with this patchset.  
With current policies loaded into a kernel with this patchset applied the 
SETQUEUE/tun_socket:create_queue permission would be treated according to the 
policy's unknown permission setting.

-- 
paul moore
security and virtualization @ redhat
